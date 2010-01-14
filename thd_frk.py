#!/usr/bin/python


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

import sys
import os
import signal
# import thread - 2.6, but not 2.5?
import threading
import datetime

# pretend to do something that would generate some CPU work
def gen_pg_template():
	text = "<blah/>"
	for num in xrange( 6):

		text += text

	return text

# do something on the thread
def service_thread():
	# force a shared data situation, however contrived
	lock.acquire()
	local_process_var = datetime.datetime.today()
	lock.release()

	print local_process_var, " ", gen_pg_template()
	return

# run a test using threads
def do_threads( cnt):
	for unused in xrange( cnt):
		# thread.start_new_thread( service_thread)
		threading.Thread( target=service_thread).start()
	return

# do something on child process
def service_fork():
	local_process_var = datetime.datetime.today()
	print local_process_var, " ", gen_pg_template()
	return

# run a test using fork
def do_forks( cnt):
	signal.signal( signal.SIGCHLD,signal.SIG_IGN)
	for unused in xrange( cnt):
		if not os.fork():
			service_fork()
			exit( 0)
	return

# test sequential processing for timing baseline
def do_sequence( cnt):
	for unused in xrange( cnt):
		service_fork()  # reuse, since no locks or shared resources
	return

mode = sys.argv[ 1 ]
cnt = int( sys.argv[ 2 ])
if mode == 'T':
	lock = threading.Lock()
	do_threads( cnt)
elif mode == 'F':
	do_forks( cnt)
elif mode == 'S':
	do_sequence( cnt)
else:
	raise Exception( 'Arg 1 must be T (thread), F (fork), or S (sequential)' )

# ****** EOF ******
