#!/usr/bin/ruby
#
# Test Ruby threads (or other concurrency method)


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

require 'thread.rb'

$local_process_var = nil

$thread_dangerous_var = nil

$mutex = Mutex.new

# pretend to do something that would generate some CPU work
def gen_pg_template
	text = '<blah/>'
	( 1 .. 6).each do ||

		text += text
	end  # cat some crud up to thrash on cache

	return text
end

# service a request which does not need to worry about shared data
def service_fork
	$local_process_var = Time.now
	print $local_process_var.to_s + ' ' + gen_pg_template + "\n"
end

# test sequential processing for timing baseline
def do_sequence( cnt)
	( 1 .. cnt).each do | |

		service_fork();  # reuse, since no locks or shared resources
	end

end

# test fork based concurrency
def do_forks( cnt)

	# zombie reaper
	Signal.trap( 'CHLD', 'IGNORE')

	( 1 .. cnt).each do | |

		fork do
			service_fork  # reuse, since no locks or shared resources
		end
	end  # lob off each slave to process "request"

end

# pretend to provide a useful service for thread testing
def service_thread
	# force a shared data situation, however contrived
	$mutex.synchronize do
		$thread_dangerous_var = Time.now
		print $thread_dangerous_var.to_s + ' ' + gen_pg_template + "\n"
	end
end

# test thread based concurrency
def do_threads( cnt)
	( 1 .. cnt).each do | |

		Thread.new do
			service_thread
		end
	end  # lob off each slave to process "request"

	Thread.list.each do | thd |

		if ( thd != Thread.main)
			thd.join
		end
	end  # wait for each "child" to complete
end

# main program logic:  spawn crud to see what happens
def	main
	mode = ARGV[ 0 ]
	cnt = ARGV[ 1 ].to_i
	if ( mode == 'S')
		do_sequence( cnt)
	elsif ( mode == 'F')
		do_forks( cnt)
	elsif ( mode == 'T')
		do_threads( cnt)
	else
		raise "Arg 1 must be T (thread), F (fork), or S (sequential)"
	end
end

main()
exit 0

# vi: ts=4 sw=4
# *** EOF ***
