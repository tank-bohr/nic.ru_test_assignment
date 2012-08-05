package MaillogApp;

use Data::Dumper;
use Log::Log4perl;
use FindBin qw/$Bin/;
use Text::Haml;

use DBController qw/dbh/;

use strict;
use warnings;

sub process_request {
    my $request = shift;

    init_logger();
    &logger->debug('logger works');

    if ($request->method() eq 'POST') {
        my $prm = $request->body_parameters();
        my $address = $prm->{address};
        &logger->info("address is [$address]");
    }

    my $data = get_data();    
    my $haml_engine = Text::Haml->new();
    my $html = $haml_engine->render(&template, %$data, title => 'Список записей');
    return $request->new_response(200, { 'Content-Type' => 'text/html' }, $html);
}




sub get_data {
    my $list  = &dbh->selectall_arrayref(q!
        (SELECT created, int_id, str FROM message)
        UNION ALL
        (SELECT created, int_id, str FROM log)
        ORDER BY int_id, created
        LIMIT 100
    !);
    my $count = &dbh->selectrow_arrayref('SELECT (SELECT COUNT(*) FROM message) + (SELECT COUNT(*) FROM log)');

    return {
        list  => $list,
        count => $count->[0]
    };
}



sub get_html {
    my $data = shift;
}



sub template {
    my $template = q[!!!
%html
    %head
        %title= $title
    %body
        - foreach my $item (@$list) {
            %pre #{$item->[0]} #{$item->[2]}
        - }
        - if ($count > 100) {
            %pre ...
            %hr
            %span Всего записей #{$count}
        - }

];
    return $template;
}



sub init_logger {
    my $log_dir = "$Bin/log";
    mkdir $log_dir unless (-d $log_dir);

    my $config_text = <<EOF;
log4perl.rootLogger=DEBUG, RootAppender
log4perl.appender.RootAppender=Log::Log4perl::Appender::File
log4perl.appender.RootAppender.filename=$log_dir/maillogapp.log
log4perl.appender.RootAppender.layout=PatternLayout
log4perl.appender.RootAppender.layout.ConversionPattern=%d [%p] > %l %m%n
EOF
    Log::Log4perl->init_once(\$config_text);
}

sub logger {
    Log::Log4perl->get_logger();
}





1;

