`define MAX_ROWS 16 
`define MAX_COLS 16 

module LMUL 
(
input wire [15:0] iData_A ,
input wire [15:0] iData_B ,
output wire [31:0] oResult 
);


wire[15:0] wCarry [14:0];
wire[15:0] wPartial_Results[14:0];

	genvar CurrentRow, CurrentCol;
	generate
	for ( CurrentCol = 0; CurrentCol < `MAX_COLS; CurrentCol = CurrentCol + 1)
		begin : MUL_COL
			for ( CurrentRow = 0; CurrentRow < `MAX_ROWS -1; CurrentRow = CurrentRow + 1)
				begin : MUL_ROW
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
										.iData_A(iData_B[CurrentRow] & iData_A[CurrentCol+1]),
										.iData_B(iData_B[CurrentRow+1] & iData_A[CurrentCol]),
										.iData_Ci( wCarry[ CurrentRow ][ CurrentCol-1 ] ),
										.oData_Co( wCarry[ CurrentRow ][ CurrentCol]),
										.oPartialResult( wPartial_Results[CurrentRow][CurrentCol])
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
			if(CurrentCol < 15)
				begin
					assign oResult [CurrentCol+1] = wPartial_Results[CurrentCol][0]; 	
					assign oResult [CurrentCol+16] = wPartial_Results[`MAX_ROWS - 2][CurrentCol+1];
				end
		end
				
	endgenerate
	
	assign oResult [0]  = iData_A[0] & iData_B[0];
	assign oResult [31] = wCarry[14][15];
	
endmodule
