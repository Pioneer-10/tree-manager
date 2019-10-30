#!/bin/env perl

use FindBin;
use File::Spec;

use Plack::Builder;
use Plack::Request;

BEGIN {
	my $path_lib = File::Spec->rel2abs('../lib', $FindBin::Bin);
	require lib;
	lib->import($path_lib);
}

use Application;


my $app = Application->new;

builder {
	mount '/' => sub { $app->handle_request(Plack::Request->new(@_)) },
}
