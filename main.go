package main

import (
	"fmt"
	"os"
	// "strings"
	"strconv"
)

/* main program logic:  spawn crud to see what happens */
func main() {
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
func do_sequence( cnt int) {
    for ; cnt > 0; cnt-- {
        service_fork();  // just in case faking a fork becomes practical
	}  // run each "request" in turn

}

/* pretend to provide a useful service for fork testing */
func service_fork() {

	// TODO:  get timestamp

	pg := "TODO"  // TODO: page template function

	buf := pg + "\n"  // TODO: prepend / append stuff

	fmt.Print( buf)
	os.Stdout.Sync()

}


// *** EOF ****
