package MaillogApp;

use Data::Dumper;
use Log::Log4perl;
use FindBin qw/$Bin/;

use DBController;

use strict;
use warnings;

sub process_request {
    my $request = shift;

    init_logger();
    &logger->debug('test');

    return $request->new_response(200, { 'Content-Type' => 'text/html' }, 'Test');
}



sub init_logger {
    my $config_text = <<EOF;
log4perl.rootLogger=DEBUG, RootAppender
log4perl.appender.RootAppender=Log::Log4perl::Appender::File
log4perl.appender.RootAppender.filename=$Bin/maillog.log
log4perl.appender.RootAppender.layout=PatternLayout
log4perl.appender.RootAppender.layout.ConversionPattern=%d [%p] > %l %m%n
EOF
    Log::Log4perl->init_once(\$config_text);
}

sub logger {
    Log::Log4perl->get_logger();
}





1;

