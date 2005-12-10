#!/usr/bin/perl

use strict;
use Test::More 'no_plan';
use Net::YADIS::Server;

my $nys = Net::YADIS::Server->new();
ok($nys);

my $res;

$res = $nys->add_namespaces( 'xmlns:openid' => 'http://openid.net/xmlns/1.0' );
ok($res);

$res = $nys->add_service(
                         'type'            => 'http://openid.net/signon/1.0',
                         'URI'             => 'http://www.livejournal.com/openid/server.bml',
                         'priority'        => 0,
                         'openid:Delegate' => 'http://daveman692.livejournal.com',
                         );
ok($res);

my $gen_doc = $nys->get_document();

my $doc;
$doc .= '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
$doc .= "<xrds:XRDS\n";
$doc .= "\txmlns=\"xri://\$xrd*(\$v*2.0)\"\n";
$doc .= "\txmlns:xrds=\"xri://\$xrds\"\n";
$doc .= "\txmlns:openid=\"http://openid.net/xmlns/1.0\">\n";
$doc .= "\t<XRD>\n";
$doc .= "\t<Service priority=\"0\">\n";
$doc .= "\t\t<openid:Delegate>http://daveman692.livejournal.com</openid:Delegate>\n";
$doc .= "\t\t<type>http://openid.net/signon/1.0</type>\n";
$doc .= "\t\t<URI>http://www.livejournal.com/openid/server.bml</URI>\n";
$doc .= "\t</Service>\n";
$doc .= "\t</XRD>\n";
$doc .= "</xrds:XRDS>";

ok($doc eq $gen_doc);
