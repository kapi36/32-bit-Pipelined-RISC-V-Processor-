`timescale 1ns / 1ps
module FloatingAddition (input [31:0]A,
   						 input [31:0]B,                  
   						 output reg  [31:0] result);

reg [23:0] A_Mantissa,B_Mantissa; // Mantissa is only 22 bit but one extra bit is added
reg [23:0] Temp_Mantissa;
reg [22:0] Mantissa;// main mantissa 
reg [7:0] Exponent; // 8 bit main exponent 
reg Sign;
wire MSB;
reg [7:0] A_Exponent,B_Exponent,diff_Exponent; // 8 bit exponent
reg A_sign,B_sign;
reg [32:0] Temp;
reg carry;
reg comp;
reg [7:0] exp_adjust;
  
  
always @(*)
begin

  comp =  (A[30:23] >= B[30:23])? 1'b1 : 1'b0; // Comparring the exponent size 
  A_Mantissa = comp ? {1'b1,A[22:0]} : {1'b1,B[22:0]};// if value of exponent of a is greter then b then putting the value of a mantissa in a. 
A_Exponent = comp ? A[30:23] : B[30:23];
A_sign = comp ? A[31] : B[31];
  
B_Mantissa = comp ? {1'b1,B[22:0]} : {1'b1,A[22:0]};
B_Exponent = comp ? B[30:23] : A[30:23];
B_sign = comp ? B[31] : A[31];

diff_Exponent = A_Exponent-B_Exponent;
B_Mantissa = (B_Mantissa >> diff_Exponent);// we know that we put the less exponent value in b- mantissa
  
{carry,Temp_Mantissa} =  (A_sign ~^ B_sign)? A_Mantissa + B_Mantissa : A_Mantissa-B_Mantissa ; 
exp_adjust = A_Exponent;
  
if(carry)
    begin
        Temp_Mantissa = Temp_Mantissa>>1; // right shift  
        exp_adjust = exp_adjust+1'b1; // after right shifting we got one extra exponent we added the exponent 
    end
else
    begin
      while(!Temp_Mantissa[23])// if my temp mantissa 24 bit is zero then do left shift until and unless it becomes 1 and decrease the exponent as we shifting left the number 
        begin
           Temp_Mantissa = Temp_Mantissa<<1;
           exp_adjust =  exp_adjust-1'b1;
        end
    end
Sign = A_sign;
Mantissa = Temp_Mantissa[22:0];
Exponent = exp_adjust;
result = {Sign,Exponent,Mantissa};

end
endmodule
