#!/usr/bin/perl

use DBI;
use Data::Dumper;
use FindBin qw/$Bin/;
use Time::HiRes qw/time/;

use strict;
use warnings;
use feature qw/say/;


my $file_path = "$Bin/out";

unless (-e $file_path) {
    die 'There is no file to parse';
}





my (@message, @log);
if (open my $fh => $file_path) {
    while (my $string = <$fh>) {
        chomp $string;
        my ($table_name, $item) = process_string($string);
        if ($table_name eq 'message') {
            push @message, $item;
        }
        elsif ($table_name eq 'log') {
            push @log, $item;
        }
    }
    close $fh;
}
else {
    say "Cannot open file [$file_path]: $!";
}


#my $dbh = connect_db();
#$dbh->disconnect();


sub batch_insert {
    my ($dbh, $params) = @_;
    my ($table_name, $fields, $data) = @{ $params }{ qw/table_name fields data/ };

    #my @fields = qw/created id int_id str/;
    my $fields_list  = join ', ' => @$fields;
    my $placeholder  = join ', ' => map {'?'}              0..$#$fields;
    my $placeholders = join ', ' => map {"($placeholder)"} 0..$#$data;

    my $query = qq!INSERT INTO $table_name ($fields_list) VALUES $placeholders!;

    my @bind_values;
    foreach my $item (@$data) {
        push @bind_values, @{ $item }{ @fields };
    }

    #$dbh->do($query, undef, @bind_values);
}





sub process_string {
    my $string = shift;
    my ($date, $time, $string_without_timestamp) = split ' ', $string, 3;
    my ($int_id, $flag, $address, $other) = split ' ', $string_without_timestamp, 4;

    $flag = '' if $flag !~ qr/(?:<=|=>|->|\*\*|==)/;
    if ($flag eq '<=') {
        my ($id) = $other =~ qr/\sid=(.+)/;
        $id ||= time();
        return ('message', {
            created => "$date $time",
            id => $id,
            int_id => $int_id,
            str => $string_without_timestamp
        });
    }
    else {
         return ('log', {
            created => "$date $time",
            int_id => $int_id,
            str => $string_without_timestamp,
            address => $address
        });
    }

}



sub insert_one {
    my ($table_name, $item) = @_;

    my @fields = grep {defined $item->{$_}} keys %$item;

    my $fields_list = join ', ' => @fields;
    my $placeholders = join ', ' => map {'?'} 0..$#fields;

    my $query = qq!INSERT INTO $table_name ($fields_list) VALUES ($placeholders)!;
    my @bind_values = map {$item->{$_}} @fields;

    #$dbh->do($query, undef, @bind_values);
}


sub connect_db {
    my $db_driver = 'mysql';
    my $host = 'localhost';
    my $port = '3306';
    my $user = 'root';
    my $db = 'ru_center';
    my $password = '';

    my $dbh = DBI->connect("DBI:$db_driver:database=$db;host=$host;port=$port", $user, $password, {
        RaiseError => 1,
        AutoCommit => 1
    });

    return $dbh;
}

