program ThdFrk;

uses
	sysutils;

var
	mode : string[ 1 ];
	cnt : string[ 7 ];

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
		writeln( 'TODO: serviceSequence()');
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
