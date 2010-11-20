#!/usr/bin/perl

# Rob Anderson, 2009
# roboprogs.com
# Drive the various implementations and variations
# of my bogus "C10K" (string masher response) test
#
# OK, not really a "C10K" test,
# as there are no open sockets waiting for responses,
# but it does let you measure the cost of various "computation" implementations,
# where "computation" = (biz app) string manipulation instead of floating point.


#    mp_bench - multiprocessing benchmarks for string handling
#
#    Copyright (C) 2009, 2010, Robin R Anderson
#    roboprog@yahoo.com
#    PO 1608
#    Shingle Springs, CA 95682
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;

# implementations in various languages, with supported run type methods.
#  (S = sequential, F = fork, T = thread)
my %IMPLS =
	(
	'./thd_frk.bzrt.cbin' =>
		[
		'gcc --version',
		[ 'S', 'F' ]
		],
	'./thd_frk.cbin' =>
		[
		'gcc --version',
		[ 'S', 'F' ]
		],
	'./thd_frk.pl' =>
		[
		'perl --version',
		[ 'S', 'F', 'T' ]
		],
	'/usr/local/java/bin/java ThdFrk' =>
		[
		'/usr/local/java/bin/java -version',
		[ 'S', 'T' ]
		],
	'./thd_frk.py' =>
		[
		'python --version',
		[ 'S', 'F', 'T' ]
		],
	'./thd_frk.rb' =>
		[
		'ruby --version',
		[ 'S', 'F', 'T' ]
		],
	);

# number of times to repeat a trial:
my $MAX_TRIALS = 5;

# max number of iterations (simulated requests) within a trial:
my $MAX_ITERS = 20000;

# sundry commands to dump system info of possible relevance:
my @SYS_INFO_CMDS =
	(
	# you can have any system you want, as long as it's unix / linux:
	'uname -a',
	'cat /proc/cpuinfo',
	'free',
	);

&main();
exit 0;
# _________________________________________________________________

# drive the various tests, display timings
sub	main
	{
	my( $si, $impl, $method_ref);

	&build();
	print "\n\n";
	foreach $si ( @SYS_INFO_CMDS)

		{
		system( $si);
		}  # run each system info command

	print "\n\n";
	foreach $impl ( sort( keys( %IMPLS) ) )

		{
		$method_ref = $IMPLS{ $impl };
		&run_methods( $impl, $method_ref);
		}  # test run each implementation a few times

	} # ____________________________________________________________

# compile implementations that need it
sub	build
	{

	print "C compile(s)...\n";
	# use max optomization, for all the good it does:
	system( 'gcc -O3 thd_frk.bzrt.c ' .
			'buzzard-0.1/libbzrt.a ' .
			'-o thd_frk.bzrt.cbin');
	system( 'gcc -O3 thd_frk.c -o thd_frk.cbin');

	print "Java compile...\n";
	# "just" compile, as the JIT deals with optomization later
	system( '/usr/local/java/bin/javac ThdFrk.java');

	# TODO: error checks
	} # ____________________________________________________________

# run all the methods of an implementation
sub	run_methods
	{
	my	(
		$impl,							# implementation, w/ interpreter if needed
		$impl_details,					# language version + "methods"
		) = @_;

	my( $lang_ver, $method_ref, $method);

	print <<END_TADA


Now trying $impl implementation:
END_TADA
	;
	$lang_ver = ${ $impl_details }[ 0 ];
	system( $lang_ver);
	$method_ref = ${ $impl_details }[ 1 ];
	foreach $method ( @{ $method_ref })

		{
		&run( $impl, $method);
		}  # run each method on implementation

	} # ____________________________________________________________

# run a method of an implementation
sub	run
	{
	my	(
		$impl,							# implementation, w/ interpreter if needed
		$method							# method (fork, thread, sequential) to run
		) = @_;

	my( $ipower, $iters);

	print <<END_TADA

	Now trying $method method
END_TADA
	;
	# foreach $iters ( 1, 5001, 10001, 20001)
	for ( 	$ipower = -1;
			( ( $ipower >= 0) ?
					( $iters = 5000 * ( 2 ** $ipower) ) : 0),
			$iters <= $MAX_ITERS;
		  	$ipower++)

		{
		$iters++;  # use 1 (then N + 1) as starting point, rather than 0.
		&run_size( $impl, $method, $iters);
		}  # kick off runs of various sizes (iteration count)

	} # ____________________________________________________________

# run a method of an implementation
sub	run_size
	{
	my	(
		$impl,							# implementation, w/ interpreter if needed
		$method,						# method (fork, thread, sequential) to run
		$iters,							# number of iterations (size of run)
		) = @_;

	my( $time_text, $elapsed, $perc_cpu);

	print "\t\t$iters iterations:\n";
	# make 2*N+1 runs, so we can take the median time
	foreach ( 1 .. $MAX_TRIALS)

		{
		# throw stuff in a dummy file rather than /dev/null,
		# just in case the OS would "cheat" on the output in some way
		$time_text = `( /usr/bin/time $impl $method $iters > ignore.txt ) 2>&1`;
		if ( $time_text !~ /([\d:\.]+elapsed) ([\d\?]+%CPU)/)
			{
			die "Failed to parse time output [$time_text]";
			}  # failed to parse time's output?

		$elapsed = $1;
		$perc_cpu = $2;
		print "\t\t\t$1 $2\n";
		}  # run multiple trials

	} # ____________________________________________________________


# vi: ts=4 sw=4
# *** EOF ***
