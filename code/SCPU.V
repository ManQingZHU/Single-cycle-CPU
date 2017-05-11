`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:12:17 04/05/2017 
// Design Name: 
// Module Name:    SCPU 
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
module SCPU(
				input clk,			
				input reset,
				input MIO_ready,				
				input [31:0]inst_in,//instruction
				input [31:0]Data_in,			
				output mem_w,					
				output reg [31:0]PC_out,//program counter
				output[31:0]Addr_out,
				output[31:0]Data_out, 
				output CPU_MIO,
				input INT
				);
	reg [31:0]PC;
	initial PC = 32'b0;
	
	always@(posedge clk)
		PC_out <= PC;
	
	wire [31:0]PC_Add_4;
	assign PC_Add_4=PC_out+4;
	
	wire [1:0]RegDst;
	wire [1:0]Jump;
	wire [1:0]Branch;
	wire RegSrc;
	wire MemRead;
	wire [1:0]Mem2Reg;
	wire [1:0]ALUSrc;
	wire RegWrite;
	wire [3:0]ALUop;
	
	Controller M0(
		.opcode(inst_in[31:26]),
		.func(inst_in[5:0]),
		.RegDst(RegDst),
		.Jump(Jump),
		.Branch(Branch),
		.RegSrc(RegSrc),
		.MemRead(MemRead),
		.Mem2Reg(Mem2Reg),
		.MemWrite(mem_w),
		.ALUSrc(ALUSrc),
		.RegWrite(RegWrite),
		.ALUop(ALUop)
	);

	reg [4:0]rs;
	reg [4:0]rd;
	reg [31:0]RegData_in;
	wire [31:0]RegData_outA;
	wire [31:0]RegData_outB;
	reg [31:0]ALU_inB;
	wire [31:0]SignExt;
	wire zero;
	
	assign SignExt=(inst_in[15]==1)?({16'b1111111111111111,inst_in[15:0]}):({16'b0000000000000000,inst_in[15:0]});
	
	RegFile M2(
		.clk(clk),
		.rst(rst),
		.L_S(RegWrite),
		.R_addr_A(rs),
		.R_addr_B(inst_in[20:16]),
		.Wt_addr(rd),
		.Wt_data(RegData_in),
		.rdata_A(RegData_outA),
		.rdata_B(RegData_outB)
	);

	
	ALU M3(
		.ALU_operation(ALUop),
		.A(RegData_outA),
		.B(ALU_inB),
		.res(Addr_out),
		.zero(zero)
	);
	
	assign Data_out=RegData_outB;
	
	wire [31:0]PC_Branch;
    assign PC_Branch=PC_Add_4+({SignExt[29:0],2'b0});
	
	wire [31:0]PC_Jump;
	assign PC_Jump=({PC_Add_4[31:28],inst_in[25:0],2'b0});
	
	always@(*)
	begin
		if(RegSrc==1'b0)
			rs<=inst_in[25:21];
		else 
			rs<=inst_in[20:16];
			
		if(RegDst==2'b00)
			rd<=inst_in[15:11];
		else if(RegDst==2'b01)
			rd<=inst_in[20:16];
		else if(RegDst==2'b10)
			rd<=5'b11111;
		
		if(ALUSrc==2'b00)
			ALU_inB<=RegData_outB;
		else if(ALUSrc==2'b01)
			ALU_inB<=inst_in;
		else if(ALUSrc==2'b10)
			ALU_inB<=SignExt;
		else 
			ALU_inB<=({16'b0,inst_in[15:0]});
		
		if(Mem2Reg==2'b00)
			RegData_in<=Addr_out;
		else if(Mem2Reg==2'b01)
			RegData_in<=Data_in;
		else if(Mem2Reg==2'b10)
			RegData_in<=PC_Add_4;
		else 
			RegData_in<={inst_in[15:0],16'b0};
			
		if(Jump==2'b01)
			PC<=RegData_outA;
		else if(Jump==2'b11)
			PC<=PC_Jump;
        else if(Jump==2'b00 && Branch==2'b01 && zero==1'b1 )
            PC <=PC_Branch;
        else if(Jump==2'b00 && Branch==2'b11 && zero==1'b0 )
            PC <=PC_Branch;
        else PC <=PC_Add_4;    
	end
	
	
	
endmodule
