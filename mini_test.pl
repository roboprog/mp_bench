#!/usr/bin/perl 

# help run a subset of the benchmark tests
# ..........................................

$mode = shift @ARGV;
$size = shift @ARGV;
$repeats= shift @ARGV;
# @CMDS = ( "jjs -scripting thd_frk.js -- ", "node thd_frk.js ", "java ThdFrk ", "./thd_frk.pl " );
@CMDS = @ARGV;

foreach $cmd ( @CMDS ) {
    $sys_cmd = "time $cmd $mode $size > trash.txt";
    print "\n", $sys_cmd, "\n";
    foreach ( 1 .. $repeats ) {
        system( $sys_cmd ); 
    }
}


# vi: ts=4 sw=4 expandtab ai
# *** EOF ***
