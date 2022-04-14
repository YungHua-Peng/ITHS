module SENSOR_OUT  (
	input [7:0]   Temperature    ,
   input [7:0]   HUMITY         ,
	input [15:0]  Ambient_LIGHT0 ,
	input [15:0]  Ambient_LIGHT1 ,
 	input [15:0]  ACCELEROMETER_X,
	input [15:0]  ACCELEROMETER_Y,
	input [15:0]  ACCELEROMETER_Z,
	input [15:0]  GYROSCOPE_X    ,
	input [15:0]  GYROSCOPE_Y    ,
	input [15:0]  GYROSCOPE_Z    ,
	input [15:0]  MAGNETOMETER_X ,
	input [15:0]  MAGNETOMETER_Y ,
	input [15:0]  MAGNETOMETER_Z ,	
	input         RH_TEMP_DRDY_n ,       
	input         HM_TR                   
); 


endmodule 