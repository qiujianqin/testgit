//---------------------------------------------------------------------------
//--	文件名		:	Key_Module.v
//--	作者		:	
//--	描述		:	按键消抖模块
//--	修订历史	:	
//---------------------------------------------------------------------------
module Key_Module
(
	//输入端口
	CLK_50M,RST_N,KEY,
	//输出端口
	LED,
	KEY_MODE_OUT
);  
 
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;				//时钟的端口,开发板用的50MHz晶振
input					RST_N;				//复位的端口,低电平复位
input		[ 7:0]	KEY;					//对应开发板上的KEY
output	[ 7:0]	LED;					//对应开发板上的LED
output 	[ 1:0]   KEY_MODE_OUT;
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[19:0]	time_cnt;			//用来计数按键延迟的定时计数器
reg		[19:0]	time_cnt_n;			//time_cnt的下一个状态
reg		[ 7:0]	key_reg;				//用来接收按键信号的寄存器
reg		[ 7:0]	key_reg_n;			//key_reg的下一个状态
wire		[ 7:0]	key_out;				//消抖完成输出按键
reg		[ 7:0]	LED;					//对应开发板上的LED
reg		[ 7:0]	LED_N;				//LED的下一个状态
wire 		[ 1:0]   KEY_MODE_OUT;
reg 		[ 1:0]   KEY_MODE_OUT_n;
//设置定时器的时间为20ms,计算方法为  (20*10^6)ns / (1/50)ns  50MHz为开发板晶振
parameter SET_TIME_20MS = 27'd1_000_000;	

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路，用来给time_cnt寄存器赋值
always @ (posedge CLK_50M, negedge RST_N)
begin
	if(!RST_N)								//判断复位
		time_cnt <= 20'h0;				//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;			//用来给time_cnt赋值
end

//组合电路，实现20ms的定时计数器
always @ (*)
begin
	if(time_cnt == SET_TIME_20MS)		//判断20ms时间
		time_cnt_n = 20'h0;				//如果到达20ms,定时计数器将会被清零
	else
		time_cnt_n <= time_cnt + 1'b1;//如果未到20ms,定时计数器将会继续累加
end

//时序电路，用来key_reg寄存器赋值
always @ (posedge CLK_50M, negedge RST_N)
begin
	if(!RST_N)								//判断复位
		key_reg <= 8'h0;					//初始化key_reg值
	else
		key_reg <= key_reg_n;			//用来给key_reg赋值
end

//组合电路，每20ms接收一次按键的值
always @ (*)
begin
	if(time_cnt == SET_TIME_20MS)		//判断20ms时间
		key_reg_n <= KEY;					//如果到达20ms,接收一次按键的值
	else
		key_reg_n <= key_reg;			//如果未到20ms,保持原状态不变
end

assign key_out = key_reg & (~key_reg_n);//判断按键有没有按下并点亮相应的LED

//时序电路，用来LED寄存器赋值
always @ (posedge CLK_50M, negedge RST_N)
begin
	if(!RST_N)								//判断复位
		LED <= 8'h0;						//初始化LED值
	else
		LED <= LED_N;						//用来给LED赋值
end

//组合电路，根据按键的值点亮相应的LED
always @ (*)
begin
	case(key_out)
		8'h01  : LED_N = 8'b00000001; //按键1熄灭LED1
		8'h02  : LED_N = 8'b00000010; //按键2熄灭LED2
		8'h04  : LED_N = 8'b00000100; //按键3熄灭LED3
		8'h08  : LED_N = 8'b00001000; //按键4熄灭LED4
		8'h10  : LED_N = 8'b00010000; //按键5熄灭LED5
		8'h20  : LED_N = 8'b00100000; //按键6熄灭LED6
		8'h40  : LED_N = 8'b01000000; //按键7熄灭LED7
		8'h80  : LED_N = 8'b10000000; //按键8熄灭LED8
		default: LED_N = LED;
	endcase
end
//组合电路，根据按键的值点亮相应的LED
always @ (*)
begin
	case(key_out)
		8'h40  : KEY_MODE_OUT_n = 2'b00; //按键7熄灭LED7
		8'h80  : KEY_MODE_OUT_n = 2'b01; //按键8熄灭LED8
		default: KEY_MODE_OUT_n = KEY_MODE_OUT;
	endcase
end
assign KEY_MODE_OUT = KEY_MODE_OUT_n;

endmodule
