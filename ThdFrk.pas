program ThdFrk;

uses
	sysutils;

var
	mode : string[ 1 ];
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

{ pretend to provide a useful service for sequential testing }
procedure serviceSequence;
	var
		timestamp : String[ 32 ];
	begin
	// timestamp = threadDangerousVar.format( new Date() );
	timestamp := 'TODO: timestamp';
	writeln( timestamp, ' ', genPgTemplate() );
	end;

{ test sequential processing for timing baseline }
procedure doSequence
	(
	cnt : Integer
	);
	var
		idx : Integer;
	begin
	for idx := 1 to cnt do

		begin
		serviceSequence();
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
			end;
		'F' :
			begin
			Assert( false, 'TODO: forks...');
			end;
		'S' :
			begin
            doSequence( StrToInt( cnt) );
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
