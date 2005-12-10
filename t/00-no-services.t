#!/usr/bin/perl

use strict;
use Test::More 'no_plan';
use Net::YADIS::Server;

my $nys = Net::YADIS::Server->new();
ok($nys);

my $gen_doc = $nys->get_document();

my $doc;
$doc .= '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
$doc .= "<xrds:XRDS\n";
$doc .= "\txmlns=\"xri://\$xrd*(\$v*2.0)\"\n";
$doc .= "\txmlns:xrds=\"xri://\$xrds\">\n";
$doc .= "\t<XRD>\n";
$doc .= "\t</XRD>\n";
$doc .= "</xrds:XRDS>";

ok($doc eq $gen_doc);
