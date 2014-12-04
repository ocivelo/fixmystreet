package FixMyStreet::Cobrand::Harrogate;
use base 'FixMyStreet::Cobrand::UKCouncils';

use strict;
use warnings;

sub council_id { return 2407; }
sub council_area { return 'Harrogate'; }
sub council_name { return 'Harrogate Borough Council'; }
sub council_url { return 'harrogate'; }
sub is_two_tier { return 1; } # with North Yorkshire CC 2235

sub disambiguate_location {
    my $self    = shift;
    my $string  = shift;
    return {
        %{ $self->SUPER::disambiguate_location() },
        town   => 'Harrogate',
        centre => '54.0671557690306,-1.59581319536637',
        span   => '0.370193897090822,0.829517054931808',
        bounds => [ 53.8914112467619, -2.00450542308575, 54.2616051438527, -1.17498836815394 ],
    };
}

sub example_places {
    return ( 'LS21 2HX', 'Smithy Lane, Denton' );
}

sub enter_postcode_text {
    my ($self) = @_;
    return 'Enter a Harrogate postcode, or street name and area';
}

# increase map zoom level so street names are visible
sub default_map_zoom { return 3; }


=head2 temp_update_contacts

Routine to update the extra for potholes (temporary setup hack, cargo-culted
from ESCC, may in future be superseded either by Open311/integration or a
better mechanism for manually creating rich contacts).

Can run with a script or command line like:

 bin/cron-wrapper perl -MFixMyStreet::App -MFixMyStreet::Cobrand::Harrogate -e \
 'FixMyStreet::Cobrand::Harrogate->new({c => FixMyStreet::App->new})->temp_update_contacts'

=cut

sub temp_update_contacts {
    my $self = shift;

    my $contact_rs = $self->{c}->model('DB::Contact');

    my $_update = sub {
        my ($category, $field) = @_; # we're accepting just 1 field, but supply as array [ $field ]
        my $contact = $contact_rs->search({
            body_id => $self->council_id,
            category => $category,
        })->first
        or do {
            warn "No such category: $category (skipping)\n";
            return;
        };

        use feature 'say';
        say "Found category: $category\n";

        my %default = (
            variable => 'true',
            order => '1',
            required => 'no',
            datatype => 'string',
            datatype_description => 'a string',
        );

        if ($field->{datatype} || '' eq 'boolean') {
            %default = (
                %default,
                datatype => 'singlevaluelist',
                datatype_description => 'Yes or No',
                values => { value => [ 
                        { key => ['no'],  name => ['No'] },
                        { key => ['yes'], name => ['Yes'] }, 
                ] },
            );
        }

        $contact->update({ extra => [ { %default, %$field } ] });
    };

    $_update->( 'Abandoned vehicles', {
            code => 'vehicle_registration_no',
            description => 'Vehicle Registration number:',
        });

    $_update->( 'Dead animals', {
            code => 'INFO_TEXT',
            variable => 'false',
            description => 'We do not remove small species, e.g. squirrels, rabbits, and small birds.',
        });

    $_update->( 'Flyposting', {
            code => 'offensive',
            description => 'Is it offensive?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

    $_update->( 'Flytipping', {
            code => 'size',
            description => 'Size?',
            datatype => 'singlevaluelist',
            values => { value => [ 
                    { key => ['single_item'],       name => ['Single item'] },
                    { key => ['car_boot_load'],     name => ['Car boot load'] },
                    { key => ['small_van_load'],    name => ['Small van load'] },
                    { key => ['transit_van_load'],  name => ['Transit van load'] },
                    { key => ['tipper_lorry_load'], name => ['Tipper lorry load'] },
                    { key => ['significant_load'],  name => ['Significant load'] },
                ] },
        });

    $_update->( 'Graffiti', {
            code => 'offensive',
            description => 'Is it offensive?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

    $_update->( 'Parks and playgrounds', {
            code => 'dangerous',
            description => 'Is it dangerous or could cause injury?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

    $_update->( 'Trees', {
            code => 'dangerous',
            description => 'Is it dangerous or could cause injury?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

}

sub get_geocoder {
    # return 'OSM'; # default of Bing gives poor results for ESCC, uncomment this if relevant to Harrogate?
}

1;

