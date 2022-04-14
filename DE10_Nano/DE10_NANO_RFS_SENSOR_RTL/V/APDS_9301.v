
module  APDS_9301 (  // LIGHT Digital Sensor // 
   input            RESET_N ,
	input            CLK_50,
	input            RDY_n   ,  
	output           I2C_SCL  , 
	inout            I2C_SDA  , 	

	output reg [7:0] DATA0LOW  ,
	output reg [7:0] DATA0HIGH,
	output reg [7:0] DATA1LOW ,
	output reg [7:0] DATA1HIGH,
	output reg [7:0] POWERUP , 
	output reg [7:0] ID  , 
	
	output     [15:0]DATA0  ,
	output     [15:0]DATA1 ,
	
	
	//---FOR TEST 
	output           CLK_400K ,
   output reg       I2C_LO0P,
   output reg [7:0] ST ,
   output reg [7:0] CNT,
	output           W_WORD_END ,
   output reg       W_WORD_GO ,	
	output [7:0]     WORD_ST,
	output [7:0]     WORD_CNT,
	output [7:0]     WORD_BYTE	,
   output [7:0]     R_DATA,
   output reg    [7:0] W_POINTER_REG
		
	);

//--ADC DATA 
	assign DATA0 ={DATA0HIGH ,DATA0LOW } ;
	assign DATA1 ={DATA1HIGH ,DATA1LOW } ;	
//-- I2C clock 400k generater 
CLOCKMEM MM(  .CLK(CLK_50) ,.CLK_FREQ(500), .CK_1HZ (CLK_400K) ) ;
  
//======== Main-ST =======
parameter SLAVE_ADDR      =8'h52 ; 
//-Pointer Register Number-- 
parameter P_Control      = 8'hc0;
parameter P_ID           = 8'hcA;
parameter P_Timing       = 8'hc1; 
parameter P_Interrupt    = 8'hc6; 


parameter P_DATA0LOW     = 8'hcC ;  
parameter P_DATA0HIGH    = 8'hcD ;  
parameter P_DATA1LOW     = 8'hcE ;  
parameter P_DATA1HIGH    = 8'hcF ;  

//--ST--
reg [7:0] DELY ; //ST DELAY
always @(negedge RESET_N or posedge CLK_400K )
begin 
 if (!RESET_N)   begin 
     ST      <=0;
	  POWERUP <=0;
	  DATA0LOW <=0;
	  DATA0HIGH<=0;
	  DATA1LOW <=0;
	  DATA1HIGH<=0;
	  W_POINTER_GO <=1;   
	  R_GO         <=1;
	  W_WORD_GO    <=1;
	 
  end 	  
 else 
case (ST)
0: begin 
    ST<=30;
	 W_POINTER_GO <=1;   
	 R_GO         <=1;
	 W_WORD_GO    <=1;
  end
//<----------------READ -------	
1: begin 
     ST<=2; 
	end	
2: begin 
        if ( CNT==0 ) W_POINTER_REG <=P_Control   ; 
   else if ( CNT==1 ) W_POINTER_REG <=P_ID ; 
	else if ( CNT==2)  W_POINTER_REG <=P_DATA0LOW   ; 
   else if ( CNT==3)  W_POINTER_REG <=P_DATA0HIGH ;
	else if ( CNT==4)  W_POINTER_REG <=P_DATA1LOW  ;  
	else if ( CNT==5)  W_POINTER_REG <=P_DATA1HIGH ;  	
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
5: begin ST<=6 ; end //delay
	
//read DATA 		 
6: begin 
	if ( R_END ) begin  R_GO  <=0; ST<=7 ; DELY<=0; end
	end  
	             
	// Write ID pointer 
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
	       if ( CNT==0) POWERUP  <=R_DATA ; 
	  else if ( CNT==1) ID <=R_DATA ; 
	  else if ( CNT==2) DATA0LOW <=R_DATA ; 
	  else if ( CNT==3) DATA0HIGH<=R_DATA ; 			 
	  else if ( CNT==4) DATA1LOW <=R_DATA ; 
	  else if ( CNT==5) DATA1HIGH<=R_DATA ; 
	  ST<=10 ; 	
	  CNT<=CNT+1 ;
	 end
	end              
