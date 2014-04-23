use ExtUtils::MakeMaker;

our $VERSION ='0.01';
use 5.006;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    NAME         => 'netconf-perl',
    AUTHOR       => 'Juniper Networks, Inc',
    VERSION_FROM => 'Makefile.PL',
    PREREQ_PM => {'XML::LibXML'=>0, 'File::Which'=>0, 'Bundle::Expect'=> 0,},
    ABSTRACT     => 'netconf libraries for perl',
   
);

