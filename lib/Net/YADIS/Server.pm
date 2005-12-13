# LICENSE: You're free to distribute this under the same terms as Perl itself.

use strict;
use Carp;
use XML::Writer;

############################################################################
package Net::YADIS::Server;

use vars qw($VERSION);
$VERSION = "0.02";

use fields (
            'namespaces', # Hashref of namespaces for the capabilities document ( prefix => uri )
            'services',   # Arrayref of services for the capabilities document
            );

sub new {
    my Net::YADIS::Server $self = shift;
    $self = fields::new($self) unless ref $self;

    Carp::croak "Unknown arguments passed to Net::YADIS::Server" if @_;

    $self->{'namespaces'} = ();
    $self->{'services'}   = ();

    # Setup the two default namespaces for XRD and XRDS
    $self->add_namespaces(
                          'xmlns' => 'xri://$xrd*($v*2.0)',
                          'xrds'  => 'xri://$xrds',
                          );

    return $self;
}

sub add_namespaces {
    my Net::YADIS::Server $self = shift;
    my %namespaces = @_;

    Carp::croak "Net::YADIS::Server::add_namespaces requires a hash-ref"
        unless %namespaces;

    foreach my $prefix (keys %namespaces) {
        $self->{'namespaces'}->{$prefix} = $namespaces{$prefix};
    }

    return 1;
}

sub add_service {
    my Net::YADIS::Server $self = shift;
    my %opts = @_;

    Carp::croak '"type" and "URI" elements must be passed to Net::YADIS::Server::add_service'
        unless defined $opts{'type'} && defined $opts{'URI'};

    my %service;

    $service{'type'} = delete $opts{'type'};
    $service{'URI'}  = delete $opts{'URI'};

    $service{'priority'} = delete $opts{'priority'}
        if defined $opts{'priority'};

    foreach my $key (keys %opts) {
        $service{$key} = $opts{$key};
    }

    push @{$self->{'services'}}, \%service;

    return 1;
}

sub get_document {
    my Net::YADIS::Server $self = shift;

    # Make sure we have namespaces
    Carp::croak "Your server has no namespaces defined, something is really " .
        "wrong since the constructor should setup two for you."
        unless ref $self->{'namespaces'} eq 'HASH' && %{$self->{'namespaces'}};

    my $doc;

    my $writer = new XML::Writer(
                                 OUTPUT => \$doc,
                                 NAMESPACES => 1, # Use namespaces
                                 UNSAFE => 1,     # Disable wellformedness checking, to allow for openid:Delegate in elements
                                 );
    $writer->xmlDecl('UTF-8');

    foreach my $prefix (keys %{$self->{'namespaces'}}) {
        my $uri = $self->{'namespaces'}->{$prefix};

        if ($prefix eq 'xmlns') { # Default namespace
            $writer->addPrefix($uri);
        } else {
            $writer->addPrefix($uri, $prefix);
        }

        $writer->forceNSDecl($uri);
    }

    $writer->startTag('xrds:XRDS');
    $writer->startTag('XRD');

    # You could have a server with no services, for testing or something,
    # but in most cases it would be useless
    Carp::carp "Seems you have no services defined, sure you want a useless server?"
        unless ref $self->{'services'} eq 'ARRAY' &&
        @{$self->{'services'}};

    # Output service blocks
    foreach my $srv (@{$self->{'services'}}) {

        if (defined $srv->{'priority'}) {
            $writer->startTag('Service',
                              'priority' => $srv->{'priority'},
                              );
            delete $srv->{'priority'};
        } else {
            $writer->startTag('Service');
        }

        # Create elements for each other argument
        foreach my $element (sort {lc($a) cmp lc($b)} keys %$srv) {

            # Are there multiple values for this element?
            if (ref $srv->{$element} eq 'ARRAY') {
                foreach (@{$srv->{$element}}) {
                    $writer->startTag($element);
                    $writer->characters($_);
                    $writer->endTag($element);
                }
            } else {
                $writer->startTag($element);
                $writer->characters($srv->{$element});
                $writer->endTag($element);
            }
        }
        $writer->endTag('Service');
    }

    $writer->endTag('XRD');
    $writer->endTag('xrds:XRDS');
    $writer->end();

    return $doc;
}

__END__

=head1 NAME

Net::YADIS::Server - simple library for YADIS enabled servers to generate
                     capability discovery documents

=head1 SYNOPSIS

    use Net::YADIS::Server;

    my $nys = new Net::YADIS::Server();

    $nys->add_service(
                      'type'          => URI including version number representing service
                      'URI'           => URI endpoint requuests should be made against
                      'xmlns:Element' => Elements defined in a custom xmlns
                      );

=head1 DESCRIPTION

This is the PERL API for the server half of the YADIS identity
interoperability project.  This library is designed to make it
easy to create capability discovery documents for an identity
enabled URL.  More information can be found at:
    http://yadis.org

=head1 CONSTRUCTOR

=over 4

=item Net::YADIS::Server->B<new>()

The constructor currently takes no arguments and returns a
Net::YADIS::Server object.

=back

=head1 METHODS

=item $nys->B<add_service>( %opts )

Adds a service element to the capabilities document.  Any unknown elements
will be added to the XRD service declaration as well.  Thus allowing service
specific elements.  Elements not defined in the xrd or xrds namespaces should
be prefixed with their namespace. ie openid:Delegate.  All keys except for priority
support being passed an Arrayref if you have multiple values for the element.

=over

=item C<type>

Required.  URI including version number representing service

=item C<URI>

Required.  URIof the service's endpoint that a consumer should make their
requests against.

=item C<priority>

Optional.  You can specify a "priority" element with a whole number value
greater than or equal to zero.  This value  can then be used, via XRD resolution,
by consumers (relying parties) if one of your identity services, of the same
type, is currently unavailiable.  More can be learned about XRD resolution at
http://www.oasis-open.org/committees/tc_home.php?wg_abbrev=xri

=back

=item $nys->add_namespaces( prefix => URI, prefix => URI, ... )

Add, one or more, additional namespace declarations to your capabilities
document.  Useful for services such as OpenID which can declare custom
Service elements.

=item $nys->get_document()

Returns the capability discovery document as XML designed to be directly output
via your webserver.

=head1 COPYRIGHT

This module is Copyright (c) 2005 David Recordon.
All rights reserved.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the Perl README file.
If you need more liberal licensing terms, please contact the
maintainer.

=head1 WARRANTY

This is free software. IT COMES WITHOUT WARRANTY OF ANY KIND.

=head1 SEE ALSO

YADIS website:  http://www.yadis.org/

=head1 AUTHORS

David Recordon <david@sixapart.com>
