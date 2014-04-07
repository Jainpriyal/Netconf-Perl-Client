
use ExtUtils::MakeMaker;

$VERSION = ( exists $ENV{'RELEASE'} ? $ENV{'RELEASE'} : '<RELEASE>' );

sub MY::libscan
{
    package MY;

    my ($self, $file) = @_;

    # Don't install these PM files (or Emacs or other backups: *~ *.bak)
    return undef if $file =~ /(.svn$|CVS$|.cvsignore$|install.*.pl|install.pm|required-mod.pl|~$|\.bak$)/;

    return $self->SUPER::libscan ($file);
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    NAME         => 'netconf-perl',
    AUTHOR       => 'Juniper Networks, Inc',
    ABSTRACT     => 'netconf libraries for perl',
    VERSION_FROM => 'Makefile.PL',
);
