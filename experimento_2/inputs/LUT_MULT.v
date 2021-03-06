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
////////////////////////////////////////////////////////////////////////
/////////// LUT2
////////////////////////////////////////////////////////////////////////
// Implements a multiplication of 2 bits, using LUT table implementation
// Multiplies iData_A (16b) with iTWO_BITS_Data_B (2b)
module LUT_4bits 
(
input wire [15:0] iData_A, // Input data, 15Bits multiplicand
input wire [3:0] iFOUR_BITS_Data_B, // Input data, 2Bits multiplicand
output reg [15:0] oPartial_Result // Result of iData_A*iTWO_BITS_Data_B
);

always @ (iFOUR_BITS_Data_B)
	case (iFOUR_BITS_Data_B)
		0: oPartial_Result = 0; // Multiplying by 0, gives 0
		1: oPartial_Result = iData_A; // Multiplying by 1, gives A
		2: oPartial_Result = iData_A >> 1; // Multiplying by 2, gives 2*A -- Multiplying by 2, its the same as a displacement to the left
		3: oPartial_Result = (iData_A >> 1) + iData_A; // Multipliying by 3, gives 3*A = A + 2*A
		4: oPartial_Result = (iData_A >> 2); // Multiplying by 4 is shifting two bits to the left
		5: oPartial_Result = (iData_A >> 2) + iData_A; // 5*A = 4*A + A = A>>2 + A
		6: oPartial_Result = (iData_A >> 1) + (iData_A >> 2); // 6*A = 4*A + 2*A = A>>2 + A>>1
		7: oPartial_Result = (iData_A >> 1) + (iData_A >> 2) + iData_A; // 7*A = 6*A + A =  A>>2 + A>>1 + A
		8: oPartial_Result = (iData_A >> 3);
		9: oPartial_Result = (iData_A >> 3) + iData_A;
		10: oPartial_Result = (iData_A >> 3) + (iData_A >>1);
		11: oPartial_Result = (iData_A >> 3) + (iData_A >>1) + iData_A;
		12: oPartial_Result = (iData_A >> 3) + (iData_A >>2);
		13: oPartial_Result = (iData_A >> 3) + (iData_A >>2) + iData_A;
		14: oPartial_Result = (iData_A >> 3) + (iData_A >>2) + (iData_A>>1);
		15: oPartial_Result = (iData_A >> 3) + (iData_A >>2) + (iData_A>>1) + iData_A;
	endcase 
endmodule 

module LUT_2
(
input wire [15:0] iData_A, // Input data, 16Bits multiplicand
input wire [15:0] iData_B, // Input data, 15Bits multiplicand
output wire [15:0] oResult // Result of iData_A*iTWO_BITS_Data_B
);
wire [15:0] oPartial_Results [3:0];
	genvar index;
	generate
		for ( index = 0; index < 15; index = index + 4)
			begin : MUL_COL
				LUT_4bits myLUT 
				(
				.iData_A(iData_A),
				.iFOUR_BITS_Data_B(iData_B[index+3:index]),
				.oPartial_Result(oPartial_Results[(index/4)])
				);
			end
	endgenerate
// Output definitions
assign oResult = (oPartial_Results[0]) + (oPartial_Results[1] >> 4) + (oPartial_Results[2] >> 8) + (oPartial_Results[3] >> 12);
endmodule
