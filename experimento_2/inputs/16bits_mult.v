`define MAX_ROWS 16 
`define MAX_COLS 16 

module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire  iData_A [15:0];
input wire  iData_B [15:0];
output wire oResult [31:0];
);


wire[15:0] wCarry [14:0];
wire[15:0] wPartial_Results[14:0];

	genvar CurrentRow, CurrentCol;
	generate
	for ( CurrentCol = 0; CurrentCol < `MAX_COLS; CurrentCol = CurrentCol + 1)
		begin : MUL_ROW
			for ( CurrentRow = 0; CurrentRow < `MAX_ROWS -1; CurrentRow = CurrentCol + 1)
				begin
					///////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Case for the first row 
					if(CurrentRow == 0)
						begin
							if (CurrentCol == `MAX_COLS -1) 
								begin
									// last element of row
									MODULE_ADDER MyAdder
									(
										.iData_A (iData_B[ CurrentRow+1] & iData_A[CurrentCol]),
										.iData_B (0),
										.iData_Ci( wCarry[ CurrentRow ][ CurrentCol-1 ] ),
										.oData_Co( wCarry[ CurrentRow ][ CurrentCol ]),
										.oPartialResult( wPartial_Results[CurrentRow][CurrentCol])
									);
								end
							else if (CurrentCol == 0) 
								begin
									// First element of row
									MODULE_ADDER MyAdder
									(
										.iData_A(iData_B[0] & iData_A[1]),
										.iData_B(iData_B[1] & iData_A[0]),
										.iData_Ci( 0 ),
										.oData_Co( wCarry[ CurrentRow ][ CurrentCol ]),
										.oPartialResult( wPartial_Results[CurrentRow][CurrentCol])
									);
								end
							else
								begin 
									// First element of row
									MODULE_ADDER MyAdder
									(
										.A(iData_B[CurrentRow] & iData_A[CurrentCol+1]),
										.B(iData_B[CurrentRow+1] & iData_A[CurrentCol]),
										.Ci( wCarry[ CurrentRow ][ CurrentCol-1 ] ),
										.Co( wCarry[ CurrentRow ][ CurrentCol]),
									);
								end
						end
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// General Case
					else 
						begin
							if (CurrentCol == `MAX_COLS -1) 
								begin
									// last element of row
									MODULE_ADDER MyAdder
									(
										.iData_A ( iData_B[ CurrentRow+1] & iData_A[CurrentCol]),
										.iData_B ( wCarry[ CurrentRow-1][ CurrentCol ]),
										.iData_Ci( wCarry[ CurrentRow  ][ CurrentCol-1 ] ),
										.oData_Co( wCarry[ CurrentRow  ][ CurrentCol ]),
										.oPartialResult( wPartial_Results[CurrentRow][CurrentCol])
									);
								end
							else if (CurrentCol == 0) 
								begin
									// First element of row
									MODULE_ADDER MyAdder
									(
										.iData_A( wPartial_Results[CurrentRow-1][CurrentCol+1]),
										.iData_B( iData_B[CurrentRow+1] & iData_A[CurrentCol]),
										.iData_Ci( 0 ),
										.oData_Co( wCarry[ CurrentRow ][ CurrentCol ]),
										.oPartialResult( wPartial_Results[CurrentRow][CurrentCol])
									);
								end
							else
								begin 
									// First element of row
									MODULE_ADDER MyAdder
									(
										.iData_A( wPartial_Results[CurrentRow-1][CurrentCol+1]),
										.iData_B( iData_B[CurrentRow+1] & iData_A[CurrentCol]),
										.iData_Ci( wCarry[ CurrentRow ][ CurrentCol-1 ] ),
										.oData_Co( wCarry[ CurrentRow ][ CurrentCol]),
										.oPartialResult( wPartial_Results[CurrentRow][CurrentCol])
									);
								end
						end
						
				end
			assign oResult [CurrentCol+1] = wPartial_Results[CurrentCol][0]; 	
			if(CurrentCol < `MAX_ROWS-2) {
				assign oResult [CurrentCol+17] = wPartial_Results[`MAX_ROWS - 2][CurrentCol+1];
			}
		end
				
	endgenerate
	
	assign oResult [0]  = iData_A[0] & iData_B[0];
	assign oResult [31] = wCarry[14][15];
	
endmodule
