// #!/usr/bin/env jjs -scripting

// Basic demo of writing a JavaScript script,
//  but using Java 1.8 jjs rather than Node.js
//  
//  Usage:
//          basic.js [ -- <<name>> ]
// .....................................

'use strict'

var thread_dangerous_var
var local_process_var

/** somewhat portable runtime setup */
var rt = ( function () {
    var rt

    if ( typeof Java === 'undefined' ) {
        // assume Node
        rt = { argv: process.argv, out: console.log }
        rt.argv.shift( null )  // remove "node" from cmd line
        return rt
    }

    // assume Nashorn (jjs -scripting <<script>> -- ...)
    rt = { argv: $ARG, out: print }
    rt.argv.unshift( null )  // no meaninful argv[0] for Nashorn
    return rt
} )()

/** main program logic:  spawn crud to see what happens */
var main = function()
    {
    rt.argv.shift()  // toss prog name
	var mode = rt.argv.shift().toUpperCase()
	var cnt = new Number( rt.argv.shift() )
/*
	if ( uc( $mode) eq 'T')
        {
		&do_threads( $cnt);
		}  # threads?
	elsif ( uc( $mode) eq 'F')
		{
		&do_forks( $cnt);
		}  # forks?
*/
	if ( mode === 'S' )
		{
		do_sequence( cnt )
		}  // sequential?
	else
		{
		throw new Error( "Arg 1 must be T (thread), F (fork), or S (sequential)" )
		}
    }

/** test sequential processing for timing baseline */
var do_sequence = function ( cnt )
	{
	for ( ; cnt > 0; cnt -- )

		{
        service_fork()  // reuse, since no locks or shared resources
		}  // run each "request" in turn

	}

/** pretend to provide a useful service for fork testing */
var service_fork = function ()
	{
	local_process_var = new Date()
	rt.out( local_process_var + " " + gen_pg_template() )
	}

/** pretend to do something that would generate some CPU work */
var gen_pg_template = function ()
	{
    var idx

	var text = "<blah/>"
	for ( idx = 0; idx < 6; idx ++ )

		{
		text += text
		}  // cat some crud up to thrash on cache

	return text
	}

main()


// vi: ts=4 sw=4 expandtab ai
// *** EOF ***
