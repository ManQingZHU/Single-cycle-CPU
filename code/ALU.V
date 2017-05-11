`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:23:18 03/21/2017 
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ALU(
		input[31:0] A, B, 
        input[3:0] ALU_operation, 
		output reg[31:0] res, 
		output zero
    );
    
    wire [31:0] res_and, res_or, res_xor, res_nor, res_srl, res_add, res_sub, res_sll;
    reg [31:0] res_slt;
    
	 always @ (*) 
        	case (ALU_operation)
            	4'b0000: res=res_and;	
            	4'b0001: res=res_or;	
            	4'b0010: res=res_add;
		4'b0011: res=res_xor;
		4'b0100: res=res_nor;
		4'b0101: res=res_srl;
            	4'b0110: res=res_sub;
		4'b0111: res=res_slt;
		4'b1000: res=res_sll;
        	endcase

	assign zero = (res == 0);
	
	
	parameter one = 32'h00000001, zero_0 = 32'h00000000;
    
     assign res_and = A&B;
	 assign res_or = A|B;
	 assign res_nor = ~(A | B);
	 assign res_add = A+B;
	 assign res_sub = A-B;
	 assign res_xor = A^B;
	 assign res_srl = A >> B[10:6];
	 assign res_sll = A << B[10:6]; 
	
	always @(*) begin
	 if(A[31]==1 && B[31]==1) // 都是负数
	   res_slt =(A < B) ? zero_0: one;
	else if(A[31]==0 && B[31]==0)
        res_slt =(A < B) ? one : zero_0;   // 都是正数
	else  // 一正一负
		res_slt =(A[31] == 1) ? one : zero_0;
	end
	
	
endmodule
