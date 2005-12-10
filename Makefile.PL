use ExtUtils::MakeMaker;
WriteMakefile( 'NAME' => 'Net::YADIS::Server',
               'VERSION_FROM' => 'lib/Net/YADIS/Server.pm',
               ($] >= 5.005 ?
                (ABSTRACT_FROM => 'lib/Net/YADIS/Server.pm',
                 AUTHOR     => 'David Recordon <david@sixapart.com>') : ()),
               );
