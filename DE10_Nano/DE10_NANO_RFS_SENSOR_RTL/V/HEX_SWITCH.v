module HEX_SWITCH  (
   input [3:0]SW , 
	input [7:0]  BCD_T,
   input [7:0]  BCD_H,
	input [15:0]  DATA0,
	input [15:0]  DATA1,
 	input [15:0]  ACCEL_XOUT,
	input [15:0]  ACCEL_YOUT,
	input [15:0]  ACCEL_ZOUT,
	input [15:0]  GYRO_XOUT,
	input [15:0]  GYRO_YOUT,
	input [15:0]  GYRO_ZOUT,
	input [15:0]  HM_XOUT,
	input [15:0]  HM_YOUT,
	input [15:0]  HM_ZOUT,	
	input   RH_TEMP_DRDY_n , 
	input   [2:0] POWERUP , 
	input   HM_TR, 
 	output  [7:0]		HEX0,
	output  [7:0]		HEX1,
	output  [7:0]		HEX2,
	output  [7:0]		HEX3,
	output  [7:0]		HEX4,
	output  [7:0]		HEX5,
	output  [7:0]		HEX6,
	output  [7:0]		HEX7,
	output  [17:0]		LEDR
); 

//----------------4 HEX VIEW -------
//sw:0  HUMITY-TEMP       
//sw:1  LIGHT SENSOR ADC0 (DATA0)
//sw:2  LIGHT SENSOR ADC1 (DATA1)
//sw:3  THREE-AXIS MEMS ACCELEROMETER X
//sw:4  THREE-AXIS MEMS ACCELEROMETER Y
//sw:5  THREE-AXIS MEMS ACCELEROMETER Z
//sw:6  THREE-AXIS MEMS GYROSCOPE     X
//sw:7  THREE-AXIS MEMS GYROSCOPE     Y
//sw:8  THREE-AXIS MEMS GYROSCOPE     Z
//sw:9  THREE-AXIS MEMS MAGNETOMETER  X
//sw:10 THREE-AXIS MEMS MAGNETOMETER  Y
//sw:11 THREE-AXIS MEMS MAGNETOMETER  Z
//---------------------------------


wire [3:0] DIG0;
wire [3:0] DIG1;
wire [3:0] DIG2;
wire [3:0] DIG3;

//===INI

assign HEX4=8'hff;
assign HEX5=8'hff;
assign HEX6=8'hff;
assign HEX7=8'hff;

	
//--LED SW 	
assign  LEDR =  (
(SW==0) ?  RH_TEMP_DRDY_n: ( 
(SW==1) ?  POWERUP: (
(SW==2) ?  POWERUP:HM_TR
)));

	

//---HEX SW
assign  DIG0  = (
(SW==0)?BCD_T      [3:0]:(
(SW==1)?DATA0      [3:0]:(
(SW==2)?DATA1      [3:0]:(
(SW==3)?ACCEL_XOUT [3:0]:(
(SW==4)?ACCEL_YOUT [3:0]:(
(SW==5)?ACCEL_ZOUT [3:0]:(
(SW==6)?GYRO_XOUT  [3:0]:(
(SW==7)?GYRO_YOUT  [3:0]:(
(SW==8)?GYRO_ZOUT  [3:0]:(
(SW==9)?HM_XOUT    [3:0]:(
(SW==10)?HM_YOUT   [3:0]:(
(SW==11)?HM_ZOUT   [3:0]:HM_ZOUT   [3:0]
))))))))))));


assign  DIG1  = (
(SW==0)?BCD_T      [7:4]:(
(SW==1)?DATA0      [7:4]:(
(SW==2)?DATA1      [7:4]:(
(SW==3)?ACCEL_XOUT [7:4]:(
(SW==4)?ACCEL_YOUT [7:4]:(
(SW==5)?ACCEL_ZOUT [7:4]:(
(SW==6)?GYRO_XOUT  [7:4]:(
(SW==7)?GYRO_YOUT  [7:4]:(
(SW==8)?GYRO_ZOUT  [7:4]:(
(SW==9)?HM_XOUT    [7:4]:(
(SW==10)?HM_YOUT   [7:4]:(
(SW==11)?HM_ZOUT   [7:4]:HM_ZOUT   [7:4]
))))))))))));


assign  DIG2  = (
(SW==0)?BCD_H      [3:0]:(
(SW==1)?DATA0      [11:8]:(
(SW==2)?DATA1      [11:8]:(
(SW==3)?ACCEL_XOUT [11:8]:(
(SW==4)?ACCEL_YOUT [11:8]:(
(SW==5)?ACCEL_ZOUT [11:8]:(
(SW==6)?GYRO_XOUT  [11:8]:(
(SW==7)?GYRO_YOUT  [11:8]:(
(SW==8)?GYRO_ZOUT  [11:8]:(
(SW==9)?HM_XOUT    [11:8]:(
(SW==10)?HM_YOUT   [11:8]:(
(SW==11)?HM_ZOUT   [11:8]:HM_ZOUT   [11:8]
))))))))))));


assign  DIG3  = (
(SW==0)?BCD_H      [7:4]:(
(SW==1)?DATA0      [15:12]:(
(SW==2)?DATA1      [15:12]:(
(SW==3)?ACCEL_XOUT [15:12]:(
(SW==4)?ACCEL_YOUT [15:12]:(
(SW==5)?ACCEL_ZOUT [15:12]:(
(SW==6)?GYRO_XOUT  [15:12]:(
(SW==7)?GYRO_YOUT  [15:12]:(
(SW==8)?GYRO_ZOUT  [15:12]:(
(SW==9)?HM_XOUT    [15:12]:(
(SW==10)?HM_YOUT   [15:12]:(
(SW==11)?HM_ZOUT   [15:12]:HM_ZOUT   [15:12]
))))))))))));



SEG7_LUT_V	 h1(	 .iDIG (DIG0) , .oSEG (HEX0) ) ; 
SEG7_LUT_V	 h2(	 .iDIG (DIG1) , .oSEG (HEX1) ) ; 
SEG7_LUT_V	 h3(	 .iDIG (DIG2) , .oSEG (HEX2) ) ; 
SEG7_LUT_V	 h4(	 .iDIG (DIG3) , .oSEG (HEX3) ) ; 


endmodule 