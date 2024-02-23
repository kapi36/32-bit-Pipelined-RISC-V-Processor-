`timescale 1ns / 1ps
module FloatingMultiply(input [31:0]A,
                     input [31:0]B,
                     output reg  [31:0] result);

reg [23:0] A_Mantissa,B_Mantissa;//24 bit Mantissa for A and B 
reg [22:0] Mantissa;// Answer mantissa
 reg [47:0] Temp_Mantissa;//Multiply answer store here
  reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,Exponent;// 8 bit a exponent b exponent Temporary store exponent,answer expoenent
reg A_sign,B_sign,Sign;
reg [32:0] Temp;
reg [6:0] exp_adjust;
  integer i = 0 ;

  
 
always@(*)
begin
  A_Mantissa = {1'b1,A[22:0]};//Storing A values
A_Exponent = A[30:23];
A_sign = A[31];
  
  B_Mantissa = {1'b1,B[22:0]}; // Stroing B values
B_Exponent = B[30:23];
B_sign = B[31];

  Temp_Mantissa = A_Mantissa*B_Mantissa ; 
  Temp_Exponent = A_Exponent + B_Exponent -127 ; 
  
  if (Temp_Mantissa[47])begin 
    Mantissa = Temp_Mantissa[46:24] ; 
    Exponent =  Temp_Exponent+1'b1 ; 
  end
  else if(Temp_Mantissa[46])begin
    Mantissa = Temp_Mantissa[45:23]; 
     Exponent =  Temp_Exponent; 
  end
  
  else if (!Temp_Mantissa[46])begin 
     i = 1 ; 
    while(Temp_Mantissa[46-i] == 0 )begin 
      i = i+1 ; 
    end
    
    Exponent =  Temp_Exponent- i ;
    Temp_Mantissa = Temp_Mantissa<< i ; 
    Mantissa = Temp_Mantissa[45:23] ; 
  end
Sign = A_sign^B_sign;
result = {Sign,Exponent,Mantissa};
end
endmodule
