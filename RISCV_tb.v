module test_risc32;
  reg clk1, clk2;
  integer k,i;
  RISCV_32 risc (clk1, clk2);
  initial
  begin
    clk1 = 1;
    clk2 = 0;
    forever // Generating two-phase clock
    begin
      #5 clk1 = 0;
      #5 clk2 = 1;
      #5 clk2 = 0;
      #5 clk1 = 1;
    end
  end
  
//   //MOVE R1,R2----5 cycles
//   initial
//   begin
//     for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h4801000a; // ADDI R1,R0,10
//     risc.Mem[1] = 32'h48020014; // ADDI R2,R0,20
//     risc.Mem[2] = 32'h60400800; // MOVE R1,R2---- SAME AS ADD R1,R2,R0
//     risc.Mem[3] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%0t, R1= %0d, R2=%0d",$time,$signed(risc.Reg[1]),$signed(risc.Reg[2]));
//   end
  
  
  
//   //ADD R4,R1,R2----> SUB R5,R4,R3--- 7 clk cycle
//   initial
//   begin
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h4801000a; // ADDI R1,R0,10
//     risc.Mem[1] = 32'h48020014; // ADDI R2,R0,20 
//     risc.Mem[2] = 32'h4803001e; // ADDI R3,R0,30
//     risc.Mem[3] = 32'h00222000; // ADD R4,R1,R2
//     risc.Mem[4] = 32'h04832800; // SUB R5,R4,R3
//     risc.Mem[5] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
    
    
    
//     $monitor ("time=%0t, R1= %0d,R2=%0d,R3=%0d,R4=%0d,R5=%0d, MEM_WB_FORWARDED_A=%0d,MEM_WB_FORWARDED_B=%0d, ForwardA=%0d,ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0h",$time,risc.Reg[1],risc.Reg[2],risc.Reg[3],risc.Reg[4],risc.Reg[5],risc.MEM_WB_FORWARDED_A,risc.MEM_WB_FORWARDED_B,risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);
//   end

  
  
  
  
//   //LOGICAL OPOERATIONS----10 clk cycle
//   initial
//   begin
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h4801000a; // ADDI R1,R0,10
//     risc.Mem[1] = 32'h48020014; // ADDI R2,R0,20 
//     risc.Mem[2] = 32'h4803001e; // ADDI R3,R0,30
//     risc.Mem[3] = 32'h10222000; // AND R4,R1,R2
//     risc.Mem[4] = 32'h14832800; // OR R5,R4,R3
//     risc.Mem[5] = 32'h18a43000; // XOR R6,R5,R4
//     risc.Mem[6] = 32'h50280014; // ANDI R8,R1,20
//     risc.Mem[7] = 32'h5449001e; // ORI R9,R2,30
//     risc.Mem[8] = 32'h586a000a; // XORI R10,R3,10
//     risc.Mem[9] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%2t, R1= %2d, R2=%2d, R3=%2d, R4=%2d, R5=%2d,  R6=%2d, R7=%2d, R8=%2d, R9=%2d, R10=%2d, ForwardA=%0d,ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0",$time,risc.Reg[1],risc.Reg[2],risc.Reg[3],risc.Reg[4],risc.Reg[5],risc.Reg[6],risc.Reg[7],risc.Reg[8],risc.Reg[9],risc.Reg[10],risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);
  
  
//   end

  
  
// // //LOAD,STORE,BNEQZ Demonstration using Factorial code
//   initial
//   begin
    
