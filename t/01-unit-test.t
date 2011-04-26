#!perl

use strict; use warnings;
use Algorithm::Health::BFI;
use Test::More tests => 4;

my $bfi = Algorithm::Health::BFI->new();

is($bfi->get_bfi({ sex => 'f', weight => 60, waist => 40, wrist => 3, hips => 30, forearm => 3}), "30.98");

is($bfi->get_category(), "Average");

is($bfi->get_bfi({ sex => 'm', weight => 60, waist => 38}), "97.27");

is($bfi->get_category(), "Obese");