#!/usr/bin/perl

use strict;
use Test::More 'no_plan';
use Net::YADIS::Server;

my $nys = Net::YADIS::Server->new();
ok($nys);

my $str = "<>&\"'";
my $estr = $nys->_exml($str);
my $good = "&lt;&gt;&amp;&quot;&apos;";

ok ($estr eq $good);
