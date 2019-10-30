package View::BaseTemplate;

use strict;
use warnings;
use utf8;

use Template;

use constant TEMPLATE_NAME => undef;
use constant CONTENT_TYPE => 'text/html';


sub new {
	my $class = shift;

	return bless {
		'_tmpl' => Template->new(
			INCLUDE_PATH => 'tpl',
		),
	}, ref($class) || $class;
}

sub get_data {
	return undef;
}

sub render {
	my $self = shift;

	my $template_name = $self->TEMPLATE_NAME
	or return $self->error('TEMPLATE_NAME is not provided');
	my $data = $self->get_data || {};

	my $body;
	$self->{'_tmpl'}->process($template_name, $data, \$body);

	if (my $err = $self->{'_tmpl'}->error) {
		return $self->error($err);
	}
	return $body;
}

sub error {
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_error'} = shift;
		return
	}

	return $self->{'_error'};
}

1;
