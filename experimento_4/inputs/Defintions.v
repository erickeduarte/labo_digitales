`timescale 1ns / 1ps
`ifndef DEFINTIONS_V
`define DEFINTIONS_V
	
`default_nettype none	
`define NOP   	4'd0
`define LED   	4'd2
`define BLE   	4'd3
`define STO 	4'd4
`define ADD 	4'd5
`define SUB		4'd6
`define JMP		4'd7
`define MUL		4'd8
`define BNLCD	4'd9
`define LCD		4'd10
//`define CALL	4'd11
`define CPY		4'd11
//`define RET	4'd12

`define VGA		4'd13
`define BKEY	4'd14
`define KEY	4'd15



`define R0 8'd0
`define R1 8'd1
`define R2 8'd2
`define R3 8'd3
`define R4 8'd4
`define R5 8'd5
`define R6 8'd6
`define R7 8'd7

// Color Definition
`define COLOR_BLACK 	3'b000
`define COLOR_BLUE 		3'b001
`define COLOR_GREEN 	3'b010
`define COLOR_CYAN 		3'b011
`define COLOR_RED 		3'b100
`define COLOR_MAGENTA 	3'b101
`define COLOR_YELLOW 	3'b110
`define COLOR_WHITE 	3'b111

`endif
