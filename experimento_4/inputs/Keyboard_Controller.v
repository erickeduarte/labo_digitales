module Keyboard_Controller(
	input wire Clock,
	input wire Reset,
	input wire iKey_Data_In,
	output reg [10:0]oKey_Data_Out
);

reg Key_Data_Out_temp;
wire [3:0]Counter;
always @(negedge Clock or Reset)
	begin
		if(~Reset)
		begin
			Key_Data_Out_temp = (Key_Data_Out_temp >> 1) + iKey_Data_In
			Counter = Counter+1;

			if(Counter == 10)
			begin
				oKey_Data_Out = Key_Data_Out_temp;
				Counter=4'b0;
			end
		end
		else
		begin
			oKey_Data_Out = 11'b0;
			Counter = 4'b0;
		end
	end

endmodule
