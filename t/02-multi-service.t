#!/usr/bin/perl

use strict;
use Test::More 'no_plan';
use Net::YADIS::Server;

my $nys = Net::YADIS::Server->new();
ok($nys);

my $res;

$res = $nys->add_namespaces( 'openid' => 'http://openid.net/xmlns/1.0' );
ok($res);

$res = $nys->add_service(
                         'type'            => 'http://openid.net/signon/1.0',
                         'URI'             => 'http://www.livejournal.com/openid/server.bml',
                         'priority'        => 0,
                         'openid:Delegate' => 'http://daveman692.livejournal.com',
                         );
ok($res);

$res = $nys->add_service(
                         'type'            => 'http://lid.netmesh.org/sso/2.0b5',
                         'URI'             => 'http://www.mylid.com/users/example',
                         'priority'        => 10,
                         );
ok($res);

my $gen_doc = $nys->get_document();

my $doc;
$doc = q(<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS xmlns:openid="http://openid.net/xmlns/1.0" xmlns="xri://$xrd*($v*2.0)" xmlns:xrds="xri://$xrds"><XRD><Service priority="0"><openid:Delegate>http://daveman692.livejournal.com</openid:Delegate><type>http://openid.net/signon/1.0</type><URI>http://www.livejournal.com/openid/server.bml</URI></Service><Service priority="10"><type>http://lid.netmesh.org/sso/2.0b5</type><URI>http://www.mylid.com/users/example</URI></Service></XRD></xrds:XRDS>
);

ok($doc eq $gen_doc);
