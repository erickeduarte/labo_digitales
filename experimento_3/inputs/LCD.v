`timescale 1ns / 1ps
`define STATE_RESET 			0
`define STATE_POWERON_INIT_0 	1
`define STATE_POWERON_INIT_1 	2
`define STATE_POWERON_INIT_2 	3
`define STATE_POWERON_INIT_3 	4
`define STATE_POWERON_INIT_4 	5
`define STATE_POWERON_INIT_5 	6
`define STATE_POWERON_INIT_6 	7
`define STATE_POWERON_INIT_7 	8
`define STATE_POWERON_INIT_8 	9
`define FUNCTION_SET_UPPER_BITS	10
`define FUNCTION_SET_LOWER_BITS	11
`define ENTRY_MODE_UPPER_BITS	12
`define ENTRY_MODE_LOWER_BITS	10
	
module Module_LCD_Control
(
	input wire Clock,
	input wire Reset,
	output wire oLCD_Enabled,
	output reg oLCD_RegisterSelect, //0=Command, 1=Data
	output wire oLCD_StrataFlashControl,
	output wire oLCD_ReadWrite,
	output reg[3:0] oLCD_Data
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Variables
reg rWrite_Enabled;						// Enable
assign oLCD_ReadWrite = 0; 			// I only Write to the LCD display, never Read from it
assign oLCD_StrataFlashControl = 1; 	// StrataFlash disabled. Full read/write access to LCD
reg [7:0] rCurrentState,rNextState;		// Current and NextState 
reg [31:0] rTimeCount;					// Time counter
reg rTimeCountReset;					// Reset time counter
wire wWriteDone;						// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------//
//	Next State and delay logic
always @ ( posedge Clock )
begin
	if (Reset)
		begin
			CurrentState = `STATE_RESET;
			rTimeCount <= 32'b0;
		end
	else
		begin
			// Time increasing logic
			if (rTimeCountReset)
				rTimeCount <= 32'b0;
			else
				rTimeCount <= rTimeCount + 32'b1;
			// Move on to next state
			rCurrentState <= rNextState;
	end
end
//----------------------------------------------------------------------//


//----------------------------------------------------------------------//
//Current state and output logic
always @ ( * )
begin
	case (rCurrentState)
		//--------------------------------------------------------------
		/*
			Resets the state machine. Sets all signals to 0.
		*/
		`STATE_RESET:
			begin
				rWrite_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0;
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_0;
			end
		//--------------------------------------------------------------
		/*
			Wait 15 ms or longer.
			The 15 ms interval is 750,000 clock cycles at 50 MHz.
		*/
		`STATE_POWERON_INIT_0:
			begin
				rWrite_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0; //these are commands

				if (rTimeCount > 32'd750000 )
					begin
						rTimeCountReset = 1'b1;
						rNextState = `STATE_POWERON_INIT_1;
					end
				else
					begin
						rTimeCountReset = 1'b0;
						rNextState = `STATE_POWERON_INIT_0;
				end
			end
		//--------------------------------------------------------------
		/*
			Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
		*/
		`STATE_POWERON_INIT_1:
			begin
				rWrite_Enabled = 1'b1;
				oLCD_Data = 4'h3;
				oLCD_RegisterSelect = 1'b0; //these are commands
				rTimeCountReset = 1'b1;
				// Loop 
				if ( wWriteDone )
					rNextState = `STATE_POWERON_INIT_2;
				else
					rNextState = `STATE_POWERON_INIT_1;
			end
		//--------------------------------------------------------------
		/*
			Wait 4.1 ms or longer, which is 205,000 clock cycles at 50 MHz.
		*/
		`STATE_POWERON_INIT_2:
			begin
				rWrite_Enabled = 1'b0;
				LCD_Data = 4'h3;
				oLCD_RegisterSelect = 1'b0; //these are commands
				if (rTimeCount > 32'd205000 )
					begin
						rTimeCountReset = 1'b1;
						rNextState = `STATE_POWERON_INIT_3;
					end
				else
					begin
						rTimeCountReset = 1'b0;
						rNextState = `STATE_POWERON_INIT_2;
					end
			end
		//--------------------------------------------------------------
		//--------------------------------------------------------------
		`FUNCTION_SET_UPPER_BITS:
		/*
			Function Set Up:
				Sends 0x28 though a 8bit-write method. Sends upper bits, 
				then lower bits. 
				
			Upper Bits:
				Sends 0x2, and keeps rWrite_Enabled = 1, through 15 cycles, then
				lowers it and waits for >1us (60 cycles ~ 1.2us)
		*/
			begin
				if (rTimeCount < 32'd'15 ) 		// First 15 cycles -> Send first data
					begin
						rTimeCountReset = 1'b0; // Keep counting
						rWrite_Enabled = 1'b1;	// Write data 0x2
						oLCD_Data = 4'h2;		// Write data 0x2
						oLCD_RegisterSelect = 1'b0; //these are commands
						rNextState = `FUNCTION_SET_UPPER_BITS;
					end
				else if( rTimeCount < 32'd'75 ) 	// Wait 1.2us (counting the first 15 cycles).
					begin
						rTimeCountReset = 1'b0;		// Keep counting
						rWrite_Enabled = 1'b0;		// We are waiting
						oLCD_RegisterSelect = 1'b0; // These are commands
						rNextState = `FUNCTION_SET_UPPER_BITS; // Keep looping
					end
				else 	// Move on to next state
					begin
						rTimeCountReset = 1'b1; 	// Reset timer
						rWrite_Enabled = 1'b0;  	// Not enabled 
						oLCD_RegisterSelect = 1'b0; // These are commands 
						rNextState = `FUNCTION_SET_LOWER_BITS; // Next state to sent lower bits
					end
			end
		//--------------------------------------------------------------
		//--------------------------------------------------------------
		`FUNCTION_SET_LOWER_BITS:
		/*
			Function Set Up:
				Sends 0x28 though a 8bit-write method. Sends upper bits, 
				then lower bits. 
				
			LOWER Bits:
				Sends 0x8, and keeps rWrite_Enabled = 1, through 15 cycles, then
				lowers it and waits for >40us (2050 cycles ~ 41us)
		*/
			begin
				if (rTimeCount < 32'd'15 ) 		// First 15 cycles -> Send first data
					begin
						rTimeCountReset = 1'b0; // Keep counting
						rWrite_Enabled = 1'b1;	// Write data 0x8
						oLCD_Data = 4'h8;		// Write data 0x8
						oLCD_RegisterSelect = 1'b0; //these are commands
						rNextState = `FUNCTION_SET_LOWER_BITS;
					end
				else if( rTimeCount < 32'd'2065 ) 	// Wait 41us (counting the first 15 cycles).
					begin
						rTimeCountReset = 1'b0;		// Keep counting
						rWrite_Enabled = 1'b0;		// We are waiting
						oLCD_RegisterSelect = 1'b0; // These are commands
						rNextState = `FUNCTION_SET_LOWER_BITS; // Keep looping
					end
				else 	// Move on to next state
					begin
						rTimeCountReset = 1'b1; 	// Reset timer
						rWrite_Enabled = 1'b0;  	// Not enabled 
						oLCD_RegisterSelect = 1'b0; // These are commands 
						rNextState = `FUNCTION_SET_LOWER_BITS; // Next state to sent lower bits
					end
			end
		default:
			begin
				rWrite_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0;
				rTimeCountReset = 1'b0;
				rNextState = `STATE_RESET;
			end
		//------------------------------------------
	endcase
end
endmodule
