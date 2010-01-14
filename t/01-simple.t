#!/usr/bin/env perl
use common::sense;
use Test::More;

use Acme::Lingua::ZH::Remix;

my $str = rand_sentence;
ok($str);

done_testing;
