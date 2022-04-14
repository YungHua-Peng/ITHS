
module MPU_9250 (  // 9-axis(accelerometer,gyroscope,magnetometer)
   input            RESET_N ,
	input            CLK_50,
	input            RDY_n   ,  
	output           I2C_SCL  , 
	inout            I2C_SDA  , 
   output reg [7:0] ACCEL_XOUT_H,
   output reg [7:0] ACCEL_XOUT_L,
   output reg [7:0] ACCEL_YOUT_H,
   output reg [7:0] ACCEL_YOUT_L,
   output reg [7:0] ACCEL_ZOUT_H,
   output reg [7:0] ACCEL_ZOUT_L,
   output reg [7:0] TEMP_OUT_H  ,
   output reg [7:0] TEMP_OUT_L  ,
   output reg [7:0] GYRO_XOUT_H ,
   output reg [7:0] GYRO_XOUT_L ,
   output reg [7:0] GYRO_YOUT_H ,
   output reg [7:0] GYRO_YOUT_L ,
   output reg [7:0] GYRO_ZOUT_H ,
   output reg [7:0] GYRO_ZOUT_L ,
   output reg [7:0] INT_STATUS   ,
	output reg [7:0] I2C_MST_STATUS , 
	output reg [7:0] HXL,
	output reg [7:0] HXH,
	output reg [7:0] HYL,
   output reg [7:0] HYH,
	output reg [7:0] HZL,
	output reg [7:0] HZH,
	output reg [7:0] WIA ,
	output reg [7:0] INFO,
	output reg [7:0] ST1 ,
	output reg [7:0] ST2 , 
	
	output [15:0] ACCEL_XOUT,
	output [15:0] ACCEL_YOUT,
	output [15:0] ACCEL_ZOUT,
	output [15:0]   TEMP_OUT,
	output [15:0]  GYRO_XOUT,
	output [15:0]  GYRO_YOUT,
	output [15:0]  GYRO_ZOUT,
	output [15:0]  HM_XOUT,
	output [15:0]  HM_YOUT,
	output [15:0]  HM_ZOUT,	

	
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
   output [7:0]        R_DATA,
   output reg    [7:0] W_POINTER_REG,
	output TR 
		
	);
	
