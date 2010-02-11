# -* - perl -*-

package Devel::Trace::Fork;
use Devel::Trace;
our $VERSION = '0.10';

sub DB::DB {
  return unless $Devel::Trace::TRACE;
  my ($p, $f, $l) = caller;
  my $w = sprintf '%5d', $$;
  my $code = \@{"::_<$f"};
  print STDERR ">> $w:$f:$l: $code->[$l]";
}

print "Hello\n";
1;

__END__

=head1 NAME

Devel::Trace::Fork - Devel::Trace-like output for multi-process programs

=head1 SYNOPSIS

    perl -d:Trace::Fork program

=head1 DESCRIPTION

Like Mark Jason Dominus's L<Devel::Trace> module, 
but debugging output includes the process id
of the process that executes each statement. 
This can be helpful for debugging programs that make use of the
L<< fork|perlfunc/fork >> system call to run. For example,
the C<Trace::Fork> output of this program:

    if (fork() == 0) {
        print "This is the child.\n";
        exit 0;
    }
    print "This is the parent.\n";

will look something like:

    >>  5240:./test:1: if (fork() == 0) {
    >>  5240:./test:5: print "This is the parent.\n";
    This is the parent.
    >>  8188:./test:2:     print "This is the child.\n";
    This is the child.
    >>  8188:./test:4:     exit 0;

=head1 DETAILS

See L<Devel::Trace>. Use the C<$Devel::Trace::TRACE> variable
or the C<Devel::Trace::trace> function exactly the way you
would use them with the pure C<Devel::Trace> module. To import
the C<Devel::Trace::trace> function into your program's
namespace, include the line:

    use Devel::Trace 'trace';

somewhere in your program.

=head1 SEE ALSO

L<Devel::Trace>, L<Devel::Trace::More>

=head1 AUTHOR

Marty O'Brien, E<lt>mob@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2010, Marty O'Brien

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
