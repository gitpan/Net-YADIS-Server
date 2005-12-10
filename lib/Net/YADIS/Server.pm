# LICENSE: You're free to distribute this under the same terms as Perl itself.

use strict;
use Carp;

############################################################################
package Net::YADIS::Server;

use vars qw($VERSION);
$VERSION = "0.01";

use fields (
            'namespaces', # Arrayref of namespaces for the capabilities document
            'services',   # Arrayref of services for the capabilities document
            );

sub new {
    my $pkg = shift;
    my $self = bless {}, $pkg;

    Carp::croak "Unknown arguments passed to Net::YADIS::Server" if @_;

    $self->{'namespaces'} = ();
    $self->{'services'}   = ();

    # Setup the two default namespaces of an XRD
    $self->add_namespaces(
                          'xmlns'      => 'xri://$xrd*($v*2.0)',
                          'xmlns:xrds' => 'xri://$xrds',
                          );

    return $self;
}

sub add_namespaces {
    my $self = shift;
    my %namespaces = @_;

    Carp::croak "Net::YADIS::Server::add_namespaces requires a hash-ref"
        unless %namespaces;

    foreach my $ns (keys %namespaces) {
        push @{$self->{'namespaces'}}, { $ns => $namespaces{$ns} };
    }

    return 1;
}

sub add_service {
    my $self = shift;
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
    my $self = shift;

    # Make sure we have namespaces
    Carp::croak "Your server has no namespaces defined, something is really " .
        "wrong since the constructor should setup two for you."
        unless ref $self->{'namespaces'} eq 'ARRAY' &&
        @{$self->{'namespaces'}};

    my $doc;
    $doc .= '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    $doc .= "<xrds:XRDS\n";

    # Add the namespaces with linebreaks
    my $c = 0;
    foreach (@{$self->{'namespaces'}}) {
        my ($ns, $des) = %$_;
        $ns  = $self->_exml($ns);
        $des = $self->_exml($des);

        $doc .= "\n" unless $c == 0;
        $doc .= "\t$ns=\"$des\"";
        $c++;
    }

    $doc .= ">\n";
    $doc .= "\t<XRD>\n";

    # You could have a server with no services, for testing or something,
    # but in most cases it would be useless
    Carp::carp "Seems you have no services defined, sure you want a useless server?"
        unless ref $self->{'services'} eq 'ARRAY' &&
        @{$self->{'services'}};

    # Output service blocks
    foreach my $srv (@{$self->{'services'}}) {
        $doc .= "\t<Service";

        # Priority is output as an attribute to Service
        $doc .= ' priority="' . $self->_exml(delete $srv->{'priority'}) . '"'
            if defined $srv->{'priority'};

        $doc .= ">\n";

        # Create elements for each other argument
        foreach (sort {lc($a) cmp lc($b)} keys %$srv) {
            my $element = $self->_exml($_);
            my $value   = $self->_exml($srv->{$_});

            $doc .= "\t\t<$element>$srv->{$_}</$element>\n";
        }

        $doc .= "\t</Service>\n";
    }

    $doc .= "\t</XRD>\n";
    $doc .= "</xrds:XRDS>";

    return $doc;
}

# Escape characters which cannot be inserted into XMl
sub _exml {
    my $self = shift;
    my $xml  = shift;

    $xml =~ s/\&/&amp;/g;
    $xml =~ s/</&lt;/g;
    $xml =~ s/>/&gt;/g;
    $xml =~ s/\"/&quot;/g;
    $xml =~ s/\'/&apos;/g;
    $xml =~ s/[\x00-\x08\x0B\x0C\x0E-\x1F]//g;

    return $xml;
}

__END__

=head1 NAME

Net::YADIS::Server - simple library for YADIS enabled servers to generate
                     capability discovery documents

=head1 SYNOPSIS
    use Net::YADIS::Server;

    my $news = new Net::YADIS::Server();

    $nys->add_service(
                      'type' => URI including version number representing service
                      'URI'  => URI endpoint requuests should be made against
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
specific elements.

=over

=item C<type>

Required.  URI/XRI including version number representing service

=item C<URI>

Required.  URI/XRI of the service's endpoint that a consumer (relying party)
should make their requests against.

=item C<priority>

Optional.  You can specify a "priority" element with a whole number value
greater than or equal to zero.  This value  can then be used, via XRD resolution,
by consumers (relying parties) if one of your identity services, of the same
type, is currently unavailiable.  More can be learned about XRD resolution at
http://www.oasis-open.org/committees/tc_home.php?wg_abbrev=xri

=back

=item $nys->add_namespaces( namespace => descriptor, namespace => descriptor, ... )

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
