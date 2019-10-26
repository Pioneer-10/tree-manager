#!/bin/env perl

use Plack::Builder;
use Plack::Request;


sub hello_world {
	my $env = shift;

	my $request = Plack::Request->new($env);
	return [
		200,
		[],
		['Hello, world!'],
	];
}


builder {
	mount '/' => \&hello_world,
}
