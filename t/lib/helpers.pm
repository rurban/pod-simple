#!perl

package helpers;

use strict;
use warnings;

use Sub::Util 1.55;

use Exporter;

our @ISA = qw{Exporter};

our @EXPORT_OK = qw(e f);
our @EXPORT = qw{e};

sub e { Pod::Simple::DumpAsXML->_duo(@_) };
sub f { Pod::Simple::DumpAsXML->_duo(@_) };

BEGIN {
  Sub::Util::set_prototype('$$', \&e);
  Sub::Util::set_prototype('$$$', \&f);
}

1;