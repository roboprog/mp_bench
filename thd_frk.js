// #!/usr/bin/env jjs -scripting

// Basic demo of writing a JavaScript script,
//  but using Java 1.8 jjs rather than Node.js
//  
//  Usage:
//          basic.js [ -- <<name>> ]
// .....................................

'use strict'

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
	var cnt = Number.parseInt( rt.argv.shift() )
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

main()


// vi: ts=4 sw=4 expandtab ai
// *** EOF ***