//     risc.D_Mem[200] = 9;
    
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h480100c8; // ADDI R1,R0,200
//     risc.Mem[1] = 32'h48020001; //ADDI R2,R0,1
//     risc.Mem[2] = 32'h1c230000; //LW R3, 0(R1)
//     risc.Mem[3] = 32'h08431000; //LOOP: MUL R2,R2,R3
//     risc.Mem[4] = 32'h4c630001; //SUBI R3,R3,1
//     risc.Mem[5] = 32'h4460fffd; //BNEQZ R3,LOOP---->LOOP=-4(as pc will store the address of the next instruction, so to go back to the loop statement Vlaue of LOOP should be -3
//     risc.Mem[6] = 32'h2022fffe; // SW R2,-2(R1)-- here the data should be stored only once but it is storing with each cycle because it is already in loop withput checking the condition so it will execute even if the conditon is not true
//     risc.Mem[7] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%3t,   R1= %3d,  R2=%3d,  R3=%3d,   DATA_MEM[200]=%3d,   DATA_MEM[198]=%3d, Stall_flush=%0d, ForwardA=%0d,ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0h",$time,risc.Reg[1],risc.Reg[2],risc.Reg[3],risc.D_Mem[200],risc.D_Mem[198],risc.Stall_flush,risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);
//  end
  
  
  
  
  
  
  
  
//   ///SET LESS THAN (SLT & SLTI &SLTU)---6 clk cycle
//    initial
//   begin
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h4801fffb; // ADDI R1,R0,-5
//     risc.Mem[1] = 32'h48020004; // ADDI R2,R0,04
//     risc.Mem[2] = 32'h24221800; // SLT R3,R1,R2
//     risc.Mem[3] = 32'h5c240005; // SLTI R4,R1,5
//     risc.Mem[4] = 32'h84222800; // SLTU R5,R1,R2
//     risc.Mem[5] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%0t, R1= %0d,R2=%0d,R3=%0d,R4=%0d,R5=%0d,ForwardA=%0d,ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0h",$time,$signed(risc.Reg[1]),$signed(risc.Reg[2]),$signed(risc.Reg[3]),$signed(risc.Reg[4]),$signed(risc.Reg[5]),risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);
//   end
  
  
  
  
  
//     //SHIFT OPERATORS---5 clk cycle
//    initial
//   begin
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h48010002; // ADDI R1,R0,2
//     risc.Mem[1] = 32'h4802000a; // ADDI R2,R0,10
//     risc.Mem[2] = 32'h28411800; // SLL R3,R2,R1
//     risc.Mem[3] = 32'h34240005; // SLLI R4,R1,5
//     risc.Mem[4] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%0t, R1= %0d,R2=%0d,R3=%0d,R4=%0d, MEM_WB_FORWARDED_A=%0d,MEM_WB_FORWARDED_B=%0d, ForwardA=%0d,ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0h",$time,risc.Reg[1],risc.Reg[2],risc.Reg[3],risc.Reg[4],risc.MEM_WB_FORWARDED_A,risc.MEM_WB_FORWARDED_B,risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);

//   end
  
  
  

  
  
//    // LOAD AND STORE HALD WORD i.e 8 bits form LSB using both signed and unsigned 
//     initial
//   begin
    
//     risc.D_Mem[200] = 32'h00000123;
 
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h480100c8; // ADDI R1,R0,200
//     risc.Mem[1] = 32'h48020001; // ADDI R2,R0,1
//     risc.Mem[2] = 32'h6c230000; // LB R3, 0(R1)
//     risc.Mem[3] = 32'h74240000; // LBU R4, 0(R1)
//     risc.Mem[4] = 32'h7c240001; // SB R4, 1(R1)
//     risc.Mem[5] = 32'h7c230002; // SB R3, 2(R1)
//     risc.Mem[6] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
  
