#!/usr/bin/perl

use DBI;
use Data::Dumper;
use FindBin qw/$Bin/;

use strict;
use warnings;
use feature qw/say/;


my $file_path = "$Bin/out";

unless (-e $file_path) {
    die 'There is no file to parse';
}


$dbh = DBI->connect('DBI:mysql:database=ru_center;host=localhost', 'root', '', {
    RaiseError => 1,
    AutoCommit => 1
});


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
    my $item;
    if ($flag eq '<=') {
        my ($id) = $other =~ qr/\sid=(.+)/;
        $item = {
            created => "$date $time",
            id => $id,
            int_id => $int_id,
            str => $string_without_timestamp
        };
    }
    else {
         $item = {
            created => "$date $time",
            int_id => $int_id,
            str => $string_without_timestamp,
            address => $address
        };
    }
    say Dumper($item);
}