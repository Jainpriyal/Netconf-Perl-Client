#
# $Id: edit_configuration.pl,v 1.3 2005-12-21 18:47:11 sudeshna Exp $
#
# Copyright (c) 2005-2009, Juniper Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#      1.      Redistributions of source code must retain the above
# copyright notice, this list of conditions and the following
# disclaimer.
#      2.      Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#      3.      The name of the copyright owner may not be used to
# endorse or promote products derived from this software without specific
# prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

################################################################
# edit_configuration.pl
# 
# Description:
#    Load a configuration given in some XML or text file.
#    Steps:
#      Lock the candidate database
#      Load the configuration
#      Commit the changes
#        On failure:
#          - discard the changes made
#       
#      Unlock the candidate database
#      Disconnect from the Netconf server
# ##############################################################

use Carp;
use Getopt::Std;
use Net::Netconf::Manager;

# query execution status constants
use constant REPORT_SUCCESS => 1;
use constant REPORT_FAILURE => 0;
use constant STATE_CONNECTED => 1;
use constant STATE_LOCKED => 2;
use constant STATE_CONFIG_LOADED => 3;

################################################################
# output_usage
#
# Description:
#   print the usage of this script
#     - on error
#     - when user wants help
################################################################
sub output_usage
{
    my $usage = "Usage: $0 [options] <request> <target>

Where:

  <request>  name of a specific file containing the configuration
             in XML or text format.

             Example of contents of the file in XML format:

             <configuration>
               <system>
                 <host-name>my-host-name</host-name>
               </system>
             </configuration>

             Example of contents of the file in text format:

             system {
               host-name my-host-name;
             }

  <target>   The hostname of the target router.

Options:

  -l <login>    A login name accepted by the target router
  -p <password> The password for the login name
  -m <access>   Access method. Only supported method is 'ssh'
  -t            Loading a text configuration instead of XML.  See
                description of <request>
  -d <level>    Debug level [1-6]\n\n";

    croak $usage;
}

#################################################################
# graceful_shutdown
#
# Description:
#   We can be in one of the three states: 
#     STATE_CONNECTED, STATE_LOCKED, STATE_CONFIG_LOADED
#   Take actions depending on the current state
#################################################################
sub graceful_shutdown
{
   my ($jnx, $state, $success) = @_;
   if ($state >= STATE_CONFIG_LOADED) {
       # We have already done an <edit-config> operation
       # - Discard the changes
       print "Discarding the changes made ...\n";
       $jnx->discard_changes();
       if ($jnx->has_error) {
           print "Unable to discard <edit-config> changes\n";
       }
   }

   if ($state >= STATE_LOCKED) {
       # Unlock the configuration database
       $jnx->unlock_config();
       if ($jnx->has_error) {
           print "Unable to unlock the candidate configuration\n";
       }
   }

   if ($state >= STATE_CONNECTED) {
       # Disconnect from the Netconf server
       $jnx->disconnect();
   }

   if ($success) {
       print "REQUEST succeeded !!\n";
   } else {
       print "REQUEST failed !!\n";
   }
   exit;
}

#################################################################
# read_xml_file
#
# Description:
#   Open a file for reading, read and return its contents; Skip
#   xml header if exists
#################################################################
sub read_xml_file
{
    my $input_file = shift;
    my $input_string = "";

    open(FH, $input_file) || return;

    while(<FH>) {
        next if /<\?xml.*\?>/;
        $input_string .= $_;
    }

    close(FH);
    return $input_string;
}

################################################################
# get_error_info
#
# Description:
#   Print the error information
################################################################
sub get_error_info
{
    my %error = @_;
    print "\nERROR: Printing the server request error ...\n";

    # Print 'error-severity' if present
    if ($error{'error_severity'}) {
        print "ERROR SEVERITY: $error{'error_severity'}\n";
    }

    # Print 'error-message' if present
    if ($error{'error_message'}) {
        print "ERROR MESSAGE: $error{'error_message'}\n";
    }

    # Print 'bad-element' if present
    if ($error{'bad_element'}) {
        print "BAD ELEMENT: $error{'bad_element'}\n\n";
    }
}

################################################################
# Get the user input
################################################################

# Set AUTOFLUSH to true
$| = 1;

# get the user input and display usage on error 
# or when user wants help
my %opt;
getopts('l:p:d:m:ht', \%opt) || output_usage();
output_usage() if $opt{'h'};

# Retrieve command line arguments for the XML file name
my $xmlfile = shift || output_usage();

my $jnx = new Net::Netconf::Manager( 'access' => 'ssh',
        'login' => 'regress',
        'password' => 'MaRtInI',
        'hostname' => '10.209.16.204');
print "\n reply from server\n";

unless (ref $jnx) {
    croak "ERROR: $deviceinfo{hostname}: failed to connect.\n";
}

# Lock the configuration database before making any changes
print "Locking configuration database ...\n";
my %queryargs = ( 'target' => 'candidate' );
$res = $jnx->lock_config(%queryargs);
print "\nlock-reply from server $res \n";

# See if you got an error
if ($jnx->has_error) {
    print "ERROR: in processing request \n $jnx->{'request'} \n";
    graceful_shutdown($jnx, STATE_CONNECTED, REPORT_FAILURE);
}

# Load the configuration from the given XML file
print "Loading configuration from $xmlfile \n";
if (! -f $xmlfile) {
    print "ERROR: Cannot load configuration in $xmlfile\n";
    graceful_shutdown($jnx, STATE_LOCKED, REPORT_FAILURE);    
}

# Read in the XML file
my $config = read_xml_file($xmlfile);
print "\nreading xml file \n\n$config \n\n";
%queryargs = ( 
                 'target' => 'candidate'
             );

# If we are in text mode, use config-text arg with wrapped
# configuration-text, otherwise use config arg with raw
# XML
if ($opt{t}) {
  $queryargs{'config-text'} = '<configuration-text>' . $config
    . '</configuration-text>';
} else {
  $queryargs{'config'} = $config;
}

$res = $jnx->edit_config(%queryargs);
print "\nedit_config reply from server $res \n";

# See if you got an error
if ($jnx->has_error) {
    print "ERROR: in processing request\n";
    # Get the error
    my $error = $jnx->get_first_error();
    get_error_info(%$error);
    # Disconnect
    graceful_shutdown($jnx, STATE_LOCKED, REPORT_FAILURE);
}

# Commit the changes
print "Committing the <edit-config> changes ...\n";
$com=$jnx->commit();
print "\n commit reply from server $com \n\n";
if ($jnx->has_error) {
    print "ERROR: Failed to commit the configuration.\n";
    graceful_shutdown($jnx, STATE_CONFIG_LOADED, REPORT_FAILURE);
}

# Unlock the configuration database and 
# disconnect from the Netconf server
print "Disconnecting from the Netconf server ...\n";
graceful_shutdown($jnx, STATE_LOCKED, REPORT_SUCCESS);
