
require 5;
package Pod::Simple::DumpAsText;
use cperl;
our $VERSION = '4.39c'; # modernized
$VERSION =~ s/c$//;
use Pod::Simple ();
BEGIN {@ISA = ('Pod::Simple')}

use strict;

use Carp ();

BEGIN { *DEBUG = \&Pod::Simple::DEBUG unless defined &DEBUG }

sub new ($self, @args) {
  my $new = $self->SUPER::new(@args);
  $new->{'output_fh'} ||= *STDOUT{IO};
  $new->accept_codes('VerbatimFormatted');
  $new->keep_encoding_directive(1);
  return $new;
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

sub _handle_element_start ($self, $element_name, $attr?) {
  my $fh = $self->{'output_fh'};
  my($key, $value);
  DEBUG and print STDERR "++ $element_name\n";
  
  print $fh   '  ' x ($self->{'indent'} || 0),  "++", $element_name, "\n";
  $self->{'indent'}++;
  while(($key,$value) = each %{$attr}) {
    unless($key =~ m/^~/s) {
      next if $key eq 'start_line' and $self->{'hide_line_numbers'};
      _perly_escape($key);
      _perly_escape($value);
      printf $fh qq{%s \\ "%s" => "%s"\n},
        '  ' x ($self->{'indent'} || 0), $key, $value;
    }
  }
  return;
}

sub _handle_text ($self, str $text='') {
  DEBUG and print STDERR "== \"$text\"\n";
  
  if (length $text) {
    my $indent = '  ' x $self->{'indent'};
    _perly_escape($text);
    $text =~  # A not-totally-brilliant wrapping algorithm:
      s/(
         [^\n]{55}         # Snare some characters from a line
         [^\n\ ]{0,50}     #  and finish any current word
        )
        \ {1,10}(?!\n)     # capture some spaces not at line-end
       /$1"\n$indent . "/gx     # => line-break here
    ;
    
    print {$self->{'output_fh'}} $indent, '* "', $text, "\"\n";
  }
  return;
}

sub _handle_element_end ($self, str $element_name, $attr?) {
  DEBUG and print STDERR "-- $element_name\n";
  print {$self->{'output_fh'}}
   '  ' x --$self->{'indent'}, "--$element_name\n";
  return;
}

# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

sub _perly_escape { # by-ref
  foreach my $x (@_) {
    $x =~ s/([^\x00-\xFF])/sprintf'\x{%X}',ord($1)/eg;
    # Escape things very cautiously:
    $x =~ s/([^-\n\t \&\<\>\'!\#\%\(\)\*\+,\.\/\:\;=\?\~\[\]\^_\`\{\|\}abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789])/sprintf'\x%02X',ord($1)/eg;
  }
  return;
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
1;


__END__

=head1 NAME

Pod::Simple::DumpAsText -- dump Pod-parsing events as text

=head1 SYNOPSIS

  perl -MPod::Simple::DumpAsText -e \
   "exit Pod::Simple::DumpAsText->filter(shift)->any_errata_seen" \
   thingy.pod

=head1 DESCRIPTION

This class is for dumping, as text, the events gotten from parsing a Pod
document.  This class is of interest to people writing Pod formatters
based on Pod::Simple. It is useful for seeing exactly what events you
get out of some Pod that you feed in.

This is a subclass of L<Pod::Simple> and inherits all its methods.

=head1 SEE ALSO

L<Pod::Simple::DumpAsXML>

L<Pod::Simple>

=head1 SUPPORT

Questions or discussion about POD and Pod::Simple should be sent to the
pod-people@perl.org mail list. Send an empty email to
pod-people-subscribe@perl.org to subscribe.

This module is managed in an open GitHub repository,
L<https://github.com/perl-pod/pod-simple/>. Feel free to fork and contribute, or
to clone L<git://github.com/perl-pod/pod-simple.git> and send patches!

Patches against Pod::Simple are welcome. Please send bug reports to
<bug-pod-simple@rt.cpan.org>.

=head1 COPYRIGHT AND DISCLAIMERS

Copyright (c) 2002 Sean M. Burke.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=head1 AUTHOR

Pod::Simple was created by Sean M. Burke <sburke@cpan.org>.
But don't bother him, he's retired.

Pod::Simple is maintained by:

=over

=item * Allison Randal C<allison@perl.org>

=item * Hans Dieter Pearcey C<hdp@cpan.org>

=item * David E. Wheeler C<dwheeler@cpan.org>

=back

=cut
