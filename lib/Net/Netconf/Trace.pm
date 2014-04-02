#
# $Id: Trace.pm,v 1.4 2005-12-21 18:47:14 sudeshna Exp $
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
package Net::Netconf::Trace;

use strict;
use Carp;

use constant DEBUG_LEVEL => 1;
use constant TRACE_LEVEL => 2;
use constant INFO_LEVEL => 3;
use constant WARNING_LEVEL => 4;
use constant ERROR_LEVEL => 5;
use constant CRITICAL_LEVEL => 6;

sub new
{
#print"\n\n--------------inside Trace----------\n\n";
    my($class, $level) = @_;
    my $self;

    $self->{'level'} = $level;
    $class = ref($class) || $class;

    bless $self, $class;
    $self;
}

sub trace
{
    my $self = shift;
    confess 'Usage: ' . __PACKAGE__ . '::trace <level> <message>' 
    unless @_ == 2;
    my ($level, $msg) = @_;
    if ($level >= $self->{'level'}) {
        $msg .= "\n" unless $msg =~ /\n$/;
        print $msg;
    }
}

1;

__END__

=head1 NAME

Net::Netconf::Trace

=head1 SYNOPSIS

The Net::Netconf::Trace module provices tracing levels and enables tracing based
on the requested debug level.

=head1 DESCRIPTION

The Net::Netconf::Trace module provides the following tracing levels:

=over 4

=item *

DEBUG_LEVEL = 1

=item *

TRACE_LEVEL = 2

=item *

INFO_LEVEL = 3

=item *

WARNING_LEVEL = 4

=item *

ERROR_LEVEL = 5

=item *

CRITICAL_LEVEL = 6

=back

The trace level is set when instantiating a Net::Netconf::Trace object.

=head1 CONSTRUCTOR

new($level)

It takes a single argument - the trace level.

=head1 METHODS

=over 4

=item trace()

This takes two arguments, the trace level and the message. The message is
displayed on STDOUT only if level is greater than the trace level selected.

=back

=head1 SEE ALSO

=head1 AUTHOR

Juniper Networks Perl Team, send bug reports, hints, tips and suggestions to
support@juniper.net.

=head1 COPYRIGHT

Copyright (c) 2005, Juniper Networks, Inc.
All rights reserved.