//     $monitor ("time=%3t, R1= %3h,  R2=%3h,  R3=%3h,  R4=%3h,  LMD=%3h, DATA_MEM[201]=%4h,DATA_MEM[198]=%4h,     Stall_flush=%0d, EX_MEM_B=%0h, ID_EX_B=%0h, ID_EX_type=%0h, ForwardB=%0h",$time,$signed(risc.Reg[1]),$signed(risc.Reg[2]),$signed(risc.Reg[3]),$signed(risc.Reg[4]),risc.MEM_WB_LMD,$signed(risc.D_Mem[201]),$signed(risc.D_Mem[198]),
// risc.Stall_flush, risc.EX_MEM_B,risc.ID_EX_B,risc.ID_EX_type,risc.ForwardB);
// //     $monitor("time=%0t, IF_ID_IR=%0h, ID_EX_IR=%0h, EX_MEM_IR=%0h, MEM_WB_IR=%0h,  Stall_flush=%0d",$time, risc.IF_ID_IR, risc.ID_EX_IR, risc.EX_MEM_IR, risc.MEM_WB_IR, risc. Stall_flush);
//   end
  
  
  

  
  
  
  
  
//  // Load UPPER IMMEDIATE --4 clk cycle
//       initial
//   begin
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h9d41bcde; // LUI R1,R0,abcde ---> load 20 immediates bits into register R1 
//     // 32 bit instruction looks like xxxxxx_0_dddd_rrrrr_dddddddddddddddd
//     risc.Mem[1] = 32'h54210123; //ORI R1, R1, 0123
//     risc.Mem[2] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%0t, R1= %0h, MEM_WB_FORWARDED_A=%0d,MEM_WB_FORWARDED_B=%0d, ForwardA=%0d,ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,ID_EX_Imm=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0h",$time,risc.Reg[1],risc.MEM_WB_FORWARDED_A,risc.MEM_WB_FORWARDED_B,risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.ID_EX_Imm,risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);
//   end
  
  
  
  
  
  
  
  
  
  
//   // Finding the maximum value from a given array 
//   initial
//   begin
//     risc.D_Mem[200] = 10;
//     risc.D_Mem[201] = 9;
//     risc.D_Mem[202] = 7;
//     risc.D_Mem[203] = 12;
//     risc.D_Mem[204] = 30;
//     risc.D_Mem[205] = 9;
//     risc.D_Mem[206] = 32'hffffffff;//-1
    
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
    
//     risc.Mem[0] = 32'h480100c8; // ADDI R1,R0,200   
//     risc.Mem[1] = 32'h480200d2; // ADDI R2,R0,210   
//     risc.Mem[2] = 32'h48030006; // ADDI R3,R0,6
//     risc.Mem[3] = 32'h1c240000; // LW R4, 0(R1) --> load the data at 200 location in the memory into register R4
//     risc.Mem[4] = 32'h48210001; // UP:ADDI R1,R1,1
//     risc.Mem[5] = 32'h1c250000; // LW R5, 0(R1) --> load the data at 200 location in the memory into register R4
//     risc.Mem[6] = 32'h14d73800; // OR R7,R7,R7 -- dummy instr. 
//     risc.Mem[7] = 32'h90850002; // BGE R4,R5,DOWN
//     risc.Mem[8] = 32'h14d73800; // OR R7,R7,R7 -- dummy instr. 
//     risc.Mem[9] = 32'h00a02000; // ADD R4, R5,R0    --->--> storing the largest number 
//     risc.Mem[10] = 32'h4c630001; // Down: SUBI R3,R3,1
    
//     risc.Mem[11] = 32'h4460fff8; // BNEQZ R3, UP
//     risc.Mem[12] = 32'h14d73800; // OR R7,R7,R7 -- dummy instr.
//     risc.Mem[13] = 32'h20440000; // SW R4, 0 (R2)---> STORING THE RESULT AT D_mem[210]
//     risc.Mem[14] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%3t,  R1= %3d,  R2=%3d,  R3=%3d,  R4=%3d,  R5=%3d,  DATA_MEM[210]=%3d",$time, $signed(risc.Reg[1]), $signed(risc.Reg[2]), $signed(risc.Reg[3]),  $signed(risc.Reg[4]), $signed(risc.Reg[5]), $signed(risc.D_Mem[210]));
//   end
  
 
  
  
  
// //Finding the minimum value from a given array 
//   initial
//   begin
    
//     risc.D_Mem[200] = 10;
//     risc.D_Mem[201] = 0;
//     risc.D_Mem[202] = 7;
//     risc.D_Mem[203] = 5;
//     risc.D_Mem[204] = 38;
//     risc.D_Mem[205] = 9;
//     risc.D_Mem[206] = 32'hffffffff;//-1
    
