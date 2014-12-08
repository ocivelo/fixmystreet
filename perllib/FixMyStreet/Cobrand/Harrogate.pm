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

    my $town = 'Harrogate';

    # as it's the requested example location, try to avoid a disambiguation page
    $town .= ', HG1 1DH' if $string =~ /^\s*king'?s\s+r(?:oa)?d\s*(?:,\s*har\w+\s*)?$/i;

    return {
        %{ $self->SUPER::disambiguate_location() },
        town   => $town,
        centre => '54.0671557690306,-1.59581319536637',
        span   => '0.370193897090822,0.829517054931808',
        bounds => [ 53.8914112467619, -2.00450542308575, 54.2616051438527, -1.17498836815394 ],
    };
}

sub example_places {
    return ( 'HG1 2SG', "King's Road" );
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
        my ($category, $field, $category_details) = @_; 
        # NB: we're accepting just 1 field, but supply as array [ $field ]

        my $contact = $contact_rs->find_or_create(
            {
                body_id => $self->council_id,
                category => $category,

                confirmed => 1,
                deleted => 0,
                email => 'test@example.com',
                editor => 'automated script',
                note => '',
                send_method => '',
                whenedited => \'NOW()',
                %{ $category_details || {} },
            },
            {
                key => 'contacts_body_id_category_idx'
            }
        );

        use feature 'say';
        say "Editing category: $category";

        my %default = (
            variable => 'true',
            order => '1',
            required => 'no',
            datatype => 'string',
            datatype_description => 'a string',
        );

        if ($field->{datatype} || '' eq 'boolean') {
            my $description = $field->{description};
            %default = (
                %default,
                datatype => 'singlevaluelist',
                datatype_description => 'Yes or No',
                values => { value => [ 
                        { key => ["$description No"],  name => ['No'] },
                        { key => ["$description Yes"], name => ['Yes'] }, 
                ] },
            );
        }

        $contact->update({
            extra => [ { %default, %$field } ],
            confirmed => 1,
            deleted => 0,
            editor => 'automated script',
            whenedited => \'NOW()',
            note => 'temp_update_contacts method in Cobrand',
        });
    };

    # Note that we use 'detail' because template already includes this value
    # (It would be better to make the email template smarter, but aiui the email
    # templates are faked-up-PHP rather than a full template engine, so that's
    # harder than it should be.  One good option might be to allow passing a TT
    # template to send_email_cron? TODO)

    $_update->( 'Abandoned vehicles', {
            code => 'detail',
            description => 'Vehicle Registration number:',
        });

    $_update->( 'Dead animals', {
            code => 'INFO_TEXT',
            variable => 'false',
            description => 'We do not remove small species, e.g. squirrels, rabbits, and small birds.',
        });

    $_update->( 'Flyposting', {
            code => 'detail',
            description => 'Is it offensive?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

    $_update->( 'Flytipping', {
            code => 'detail',
            description => 'Size?',
            datatype => 'singlevaluelist',
            values => { value => [ 
                    { key => ['Single Item'],       name => ['Single item'] },
                    { key => ['Car boot load'],     name => ['Car boot load'] },
                    { key => ['Small van load'],    name => ['Small van load'] },
                    { key => ['Transit van load'],  name => ['Transit van load'] },
                    { key => ['Tipper lorry load'], name => ['Tipper lorry load'] },
                    { key => ['Significant load'],  name => ['Significant load'] },
                ] },
        });

    $_update->( 'Graffiti', {
            code => 'detail',
            description => 'Is it offensive?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

    $_update->( 'Parks and playgrounds', {
            code => 'detail',
            description => 'Is it dangerous or could cause injury?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });

    $_update->( 'Trees', {
            code => 'detail',
            description => 'Is it dangerous or could cause injury?',
            datatype => 'boolean', # mapped onto singlevaluelist
        });
}

sub get_geocoder {
    # return 'OSM'; # default of Bing gives poor results for ESCC, uncomment this if relevant to Harrogate?
}

1;

