use Plack::Request;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use MaillogApp;

use strict;
use warnings;

my $app = sub {
    my $env = shift;
    my $request = Plack::Request->new($env);
    my $response = MaillogApp::process_request($request);
    return $response->finalize();
};