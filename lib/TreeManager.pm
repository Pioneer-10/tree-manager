package TreeManager;

use strict;
use warnings;
use utf8;

use constant TABLE_NAME => 'tree';
use constant COLUMN_ID => 'id';
use constant COLUMN_PID => 'pid';
use constant COLUMN_LEFT => 'lft';
use constant COLUMN_RIGHT => 'rght';
use constant COLUMN_LEVEL => 'lvl';


sub new {
	my $class = shift;
	my $dbh = shift;

	return bless {
		'_dbh' => $dbh,
	}, ref($class) || $class;
}

sub count_nodes {
	my $self = shift;
	my $up_to_node = shift;

	my $dbh = $self->{'_dbh'};
	my $data = $dbh->selectrow_arrayref(
		"SELECT COUNT(1) FROM @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}"
		. ($up_to_node ? "WHERE @{[ $dbh->quote_identifier($self->COLUMN_LEFT) ]} <= ?" : ''),
		undef,
		($up_to_node ? ($up_to_node->left) : ()),
	);
	return $self->error($dbh->errstr) if ($dbh->err);
	return $data->[0];
}

sub list_nodes {
	my $self = shift;
	my $params = {
		'offset' => 0,
		'limit' => 25,
		@_,
	};

	my $dbh = $self->{'_dbh'};
	my $data = $dbh->selectall_arrayref(
		"
			SELECT *
			FROM @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			ORDER BY @{[ $dbh->quote_identifier($self->COLUMN_LEFT) ]}
			LIMIT ?,?
		",
		{ 'Slice' => {}, },
		@$params{qw/offset limit/},
	);
	return $self->error($dbh->errstr) if ($dbh->err);

	return [map {
		$self->_make_node($_)
	} @$data];
}

sub add_node {
	my $self = shift;
	my $params = { @_ };

	my $dbh = $self->{'_dbh'};
	my $node = $dbh->selectrow_hashref(
		"
			SELECT *
			FROM @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			WHERE @{[ $dbh->quote_identifier($self->COLUMN_ID) ]} = ?
		",
		undef,
		$params->{'pid'},
	);
	return $self->error($dbh->errstr) if ($dbh->err);
	return $self->error('No such node') unless ($node);

	my $col_right = $dbh->quote_identifier($self->COLUMN_RIGHT);
	my $col_left = $dbh->quote_identifier($self->COLUMN_LEFT);
	$dbh->do(
		"
			UPDATE @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			SET
				$col_left = $col_left + (CASE $col_left <= ? WHEN TRUE THEN 0 ELSE 2 END),
				$col_right = $col_right + 2
			WHERE $col_right >= ?
		",
		undef,
		$node->{ $self->COLUMN_LEFT }, $node->{ $self->COLUMN_RIGHT },
	);
	return $self->error($dbh->errstr) if ($dbh->err);

	my %data = (
		(map { %$_ } grep { $_ } $params->{'data'}),
		$self->COLUMN_PID => $params->{'pid'},
		$self->COLUMN_LEFT => $node->{ $self->COLUMN_RIGHT },
		$self->COLUMN_RIGHT => $node->{ $self->COLUMN_RIGHT } + 1,
		$self->COLUMN_LEVEL => $node->{ $self->COLUMN_LEVEL } + 1,
	);
	my (@col_names, @values);
	while (my $col_name = each %data) {
		push(@col_names, $dbh->quote_identifier($col_name));
		push(@values, $data{$col_name});
	}

	$dbh->do(
		"
			INSERT INTO @{[ $dbh->quote_identifier($self->TABLE_NAME) ]} (
				@{[ join(',', @col_names) ]}
			) VALUES (
				@{[ join(',', map { '?' } @col_names) ]}
			)
		",
		undef,
		@values,
	);
	return $self->error($dbh->errstr) if ($dbh->err);

	$data{ $self->COLUMN_ID } = $dbh->last_insert_id;
	return $self->_make_node(\%data);
}

sub _make_node {
	my $self = shift;
	my $row = shift;

	my %data = %$row;
	return TreeManager::Node->new(
		delete $data{ $self->COLUMN_ID },
		delete $data{ $self->COLUMN_PID },
		delete $data{ $self->COLUMN_LEFT },
		delete $data{ $self->COLUMN_RIGHT },
		delete $data{ $self->COLUMN_LEVEL },
		%data,
	);
}

sub error {
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_error'} = shift;
		return
	}

	return $self->{'_error'};
}


package TreeManager::Node;

sub new {
	my $class = shift;
	my ($id, $pid, $left, $right, $level, %extra_data) = @_;

	return bless {
		'_id' => $id,
		'_pid' => $pid,
		'_left' => $left,
		'_right' => $right,
		'_level' => $level,
		'_data' => \%extra_data,
	}, ref($class) || $class;
}

sub id {
	return shift->{'_id'};
}

sub pid {
	return shift->{'_pid'};
}

sub left {
	return shift->{'_left'};
}

sub right {
	return shift->{'_right'};
}

sub level {
	return shift->{'_level'};
}

sub data {
	return shift->{'_data'};
}

1;
