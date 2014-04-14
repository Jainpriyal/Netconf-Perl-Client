#
# $Id: Access.pm,v 1.4 2005-12-21 18:47:14 sudeshna Exp $
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
package Net::Netconf::Access;

use strict;
use Net::Netconf::Trace;
use Carp;

sub new
{

    my($class, $args) = @_;
    my %args = %$args;
    my $self = { %args };
    $self->{'netconf_device'} = $args;

    $class = ref $class || $class;
    my $access = $args{'access'};
    if ($args{'access'}) {
	$access =~ s/-/_/g;
    }

    $class .= '::' . $access if $access;

    bless $self, $class;
    $self;
}

sub start
{
    my($self) = @_;
    $self->{'netconf_device'}->report_error(1, 
                             'no ' . ref $self . '::start defined');
    undef;
}

sub connect
{
    my($self, %args) = @_;
    $self->start(%args);
}

sub disconnect
{
    my($self) = @_;
    undef;
}

sub send
{
    my($self, @data) = @_;
    my $data = join("", @data);

    return if (!$self->{'OUTPUT'});

    my $rc = syswrite($self->{'OUTPUT'}, $data, length($data));
    $self->{'seen_eof'} = 1 if $rc <= 0;
    $rc;
}

sub recv
{
   my($self, $timeout) = @_;
    my $data;

    return if (!$self->{INPUT});
    my $len = sysread($self->{INPUT}, $data, 0x2000);

    $self->{seen_eof} = 1 if $len < 0;
    $self->{seen_eof} = 1 if $len == 0 && eof($self->{INPUT});
    $data;
}

#
# Have we hit end-of-file yet?
#
sub eof
{
    my($self) = @_;

    $self->{'seen_eof'};
}

1;


__END__

=head1 NAME

Net::Netconf::Access

=head1 SYNOPSIS

The Net::Netconf::Access module implements the Access Method superclass. All
Access Method classes must subclass from Net::Netconf::Access.

=head1 DESCRIPTION

The Net::Netconf::Access class creates an Access object based on the access
method type specified when instantiating an object. This class is also
responsible for starting a session with the Netconf server at the destination
host by calling the connect method in the access object. After session
establishment, it exchanges hello messages with the Netconf server.

=head1 CONSTRUCTOR

new(%args)

The argument to the constructor is a hash of which this class only looks at the
'access' key. Depending on the access method type specified, the corresponding
Access object Net::Netconf::Access::<access method type> is instantiated and
returned.

=head1 METHODS

=over 4

=item connect(%ARGS)

This method is called to establish a session with the destination host.
Internally, this calls the start() method which is always overloaded by the
subclass.

This method accepts a hash table as an argument that gives additional input
parameters to establish a session. See individual access method subclasses to
see if additional input parameters are accepted.

=item disconnect()

Disconnect from the server. May be overloaded by the subclass.

=item send()

Send the XML request to the server. May be overloaded by the subclass.

=item recv()

Receive a reply from the server. May be overloaded by the subclass.

=item eof()

Check to see if we have already seen an eof.

=back

=head1 SEE ALSO

=head1 AUTHOR

Juniper Networks Perl Team, send bug reports, hints, tips and suggestions to
support@juniper.net.

=head1 COPYRIGHT

Copyright (c) 2005, Juniper Networks, Inc.
All rights reserved.
