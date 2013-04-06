package main

import (
	"fmt"
	"os"
	// "strings"
	"strconv"
	"time"
)

var (
	/*
	 * a non-local var, for the sake of argument
	 * ("a thread would stomp it, unless you are very careful" vs
	 * "in your own process space, fire at will!")
	 */
	local_process_var string
)

/* main program logic:  spawn crud to see what happens */
func main(
		) {
	mode := os.Args[ 1 ]
    cnt, _ := strconv.Atoi( os.Args[ 2 ]);  // ignore error
	if mode == "S" {
        do_sequence( cnt);
	} else {
		panic( fmt.Sprintf(
				"Arg 1 must be T (thread), F (fork), or S (sequential)," +
				" not \"%s\"", mode) );
	}
}

/* test sequential processing for timing baseline */
func do_sequence(
		cnt int) {  // how many times to run make-work
    for ; cnt > 0; cnt-- {
        service_fork();  // just in case faking a fork becomes practical
	}  // run each "request" in turn

}

/* pretend to provide a useful service for fork testing */
func service_fork(
		) {

    // call non-reentrant routine on global var - safe w/out threading!
    secs := time.Now()
    local_process_var = secs.Format( "01/02/06 03:04 PM")  // digits are places from majik timestamp "Mon Jan 2 15:04:05 -0700 MST 2006"

	pg := gen_pg_template()
	buf := local_process_var + " " + pg + "\n"

	fmt.Print( buf)
	// do not flush
}

/* pretend to do something that would generate some CPU work */
func gen_pg_template(
		) string {
    text := "<blah/>"
    for pass := 0; pass < 6; pass++ {
		text += text
	}  // cat some crud up to thrash on cache

    return text
}


// *** EOF ****
