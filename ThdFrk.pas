program ThdFrk;

var
	mode : string[ 1 ];
	cnt : string[ 7 ];

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
			writeln( 'TODO: sequential...');
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
