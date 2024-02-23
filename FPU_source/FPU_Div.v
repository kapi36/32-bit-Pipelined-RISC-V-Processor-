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


module FloatingMultiplication(input [31:0]A,
                     input [31:0]B,
                     output reg  [31:0] result);

reg [23:0] A_Mantissa,B_Mantissa;//24 bit Mantissa for A and B 
reg [22:0] Mantissa;// Answer mantissa
 reg [47:0] Temp_Mantissa;//Multiply answer store here
  reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,Exponent;// 8 bit a exponent b exponent Temporary store exponent,answer expoenent
reg A_sign,B_sign,Sign;
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

`timescale 1ns / 1ps

module FloatingDivision(input [31:0]A,
                        input [31:0]B,
                        output [31:0] result);
                         
reg [23:0] A_Mantissa,B_Mantissa;
reg [22:0] Mantissa;
wire [7:0] exp;
reg [7:0] A_Exponent,B_Exponent,Temp_Exponent;
wire [7:0] Exponent;
reg A_sign,B_sign,Sign;
wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7;
  wire[31:0] D = {1'b1,8'd126,B[22:0]}; // It is a negative divisor number made from b and truncted to 0.5 to 1 with help of exponent 126. 
wire [31:0] reciprocal;
wire [31:0] x0,x1,x2,x3;



/*----Initial value----*/
  FloatingMultiplication M1(.A(D),.B(32'h3ff0f0f1),.result(temp1)); //verified
FloatingAddition A1(.A(32'h4034b4b5),.B(temp1),.result(x0));

/*----First Iteration----*/
  FloatingMultiplication M2(.A(D),.B(x0),.result(temp2));
  FloatingAddition A2(.A(32'h40000000),.B(temp2),.result(temp3));
FloatingMultiplication M3(.A(x0),.B(temp3),.result(x1));

/*----Second Iteration----*/
  FloatingMultiplication M4(.A(D),.B(x1),.result(temp4));
FloatingAddition A3(.A(32'h40000000),.B(temp4),.result(temp5));
FloatingMultiplication M5(.A(x1),.B(temp5),.result(x2));

/*----Third Iteration----*/
  FloatingMultiplication M6(.A(D),.B(x2),.result(temp6));
FloatingAddition A4(.A(32'h40000000),.B(temp6),.result(temp7));
FloatingMultiplication M7(.A(x2),.B(temp7),.result(x3));

/*----Reciprocal : 1/B----*/
assign Exponent = x3[30:23]+8'd126-B[30:23];
assign reciprocal = {B[31],Exponent,x3[22:0]};

/*----Multiplication A*1/B----*/
FloatingMultiplication M8(.A(A),.B(reciprocal),.result(result));
endmodule


