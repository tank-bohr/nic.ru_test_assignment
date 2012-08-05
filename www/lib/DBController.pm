package DBController;
use parent qw/Exporter/;

our @EXPORT_OK = qw/dbh/;

use Data::Dumper;
use DBI;
use FindBin qw/$Bin/;
use YAML::Any;

use strict;
use warnings;

our $DatabaseHandleObject;

sub dbh {
    unless (UNIVERSAL::isa($DatabaseHandleObject, 'DBI::db')) {
        connect_db();
    }
    unless ($DatabaseHandleObject->ping()) {
        # reconnect
        connect_db();
    }

    return $DatabaseHandleObject;
}


sub connect_db {
    my $params = shift;
    $params ||= load_params_from_config();

    my ($db_driver, $db) = @{ $params }{ qw/driver db/};
    unless ($db_driver && $db) {
        # TODO: do smth
    }
    my $data_source = "DBI:$db_driver:database=$db";
    foreach my $param_name (qw/host port/) {
        my $param_value = $params->{$param_name};
        $data_source .= ";${param_name}=${param_value}" if ($param_value);
    }

    &logger->info("Connect to database [$data_source]");
    my ($user, $password) = @{ $params }{ qw/user password/};
    $DatabaseHandleObject = DBI->connect($data_source, $user, $password, {
        RaiseError => 1,
        AutoCommit => 1
    });
}



sub load_params_from_config {
    YAML::Any::LoadFile("$Bin/config/db.yml");
}


sub logger {
    Log::Log4perl->get_logger();
}



1;
