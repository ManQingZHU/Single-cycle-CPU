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
	output seg_clk,	//������λʱ��
	output seg_sout,	//�߶���ʾ����(�������)
	output SEG_PEN,	//�߶�����ʾˢ��ʹ��
	output seg_clrn,
	output led_clk,          //������λʱ��
	output led_sout,         //�������
	output led_clrn,         //LED��ʾ����
	output LED_PEN,          //LED��ʾˢ��ʹ��
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
		.BTN(BTN_OK[2:0]),				//��ӦSAnti_jitter�а���
		.Ctrl( {SW_OK[7:5], SW_OK[15], SW_OK[0]} ),				//{SW[7:5],SW[15],SW[0]}
		.D_ready(RDY),					//��ӦSAnti_jitterɨ������Ч
		.Din(Din),
		.readn(readn), 			//=0��ɨ����
		.Ai(Ai),	//���32λ��һ��Ai
		.Bi(Bi),	//���32λ������Bi
		.blink(blink)				//��������ָʾ
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
		.clk(clk),			//	ʱ��
		.rst(rst),			//��λ
		.Start(Div[20]),		//����ɨ������
		.SW0(SW_OK[0]),			//�ı�(16����)/ͼ��(����)�л�
		.flash(Div[25]),		//�߶�����˸Ƶ��
		.Hexs(Disp_num),	//32λ����ʾ��������
		.point(point_out),	//�߶���С���㣺8��
		.LES(blink_out),		//�߶���ʹ�ܣ�=1ʱ��˸
		.seg_clk(seg_clk),	//������λʱ��
		.seg_sout(seg_sout),	//�߶���ʾ����(�������)
		.SEG_PEN(SEG_PEN),	//�߶�����ʾˢ��ʹ��
		.seg_clrn(seg_clrn)	//�߶�����ʾ����
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
		.clk(~Clk_CPU),			//	ʱ��
		.rst(rst),			//��λ
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
		.clk(~Clk_CPU),			//	ʱ��
		.rst(rst),			//��λ
		.Start(Div[20]),                  //����ɨ������
		.EN(GPIOf0),                     //PIO/LED��ʾˢ��ʹ��
		.P_Data(CPU2IO),          //�������룬���ڴ����������
		.counter_set(counter_set),  //���ڼ���/��ʱģ����ƣ���ʵ�鲻��
		.LED_out(LED_out),        //�����������
		.led_clk(led_clk),          //������λʱ��
		.led_sout(led_sout),         //�������
		.led_clrn(led_clrn),         //LED��ʾ����
		.LED_PEN(LED_PEN),          //LED��ʾˢ��ʹ��
		.GPIOf0(GPIOf0)			//���ã�GPIO			 
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