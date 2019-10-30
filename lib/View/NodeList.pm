package View::NodeList;

use strict;
use warnings;
use utf8;

use parent qw/View::BaseTemplate/;

use constant TEMPLATE_NAME => 'node_list.tpl';


sub node_list {
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_node_list'} = shift;
		return $self;
	}
	return $self->{'_node_list'} || [];
}

sub pager {
	my $self = shift;

	if (scalar(@_) > 0) {
		my ($page, $per_page, $total_items) = @_;
		my $total_pages = int(($total_items - 1) / $per_page) + 1;
		$self->{'_pager'} = ($total_pages > 1) ? {
			'page' => $page,
			'prev_page' => ($page > 1) ? $page - 1 : undef,
			'next_page' => ($page < $total_pages) ? $page + 1 : undef,
		} : undef;
		return $self;
	}
	return $self->{'_pager'};
}

sub error_message {
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_error_message'} = shift;
		return $self;
	}
	return $self->{'_error_message'};
}

sub get_data {
	my $self = shift;

	return {
		'node_list' => $self->node_list,
		'pager' => $self->pager,
		'error_message' => $self->error_message,
	};
}

1;
