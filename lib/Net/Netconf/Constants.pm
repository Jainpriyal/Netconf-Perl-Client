#
# $Id: Constants.pm,v 1.5.436.1 2009-08-13 16:41:48 kdickman Exp $
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
package Net::Netconf::Constants;

# Netconf server: minimum version
use constant NC_VERS_MIN => 7.5;
# Constants pertaining to the Netconf states
use constant NC_STATE_DISCONN => 0;
use constant NC_STATE_CONN => 1;
use constant NC_STATE_HELLO_RECVD => 2;
use constant NC_STATE_HELLO_SENT => 3;
use constant NC_STATE_REQ_SENT => 4;
use constant NC_STATE_REQ_RECVD => 5;

use constant NC_DEFAULT_PORT => 830;

# Netconf tags of interest to us
use constant NC_HELLO_TAG => qq(hello);
use constant NC_REPLY_TAG => qq(rpc-reply);
use constant NC_DEFAULT_CAP => 
  qq(<capability>urn:ietf:params:xml:ns:netconf:base:1.0</capability>
  <capability>urn:ietf:params:xml:ns:netconf:base:1.0#candidate</capability>
  <capability>urn:ietf:params:xml:ns:netconf:base:1.0#confirmed-commit</capability>
  <capability>urn:ietf:params:xml:ns:netconf:base:1.0#validate</capability>
  <capability>urn:ietf:params:xml:ns:netconf:base:1.0#url?protocol=http,ftp,file</capability>);

1;


__END__

=head1 NAME

Net::Netconf::Constants

=head1 SNOPSIS

The Net::Netconf::Constants module declares all the Netconf constants.

=head1 SEE ALSO

=over 4

=item *

Net::Netconf::Manager

=item *

Net::Netconf:Device

=back

=head1 AUTHOR

Juniper Networks Perl Team, send bug reports, hints, tips and suggestions to
support@juniper.net.

=head1 COPYRIGHT

Copyright (c) 2005, Juniper Networks, Inc.
All rights reserved.
