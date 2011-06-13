/* Test C forking (in comparison w/ higher level languages) */

#include <sys/wait.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include <pthread.h>

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

/* lock for system lib calls not verified to be safe */
static
pthread_mutex_t		sys_lock;

/*
 * a non-local var, for the sake of argument
 * ("a thread would stomp it, unless you are very careful" vs
 * "in your own process space, fire at will!")
 */
static
const char *        local_process_var;

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
// TODO: fix memory leak (or not, since exit() will just toss it out)
static
const char *        gen_pg_template()
    {
    char *          text;
    int             pass;
    char *          prev;
    int             ln;

    // quick & dirty transliteration of string logic:
    //  (ignoring length counter vs terminating sentinel performance differences)

    text = strdup( "<blah/>");
    if ( text == NULL)
        {
        die( "failed memory allocation");
        }  // allocation failed?

    for ( pass = 0; pass < 6; pass++)

        {
        prev = text;
        ln = strlen( prev);
        text = malloc( ( ln * 2) + 1);
        if ( text == NULL)
            {
            die( "failed memory allocation");
            }  // allocation failed?

        memcpy( text, prev, ln);
        memcpy( text + ln, prev, ln);
        text[ ln * 2 ] = '\0';
        free( prev);
        }  // cat some crud up to thrash on cache

    return text;
    }

/* pretend to provide a useful service for fork testing */
static
void                service_fork()
    {
    time_t          secs;
    const char *    pg;
    char *          buf;
    int             tm_ln;
    int             pg_ln;
    char *          buf_off;

    // call non-reentrant routine on global var - safe w/out threading!
    secs = time( NULL);
    local_process_var = ctime( &secs);

    pg = gen_pg_template();

    // strcat into buf, one I/O call
    // now I remember why "we" don't do C any more:
    //  (strcat() would be easier, but I'm trying to milk cycles
    //  as well as avoid multiple I/O calls)

    tm_ln = strlen( local_process_var);
    pg_ln = strlen( pg);
    buf = malloc( tm_ln + pg_ln + 3);  // ' ', '\n' & '\0'
    if ( buf == NULL)
        {
        die( "failed memory allocation");
        }  // allocation failed?

    buf_off = buf;
    memcpy( buf_off, local_process_var, tm_ln);
    buf_off += tm_ln;
    *buf_off = ' ';
    buf_off++;  // increment by itself for clarity, you C sadists, let compiler optomize!
    memcpy( buf_off, pg, pg_ln);
    buf_off += pg_ln;
    *buf_off = '\n';
    buf_off++;
    *buf_off = '\0';
    puts( buf);
    fflush( stdout);

    free( (char *) pg);
    free( buf);
    }

/* pretend to provide a useful service for thread testing */
static
void *				service_thread
	(
	void *			param
	)
	{
    time_t          secs;
    const char *    pg;
    char *          buf;
    int             tm_ln;
    int             pg_ln;
    char *          buf_off;

	// TODO: mutex(es)

    // call non-reentrant routine on global var - safe w/out threading!
    secs = time( NULL);
    local_process_var = ctime( &secs);

    pg = gen_pg_template();

    // strcat into buf, one I/O call
    // now I remember why "we" don't do C any more:
    //  (strcat() would be easier, but I'm trying to milk cycles
    //  as well as avoid multiple I/O calls)

    tm_ln = strlen( local_process_var);
    pg_ln = strlen( pg);
    buf = malloc( tm_ln + pg_ln + 3);  // ' ', '\n' & '\0'
    if ( buf == NULL)
        {
        die( "failed memory allocation");
        }  // allocation failed?

    buf_off = buf;
    memcpy( buf_off, local_process_var, tm_ln);
    buf_off += tm_ln;
    *buf_off = ' ';
    buf_off++;  // increment by itself for clarity, you C sadists, let compiler optomize!
    memcpy( buf_off, pg, pg_ln);
    buf_off += pg_ln;
    *buf_off = '\n';
    buf_off++;
    *buf_off = '\0';
    puts( buf);
    fflush( stdout);

    free( (char *) pg);
    free( buf);
	}

/* test thread based concurrency */
static
void                do_threads
    (
    int             cnt
    )
    {
	pthread_t *		threads;
	int				idx;

	threads = malloc( cnt * sizeof( pthread_t) );
	assert( threads != NULL);
	pthread_mutex_init( &sys_lock, 0);
    for ( idx = 0; idx < cnt; idx++)

        {
		pthread_create( &( threads[ idx ]), NULL, &service_thread, NULL);
        }  // lob off each slave to process "request"

    for ( idx = 0; idx < cnt; idx++)

        {
		pthread_join( threads[ idx ], NULL);
        }  // wait for each slave to complete

	pthread_mutex_destroy( &sys_lock);
	free( threads);
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
        do_threads( cnt);
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
