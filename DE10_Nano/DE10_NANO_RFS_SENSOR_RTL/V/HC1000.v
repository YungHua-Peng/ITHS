module HC1000
(
input  				RESET_N,
input  				CLOCK_50,
input  				RH_TEMP_DRDY_n,
output 				RH_TEMP_I2C_SCL, 
inout  				RH_TEMP_I2C_SDA,

output  [15:0] Temperature
);
//---- Power Monitor IC Connfiguration ---
parameter  CONFIGURATION =  16'h1000;

//----Humidity_Temperature Result---	
wire [15:0] TEMP_CURRENT ;   
wire [15:0] RH_CURRENT ;

//----Humidity_Temperature ---	
RH_TEMP ctl( 
   //--SYSTEM--   
	.RESET_N 			(RESET_N       ),
   .CLK_50           (CLOCK_50      ),
	//--IC SIDE-- 
	.RH_TEMP_DRDY_n   (RH_TEMP_DRDY_n),   
	.RH_TEMP_I2C_SCL  (RH_TEMP_I2C_SCL),
	.RH_TEMP_I2C_SDA  (RH_TEMP_I2C_SDA),  
	//<Configuration>
	.Configuration    (CONFIGURATION  ),
	//<Temperature>
	.Temperature      (TEMP_CURRENT   ), 
	//<Humidity>
	.Humidity         (RH_CURRENT    )
);

//*10 means get the one number after the decimal point
assign  Temperature = (TEMP_CURRENT*165*10)/65536 -40*10 ;
//assign  Temperature = (TEMP_CURRENT*165)/65536 -40 ; 
 
 endmodule
 
 
 