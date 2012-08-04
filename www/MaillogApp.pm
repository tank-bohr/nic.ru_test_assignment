package MaillogApp;

use Data::Dumper;
use Log::Log4perl;
use FindBin qw/$Bin/;

use DBController qw/dbh/;

use strict;
use warnings;

sub process_request {
    my $request = shift;

    init_logger();
    &logger->debug('logger works');

    my $data = get_data();
    my $html = '<pre>'. Dumper($data) .'</pre>';

    return $request->new_response(200, { 'Content-Type' => 'text/html' }, $html);
}




sub get_data {
    my $message = &dbh->selectall_arrayref(q!SELECT created, int_id, str, DATE_PART('epoch', created) FROM message LIMIT 100!);
    my $log     = &dbh->selectall_arrayref(q!SELECT created, int_id, str, DATE_PART('epoch', created) FROM log     LIMIT 100!);
    my @list;
    push @list, @$message;
    push @list, @$log;

    my @sorted = sort {$a->[3] <=> $b->[3]} sort {$a->[1] cmp $b->[1]} @list;
    my @slice = @sorted[0..99];
    my $count = &dbh->selectrow_arrayref('SELECT COUNT(*) FROM message');

    return {
        list => \@slice,
        count => $count->[0]
    };
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