//--MPU9250 & AK8963 --REGISTER	
`include "MPU9250_AK8963.h"

//-Pointer Register Number-- 
parameter READ_REG_MAX      =27;
//=======================================================
//  REG/WIRE declarations
//=======================================================
reg   [7:0]  SLAVE_ADDR     ; 
wire         SDAO;
wire         R_SCL; 
wire         R_END; 
reg          R_GO; 
wire         R_SDAO;  
wire         W_POINTER_SCL ; 
wire         W_POINTER_END ; 
reg          W_POINTER_GO ; 
wire         W_POINTER_SDAO ;  
reg    [31:0] DELY ;

wire          W_WORD_SCL ; 
reg    [7:0]  W_WORD_REG ; 
reg    [15:0] W_WORD_DATA;
wire          W_WORD_SDAO ;  
//=======================================================
//  Structural coding
//=======================================================



//THREE-AXIS MEMS ACCELEROMETER

	assign ACCEL_XOUT={ACCEL_XOUT_H,ACCEL_XOUT_L};
	assign ACCEL_YOUT={ACCEL_YOUT_H,ACCEL_YOUT_L};
	assign ACCEL_ZOUT={ACCEL_ZOUT_H,ACCEL_ZOUT_L};
	assign   TEMP_OUT={  TEMP_OUT_H,  TEMP_OUT_L};

//THREE-AXIS MEMS GYROSCOPE WITH	
	assign  GYRO_XOUT={ GYRO_XOUT_H, GYRO_XOUT_L};
	assign  GYRO_YOUT={ GYRO_YOUT_H, GYRO_YOUT_L};
	assign  GYRO_ZOUT={ GYRO_ZOUT_H, GYRO_ZOUT_L};

	
//THREE-AXIS MEMS MAGNETOMETER
	assign  HM_XOUT={ HXH, HXL};
	assign  HM_YOUT={ HYH, HYL};
	assign  HM_ZOUT={ HZH, HZL};
	
   assign TR = ST1[0] ; 
	
//-- I2C clock 400k generater 
CLOCKMEM MM(  .CLK(CLK_50) ,.CLK_FREQ(500), .CK_1HZ (CLK_400K) ) ;
  

//--ST--

always @(negedge RESET_N or posedge CLK_400K )
begin 
 if (!RESET_N)   
 begin 
 	 W_POINTER_GO <=1;   
	 R_GO         <=1;
	 W_WORD_GO    <=1;
    ST <=0;
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
        if ( CNT==0 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_ACCEL_XOUT_H   }; 
   else if ( CNT==1 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_ACCEL_XOUT_L   }; 
   else if ( CNT==2 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_ACCEL_YOUT_H   }; 
   else if ( CNT==3 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_ACCEL_YOUT_L   };
	else if ( CNT==4 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_ACCEL_ZOUT_H   };  
	else if ( CNT==5 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_ACCEL_ZOUT_L   }; 
	else if ( CNT==6 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_TEMP_OUT_H     };   	
	else if ( CNT==7 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_TEMP_OUT_L     };  
	else if ( CNT==8 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_GYRO_XOUT_H    };  
	else if ( CNT==9 )   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_GYRO_XOUT_L    };  
	else if ( CNT==10)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_GYRO_YOUT_H    };  
	else if ( CNT==11)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_GYRO_YOUT_L    };  
	else if ( CNT==12)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_GYRO_ZOUT_H    };  
	else if ( CNT==13)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_GYRO_ZOUT_L    };  	
	else if ( CNT==14)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_INT_STATUS     }; 
	else if ( CNT==15)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_ST2            } ; 
	else if ( CNT==16)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_INFO           };
	else if ( CNT==17)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_ST1            }; 
	else if ( CNT==18)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_HXL            };
	else if ( CNT==19)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_HXH            }; 
	else if ( CNT==20)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_HYL            }; 
	else if ( CNT==21)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_HYH            }; 
	else if ( CNT==22)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_HZL            }; 
	else if ( CNT==23)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_HZH            };
	else if ( CNT==24)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_INT_STATUS     } ;   
   else if ( CNT==25)   { SLAVE_ADDR ,W_POINTER_REG}<={MPU9250_ADDRESS,P_I2C_MST_STATUS } ; 
	else if ( CNT==26)   { SLAVE_ADDR ,W_POINTER_REG}<={MAG_ADDRESS,    P_WIA            };

	

	
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
        if ( CNT==0 )   ACCEL_XOUT_H   <=R_DATA; 
   else if ( CNT==1 )   ACCEL_XOUT_L   <=R_DATA; 
   else if ( CNT==2 )   ACCEL_YOUT_H   <=R_DATA; 
   else if ( CNT==3 )   ACCEL_YOUT_L   <=R_DATA;
	else if ( CNT==4 )   ACCEL_ZOUT_H   <=R_DATA;  
	else if ( CNT==5 )   ACCEL_ZOUT_L   <=R_DATA; 
	else if ( CNT==6 )   TEMP_OUT_H     <=R_DATA;   	
	else if ( CNT==7 )   TEMP_OUT_L     <=R_DATA;  
	else if ( CNT==8 )   GYRO_XOUT_H    <=R_DATA;  
	else if ( CNT==9 )   GYRO_XOUT_L    <=R_DATA;  
	else if ( CNT==10)   GYRO_YOUT_H    <=R_DATA;  
	else if ( CNT==11)   GYRO_YOUT_L    <=R_DATA;  
	else if ( CNT==12)   GYRO_ZOUT_H    <=R_DATA;  
	else if ( CNT==13)   GYRO_ZOUT_L    <=R_DATA;  	
	else if ( CNT==14)   INT_STATUS     <=R_DATA; 
	else if ( CNT==15)   ST2            <=R_DATA ; 	
	else if ( CNT==16)   INFO           <=R_DATA;
	else if ( CNT==17)   ST1            <=R_DATA; 
	else if ( CNT==18)   HXL            <=R_DATA;
	else if ( CNT==19)   HXH            <=R_DATA; 
	else if ( CNT==20)   HYL            <=R_DATA; 
	else if ( CNT==21)   HYH            <=R_DATA; 
	else if ( CNT==22)   HZL            <=R_DATA; 
	else if ( CNT==23)   HZH            <=R_DATA;
	else if ( CNT==24)   INT_STATUS     <=R_DATA ;   
   else if ( CNT==25)   I2C_MST_STATUS <=R_DATA ; 
	else if ( CNT==26)   WIA            <=R_DATA;	   
	  ST<=10 ; 	     
	  CNT<=CNT+1 ;   
	 end
	end              
10: begin   
	    if (CNT ==READ_REG_MAX ) CNT <= 0 ; 		 
		 else if ( ( CNT==18) && ( ST1[0]==0 ) ) CNT <= 17;
	    ST<=1 ; 		  	
	    W_POINTER_GO <=1;
       R_GO         <=1 ;		 
	    W_WORD_GO    <=1;
		 
	 end	
	 
	 
//<----------------------------------WRITE WORD-----------------
30: begin 
    ST<=31; 
	 CNT<=0 ; 
    end	
31: begin 


if      (CNT==0) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_PWR_MGMT_1     ,8'h01};
else if (CNT==1) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_PWR_MGMT_2     ,8'h00};
else if (CNT==2) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_CONFIG         ,8'h05};
else if (CNT==3) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_GYRO_CONFIG    ,8'h18};
else if (CNT==4) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_ACCEL_CONFIG   ,8'h08};
else if (CNT==5) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_ACCEL_CONFIG_2 ,8'h09};
else if (CNT==6) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_USER_CTRL      ,8'h00};
else if (CNT==7) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MPU9250_ADDRESS, P_MPUREG_INT_PIN_CFG    ,8'h02};
else if (CNT==8) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MAG_ADDRESS,     P_CNTL2                 ,8'h01};
else if (CNT==9) {SLAVE_ADDR ,W_WORD_REG[7:0] ,W_WORD_DATA[7:0]}<= { MAG_ADDRESS,     P_CNTL1                 ,8'h12};		

	   begin  
	     W_WORD_GO  <=0; 
		  ST<=32 ; 
		  DELY<=0; 
	   end
	 end     
32: begin 
      DELY  <=DELY +1;
      if ( DELY == 5 ) 
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
     DELY <= 0 ;
	  if   ( CNT==10 )  begin 
	          ST <=40 ;  
				 CNT<=0 ; end 
	   else  begin 
	     ST <= 31 ;  //delay 
		end 
	  end 
//  --delay 
40: begin 
       DELY  <=DELY +1;
		 if (  DELY ==40000 )   ST <= 1 ;  
	 end 
	 
	 
endcase 
end 

//--I2C-BUS-WIRE--

assign I2C_SCL = W_POINTER_SCL  & R_SCL  & W_WORD_SCL; 
assign SDAO    = W_POINTER_SDAO & R_SDAO & W_WORD_SDAO ;
assign I2C_SDA = (SDAO)?1'bz :1'b0 ; 


//----I2C WRITE WORD--
I2C_WRITE_WORD_2BYTE  wrd(
//I2C_WRITE_WORD  wrd(
   .RESET_N      ( RESET_N),
	.PT_CK        ( CLK_400K),
	.GO           ( W_WORD_GO),
	.POINTER      ( W_WORD_REG),
	.WDATA0 		  ( W_WORD_DATA),
	//.WDATA1,
	.NUM (1)  , 
	
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

I2C_READ_2BYTE rid( 	
   .RESET_N      (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (R_GO),
	.SLAVE_ADDRESS(SLAVE_ADDR),	
	.SDAI         (I2C_SDA),
	.SDAO         (R_SDAO),
	.SCLO         (R_SCL),
	.END_OK       (R_END),
	.END_BYTE     (0),
	.DATA16       (R_DATA[7:0])

);



endmodule 
	
	
	