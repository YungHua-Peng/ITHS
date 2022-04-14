
module RH_TEMP (  // HDC1000  : Humidity and Temperature Digital Sensor // 
   input  RESET_N ,
	input  CLK_50,
	input  RH_TEMP_DRDY_n   ,  
	output RH_TEMP_I2C_SCL  , 
	inout  RH_TEMP_I2C_SDA  , 	
	//<Configuration>	
   input [15:0] Configuration , 
	//<Temperature>	
	output reg [15:0] Temperature, 
	input      [15:0] TEMP_UP_LIMIT,
	input      [15:0] TEMP_DOWN_LIMIT ,	
	output            TEMP_ALARM ,	
	//<HUMIDITY>	
	output reg [15:0] Humidity,    
	input      [15:0] RH_UP_LIMIT,
	input      [15:0] RH_DOWN_LIMIT,	
	output            RH_ALARM,	
   //<ID>
	output reg [15:0] DeviceID,
	output reg [15:0] ManufacturerID ,
	
	//---FOR TEST 
	output reg       CLK_400K ,
   output reg       I2C_LO0P,
   output reg [7:0] ST ,
   output reg [7:0] CNT,
	output           W_WORD_END ,
   output reg       W_WORD_GO ,	
	output [7:0]     WORD_ST,
	output [7:0]     WORD_CNT,
	output [7:0]     WORD_BYTE	,
   output [15:0]    R_DATA
		
	);

	
//-- I2C clock 400k generater 
reg  [31:0]C_DELAY ;
always @(posedge CLK_50 ) 
begin 
  if ( C_DELAY > 125/2 ) 
  begin  
    CLK_400K<=~CLK_400K ; 
	 C_DELAY <= 0 ; 
  end 
  else 
    C_DELAY <=C_DELAY +1 ; 
end
  
//======== Main-ST =======
parameter SLAVE_ADDR        =8'h80;  

//-Pointer Register Number-- 
parameter P_Configuration   = 8'h02 ;  
parameter P_Temperature     = 8'h00 ;  
parameter P_Humidity        = 8'h01 ;  
parameter P_ManufacturerID  = 8'hfe ;  
parameter P_DeviceID        = 8'hff ;  


//--ST--
reg [7:0] DELY ; //ST DELAY
always @(negedge RESET_N or posedge CLK_400K )
begin 
 if (!RESET_N)   begin 
   ST <=0;
	W_POINTER_GO <=1;
   R_GO  <=1 ;		 
	W_WORD_GO <=1;
	Temperature <=0; 
	Humidity    <=0; 
  end 	
 else 
case (ST)
0: begin 
   ST<=30;
	W_POINTER_GO <=1;
   R_GO  <=1 ;		 
	W_WORD_GO <=1;
   end
//<----------------READ -------	
1: begin 
   ST<=2; 
	end	
2: begin 
	     if ( CNT==0)  W_POINTER_REG <= P_DeviceID ; 
   else if ( CNT==1)  W_POINTER_REG <= P_ManufacturerID;
	else if ( CNT==2)  W_POINTER_REG <= P_Temperature ;  
	else if ( CNT==3)  W_POINTER_REG <= P_Humidity;  	
	if ( W_POINTER_END ) 
	  begin  
	    W_POINTER_GO  <=0; 
		 ST<=3 ; 
		 DELY<=0;  
		end // Write ID pointer 	 
	end                 
3: begin 
   DELY  <=DELY +1;
   if ( DELY ==2 ) begin 
     W_POINTER_GO  <=1;
     ST<=4 ; 
	end
	end       
4: begin 
   if  ( W_POINTER_END ) ST<=5 ; 	
	end              
5: begin    
	if  ( !(W_POINTER_REG ==0 )   &&   !(W_POINTER_REG ==1 ) )  
	  ST<=6 ;
 	  else if  (!RH_TEMP_DRDY_n) 
	    ST<=6 ;   //tem /hum ready  ref datassheet page12
   end //ready 
	
//read DATA
6: begin 
	if ( R_END ) 
	 begin  
	   R_GO  <=0; 
		ST<=7 ; 
		DELY<=0; 
	 end
	end                // Write ID pointer 
7: begin 
    DELY  <=DELY +1;
    if ( DELY ==2 ) 
	 begin 
      R_GO  <=1;
      ST<=8 ; 
	 end
	end       
8: begin 
    ST<=9 ; 
	end 	
