#!/usr/bin/perl
#
# Test Perl threads (a la 5.6)


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

use threads;

my $thread_dangerous_var;
my $local_process_var;

main();

# main program logic:  spawn crud to see what happens
sub main()
	{
	my $mode = shift @ARGV;
	my $cnt = shift @ARGV;
	if ( uc( $mode) eq 'T')
		{
		&do_threads( $cnt);
		}  # threads?
	elsif ( uc( $mode) eq 'F')
		{
		&do_forks( $cnt);
		}  # forks?
	elsif ( uc( $mode) eq 'S')
		{
		&do_sequence( $cnt);
		}  # sequential?
	else
		{
		die "Arg 1 must be T (thread), F (fork), or S (sequential)";
		}
	}

# test thread based concurrency
sub do_threads()
	{
	my $cnt = shift @_;

	foreach ( 1 .. $cnt)

		{
		my $t = threads->new( \&service_thread);
		$t->detach;
		}  # lob off each slave to process "request"

	}

# pretend to provide a useful service for thread testing
sub service_thread
	{
	# force a shared data situation, however contrived
	lock( $thread_dangerous_var);

	# contrived?  stumbled on page stating localtime may not be thread safe!
	$thread_dangerous_var = localtime();
	print $thread_dangerous_var, " ", &gen_pg_template(), "\n";
	}

# test fork based concurrency
sub do_forks()
	{
	my $cnt = shift @_;

	$SIG{ CHILD } = sub { my $ignored = wait; };
	foreach ( 1 .. $cnt)

		{
		if ( fork() == 0)
			{
			&service_fork();
			exit 0;
			}  # in child process?
		# else:  ignore child PIDs, zombies
		}  # lob off each slave to process "request"

	}

# pretend to provide a useful service for fork testing
sub service_fork
	{
	$local_process_var = localtime();
	print $local_process_var, " ", &gen_pg_template(), "\n";
	}

# test sequential processing for timing baseline
sub do_sequence()
	{
	my $cnt = shift @_;

	foreach ( 1 .. $cnt)

		{
        &service_fork();  # reuse, since no locks or shared resources
		}  # run each "request" in turn

	}

# pretend to do something that would generate some CPU work
sub gen_pg_template
	{
	my $text = "<blah/>";
	foreach ( 1 .. 6)

		{
		$text .= $text;
		}  # cat some crud up to thrash on cache

	return $text;
	}

# *** EOF ***
