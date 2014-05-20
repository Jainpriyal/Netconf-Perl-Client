use ExtUtils::MakeMaker;

our $VERSION ='0.01';
use 5.006;

WriteMakefile(
    NAME         => 'Net-Netconf',
    AUTHOR       => 'Juniper Networks, Inc',
    VERSION_FROM => 'Makefile.PL',
    PREREQ_PM => {'XML::LibXML'=> '0', 'File::Which'=> '0',
    'IO::Stty'=> '0', 'IO::Tty'=> '0', 'IO::Pty'=> '0', },
    ABSTRACT     => 'netconf libraries for perl',
   
);

