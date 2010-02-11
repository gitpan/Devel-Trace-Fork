use Test::More tests => 13;
use Carp;
use strict;
use warnings;

unlink "t/01-testprog.pl", "t/01-testprog.out";

open(TESTPROG, ">", "t/01-testprog.pl");
print TESTPROG <<'_END_TEST_';
# a test program
#
# this is line 3. The first line of code is line 5.

my $code_from_parent = 4;
&a_function(3,6);
my $pid = fork();
if ($pid == 0) {
    my $code_from_child = 7;
    &a_function(17,5);
    # no exit statement, so code after this block
    # is executed in both parent and child
}
my $code_in_both_programs = 9;

sub a_function {
  my ($x,$y) = @_;
  return $x + $y;
}
_END_TEST_

close TESTPROG;

system("$^X -Ilib -d:Trace::Fork t/01-testprog.pl > t/01-testprog.out 2>&1");

# now examine the output .

open(TESTOUT, "<", "t/01-testprog.out");
my @TESTOUT = <TESTOUT>;
close TESTOUT;

# our expectations about the output:
#   "Hello\n" is printed exactly once.
#   a_function is called twice by two different pids, first in parent
#   code_from_parent is associated with parent pid
#   code_from_child is associated with child pid
#   code_from_both is associated with both pids.

sub extract_pid {
  # extract process id from line of Devel::Trace::Fork output
  my ($line) = @_;
  my ($pid) = $line =~ /^\>\>\s*(\-?\d+):t/; # MSWin32 can have negative pid.
  return $pid;
}

my @hello = grep { $_ eq "Hello\n" } @TESTOUT;
ok(@hello == 1);
ok(not defined extract_pid($hello[0]));

my $parent_pid = extract_pid($TESTOUT[0]);

my @a_function = grep { /return \$x \+ \$y/ } @TESTOUT;
ok(@a_function == 2);
ok(extract_pid($a_function[0]) == $parent_pid);
ok(extract_pid($a_function[1]) != $parent_pid);

my @from_parent = grep { /from_parent/ } @TESTOUT;
ok(@from_parent == 1);
ok(extract_pid($from_parent[0]) == $parent_pid);

my @from_child = grep { /from_child/ } @TESTOUT;
ok(@from_child == 1);
ok(extract_pid($from_child[0]) != $parent_pid);

my @from_both = grep { /_in_both_/ } @TESTOUT;
ok(@from_both == 2);
ok(extract_pid($from_both[0]) != extract_pid($from_both[1]));

my %pids_seen = ();
foreach my $line (grep { /^\>\>/ } @TESTOUT) {
  $pids_seen{ extract_pid($line) }++;
}

ok(2 == scalar keys %pids_seen);
delete $pids_seen{$parent_pid};
ok(1 == scalar keys %pids_seen);


