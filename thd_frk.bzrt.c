/* Test C forking (in comparison w/ higher level languages) */

#include <sys/wait.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "buzzard-0.1/bzrt_alloc.h"
#include "buzzard-0.1/bzrt_bytes.h"


//    mp_bench - multiprocessing benchmarks for string handling
//
//    Copyright (C) 2009, 2010, Robin R Anderson
//    roboprog@yahoo.com
//    PO 1608
//    Shingle Springs, CA 95682
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

/*
 * a non-local var, for the sake of argument
 * ("a thread would stomp it, unless you are very careful" vs
 * "in your own process space, fire at will!")
 */
static
size_t				local_process_var;

/* fake perl "die" so easier to reuse some code */
static
void                die
    (
    const char *    msg
    )
    {
    fputs( msg, stderr);
    fputc( '\n', stderr);
    exit( 1);
    }

/* bury zombies */
static
void                reaper
    (
    int             signal  // SIGCHLD
    )
    {
    while ( waitpid( -1, NULL, WNOHANG) > 0)
        {}  // nothing to do
    // wait( NULL);
    }

/* pretend to do something that would generate some CPU work */
static
size_t				gen_pg_template
	(
	jmp_buf *		catcher,
	t_stack * *		heap
	)
    {
	size_t			text;
    int             pass;
	size_t			prev;

    // quick & dirty transliteration of string logic:

    text = bzb_from_asciiz( catcher, heap, "<blah/>");
    for ( pass = 0; pass < 6; pass++)

        {
        prev = text;
		text = bzb_concat_to( catcher, heap, text, text);
		bzb_deref( catcher, *heap, prev);
        }  // cat some crud up to thrash on cache

    return text;
    }

/* pretend to provide a useful service for fork testing */
static
void                service_fork()
    {
    time_t          secs;
	jmp_buf			catcher;
	int				is_err;
	t_stack *		heap;
	size_t			pg;
	size_t			srcs[ 4 ];
	size_t			buf;

	is_err = setjmp( catcher);
	if ( ! is_err)
		{
		heap = bza_cons_stack_rt( &catcher, 2048, 1);
		}  // try?
	else
		{
		die( "failed stack/heap creation");
		}  // heap/stack creation failed?

	is_err = setjmp( catcher);
	if ( ! is_err)
		{
		// call non-reentrant routine on global var - safe w/out threading!
		secs = time( NULL);
		local_process_var = bzb_from_asciiz( &catcher, &heap,
				ctime( &secs) );

		pg = gen_pg_template( &catcher, &heap);
		}  // try?
	else
		{
		die( "failed text data creation");
		}  // text creation failed?

	is_err = setjmp( catcher);
	if ( ! is_err)
		{
		// cat into buf, one I/O call

		srcs[ 0 ] = local_process_var;
		srcs[ 1 ] = pg;
		srcs[ 2 ] = bzb_from_asciiz( &catcher, &heap, "\n");
		srcs[ 3 ] = 0;
		buf = bzb_concat( &catcher, &heap, srcs);

		puts( bzb_to_asciiz( &catcher, heap, buf) );
		fflush( stdout);

		// don't bother to dereference buffers here,
		//  as we are just about to toss the containing heap
		}  // try?
	else
		{
		die( "failed to access text data");
		}  // text access failed?

	is_err = setjmp( catcher);
	if ( ! is_err)
		{
		bza_dest_stack( NULL, &heap);
		}  // try?
	else
		{
		die( "failed stack/heap destruction");
		}  // heap/stack destruction failed?

    }

/* test fork based concurrency */
static
void                do_forks
    (
    int             cnt
    )
    {

    // service_fork();

    signal( SIGCHLD, reaper);
    // note:  it *looks* faster to not collect the zombie processes,
    //  but that's kind of cheating, as it shovels unattributed work back to the OS

    while ( ( cnt--) > 0)

        {
        if ( fork() == 0)
            {
            service_fork();
            exit( 0);
            }  // in child process?
        // else:  ignore child PIDs, zombies
        }  // lob off each slave to process "request"

    }

/* test sequential processing for timing baseline */
static
void                do_sequence
    (
    int             cnt
    )
    {

    while ( ( cnt--) > 0)

        {
        service_fork();  // reuse, since no locks or shared resources
        }  // run each "request" in turn

    }

/* main program logic:  spawn crud to see what happens */
int                 main
    (
    int             argc,
    char * *        argv,
    char * *        env
    )
    {
    char            mode;
    int             cnt;

    mode = toupper( argv[ 1 ][ 0 ]);
    cnt = atoi( argv[ 2 ]);
    if ( mode == 'T')
        {
        // &do_threads( $cnt);
        die( "Sorry, threads not implemented yet");
        }  // threads?
    else if ( mode == 'F')
        {
        do_forks( cnt);
        }  // forks?
    else if ( mode == 'S')
        {
        do_sequence( cnt);
        }  // sequential processing?
    else
        {
        die( "Arg 1 must be T (thread), F (fork), or S (sequential)");
        }
    return 0;
    }


/* *** EOF *** */
