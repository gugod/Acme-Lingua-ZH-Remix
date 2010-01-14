#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Test::More;

use Acme::Lingua::ZH::Remix;

my $str = rand_sentence;
ok($str);

done_testing;
