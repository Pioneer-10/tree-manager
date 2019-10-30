#!perl

use strict;
use warnings;
use utf8;

use DBI;

my $dbh = DBI->connect('dbi:SQLite:dbname=tree.db')
or die "DBI->connect(): $DBI::errstr";

$dbh->do("
	CREATE TABLE tree (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		pid INTEGER,
		lft INTEGER NOT NULL,
		rght INTEGER NOT NULL,
		lvl INTEGER NOT NULL
	)
");
$dbh->do("
	CREATE INDEX idx_tree_lvl ON tree (lvl)
");

$dbh->do("
	INSERT INTO tree (id, pid, lft, rght, lvl)
	VALUES (1, NULL, 1, 2, 0)
");
