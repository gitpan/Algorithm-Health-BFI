package Algorithm::Health::BFI;

use strict; use warnings;

use Carp;
use Data::Dumper;

=head1 NAME

Algorithm::Health::BFI - Interface to Body Fat Index.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 DESCRIPTION

A person's body fat  percentage  is the total mass of the person's fat divided by the person's 
mass  and  consists of essential body fat and storage body fat.Essential body fat is necessary
to maintain life and reproductive functions. Storage body  fat consists of fat accumulation in 
adipose tissue, part of which protects internal organs in the chest and abdomen.

Some regard the body fat percentage as the better measure of an individual's fitness level, as
it  is  the  only  body measurement which directly calculates the particular individual's body 
composition without regard to the individual's height or mass.

=head1 CONSTRUCTOR

It expects optionally reference to an anonymous hash with the following keys:

    +-------------+----------+---------+
    | Key         | Value    | Default |
    +-------------+----------+---------+
    | mass_unit   | kg/lb/st | lb      |
    | length_unit | m /in/ft | in      |
    +-------------+----------+---------+

    use strict; use warnings;
    use Algorithm::Health::BFI;

    my $bfi_1 = Algorithm::Health::BFI->new({ mass_unit => 'st', length_unit => 'ft' });

    # or simply

    my $bfi_2 = Algorithm::Health::BFI->new();

=cut

sub new
{
    my $class = shift;
    my $param = shift;

    _validate_param($param);
    $param->{mass_unit}   = 'lb' unless defined($param->{mass_unit});
    $param->{length_unit} = 'in' unless defined($param->{length_unit});

    bless $param, $class;
    return $param;
}

=head1 METHODS

=head2 get_bfi()

Return Body Fat Index for the given input. Parameters should be passed in as reference to hash
with the following key,value pairs:

    +---------+-------------------------------------------+
    | Key     | Value                                     |      
    +---------+-------------------------------------------+
    | sex     | m | f                                     |
    | mass    | mass (kg | lb | st)                       |
    | waist   | measurement (m | in | ft)                 |
    | wrist   | measurement (m | in | ft) ONLY for female |
    | hips    | measurement (m | in | ft) ONLY for female |
    | forearm | measurement (m | in | ft) ONLY for female |
    +---------+-------------------------------------------+
    
    use strict; use warnings;
    use Algorithm::Health::BFI;

    my $bfi = Algorithm::Health::BFI->new();
    print $bfi->get_bfi({sex => 'f', mass => 60, waist => 38, wrist => 3, hips => 30, forearm => 3}) . "\n";
    print $bfi->get_bfi({sex => 'm', mass => 60, waist => 40}) . "\n";

=cut

sub get_bfi
{
    my $self  = shift;
    my $param = shift;

    my ($mass, $waist, $wrist, $hips, $forearm);
    my ($lean_body_mass, $body_fat_mass, $bfi);
    my ($factor_1, $factor_2, $factor_3, $factor_4, $factor_5);
    
    _validate_input($param);
    $mass  = $self->_get_mass($param->{mass}, 'lb');
    $waist = $self->_get_length($param->{waist},  'in');
    if ($param->{sex} =~ /^m$/i)
    {
        $factor_1 = ($mass * 1.082) + 94.42;
        $factor_2 = $waist * 4.15;
        $lean_body_mass = $factor_1 - $factor_2;
    }
    elsif ($param->{sex} =~ /^f$/i)
    {
        $wrist   = $self->_get_length($param->{wrist},   'in');
        $hips    = $self->_get_length($param->{hips},    'in');
        $forearm = $self->_get_length($param->{forearm}, 'in');

        $factor_1 = ($mass * 0.732) + 8.987;
        $factor_2 = $wrist   / 3.140;
        $factor_3 = $waist   * 0.157;
        $factor_4 = $hips    * 0.249;
        $factor_5 = $forearm * 0.434;
        $lean_body_mass = $factor_1 + $factor_2 - $factor_3 - $factor_4 + $factor_5;
    }
    else
    {
        croak("ERROR: Invalid value for key sex.\n");
    }
    $body_fat_mass = $mass - $lean_body_mass;
    $self->{bfi} = sprintf("%.2f", (($body_fat_mass * 100) / $mass));
    $self->{sex} = $param->{sex};

    return $self->{bfi};
}

=head2 get_category()

Different cultures value different body compositions differently at different times, and  some 
are related to health/athletic performance. Levels of body fat are epidemiologically dependent 
on gender and age.  Different  authorities  have developed different recommendations for ideal 
body fat percentages.The table below describes different percentages but isn't recommendation.

    +---------------+--------+--------+
    | Category      | Women  | Men    |
    +---------------+--------+--------+
    | Essential Fat | 10-13% | 2-5%   |
    | Athletes      | 14-20% | 6-13%  |
    | Fitness       | 21-24% | 14-17% |
    | Average       | 25-31% | 18-24% |
    | Obese         | 32%+   | 25%+   |
    +---------------+--------+--------+

    use strict; use warnings;
    use Algorithm::Health::BFI;

    my $bfi = Algorithm::Health::BFI->new();
    print $bfi->get_bfi({sex => 'm', mass => 60, waist => 40}) . "\n";
    print $bfi->get_category() . "\n";

