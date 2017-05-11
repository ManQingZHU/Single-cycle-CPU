`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:08:08 04/05/2017 
// Design Name: 
// Module Name:    OExp05 
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
module OExp05(
	input clk,
	input RSTN,
	input [3:0]BTN_y,
	input [15:0]SW,
	output [4:0]BTN_x,
	output CR,
	output readn,
	output RDY,
	output Buzzer,
	output seg_clk,	//串行移位时钟
	output seg_sout,	//七段显示数据(串行输出)
	output SEG_PEN,	//七段码显示刷新使能
	output seg_clrn,
	output led_clk,          //串行移位时钟
	output led_sout,         //串行输出
	output led_clrn,         //LED显示清零
	output LED_PEN,          //LED显示刷新使能
	output [7:0]LED,
	output [7:0]SEGMENT,
	output [3:0]AN
    );

	assign Buzzer = 1'b1;
	
	wire [15:0]SW_OK;
	wire [3:0]BTN_OK;
	wire rst;
	wire [4:0]Din;
	wire [3:0]Pulse_out;
	
	SAnti_jitter U9(
		.clk(clk), 
		.RSTN(RSTN),
		.readn(readn),
		.Key_y(BTN_y),
		.Key_x(BTN_x),
		.SW(SW), 
		.Key_out(Din),
		.Key_ready(RDY),
		.pulse_out(Pulse_out),
		.BTN_OK(BTN_OK),
		.SW_OK(SW_OK),
		.CR(CR),
		.rst(rst)
	);
	
	wire [31:0]Div;
	wire Clk_CPU;
	
	clk_div U8(
		.clk(clk),
		.rst(rst),
		.SW2(SW_OK[2]),   
		.clkdiv(Div),
		.Clk_CPU(Clk_CPU)
    );
	 
	 wire MIO_ready;
	 wire CPU_MIO;
	 wire counter0_out;
	 wire [31:0]Addr_out;
	 wire [31:0]Data_in;
	 wire [31:0]Data_out;
	 wire [31:0]PC;
	 wire mem_w;
	 wire [31:0] inst;
	 
	 SCPU U1(
		.clk(Clk_CPU),
		.reset(rst),
		.MIO_ready(MIO_ready),
		.inst_in(inst),
		.INT(counter0_out),
		.Data_in(Data_in),
		.mem_w(mem_w),
		.PC_out(PC),
		.Addr_out(Addr_out),
		.Data_out(Data_out),
		.CPU_MIO(CPU_MIO)
	 );
	 
	 wire [31:0]ram_data_in;
	 wire data_ram_we;
	 wire [9:0]ram_addr;
	 wire [31:0]ram_data_out;
	 wire [31:0]CPU2IO;
	 wire GPIOe0000000_we;
	 wire GPIOF0;
	 wire [15:0]LED_out;
	 wire [31:0]counter_out;
	 wire counter2_out;
	 wire counter1_out;
	 wire counter_we;
	 
	 MIO_BUS U4(
		.clk(clk),
		.rst(rst),
		.BTN(BTN_OK),
		.SW(SW_OK),
		.mem_w(mem_w),
		.addr_bus(Addr_out),
		.Cpu_data4bus(Data_in),
		.Cpu_data2bus(Data_out),
		.ram_data_in(ram_data_in),
		.data_ram_we(data_ram_we),
		.ram_addr(ram_addr),
		.ram_data_out(ram_data_out),
		.Peripheral_in(CPU2IO),
		.GPIOe0000000_we(GPIOe0000000_we),
		.GPIOf0000000_we(GPIOF0),
		.led_out(LED_out),
		.counter_out(counter_out),
		.counter2_out(counter2_out),
		.counter1_out(counter1_out),
		.counter0_out(counter0_out),
		.counter_we(counter_we)
	 );
	 
	 
	 wire [31:0]Ai;
	 wire [31:0]Bi;
	 wire [7:0]blink;
	 
	 SEnter_2_32 M4(
		.clk(clk),
		.BTN(BTN_OK[2:0]),				//对应SAnti_jitter列按键
		.Ctrl( {SW_OK[7:5], SW_OK[15], SW_OK[0]} ),				//{SW[7:5],SW[15],SW[0]}
		.D_ready(RDY),					//对应SAnti_jitter扫描码有效
		.Din(Din),
		.readn(readn), 			//=0读扫描码
		.Ai(Ai),	//输出32位数一：Ai
		.Bi(Bi),	//输出32位数二：Bi
		.blink(blink)				//单键输入指示
	);
	
	ROM_D U2(
		.a( PC[11:2] ),
		.spo(inst)
	);
	
	wire [31:0] disp7;
	
	RAM_B U3(
		.clka(~clk),
		.wea(data_ram_we),
		.addra( ram_addr ),
		.dina(ram_data_in),
		.douta(ram_data_out)
	);

	wire [31:0]Disp_num;
	wire [7:0] point_out;
	wire [7:0] blink_out;
	
	SSeg7_Dev U6(
		.clk(clk),			//	时钟
		.rst(rst),			//复位
		.Start(Div[20]),		//串行扫描启动
		.SW0(SW_OK[0]),			//文本(16进制)/图型(点阵)切换
		.flash(Div[25]),		//七段码闪烁频率
		.Hexs(Disp_num),	//32位待显示输入数据
		.point(point_out),	//七段码小数点：8个
		.LES(blink_out),		//七段码使能：=1时闪烁
		.seg_clk(seg_clk),	//串行移位时钟
		.seg_sout(seg_sout),	//七段显示数据(串行输出)
		.SEG_PEN(SEG_PEN),	//七段码显示刷新使能
		.seg_clrn(seg_clrn)	//七段码显示汪零
	);
	wire [1:0]counter_set;
	Counter_x U10(
		.clk(~Clk_CPU),
		.rst(rst),
		.clk0(Div[6]),
		.clk1(Div[9]),
		.clk2(Div[11]),
		.counter_we(counter_we),
		.counter_val(CPU2IO),
		.counter_ch(counter_set),
		.counter0_OUT(counter0_out),
		.counter1_OUT(counter1_out),
		.counter2_OUT(counter2_out),
		.counter_out(counter_out)
	);
	
	
	
	
	wire [63:0]LES={N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,blink[3:0],N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,N0,blink[7:0],blink[7:0] };
	wire N0 = 1'b0;
	
	Multi_8CH32 U5(
		.clk(~Clk_CPU),			//	时钟
		.rst(rst),			//复位
		.EN(GPIOe0000000_we),
		.Test(SW_OK[7:5]),        // select signal
		.point_in({Div[31:0],Div[31:0]}),
		.LES(64'b0),
		.Data0(CPU2IO),
		.data1({N0,N0,PC[31:2]}),
		.data2(inst[31:0]),
		.data3(counter_out),
		.data4(Addr_out),
		.data5(Data_out),
		.data6(Data_in),
		.data7(PC),
		.point_out(point_out),
		.LE_out(blink_out),
		.Disp_num(Disp_num)
	);
	
	wire [13:0]GPIOf0;
	wire[31:0] P_Data = {SW[13:0], SW_OK[15:0], N0,N0};
	
	SPIO U7(
		.clk(~Clk_CPU),			//	时钟
		.rst(rst),			//复位
		.Start(Div[20]),                  //串行扫描启动
		.EN(GPIOf0),                     //PIO/LED显示刷新使能
		.P_Data(CPU2IO),          //并行输入，用于串行输出数据
		.counter_set(counter_set),  //用于计数/定时模块控制，本实验不用
		.LED_out(LED_out),        //并行输出数据
		.led_clk(led_clk),          //串行移位时钟
		.led_sout(led_sout),         //串行输出
		.led_clrn(led_clrn),         //LED显示清零
		.LED_PEN(LED_PEN),          //LED显示刷新使能
		.GPIOf0(GPIOf0)			//待用：GPIO			 
	);
	
	PIO U71(
		.clk(~Clk_CPU),
		.rst(rst),
		.EN(GPIOF0),
		.PData_in(CPU2IO),
		.LED_out(LED)
	);
	
	Seg7_Dev U61(
		.Scan({SW_OK[1], Div[19:18]}),
		.SW0(SW_OK[0]),
		.flash(Div[25]),
		.Hexs(Disp_num),
		.point(point_out),
		.LES(LE_out),
		.SEGMENT(SEGMENT),
		.AN(AN)
	);
	
endmodule 