module Fuzzy_Controller (
input  						RESET_N ,
input  						CLOCK_50,
input  			[15:0]	Real_Temperature_User_A,
input				[15:0]	Real_Temperature_User_B,
input  			[2:0]		Heat_Feeling_User_A,
input				[2:0]		Heat_Feeling_User_B,

output	reg				PWM_Heater_User_A,
output	reg				PWM_Heater_User_B
);

//Clock Assignment
parameter 					CntValue = 50000000;
reg   			[31:0]   Clk_Cnt_2Hz;
reg							Clk_2Hz;
reg	 			[7:0]		PWM_Counter;

//Weight Assignment
//Weight_1 = 0%  , Weight_2 = 25%  , Weight_3 = 50%
//Weight_4 = 75% , Weight_5 = 100%
reg				[15:0]	Weight_1_A;
reg				[15:0]	Weight_2_A;
reg 				[15:0]	Weight_3_A;
reg 				[15:0]	Weight_4_A;
reg 				[15:0]	Weight_5_A;
reg				[15:0]	Weight_1_B;
reg				[15:0]	Weight_2_B;
reg 				[15:0]	Weight_3_B;
reg 				[15:0]	Weight_4_B;
reg 				[15:0]	Weight_5_B;

reg				[7:0]		DutyCycle_Heater_User_A;
reg				[7:0]		DutyCycle_Heater_User_B;

//Get 2Hz ClocK for fuzzy controller
always @(posedge CLOCK_50) begin
	if ( Clk_Cnt_2Hz >= ((CntValue/(2*2))-1)) begin
		Clk_2Hz <= ~ Clk_2Hz;
		Clk_Cnt_2Hz <= 0;
	end else begin
		Clk_2Hz <= Clk_2Hz;
		Clk_Cnt_2Hz <= Clk_Cnt_2Hz +1;
	end
end


always@(posedge CLOCK_50) begin  //PWM產生
	if (PWM_Counter <= 255) begin
		PWM_Counter <= PWM_Counter + 1;
	end else begin
		PWM_Counter <= 0;
	end
	
end

//User A's fuzzy controller
always @(posedge Clk_2Hz) begin
	case(Heat_Feeling_User_A)
		3'b011: begin //+3:Very Hot
			Weight_1_A <= 0;
			Weight_2_A <= 0;
			Weight_3_A <= 0;
			Weight_4_A <= 0;
			Weight_5_A <= 0;
		end
		3'b010: begin //+2:Hot
			Weight_1_A <= 0;
			Weight_2_A <= 0;
			Weight_3_A <= 0;
			Weight_4_A <= 0;
			Weight_5_A <= 0;
		end
		3'b001: begin //+1:Warm
			Weight_1_A <= 0;
			Weight_2_A <= 1000;
			Weight_3_A <= 0;
			Weight_4_A <= 0;
			Weight_5_A <= 0;
		end
		3'b101: begin //-1:Cool
			Weight_1_A <= 0;
			Weight_2_A <= 0;
			Weight_3_A <= 1000;
			Weight_4_A <= 0;
			Weight_5_A <= 0;
		end
		3'b110: begin //-2:Cold
			Weight_1_A <= 0;
			Weight_2_A <= 0;
			Weight_3_A <= 0;
			Weight_4_A <= 1000;
			Weight_5_A <= 0;
		end
		3'b111: begin //-3:Very Cold
			Weight_1_A <= 0;
			Weight_2_A <= 0;
			Weight_3_A <= 0;
			Weight_4_A <= 0;
			Weight_5_A <= 1000;
		end
		default: begin
			Weight_1_A <= 0;
			Weight_2_A <= 0;
			Weight_3_A <= 0;
			Weight_4_A <= 0;
			Weight_5_A <= 0;
		end
	endcase
end

//User B's fuzzy controller
always @(posedge Clk_2Hz) begin
	case(Heat_Feeling_User_B)
		3'b011: begin //+3:Very Hot
			Weight_1_B <= 0;
			Weight_2_B <= 0;
			Weight_3_B <= 0;
			Weight_4_B <= 0;
			Weight_5_B <= 0;
		end
		3'b010: begin //+2:Hot
			Weight_1_B <= 0;
			Weight_2_B <= 0;
			Weight_3_B <= 0;
			Weight_4_B <= 0;
			Weight_5_B <= 0;
		end
		3'b001: begin //+1:Warm
			Weight_1_B <= 0;
			Weight_2_B <= 1000;
			Weight_3_B <= 0;
			Weight_4_B <= 0;
			Weight_5_B <= 0;
		end
		3'b101: begin //-1:Cool
			Weight_1_B <= 0;
			Weight_2_B <= 0;
			Weight_3_B <= 1000;
			Weight_4_B <= 0;
			Weight_5_B <= 0;
		end
		3'b110: begin //-2:Cold
			Weight_1_B <= 0;
			Weight_2_B <= 0;
			Weight_3_B <= 0;
			Weight_4_B <= 1000;
			Weight_5_B <= 0;
		end
		3'b111: begin //-3:Very Cold
			Weight_1_B <= 0;
			Weight_2_B <= 0;
			Weight_3_B <= 0;
			Weight_4_B <= 0;
			Weight_5_B <= 1000;
		end
		default: begin
			Weight_1_B <= 0;
			Weight_2_B <= 0;
			Weight_3_B <= 0;
			Weight_4_B <= 0;
			Weight_5_B <= 0;
		end
	endcase
end


always @(posedge CLOCK_50) begin
	DutyCycle_Heater_User_A <= (((25 * Weight_2_A / 1000) + (50 * Weight_3_A / 1000) + (75 * Weight_4_A / 1000) + (Weight_5_A))*255)/100; //0% to 100%
	DutyCycle_Heater_User_B <= (((25 * Weight_2_B / 1000) + (50 * Weight_3_B / 1000) + (75 * Weight_4_B / 1000) + (Weight_5_B))*255)/100; //0% to 100%
end


always@(posedge CLOCK_50) begin
	if (PWM_Counter < DutyCycle_Heater_User_A) begin
		PWM_Heater_User_A <= 1;
	end else begin
		PWM_Heater_User_A <= 0;
	end
end
always@(posedge CLOCK_50) begin
	if (PWM_Counter < DutyCycle_Heater_User_B) begin
		PWM_Heater_User_B <= 1;
	end else begin
		PWM_Heater_User_B <= 0;
	end
end


endmodule