=cut

sub get_category
{
    my $self = shift;
    croak("ERROR: Please calculate BFI.\n")
        unless defined($self->{bfi});

    if ($self->{sex} =~ /^m$/i)
    {
        if ($self->{bfi} <= 5)
        {
            return 'Essential Fat';
        }
        elsif (($self->{bfi} > 5) && ($self->{bfi} <= 13))
        {
            return 'Athletes';
        }
        elsif (($self->{bfi} > 13) && ($self->{bfi} <= 17))
        {
            return 'Fitness';
        }
        elsif (($self->{bfi} > 17) && ($self->{bfi} <= 24))
        {
            return 'Average';
        }
        elsif ($self->{bfi} >= 25)
        {
            return 'Obese';
        }
    }
    elsif ($self->{sex} =~ /^f$/i)
    {
        if ($self->{bfi} <= 13)
        {
            return 'Essential Fat';
        }
        elsif (($self->{bfi} > 13) && ($self->{bfi} <= 20))
        {
            return 'Athletes';
        }
        elsif (($self->{bfi} > 20) && ($self->{bfi} <= 24))
        {
            return 'Fitness';
        }
        elsif (($self->{bfi} > 24) && ($self->{bfi} <= 31))
        {
            return 'Average';
        }
        elsif ($self->{bfi} >= 32)
        {
            return 'Obese';
        }
    }
}

sub _get_mass
{
    my $self = shift;
    my $mass = shift;
    my $unit = shift;

    return $mass if (uc($unit) eq uc($self->{mass_unit}));

    if ($self->{mass_unit} =~ /st/i)
    {
        # 1 st = 14 lb
        return $mass*14 if ($unit =~ /lb/i);
    }
    elsif ($self->{mass_unit} =~ /kg/i)
    {
        # 1 kg = 2.20462262 lb
        return $mass*2.20462262 if ($unit =~ /lb/i);
    }
    else
    {
        croak("ERROR: Invalid unit for mass.\n");
    }
}

sub _get_length
{
    my $self   = shift;
    my $length = shift;
    my $unit   = shift;

    return $length if (uc($unit) eq uc($self->{length_unit}));
    
    if ($self->{height_unit} =~ /m/i)
    {
        # 1 m = 39.3700787 in
        return $length*39.3700787 if ($unit =~ /in/i);
    }
    elsif ($self->{height_unit} =~ /ft/i)
    {
        # 1 ft = 12 in
        return $length*12 if ($unit =~ /in/i);
    }
    else
    {
        croak("ERROR: Invalid unit for length.\n");
    }
}
    
sub _validate_input
{
    my $input = shift;
    croak("ERROR: Missing input parameters.\n") 
        unless defined $input;
    croak("ERROR: Input param has to be a ref to HASH.\n")
        if (ref($input) ne 'HASH');
    croak("ERROR: Missing key sex.\n")
        unless exists($input->{sex});
    croak("ERROR: Missing key mass.\n")
        unless exists($input->{mass});
    croak("ERROR: Missing key waist.\n")
        unless exists($input->{waist});
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (($input->{sex} =~ /^m$/i) && (scalar(keys %{$input}) != 3));
    croak("ERROR: Missing key wrist.\n")
        if (($input->{sex} =~ /^f$/i) && !exists($input->{wrist}));
    croak("ERROR: Missing key hips.\n")
        if (($input->{sex} =~ /^f$/i) && !exists($input->{hips}));
    croak("ERROR: Missing key forearm.\n")
        if (($input->{sex} =~ /^f$/i) && !exists($input->{forearm}));
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (($input->{sex} =~ /^f$/i) && (scalar(keys %{$input}) != 6));
}
    
sub _validate_param
{
    my $param = shift;
    return unless defined $param;

    croak("ERROR: Input param has to be a ref to HASH.\n")
        if (ref($param) ne 'HASH');
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (scalar(keys %{$param}) != 2);
    croak("ERROR: Missing key mass_unit.\n")
        unless exists($param->{mass_unit});
    croak("ERROR: Missing key length_unit.\n")
        unless exists($param->{length_unit});
    croak("ERROR: Invalid value for mass_unit.\n")
        unless ($param->{mass_unit} =~ /kg|lb|st/i);
    croak("ERROR: Invalid value for length_unit.\n")
        unless ($param->{length_unit} =~ /m|in|ft/i);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bug/feature requests to C<bug-algorithm-health-bfi at rt.cpan.org> / through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-Health-BFI>.
I will be notified and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::Health::BFI

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-Health-BFI>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-Health-BFI>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-Health-BFI>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-Health-BFI/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of Algorithm::Health::BFI