//    for (k=0; k<31; k++)
//       risc.Reg[k] = k;
//         risc.Mem[0] = 32'h480100c8; // ADDI R1,R0,200   
//     risc.Mem[1] = 32'h480200d2; // ADDI R2,R0,210   
//     risc.Mem[2] = 32'h48030006; // ADDI R3,R0,6
//     risc.Mem[3] = 32'h1c240000; // LW R4, 0(R1) --> load the data at 200 location in the memory into register R4
//     risc.Mem[4] = 32'h48210001; // UP:ADDI R1,R1,1
//     risc.Mem[5] = 32'h1c250000; // LW R5, 0(R1) --> load the data at 200 location in the memory into register R4
//     risc.Mem[6] = 32'h14d73800; // OR R7,R7,R7 -- dummy instr. 
//     risc.Mem[7] = 32'h8c850002; // BLT R4,R5,DOWN
//     risc.Mem[8] = 32'h14d73800; // OR R7,R7,R7 -- dummy instr. 
//     risc.Mem[9] = 32'h00a02000; // ADD R4, R5,R0    --->--> storing the largest number 
//     risc.Mem[10] = 32'h4c630001; // Down: SUBI R3,R3,1
//     risc.Mem[11] = 32'h4460fff8; // BNEQZ R3, UP
//     risc.Mem[12] = 32'h14d73800; // OR R7,R7,R7 -- dummy instr.
//     risc.Mem[13] = 32'h20440000; // SW R4, 0 (R2)---> STORING THE RESULT AT D_mem[210]
//     risc.Mem[14] = 32'hfc000000; // HLT
//     risc.HALTED = 0;
//     risc.PC = 0;
//     risc.TAKEN_BRANCH = 0;
//     $monitor ("time=%3t,  R1= %3d,  R2=%3d,  R3=%3d,  R4=%3d,  R5=%3d,  DATA_MEM[210]=%3d,  EX_MEM_cond=%1d,    EX_MEM_cond1=%1d",$time, $signed(risc.Reg[1]), $signed(risc.Reg[2]), $signed(risc.Reg[3]),  $signed(risc.Reg[4]), $signed(risc.Reg[5]), $signed(risc.D_Mem[210]), risc.EX_MEM_cond, risc.EX_MEM_cond1);
//   end
  
  
  
    // MOVE R1,R2----5 cycles
  initial
  begin

    risc.D_Mem[210] = 40;
    for (k=0; k<31; k++)
       risc.Reg[k] = k;
    
 
    risc.Mem[0] = 32'h480200d2; // ADDI R2,R0,210  
    risc.Mem[1] = 32'h1c410000;//  LW R1, 0(R2)
    risc.Mem[2] = 32'h00222000; // ADD R4,R1,R2
    risc.Mem[3] = 32'h04822800; // SUB R5,R4,R2
    risc.Mem[4] = 32'hfc000000; // HLT
    risc.HALTED = 0;
    risc.PC = 0;
    risc.TAKEN_BRANCH = 0;
    $monitor ("time=%0t, R1=%0d,  R2=%0d, R4=%0d, R5=%0d, Stall_flush=%0h,ForwardA=%0d, ForwardB=%0d,ID_EX_A=%0h,ID_EX_B=%0h,IF_ID_IR[20:16]=%0h,MEM_WB_ALUOut=%0h,EX_MEM_ALUOut=%0h",$time,$signed(risc.Reg[1]),$signed(risc.Reg[2]),$signed(risc.Reg[4]),$signed(risc.Reg[5]),risc.Stall_flush,risc.ForwardA,risc.ForwardB,risc.ID_EX_A,risc.ID_EX_B,risc.IF_ID_IR[20:16],risc.MEM_WB_ALUOut,risc.EX_MEM_ALUOut);
  end
 

  
  initial
  begin
    $dumpfile ("mips.vcd");
    $dumpvars (0, test_risc32);
    #2000 $finish;
  end
endmodule
