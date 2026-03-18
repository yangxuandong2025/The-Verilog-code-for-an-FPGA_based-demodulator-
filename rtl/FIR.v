module fir(
    input               sys_clk,
    input               sys_rst_n,
    
    input signed [15:0] fir_coe,
    
    input signed [15:0] adc_input,
    output reg   [15:0] dac_output
);

parameter ORDER_NUM = 31;

wire signed [15:0] coe [(ORDER_NUM-1)/2:0];
reg  signed [15:0] adc_input_shift [ORDER_NUM:0]; // 移项寄存器

assign coe[0]  = 8;
assign coe[1]  = 23;
assign coe[2]  = 53;
assign coe[3]  = 105;
assign coe[4]  = 186;
assign coe[5]  = 304;
assign coe[6]  = 462;
assign coe[7]  = 662;
assign coe[8]  = 900;
assign coe[9]  = 1168;
assign coe[10] = 1452;
assign coe[11] = 1735;
assign coe[12] = 1995;
assign coe[13] = 2213;
assign coe[14] = 2370;
assign coe[15] = 2452;

// 移项操作
always @(posedge sys_clk or negedge sys_rst_n) begin
    integer i, j;
    if(!sys_rst_n) begin
        for(i = 0; i < ORDER_NUM+1; i = i+1)
            adc_input_shift[i] = 16'd0; 
    end
    else begin
        for(j = 0; j < ORDER_NUM; j = j+1) // 若改为阻塞赋值所有值将全为adc_input_shift[0]
            adc_input_shift[j+1] <= adc_input_shift[j];
        adc_input_shift[0] <= adc_input;
    end
end
// 将对称系数的输入数据相加，同时将对应的滤波器系数送入乘法器
reg signed [16:0] adc_input_add [(ORDER_NUM-1)/2:0]; // 加法寄存器

always @(posedge sys_clk or negedge sys_rst_n) begin
    integer i, j;
    if(!sys_rst_n) begin
        for(i = 0; i < (ORDER_NUM+1)/2; i = i+1)
            adc_input_add[i] = 17'd0; 
    end
    else begin
        for(j = 0; j < (ORDER_NUM+1)/2; j = j+1)
            adc_input_add[j] <= adc_input_shift[j] + adc_input_shift[ORDER_NUM-1-j];
    end
end
// 与串行结构不同，另外需要实例化ORDER_NUM+1)/2个乘法器IP核
wire signed [32:0] Mout [(ORDER_NUM-1)/2:0]; // 乘法器输出为32比特数据
// 使用generate语句动态实例化乘法器

genvar k; // 生成循环的变量

generate
    for(k = 0; k < (ORDER_NUM+1)/2; k = k+1) begin : mult_gen
    MULT MULT(
            .dataa  ( adc_input_add[k] ),
            .datab  ( coe[k] ), // 确保coe的索引与此匹配
            .result ( Mout[k] )
        );
    end
endgenerate

//对滤波器系数与输入数据的乘法结果进行累加，并输出滤波后的数据
//与串行结构不同，此处在一个时钟周期内直接将所有乘法器结果相加
reg signed [36:0] sum;

always @(posedge sys_clk or negedge sys_rst_n) begin
    integer i;
    if(!sys_rst_n) begin
		sum <= 37'd0;
    end
    else begin
        sum = 37'd0;
        for(i = 0; i < (ORDER_NUM+1)/2; i = i+1)
            sum = sum + Mout[i];
        dac_output = 16'h8000 - (sum >>> 15);
    end
end

endmodule
