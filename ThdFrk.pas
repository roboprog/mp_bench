program ThdFrk;

uses
	baseunix,
	sysutils;

var
	thread_dangerous_var : TDateTime;
	local_process_var : TDateTime;
	mode : string[ 1 ];  // any overflow will simply be truncated silently
	cnt : string[ 7 ];

{ pretend to do something that would generate some CPU work }
function genPgTemplate : AnsiString;
	var
		text : AnsiString;
		cnt : Integer;
	begin
	text := '<blah/>';
	for cnt := 1 to 6 do

		begin
		text := text + text;
		end;  // cat some crud up to thrash on cache

	genPgTemplate := text;
	end;

{ pretend to provide a useful service for fork (or sequential) testing }
procedure service_fork;
	var
		timestamp : String[ 32 ];
	begin
	local_process_var := Now;
	timestamp := DateTimeToStr( local_process_var);  // european format by default  :-)
	writeln( timestamp, ' ', genPgTemplate() );
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
	for idx := 1 to cnt do

		begin
		if ( FpFork = 0) then
			begin
			service_fork();
			Halt;  // === done ===
			end;
		end  // lob off each slave to process "request"

	end;


{ main program logic:  spawn crud to see what happens }
begin
	mode := ParamStr( 1);
	cnt := ParamStr( 2);
	case UpCase( mode[ 1 ]) of
		'T' :
			begin
			Assert( false, 'TODO: threads...');
			// TODO:  see "Clone"
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
	end
end.

// vi: ts=4 sw=4 ai
// ****** EOF *******
