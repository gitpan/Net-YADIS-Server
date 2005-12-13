#!/usr/bin/perl

use strict;
use Test::More 'no_plan';
use Net::YADIS::Server;

my $nys = Net::YADIS::Server->new();
ok($nys);

my $gen_doc = $nys->get_document();

my $doc;
$doc = q(<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS xmlns="xri://$xrd*($v*2.0)" xmlns:xrds="xri://$xrds"><XRD></XRD></xrds:XRDS>
);

ok($doc eq $gen_doc);
