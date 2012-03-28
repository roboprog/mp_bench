program ThdFrk;

uses
	cthreads,  // this has to be first, per manual (when using threads)
	cmem,  // supposed to be faster with threading
	baseunix,
	sysutils;

var
	output : TextFile;  // can't write to console from a thread
	thread_lock : TRTLCriticalSection;
	thread_dangerous_var : TDateTime;
	local_process_var : TDateTime;
	mode : string[ 1 ];  // any overflow will simply be truncated silently
	cnt : string[ 7 ];

{ pretend to do something that would generate some CPU work }
function gen_pg_template : AnsiString;
	var
		text : AnsiString;
		cnt : Integer;
	begin
	text := '<blah/>';
	for cnt := 1 to 6 do

		begin
		text := text + text;
		end;  // cat some crud up to thrash on cache

	gen_pg_template := text;
	end;

{ pretend to provide a useful service for fork (or sequential) testing }
procedure service_fork;
	var
		timestamp : String[ 32 ];
	begin
	local_process_var := Now;
	timestamp := DateTimeToStr( local_process_var);  // european format by default  :-)
	writeln( timestamp, ' ', gen_pg_template() );
	end;

{ test sequential processing for timing baseline }
procedure do_sequence
	(
	cnt : Integer		// how many times to repeat the output
	);
	var
		idx : Integer;
	begin
	for idx := 1 to cnt do

		begin
		service_fork();
		end  // lob off each slave to process "request"

	end;

{ test fork based concurrency }
procedure do_forks
	(
	cnt : Integer		// how many times to repeat the output
	);
	var
		idx : Integer;
	begin
	FpSigAction( SigChld, nil, nil);
	// FpSignal( SigChld, SIG_IGN);
	for idx := 1 to cnt do

		begin
		if ( FpFork = 0) then
			begin
			service_fork();
			Halt;  // === done ===
			end;
		end  // lob off each slave to process "request"

	end;

{ pretend to provide a useful service for thread testing }
function service_thread
	(
	args : pointer
	) : ptrint;
	// var
	begin
	EnterCriticalSection( thread_lock);
	// writeln( 'TODO'); - ignored within a non-main thread, unfortunately
	writeln( output, 'TODO');
	Flush( output);
	LeaveCriticalSection( thread_lock);
	// TODO: post "done" message
	service_thread := 0;
	end;

{ test thread based concurrency }
procedure do_threads
	(
	cnt : Integer		// how many times to repeat the output
	);
	var
		idx : Integer;
	begin
	for idx := 1 to cnt do

		begin
		BeginThread( @service_thread);
		writeln( 'TODO: make thread ', idx, ' do something');
		end;  // lob off each slave to process "request"

	// TODO:  receive and count "done" messages
	end;


{ main program logic:  spawn crud to see what happens }
begin
	Assign( output, 'fp.out.txt');
	InitCriticalSection( thread_lock);
	Rewrite( output);
	mode := ParamStr( 1);
	cnt := ParamStr( 2);
	case UpCase( mode[ 1 ]) of
		'T' :
			begin
			do_threads( StrToInt( cnt) );
			end;
		'F' :
			begin
			do_forks( StrToInt( cnt) );
			end;
		'S' :
			begin
			do_sequence( StrToInt( cnt) );
				// StrToInt is FreePascal extension  --
				// GNU Pascal integer conversion is brain damaged
			end;
		otherwise
			begin
			Assert( false,
					'Arg 1 must be T (thread), F (fork), or S (sequential)');
			end
	end;
	DoneCriticalSection( thread_lock);
	Close( output);
end.

// vi: ts=4 sw=4 ai
// ****** EOF *******
