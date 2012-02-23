#!/usr/bin/env perl
use Test::More;
use strict;
use utf8;
use Acme::Lingua::ZH::Remix;

my $r = Acme::Lingua::ZH::Remix->new;

for (1..100) {
    my $s = $r->random_sentence(min => 5, max => 8);
    my $l = length($s);

    utf8::encode($s);
    ok $s, "something is generated: $s";
    ok($l >= 5 && $l <= 8, "length constrain: 5 <= $l <= 8 $s");
}


done_testing;

