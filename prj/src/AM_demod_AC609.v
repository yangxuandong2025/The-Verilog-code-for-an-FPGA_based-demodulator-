module AM_demod_AC609(
    input        Clk,//时钟信号
    input        Rst_n,//复位信号，低电平有效
    input  [7:0] AD,//输入信号
    output       AD_CLK,//AD采样时钟
    output       dac_clk,
    output reg [7:0] ad_data,//采样数据
	
//   output reg       ad_valid
//	 output [15:0] avg_value,//平均值输出
    input        Rs232_Rx, //RS232数据输入(rx)
    output       Rs232_Tx,
   
//	input [7:0]data_byte;
	input        send_en,
//	input [2:0]baud_set,
	output       Tx_Done,
	output       uart_state
	
);


   reg    ad_valid;//ADC数据有效标志
	wire   clk_6M;
	wire   clk_6M_deg180;
	wire   clk_100M;
   wire   locked;
   reg    rx_valid;//uart_rx数据有效标志
	reg  [7:0]data_rx_r;//uart_rx配置
	wire [7:0]data_rx;//uart_rx输出
	wire   Rx_Done;
	
/////////////// 解调电路状态定义//////////////
parameter S0 = 3'b000 ;//空闲态
parameter S1 = 3'b001 ;//AM
parameter S2 = 3'b010 ;//FM
parameter S3 = 3'b011 ;//CW/
parameter S4 = 3'b100 ;//2ASK
parameter S5 = 3'b101 ;//2PSK
parameter S6 = 3'b110 ;//ZFSK   
reg [3:0] state, next_state;
/////////////////////////////////////////////////////////////////////////////////////	
parameter baud_set = 3'd4;//uart_tx波特率115200
 assign AD_CLK = Clk;//AD采样时钟直接使用系统时钟
 assign dac_clk = clk_6M_deg180;
 // 采集AD数据并输出
 always @(posedge Clk or negedge Rst_n) begin
     if(!Rst_n) begin
         ad_data  <= 8'd0;
         ad_valid <= 1'b0;
     end
     else begin//每个时钟周期采样一次AD数据
         ad_data  <= AD;
         ad_valid <= 1'b1;
     end
 end
///PLL锁相环生成不同频率的时钟
 pll	pll_inst (
	.areset (  ~Rst_n ),
	.inclk0 ( Clk ),
	.c0 ( clk_100M ),//100M
	.c1 ( clk_6M ),//6M
	.c2 ( clk_6M_deg180),//6M
	.locked ( locked )
	);


	
	
//	ISSP issp(
//		.probe(data_rx_r),
//		.source()
//	);
//	
	
	always@(posedge Clk or negedge Rst_n) begin
	if(!Rst_n) begin
		data_rx_r <= 8'd0;
		rx_valid <= 1'b0;
		end
	else if(Rx_Done)
	begin
		data_rx_r <= data_rx;//只有当接收完成时才更新寄存器，避免在接收过程中数据变化导致误判
		rx_valid <= 1'b1;
		end
	else begin
		data_rx_r <= data_rx_r;//保持原值，直到下一次接收完成
		rx_valid <= 1'b0;
		end
    end


//////////////////////////////////////////////////////////////////////////////
///////////////步骤二：接送单片机信号实现命令解码和模式切换////////////////////
// 1. 实例化解码器
wire pulse_a, pulse_b, pulse_c, pulse_d, pulse_e, pulse_f, pulse_g, pulse_err;// 对应 A-G 和错误

///////串口接收模块——接收单片机发送的命令//////////////////
	uart_byte_rx uart_byte_rx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.baud_set(baud_set),
		.Rs232_Rx( Rs232_Rx ),//uart_rx引脚	
		.data_byte(data_rx),//接收数据
		.Rx_Done(Rx_Done)
	);

//////////串口命令解码模块——将接收到的字节转换为对应的模式切换脉冲//////////////////
uart_cmd_decoder_simple u_decoder (
   .Clk(Clk),
   .Rst_n(Rst_n),
   .rx_valid(rx_valid),
   .rx_data(data_rx_r),
   .cmd_a(pulse_a),
   .cmd_b(pulse_b),
   .cmd_c(pulse_c),
   .cmd_d(pulse_d),
   .cmd_e(pulse_e),
   .cmd_f(pulse_f),
   .cmd_g(pulse_g),
   .cmd_error(pulse_err)
);

