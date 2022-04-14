module HEX2BCD (
 input  iCLK_50 ,
 input  [7:0]iHEX,
 output  reg [7:0]oBCD,
 output oBCD_V
 
);

wire  [7:0]DEC;
wire  [7:0]BCD  ;

assign oBCD_V  =  iHEX /100 ;
assign DEC[7:4] = (iHEX -oBCD_V *100 )/10 ; 
assign DEC[3:0] = iHEX - ( oBCD_V *100 + DEC[7:4] * 10) ; 

reg [31:0] T ;
reg HZ_05 ;

always @(posedge iCLK_50 )  begin 
 if ( T > 14000000 ) 
        begin  T <=0; HZ_05 <=~HZ_05 ;end 
 else T<=T+1 ;
end


always @(posedge HZ_05 ) begin 
	oBCD[7:4] <= DEC[7:4] ;
   oBCD[3:0] <= DEC[3:0] ;
end	


//assign oBCD[7:4] = DEC[7:4] ;
//assign oBCD[3:0] = DEC[3:0] ;


endmodule
