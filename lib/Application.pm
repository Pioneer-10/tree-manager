package Application;

use strict;
use warnings;
use utf8;

use constant PER_PAGE => 25;

use DBI;
use Plack::Response;
use Routes::Tiny;
use TreeManager;
use View::NodeList;


sub new {
	my $class = shift;

	my $dbh = DBI->connect('dbi:SQLite:dbname=tree.db')
	or die "DBI->connect(): $DBI::errstr";

	my $self = bless { '_dbh' => $dbh, }, ref($class) || $class;
	$self->_init_routes;
	return $self;
}

sub _init_routes {
	my $self = shift;

	my $routes = $self->{'_routes'} = Routes::Tiny->new;
	$routes->add_route(GET => '/', name => 'list_nodes');
	$routes->add_route(POST => '/add_node/', name => 'add_node');
}

sub handle_request {
	my $self = shift;
	my $request = shift;

	my $method = 'handle_not_found';
	if (my $match = $self->{'_routes'}->match($request->path, method => $request->env->{'REQUEST_METHOD'})) {
		$method = $match->name;
	}
	return $self->$method($request);
}

sub list_nodes {
	my $self = shift;
	my $request = shift;

	my $page = $request->param('page') || 1;
	if ($page =~ /\D/ || $page < 1) {
		return $self->handle_not_found;
	}

	my $manager = TreeManager->new($self->{'_dbh'});
	my $view = View::NodeList->new;
	my $nodes = $manager->list_nodes(offset => ($page - 1) * PER_PAGE, limit => PER_PAGE)
	or return $self->handle_error($manager->error);

	if ($page > 1 && scalar(@$nodes) == 0) {
		$view->error_message("You've gone too far. There is no results for the requested page");
	}

	$view->node_list($nodes);
	$view->pager($page, PER_PAGE, $manager->count_nodes);

	my $response = Plack::Response->new(200);
	$response->content_type($view->CONTENT_TYPE);
	$response->body($view->render);
	return $response->finalize;
}

sub add_node {
	my $self = shift;
	my $request = shift;

	my $manager = TreeManager->new($self->{'_dbh'});
	my $view = View::NodeList->new;
	my $pid = $request->param('pid');

	if (!defined($pid)) {
		$view->error_message('No pid specified');
	} elsif ($pid =~ /\D/ || $pid < 1) {
		$view->error_message('PID must be positive integer');
	} elsif (my $node = $manager->add_node(pid => $pid)) {
		my $node_ordering_number = $manager->count_nodes($node);
		my $page = int(($node_ordering_number - 1) / PER_PAGE) + 1;
		my $nodes = $manager->list_nodes(offset => ($page - 1) * PER_PAGE, limit => PER_PAGE)
		or return $self->handle_error($manager->error);

		$view->node_list($nodes);
		$view->pager($page, PER_PAGE, $manager->count_nodes);
	} else {
		$view->error_message($manager->error);
	}

	if (!$view->node_list) {
		my $nodes = $manager->list_nodes(limit => PER_PAGE);
		$view->node_list($nodes);
		$view->pager(1, PER_PAGE, $manager->count_nodes)
	}

	my $response = Plack::Response->new(200);
	$response->content_type($view->CONTENT_TYPE);
	$response->body($view->render);
	return $response->finalize;
}

sub handle_not_found {
	my $self = shift;
	my $request = shift;

	my $response = Plack::Response->new(404);
	$response->content_type('text/plain');
	$response->body(($request) ? "Requested URL @{[ $request->path ]} was not found" : 'Page not found');

	return $response->finalize;
}

sub handle_error {
	my $self = shift;
	my $msg = shift || 'There was error while processing your request';

	my $response = Plack::Response->new(500);
	$response->content_type('text/plain');
	$response->body($msg);

	return $response->finalize;
}

1;