9: begin 
    if  ( R_END ) 
	 begin 
	       if ( CNT==0)        DeviceID <=R_DATA ; 
	  else if ( CNT==1)  ManufacturerID <=R_DATA ; 			 
	  else if ( CNT==2)     Temperature <=R_DATA ; 
	  else if ( CNT==3)        Humidity <=R_DATA ; 
	  ST<=10 ; 	
	  CNT<=CNT+1 ;
	 end
	end              
10: begin      
     if (CNT ==4) CNT <= 0 ;
	    W_POINTER_GO <=1;
       R_GO         <=1 ;		 
	    W_WORD_GO    <=1;
	    ST<=1;
	 end	
//<----------------------------------WRITE WORD-----------------
30: begin 
    ST<=31; 
	 CNT=0 ; 
    end	
31: begin 
    {W_WORD_REG[7:0] ,W_WORD_DATA[15:0]} <= { P_Configuration[7:0] ,Configuration  }; 
	   if (  W_WORD_END ) 
	   begin  
	     W_WORD_GO  <=0; 
		  ST<=32 ; 
		  DELY<=0; 
	   end
	end     
32: begin 
      DELY  <=DELY +1;
      if ( DELY ==2 ) 
		  begin 
          W_WORD_GO  <=1;
          ST<=33 ; 
	     end
	 end       
33: begin 
    ST<=34 ; 
	end       	
34: begin 
     if  ( W_WORD_END )  begin 
			ST<=35 ; 	
	  end
	end              
35: begin 
	 ST <=1 ; 
	 CNT<=0 ;
	 end 
endcase 
end 

//--I2C-BUS-WIRE--
wire SDAO;
assign RH_TEMP_I2C_SCL = W_POINTER_SCL  & R_SCL  & W_WORD_SCL; 
assign SDAO            = W_POINTER_SDAO & R_SDAO & W_WORD_SDAO ;
assign RH_TEMP_I2C_SDA = (SDAO)?1'bz :1'b0 ; 


//----I2C WRITE WORD--
wire          W_WORD_SCL ; 
reg    [7:0]  W_WORD_REG ; 
reg    [15:0] W_WORD_DATA;
wire          W_WORD_SDAO ;  
I2C_WRITE_WORD_2BYTE  wrd(
   .RESET_N (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (W_WORD_GO),
	.POINTER      (W_WORD_REG),
   .WDATA0(W_WORD_DATA[15:8]),
	.WDATA1(W_WORD_DATA[7:0]),
   //.WDATA16	     (W_WORD_DATA),
	.NUM  (2) ,
	.SLAVE_ADDRESS(SLAVE_ADDR),
	.SDAI  (RH_TEMP_I2C_SDA),
	.SDAO  (W_WORD_SDAO),
	.SCLO  (W_WORD_SCL ),
	.END_OK(W_WORD_END),
	//--for test 
	.ST  (WORD_ST ),
	.CNT (WORD_CNT),
	.BYTE(WORD_BYTE),
	.ACK_OK(),

);

//----I2C WRITE POINTER---
wire         W_POINTER_SCL ; 
wire         W_POINTER_END ; 
reg          W_POINTER_GO ; 
reg    [7:0] W_POINTER_REG ; 
wire         W_POINTER_SDAO ;  
I2C_WRITE_POINTER  wpt(
   .RESET_N      (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (W_POINTER_GO),
	.POINTER      (W_POINTER_REG),
	.SLAVE_ADDRESS(SLAVE_ADDR),	
	.SDAI  (RH_TEMP_I2C_SDA),
	.SDAO  (W_POINTER_SDAO),
	.SCLO  (W_POINTER_SCL ),
	.END_OK(W_POINTER_END),
	//--for test 
	.ST (),
	.ACK_OK(),
	.CNT (),
	.BYTE()  	
);


//------I2C READ DATA --- 
wire R_SCL; 
wire R_END; 
reg  R_GO; 
wire R_SDAO;  

I2C_READ_2BYTE rid( 	
   .RESET_N (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (R_GO),
	.SLAVE_ADDRESS(SLAVE_ADDR),	
	.SDAI  (RH_TEMP_I2C_SDA),
	.SDAO  (R_SDAO),
	.SCLO  (R_SCL),
	.END_OK(R_END),
	.DATA16(R_DATA),
	.END_BYTE (1) ,  
	//--for test 
	.ST    (),
	.ACK_OK(),
	.CNT   (),
	.BYTE  () ,
    	
);

endmodule 
	
	
	