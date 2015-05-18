////////////////////////////////////////////////////////////////////////
//////	MODULE: Keyboard_Controller									////
////////////////////////////////////////////////////////////////////////

module Keyboard_Controller(
	input wire 		Clock,			// Clock received from keyboard
	input wire 		Reset,			// Reset
	input wire 		iKey_Data_In,	// Data from the keyboard
	output reg [10:0] 	oKey_Data_Out,	// Output data
	output reg			oData_Ready,	// Output to inform data is ready
	input wire			iData_Received	// Input to inform data has been received
);

reg Key_Data_Out_temp;
// Counter
wire [3:0]Counter;


always @(negedge Clock or Reset)
	begin
		if(~Reset)
			
			// ------------------------------------------------------- //
			begin
				Key_Data_Out_temp = (Key_Data_Out_temp >> 1) + iKey_Data_In
				Counter = Counter+1;

				if(Counter == 10)
					begin
						oKey_Data_Out = Key_Data_Out_temp;
						Counter = 4'b0;
						oData_Ready = 1;
					end
				else if (iData_Received)
					oData_Ready = 0;
			end
			// ------------------------------------------------------- //
		else
			// ------ RESET ------- //
			begin
				oKey_Data_Out = 11'b0;
				oData_Ready = 0;
				Counter = 4'b0;
			end
			// -------------------- //
	end

endmodule