10: begin   
      if ( ( POWERUP & 3 )   !=3  ) ST<= 30 ;
		else  begin 
	   if (CNT ==6)       begin CNT <= 0 ; end 
	    W_POINTER_GO <=1;
       R_GO         <=1 ;		 
	    W_WORD_GO    <=1;
		 ST<=1 ; 
		end  
		  
	 end	
//<----------------------------------WRITE WORD-----------------
30: begin 
    ST<=31; 
	 CNT=0 ; 
    end	
31: begin 
			  if (CNT==0 )    {W_WORD_REG[7:0] ,W_WORD_DATA[7:0]} <= { P_Control   [7:0]  ,8'h03 }; 
		 else if (CNT==1 )   {W_WORD_REG[7:0] ,W_WORD_DATA[7:0]} <= { P_Timing    [7:0]  ,8'h19 }; //GAIN x16 / 101 ms
		else if (CNT==2 )    {W_WORD_REG[7:0] ,W_WORD_DATA[7:0]} <= { P_Interrupt [7:0]  ,8'h1f }; 
		
		
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
		   CNT <=CNT +1 ;	
	  end
	end              
35: begin 
	 if   ( CNT==3 )  begin ST <=1 ;  CNT<=0 ; end 
	 else ST <= 31 ; 
	 end 
endcase 
end 

//--I2C-BUS-WIRE--
wire SDAO;
assign I2C_SCL = W_POINTER_SCL  & R_SCL  & W_WORD_SCL; 
assign SDAO    = W_POINTER_SDAO & R_SDAO & W_WORD_SDAO ;
assign I2C_SDA = (SDAO)?1'bz :1'b0 ; 


//----I2C WRITE WORD--
wire          W_WORD_SCL ; 
reg    [7:0]  W_WORD_REG ; 
reg    [15:0] W_WORD_DATA;
wire          W_WORD_SDAO ;  

I2C_WRITE_WORD_2BYTE  wrd(
   .RESET_N      ( RESET_N),
	.PT_CK        ( CLK_400K),
	.GO           ( W_WORD_GO),
	.POINTER      ( W_WORD_REG),
   .WDATA0	     ( W_WORD_DATA),		
	//WDATA1,		
	.NUM  ( 1), 
	.SLAVE_ADDRESS( SLAVE_ADDR),
	.SDAI         ( I2C_SDA),
	.SDAO         ( W_WORD_SDAO),
	.SCLO         ( W_WORD_SCL ),
	.END_OK       ( W_WORD_END),
	//--for test 
	.ST           ( WORD_ST ),
	.CNT          ( WORD_CNT),
	.BYTE         ( WORD_BYTE),
	.ACK_OK       ( )
);

//----I2C WRITE POINTER---
wire         W_POINTER_SCL ; 
wire         W_POINTER_END ; 
reg          W_POINTER_GO ; 

wire         W_POINTER_SDAO ;  
I2C_WRITE_POINTER  wpt(
   .RESET_N      ( RESET_N),
	.PT_CK        ( CLK_400K),
	.GO           ( W_POINTER_GO),
	.POINTER      ( W_POINTER_REG),
	.SLAVE_ADDRESS( SLAVE_ADDR),	
	.SDAI         ( I2C_SDA),
	.SDAO         ( W_POINTER_SDAO),
	.SCLO         ( W_POINTER_SCL ),
	.END_OK       ( W_POINTER_END),
	//--for test 
	.ST           (),
	.ACK_OK       (),
	.CNT          (),
	.BYTE         ()  	
);


//------I2C READ DATA --- 
wire R_SCL; 
wire R_END; 
reg  R_GO; 
wire R_SDAO; 
I2C_READ_2BYTE  rid( 	
   .RESET_N      (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (R_GO),
	.SLAVE_ADDRESS(SLAVE_ADDR),	
	.SDAI         (I2C_SDA),
	.SDAO         (R_SDAO),
	.SCLO         (R_SCL),
	.END_OK       (R_END),
	.DATA16       (R_DATA[7:0]),
	.END_BYTE     (0) 

);

endmodule 
	
	
	