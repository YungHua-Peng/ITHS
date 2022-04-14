
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE10_NANO_RFS_SENSOR_RTL(

	//////////// CLOCK //////////
	input 		          		FPGA_CLK1_50,
	input 		          		FPGA_CLK2_50,
	input 		          		FPGA_CLK3_50,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW,
	
	//////////// GPIO_0, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO,

	//////////// GPIO_1, GPIO connect to RFS - RF and Sensor //////////
	inout 		          		BT_KEY,
	input 		          		BT_UART_RX,
	output		          		BT_UART_TX,
	input 		          		LSENSOR_INT,
	inout 		          		LSENSOR_SCL,
	inout 		          		LSENSOR_SDA,
	output		          		MPU_AD0_SDO,
	output		          		MPU_CS_n,
	output		          		MPU_FSYNC,
	input 		          		MPU_INT,
	inout 		          		MPU_SCL_SCLK,
	inout 		          		MPU_SDA_SDI,
	input 		          		RH_TEMP_DRDY_n,
	inout 		          		RH_TEMP_I2C_SCL,
	inout 		          		RH_TEMP_I2C_SDA,
	inout 		     [7:0]		TMD_D,
	input 		          		UART2USB_CTS,
	output		          		UART2USB_RTS,
	input 		          		UART2USB_RX,
	output		          		UART2USB_TX,
	output		          		WIFI_EN,
	output		          		WIFI_RST_n,
	input 		          		WIFI_UART0_CTS,
	output		          		WIFI_UART0_RTS,
	input 		          		WIFI_UART0_RX,
	output		          		WIFI_UART0_TX,
	input 		          		WIFI_UART1_RX
);


//=======================================================
//  REG/WIRE declarations
//======================================================
   wire       RESET_N ; 
   wire [7:0] BCD_T , BCD_H;  
   wire [7:0] POWERUP	 ; 
   
   wire [15:0] DATA0  ; 
   wire [15:0] DATA1  ; 
   wire        HM_TR ;
	
	wire	[15:0]	Temperature_From_DHT22;
	wire	[15:0]	Temperature_From_HC1000;
	
	//Clock Assignment
	parameter 			CntValue = 50000000;
	reg   	[31:0]   Clk_Cnt;
	reg					Clk_LowFequence;
	
//=======================================================
//  Structural coding
//=======================================================


//---- RESET ---
assign RESET_N =KEY[0];

//----Humidity -Temperature SENSOR ---	
HC1000 HC(
      .RESET_N        (RESET_N        ),
      .CLOCK_50       (FPGA_CLK1_50   ),
      .RH_TEMP_DRDY_n (RH_TEMP_DRDY_n ),
      .RH_TEMP_I2C_SCL(RH_TEMP_I2C_SCL), 
      .RH_TEMP_I2C_SDA(RH_TEMP_I2C_SDA),
      .Temperature	 	(Temperature_From_HC1000)
);
	
//----Temperature -DHT22 Temperature SENSOR ---	
//Output temperature in Binary, Convert to decimal when using
//the units digit means the number after the decimal point
DHT22 DHT22(
	.clk		(FPGA_CLK1_50),
	.res		(RESET_N),
	.dht22	(GPIO[0]),
	.data_out(Temperature_From_DHT22)	//Temperature in Binary 
);


//Get low Hz CloCK
always @(posedge FPGA_CLK1_50) begin
	
	if ( Clk_Cnt >= ((CntValue/(2*2))-1)) begin
		Clk_LowFequence <= ~ Clk_LowFequence;
		Clk_Cnt <= 0;
	end else begin
		Clk_LowFequence <= Clk_LowFequence;
		Clk_LowFequence <= Clk_Cnt +1;
	end
end

assign GPIO[1] = Clk_LowFequence;


//Send data to Arduino
assign GPIO[26:18] = Temperature_From_HC1000[8:0];
assign GPIO[35:27] = Temperature_From_DHT22[8:0];

//----Fuzzy Controller ---	
Fuzzy_Controller Fuzzy(
	.RESET_N							(RESET_N),
	.CLOCK_50						(FPGA_CLK1_50),
	.Real_Temperature_User_A	(Temperature_From_DHT22),
	.Real_Temperature_User_B	(Temperature_From_HC1000),	//Temperature in Binary 
	.Heat_Feeling_User_A			({GPIO[14], GPIO[12], GPIO[10]}),
	.Heat_Feeling_User_B			({GPIO[15], GPIO[13], GPIO[11]}),
	.PWM_Heater_User_A			(GPIO[2]),
	.PWM_Heater_User_B			(GPIO[3])
);
assign GPIO[4] = 1'b1;assign GPIO[6] = 1'b0;
assign GPIO[5] = 1'b1;assign GPIO[7] = 1'b0;

endmodule

