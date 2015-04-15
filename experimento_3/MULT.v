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


////////////////////////////////////////////////////////////////////////
/////////// TWO_BITS_LUT_MULT
////////////////////////////////////////////////////////////////////////
// Implements a multiplication of 2 bits, using LUT table implementation
// Multiplies iData_A (16b) with iTWO_BITS_Data_B (2b)
module TWO_BITS_LUT_MULT 
(
input wire [15:0] iData_A, // Input data, 15Bits multiplicand
input wire [1:0] iTWO_BITS_Data_B, // Input data, 2Bits multiplicand
output reg [15:0] oPartial_Result // Result of iData_A*iTWO_BITS_Data_B
);

always @ (*) 
	case (iTWO_BITS_Data_B)
		0: oPartial_Result = 0; // Multiplying by 0, gives 0
		1: oPartial_Result = iData_A; // Multiplying by 1, gives A
		2: oPartial_Result = iData_A >> 1; // Multiplying by 2, gives 2*A -- Multiplying by 2, its the same as a displacement to the left
		3: oPartial_Result = (iData_A >> 1) + iData_A; // Multipliying by 3, gives 3*A = A + 2*A
	endcase
endmodule
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
///// Implementation of a 4BIT multiplication, with LUT
////////////////////////////////////////////////////////////////////////
// Implements a 4bit to 16bit multiplication, using two TWO_BITS_LUT_MULT
// modules. 
module FOUR_BITS_LUT_MULT
(
input wire [15:0] iData_A, // Input data, 15Bits multiplicand
input wire [3:0] iFOUR_BITS_Data_B, // Input data, 4Bits multiplicand
output wire [15:0] oPartial_Result // Result of iData_A*iFOUR_BITS_Data_B
);

// Definitions of wires for partial results:
wire [15:0] lower_bits_result, higher_bits_result;

//// Definition of two modules of 2BIT multiplication with LUT

// Lower bit multiplication
TWO_BITS_LUT_MULT lower_bits_mult
(
	.iData_A( iData_A ),
	.iTWO_BITS_Data_B( iFOUR_BITS_Data_B[1:0] ),
	.oPartial_Result( lower_bits_result )
);

// Higher bits multiplication
TWO_BITS_LUT_MULT higher_bits_mult
(
	.iData_A( iData_A ),
	.iTWO_BITS_Data_B( iFOUR_BITS_Data_B[3:2] ),
	.oPartial_Result( higher_bits_result )
);

//// Definition of the result, based on the partial outputs
// Result is the sum of the lower bits, plus the higher bits with 2 bits shifted
assign oPartial_Result = lower_bits_result + (higher_bits_result << 2);


endmodule
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
///// Implementation of a 8BIT multiplication, with LUT
module EIGHT_BITS_LUT_MULT
(
input wire [15:0] iData_A,
input wire [7:0] iEIGHT_BITS_Data_B,
output wire [15:0] oPartial_Result
);

// Definitions of wires for partial results:
wire [15:0] lower_bits_result, higher_bits_result;

//// Definition of two modules of 2BIT multiplication with LUT

// Lower bit multiplication
FOUR_BITS_LUT_MULT lower_bits_mult
(
	.iData_A( iData_A ),
	.iFOUR_BITS_Data_B( iEIGHT_BITS_Data_B[3:0] ),
	.oPartial_Result( lower_bits_result )
);

// Higher bits multiplication
FOUR_BITS_LUT_MULT higher_bits_mult
(
	.iData_A( iData_A ),
	.iFOUR_BITS_Data_B( iEIGHT_BITS_Data_B[7:4] ),
	.oPartial_Result( higher_bits_result )
);

//// Definition of the result, based on the partial outputs
// Result is the sum of the lower bits, plus the higher bits with 2 bits shifted
assign oPartial_Result = lower_bits_result + (higher_bits_result << 4);


endmodule
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
///// Implementation of a 16BIT multiplication, with LUT
module LUT_MULT
(
input wire [15:0] iData_A,
input wire [15:0] iData_B,
output wire [15:0] oResult
);

// Definitions of wires for partial results:
wire [15:0] lower_bits_result, higher_bits_result;

//// Definition of two modules of 2BIT multiplication with LUT

// Lower bit multiplication
EIGHT_BITS_LUT_MULT lower_bits_mult
(
	.iData_A( iData_A ),
	.iEIGHT_BITS_Data_B( iData_B[7:0] ),
	.oPartial_Result( lower_bits_result )
);

// Higher bits multiplication
EIGHT_BITS_LUT_MULT higher_bits_mult
(
	.iData_A( iData_A ),
	.iEIGHT_BITS_Data_B( iData_B[15:8] ),
	.oPartial_Result( higher_bits_result )
);

//// Definition of the result, based on the partial outputs
// Result is the sum of the lower bits, plus the higher bits with 2 bits shifted
assign oResult = lower_bits_result + (higher_bits_result << 8);


endmodule
////////////////////////////////////////////////////////////////////////

