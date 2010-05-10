#!/usr/bin/env perl
use Test::More;
use common::sense;
use Acme::Lingua::ZH::Remix;
use Quantum::Superpositions;

subtest 'split_corpus method' => sub {
    my $r = Acme::Lingua::ZH::Remix->new;
    my @phrases = $r->split_corpus(q(還不賴！ 總之， 很好。 如何？));
    ok all(@phrases) == all(qw(還不賴！ 總之， 很好。 如何？));

    done_testing;
};

subtest 'a simple one' => sub {
    my $r = Acme::Lingua::ZH::Remix->new;
    my $s = $r->random_sentence;

    ok($r->phrase_count > 4, "phrase_count seems to be correct");
    ok $s, "something is generated.";
    done_testing;
};

subtest 'custom phrase materials' => sub {
    my $r = Acme::Lingua::ZH::Remix->new;
    $r->feed("還不賴！ 總之， 很好。 如何？");

    is ($r->phrase_count, 4, "phrase_count is correct");
    ok $r->random_sentence, "something is generated.";

    done_testing;
};

done_testing;

