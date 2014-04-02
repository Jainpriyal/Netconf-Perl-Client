#
# $Id: SAXHandler.pm,v 1.5 2005-12-21 18:47:14 sudeshna Exp $
#
# Copyright (c) 2005, Juniper Networks, Inc.
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
package Net::Netconf::SAXHandler;

use strict;
use Carp;

use vars qw(@EXPORT_OK @parsed_cap $session_id $found_error $no_error
%rpc_errors $junos_version);
require Exporter;
@EXPORT_OK = qw(@parsed_cap $session_id $found_error $no_error %rpc_errors
$junos_version);

use base qw(XML::SAX::Base);

@parsed_cap;
$session_id;
%rpc_errors;
$found_error = 0;
$no_error = 0;


sub attlist_decl
{
    my $self = shift;
}

sub ignorable_whitespace
{
    my $self = shift;
}

sub start_document
{
    my ($self) = shift;
}

sub end_document
{
    my ($self) = shift;
}

sub comment
{
    my $self=shift;
}

#overriding start_element class of handler
sub start_element
{
    my($self, $data) = @_;

    if ($data->{'LocalName'} eq 'hello') {
       $self->{'seen_hello'} = 1;
    } elsif ($data->{'LocalName'} eq 'package-information') {
        $self->{'get_pkg'} = 1;
    } elsif ($self->{'get_pkg'} && ($data->{'LocalName'} eq 'comment')) {
        $self->{'get_junos_ver'} = 1;
    } elsif ($data->{'LocalName'} eq 'rpc-reply') {
        $found_error = 0;
        $no_error = 0;
        %rpc_errors = undef;
    } elsif ($data->{'LocalName'} eq 'capability') {
        $self->{'add_capability'} = 1;
    } elsif (($data->{'LocalName'} eq 'session-id') 
             && ($self->{'seen_hello'})) {
        $self->{'get_session_id'} = 1;
    } elsif ($data->{'LocalName'} eq 'rpc-error') {
	$found_error++;
        $self->{'get_error'} = 1;
    } elsif ($data->{'LocalName'} eq 'ok') {
        $no_error = 1;
    } elsif ($self->{'get_error'}) {
        # Insert this field into the hash
        $self->{'capture_error'} = $data->{'LocalName'};
    }
   $self->SUPER::start_element($data);
}

sub end_element
{
    my ($self, $data) = @_;
    if ($data->{'LocalName'} eq 'capability') {
        if ($self->{'current_cap'}) {
            push @parsed_cap, $self->{'current_cap'};
            undef $self->{'current_cap'};
        }
        $self->{'add_capability'} = 0;
    } elsif (($data->{'LocalName'} eq 'session-id') 
             && ($self->{'get_session_id'})) {
        $self->{'seen_hello'} = 0;
        $self->{'get_session_id'} = 0;
    } elsif ($data->{'LocalName'} eq 'package-information') {
        $self->{'get_pkg'} = 0;
        $self->{'get_junos_ver'} = 0;
    } elsif ($data->{'LocalName'} eq 'rpc-error') {
        $self->{'get_error'} = 0;
        $self->{'capture_error'} = undef;
    } 
    
    $self->SUPER::end_element($data);
}

sub characters
{
    my ($self, $data) = @_;
    if ($self->{'add_capability'} && $data->{'Data'} =~ /\S/) {
        my $capability = $data->{'Data'};
        my $cap_urn;
        ($cap_urn,) = split(/\?/, $capability) if ($capability);
        $capability = $cap_urn;
        $self->{'current_cap'} .= $capability;
    } elsif ($self->{'get_session_id'}) {
        if ($data->{'Data'} =~ /\S/) {
            $session_id = $data->{'Data'};
        }
    } elsif ($self->{'get_pkg'} && $self->{'get_junos_ver'}) {
        if ($data->{'Data'} =~ /JUNOS Base OS/) {
            my @comment;
            @comment = split(/\[/, $data->{'Data'});
            $junos_version = $comment[1];
            $junos_version = substr($junos_version, 0, 3);
        }
    } elsif ($self->{'get_error'}) { #Get the error value
        if ($data->{'Data'} =~ /\S/) {
            $self->{'capture_error'} =~ s/-/_/gs;
            $rpc_errors{$found_error}{$self->{'capture_error'}}=$data->{'Data'};
        }
    }
    $self->SUPER::characters($data);
}


sub fatal_error
{
    my ($self) = shift;
    carp 'Parser FATAL ERROR: ' . @_ . "\n";
}

sub error
{
    my ($self) = shift;
    carp 'Parser ERROR: ' . @_ . "\n";
}

sub warning
{
    my ($self) = shift;
    carp 'Parser WARNING: ' . @_ . "\n";
}

sub parse
{
    my ($self, $data) = @_;
    eval {
        if (ref($data)) {
            $self->parse({'Source' => {'ByteStream' => $data}});
        } else {
            $self->parse({'Source' => {'String' => $data}});
        }
    };
    if (@_) {
        carp 'Parser ERROR: ' . $@ . "\n";
    }
}

1;

__END__

=head1 NAME

Net::Netconf::SAXHandler

=head1 SYNOPSIS

The Net::Netconf::SAXHandler module is used to parse responses from a Netconf
server.

=head1 DESCRIPTION

The Net::Netconf::SAXHandler module is a SAX-based parser used to parse
responses from a Netconf server.

=head1 METHODS

Implements all SAX handles.

=head1 SEE ALSO

=over 4

=item *

Net::Netconf::Manager

=item *

Net::Netconf::Device

=back

=head1 AUTHOR

Juniper Networks Perl Team, send bug reports, hints, tips and suggestions to
support@juniper.net.

=head1 COPYRIGHT

Copyright (c) 2005, Juniper Networks, Inc.
All rights reserved.
