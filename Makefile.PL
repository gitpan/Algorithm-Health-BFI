use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Algorithm::Health::BFI',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/Algorithm/Health/BFI.pm',
    ABSTRACT_FROM => 'lib/Algorithm/Health/BFI.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Algorithm-Health-BFI-*' },
    PREREQ_PM     => {
        'Test::More' => 0,
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);