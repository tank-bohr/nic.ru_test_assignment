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


my %pasrsed = (
    message => [],
    log     => []
);
if (open my $fh => $file_path) {
    while (my $string = <$fh>) {
        chomp $string;
        my ($table_name, $item) = process_string($string);
        push @{ $pasrsed{$table_name} }, $item;
    }
    close $fh;
}
else {
    say "Cannot open file [$file_path]: $!";
}


my $dbh = connect_db();
foreach my $table_name (keys %pasrsed) {
    #batch_insert($dbh, $table_name, $pasrsed{$table_name});
    foreach my $item (@{ $pasrsed{$table_name} }) {
        insert_one($dbh, $table_name, $item);
    }
}
$dbh->disconnect();


sub batch_insert {
    my ($dbh, $table_name, $data) = @_;

    my $fields = $dbh->selectcol_arrayref(qq!SHOW COLUMNS FROM $table_name!);
    say Dumper($fields);

    my $fields_list  = join ', ' => @$fields;
    my $placeholder  = join ', ' => map {'?'}              0..$#$fields;
    my $placeholders = join ', ' => map {"($placeholder)"} 0..$#$data;

    my $query = qq!INSERT INTO $table_name ($fields_list) VALUES $placeholders!;

    my @bind_values;
    foreach my $item (@$data) {
        push @bind_values, @{ $item }{ @$fields };
    }

    say $query;
    $dbh->do($query, undef, @bind_values);
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
    my ($dbh, $table_name, $item) = @_;

    my @fields = grep {defined $item->{$_}} keys %$item;

    my $fields_list = join ', ' => @fields;
    my $placeholders = join ', ' => map {'?'} 0..$#fields;

    my $query = qq!INSERT INTO $table_name ($fields_list) VALUES ($placeholders)!;
    my @bind_values = map {$item->{$_}} @fields;

    $dbh->do($query, undef, @bind_values);
}




sub connect_db {
    my $db_driver = 'Pg';
    my $host = 'ubuntu-server';
    my $user = 'xoma';
    my $db = 'ru_center';
    my $password = 'secret';

    my $dbh = DBI->connect("DBI:$db_driver:database=$db;host=$host", $user, $password, {
        RaiseError => 1,
        AutoCommit => 1
    });

    return $dbh;
}



