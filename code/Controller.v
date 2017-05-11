`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:20:14 04/09/2017 
// Design Name: 
// Module Name:    Control 
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
module Controller( input [5:0]opcode,
					 input [5:0]func,
					 output reg [1:0]RegDst,
					 output reg [1:0]Jump,
					 output reg [1:0]Branch,
					 output reg RegSrc,
					 output reg MemRead,
					 output reg [1:0]Mem2Reg,
					 output reg MemWrite,
					 output reg [1:0]ALUSrc,
					 output reg RegWrite,
					 output reg [3:0]ALUop
    );
	 
	 always@(*)
		if(opcode==6'b000000&&func==6'b100100)//and
		begin
			ALUop<=4'b0000; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b100101)//or
		begin
			ALUop<=4'b0001; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00;
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b100000)//add
		begin
			ALUop<=4'b0010; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b100110)//xor
		begin
			ALUop<=4'b0011; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b100111)//nor
		begin
			ALUop<=4'b0100; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b100010)//sub
		begin
			ALUop<=4'b0110; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b101010)//slt
		begin
			ALUop<=4'b0111; RegSrc<=1'b0; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b000010)//srl
		begin
			ALUop<=4'b0101; RegSrc<=1'b1; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<=1'b0; ALUSrc<=2'b01; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b000000)//sll
		begin
			ALUop<=4'b1000; RegSrc<=1'b1; RegDst<=2'b00; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<= 1'b0; ALUSrc<=2'b01; RegWrite<=1'b1;
		end
		else if(opcode==6'b000000&&func==6'b001000)//jr
		begin
								RegSrc<=1'b0; 						Jump<=2'b01; Branch<=2'b00;				   
			MemRead<=1'b0; 						MemWrite<=1'b0; 					RegWrite<=1'b0;
		end
		else if(opcode==6'b100011)//lw
		begin
			ALUop<=4'b0010; RegSrc<=1'b0; RegDst<=2'b01; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b1; Mem2Reg<=2'b01; MemWrite<=1'b0; ALUSrc<=2'b10; RegWrite<=1'b1;
		end
		else if(opcode==6'b101011)//sw
		begin
			ALUop<=4'b0010; RegSrc<=1'b0; 					Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; 						MemWrite<=1'b1; ALUSrc<=2'b10; RegWrite<=1'b0;			
		end
		else if(opcode==6'b000100)//beq
		begin
			ALUop<=4'b0110; RegSrc<=1'b0; 					Jump<=2'b00; Branch<=2'b01; 
			MemRead<=1'b0; 						MemWrite<= 1'b0; ALUSrc<=2'b00; RegWrite<=1'b0;
		end
		else if(opcode==6'b000101)//bne
		begin
			ALUop<=4'b0110; RegSrc<=1'b0; 					Jump<=2'b00; Branch<=2'b11; 
			MemRead<=1'b0; 						MemWrite<=1'b0; ALUSrc<=2'b00; RegWrite<=1'b0;
		end
		else if(opcode==6'b001000)//addi
		begin
			ALUop<=4'b0010; RegSrc<=1'b0; RegDst<=2'b01; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<=1'b0; ALUSrc<=2'b10; RegWrite<=1'b1;
		end
		else if(opcode==6'b001101)//ori
		begin
			ALUop<=4'b0001; RegSrc<=1'b0; RegDst<=2'b01; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b00; MemWrite<=1'b0; ALUSrc<=2'b11; RegWrite<=1'b1;
		end
		else if(opcode==6'b001111)//lui
		begin
													RegDst<=2'b01; Jump<=2'b00; Branch<=2'b00; 
			MemRead<=1'b0; Mem2Reg<=2'b11; MemWrite<=1'b0; 					RegWrite<=1'b1;			
		end
		else if(opcode==6'b000010)//j
		begin
																		Jump<=2'b11; Branch<=2'b00;				   
			MemRead<=1'b0; 					  MemWrite<=1'b0; 					RegWrite<=1'b0;
		end
		else if(opcode==6'b000011)//jal
		begin
													RegDst<=2'b10; Jump<=2'b11; Branch<=2'b00;					
			MemRead<=1'b0; Mem2Reg<=2'b10; MemWrite<=1'b0;						RegWrite<=1'b1;
		end
		
endmodule
