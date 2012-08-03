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


my $dbh = connect_db();

=test
my $tables = $dbh->selectall_arrayref('SHOW tables');
say Dumper($tables);
=cut


if (open my $fh => $file_path) {
    while (my $string = <$fh>) {
        chomp $string;
        process_string($string);
    }
    close $fh;
}
else {
    say "Cannot open file [$file_path]: $!";
}


$dbh->disconnect();



sub process_string {
    my $string = shift;
    my ($date, $time, $string_without_timestamp) = split ' ', $string, 3;
    my ($int_id, $flag, $address, $other) = split ' ', $string_without_timestamp, 4;

    $flag = '' if $flag !~ qr/(?:<=|=>|->|\*\*\|==)/;

    if ($flag eq '<=') {
        my ($id) = $other =~ qr/\sid=(.+)/;
        $id ||= time();
        insert_table('message', {
            created => "$date $time",
            id => $id,
            int_id => $int_id,
            str => $string_without_timestamp
        });
    }
    else {
         insert_table('log', {
            created => "$date $time",
            int_id => $int_id,
            str => $string_without_timestamp,
            address => $address
        });
    }

}



sub insert_table {
    my ($table_name, $item) = @_;

    my @fields = grep {defined $item->{$_}} keys %$item;

    my $fields_list = join ', ' => @fields;
    my $placeholders = join ', ' => map {'?'} 0..$#fields;

    my $query = qq!INSERT INTO $table_name ($fields_list) VALUES ($placeholders)!;
    my @bind_values = map {$item->{$_}} @fields;

    $dbh->do($query, undef, @bind_values);
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

