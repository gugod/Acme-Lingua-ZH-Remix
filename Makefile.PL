use strict;
use warnings;
use inc::Module::Install;

all_from      'lib/Acme/Lingua/ZH/Remix.pm';

build_requires  'Test::More'        => '0.88';

requires
    'common::sense' => 3.0,
    'Memoize' => 0,
    'List::MoreUtils' => 0;

license        'mit';
repository     'http://github.com/gugod/Acme-Lingua-ZH-Remix.git';

tests 't/*.t';

WriteAll;
