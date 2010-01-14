#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok 'Acme::Lingua::ZH::Remix';
}

require_ok 'Acme::Lingua::ZH::Remix';