// 2. 定义模式 (3位二进制足够表示 0-7)
localparam MODE_STOP = 3'd0; // G IDLE/STOP
localparam MODE_AM   = 3'd1; // A AM
localparam MODE_FM   = 3'd2; // B FM
localparam MODE_CM   = 3'd3; // C CW
localparam MODE_ASK  = 3'd4; // D ASK
localparam MODE_PSK  = 3'd5; // E PSK
localparam MODE_FSK  = 3'd6; // F FSK

reg [2:0] current_mode;

always @(posedge Clk or negedge Rst_n) begin
   if (!Rst_n)
       current_mode <= MODE_STOP;
   else begin
       // 直接根据脉冲切换解调电路
       if (pulse_a)      current_mode <= MODE_AM;
       else if (pulse_b) current_mode <= MODE_FM;
       else if (pulse_c) current_mode <= MODE_CM;
       else if (pulse_d) current_mode <= MODE_ASK;
       else if (pulse_e) current_mode <= MODE_PSK;
       else if (pulse_f) current_mode <= MODE_FSK;
       else if (pulse_g) current_mode <= MODE_STOP;
   end
end

// 3. 输出选择 (MUX)
wire out_am, out_fm, out_cm, out_ask, out_psk, out_fsk;// 这些信号需要根据实际解调电路的输出连接
reg final_output;// 最终输出信号

always @(*) begin
   case (current_mode)
       MODE_AM:   final_output = out_am;
       MODE_FM:   final_output = out_fm;
       MODE_CM:   final_output = out_cm;
       MODE_ASK:  final_output = out_ask;
       MODE_PSK:  final_output = out_psk;
       MODE_FSK:  final_output = out_fsk;
       default:   final_output = 0      ; // STOP 模式输出 0
   endcase
end

////////////////////////////////////////////////
///////////////步骤三：实现各个解调电路//////////////////////////////////////////
// 这里需要根据每种调制方式的解调原理，设计对应的解调电路，/////////////////////////
//并将它们的输出连接到上面的 MUX 输入端口 (out_am, out_fm, etc.)。////////////////
//////////////////////////////////////////////////////////////////////////////
 
///////////////步骤三（一）：实现AM解调电路//////////////////////////////////////////
   AM AM(
   .Clk(Clk),//时钟信号
   .clk_6M(clk_6M),
   .clk_6M_deg180(clk_6M_deg180),
   .clk_100M(clk_100M),
   .Rst_n(Rst_n),//复位信号，低电平有效
   .m_signal(AD),//输入信号
   .d_signal(out_am)//输出数据
    );

///////////////步骤三（二）：实现FM解调电路////////////////////////////////////////////
///////////////步骤三（三）：实现CW解调电路///////////////////////////////////////////
///////////////步骤三（四）：实现ASK解调电路//////////////////////////////////////////
///////////////步骤三（五）：实现PSK解调电路//////////////////////////////////////////
///////////////步骤三（六）：实现FSK解调电路//////////////////////////////////////////
///////////////暂时无用///////////////////
// reg [23:0] cnt;
// reg send_en_r;
// reg [7:0] tx_data;

// always @(posedge Clk or negedge Rst_n) begin
//     if(!Rst_n) begin
//         cnt      <= 24'd0;
//         send_en_r <= 1'b0;
//         tx_data  <= 8'h55;   // 串口助手里会看到 'U'
//     end
//     else begin
//         if(cnt == 24'd999_999) begin   // 50MHz 下约 20ms 发一次
//             cnt      <= 24'd0;
//             send_en_r <= 1'b1;         // 只给 1 个时钟脉冲
//         end
//         else begin
//             cnt      <= cnt + 1'b1;
//             send_en_r <= 1'b0;
//         end
//     end
// end
///////////////暂时无用///////////////////

////////暂时无用////////
//  uart_byte_tx uart_tx(
// 	.Clk(Clk),       //50M时钟输入
// 	.Rst_n(Rst_n),     //模块复位
// 	.data_byte(ad_data), //待传输8bit数据
// 	.send_en(send_en),   //发送使能
// 	.baud_set(baud_set),  //波特率设置
	
// 	.Rs232_Tx(Rs232_Tx),  //Rs232输出信号
// 	.Tx_Done(Tx_Done),   //一次发送数据完成标志
// 	.uart_state(uart_state) //发送数据状态
// );

// uart_byte_tx uart_tx(
//     .Clk(Clk),
//     .Rst_n(Rst_n),
//     .data_byte(tx_data),
//     .send_en(send_en_r),
//     .baud_set(baud_set),
//     .Rs232_Tx(Rs232_Tx),
//     .Tx_Done(Tx_Done),
//     .uart_state(uart_state)
// );
//////////暂时无用////////

endmodule
