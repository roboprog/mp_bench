package main

//    mp_bench - multiprocessing benchmarks for string handling
//
//    Copyright (C) 2009 - 2013, Robin R Anderson
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

import (
	"fmt"
	"os"
	// "strings"
	"strconv"
	"time"
)

var (
	/** non-reentrant data/code */
	thread_dangerous_var = func (
			) string {
		secs := time.Now()
		return secs.Format( "01/02/06 03:04 PM")  // digits are places from majik timestamp "Mon Jan 2 15:04:05 -0700 MST 2006"
	}
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
    timestamp := thread_dangerous_var()

	buf := timestamp + " " + gen_pg_template() + "\n"

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
