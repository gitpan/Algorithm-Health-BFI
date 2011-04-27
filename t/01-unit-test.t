#!perl

use strict; use warnings;
use Algorithm::Health::BFI;
use Test::More tests => 15;

my $bfi = Algorithm::Health::BFI->new();

is($bfi->get_bfi({ sex => 'f', mass => 60, waist => 40, wrist => 3, hips => 30, forearm => 3}), "30.98");

is($bfi->get_category(), "Average");

is($bfi->get_bfi({ sex => 'm', mass => 60, waist => 38}), "97.27");

is($bfi->get_category(), "Obese");

eval { $bfi->get_bfi(); };
like($@, qr/ERROR: Missing input parameters./);

eval { $bfi->get_bfi(sex => 'm'); };
like($@, qr/ERROR: Input param has to be a ref to HASH./);

eval { $bfi->get_bfi({ sxe => 'm' }); };
like($@, qr/ERROR: Missing key sex./);

eval { $bfi->get_bfi({ sex => 'm', mas => 70 }); };
like($@, qr/ERROR: Missing key mass./);

eval { $bfi->get_bfi({ sex => 'm', mass => 70, wast => 40 }); };
like($@, qr/ERROR: Missing key waist./);

eval { $bfi->get_bfi({ sex => 'x', mass => 70, waist => 40 }); };
like($@, qr/ERROR: Invalid value for key sex./);

eval { $bfi->get_bfi({ sex => 'm', mass => 70, waist => 40, wrist => 4 }); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);

eval { $bfi->get_bfi({ sex => 'f', mass => 70, waist => 40, writs => 4 }); };
like($@, qr/ERROR: Missing key wrist./);

eval { $bfi->get_bfi({ sex => 'f', mass => 70, waist => 40, wrist => 4, hps => 40 }); };
like($@, qr/ERROR: Missing key hips./);

eval { $bfi->get_bfi({ sex => 'f', mass => 70, waist => 40, wrist => 4, hips => 40, foremr => 4 }); };
like($@, qr/ERROR: Missing key forearm./);

eval { $bfi->get_bfi({ sex => 'f', mass => 70, waist => 40, wrist => 4, hips => 40, forearm => 4, xyz => 1 }); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);