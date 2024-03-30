// Code your design here
// Code your design here
module RISCV_32(clk1,clk2);
  input clk1,clk2;  //Two phase clock
  
  reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
  reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
  reg [3:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
  reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B, EX_MEM_cond;
  reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
  reg [31:0] EX_MEM_cond1 , EX_MEM_cond2, EX_MEM_cond3,EX_MEM_cond4;
  reg [63:0] Reg_For_Mul; 
 
  
  reg [31:0] Reg [0:31];  // Register bank of 32 registers with each registers of 32 bit width
  reg [31:0] Mem [0:1023]; // Memory of 1024 locations with each location having 32 bit 
  reg [31:0] D_Mem[0:1023]; 
  
  
  reg HALTED;         //set after hlt instruction is completed (in WB stage)
  reg TAKEN_BRANCH;   //Required to disable instructions after branch
  
  
  // variables for stall cntrol unit
  reg PC_Write_En    =1'b1;
  reg IF_ID_Write_En =1'b1;
  reg Stall_flush    =1'b0;

  
  //VARIABLES FOR FORWARDING UNIT
  reg [1:0] ForwardA = 2'b00;
  reg [1:0] ForwardB = 2'b00;
  reg MEM_WB_FORWARDED_A=0;
  reg MEM_WB_FORWARDED_B=0;
  
  
  //Instruction set
  // Format R type 
  parameter ADD  = 7'b0000000; //
  parameter SUB  = 7'b0000001; //
  parameter AND  = 7'b0000010; //
  parameter OR   = 7'b0000011; //
  parameter XOR  = 7'b0000100; //
  parameter SLT  = 7'b0000101; //
  parameter SLTU = 7'b0000110; // Shift less than unsigned 
  parameter SLL  = 7'b0000111; // shift left logical 
  parameter SRL  = 7'b0001000; // shift right logic 
  parameter SRA  = 7'b0001001; // shift Right Arithmetic 
  
  
  
  parameter ADDI  = 7'b0001010; //
  parameter SUBI  = 7'b0001011; //
  parameter ANDI  = 7'b0001100; //
  parameter ORI   = 7'b0001101; //
  parameter XORI  = 7'b0001110; //
  parameter SLTI  = 7'b0001111; //
  parameter SLTIU = 7'b0010000; // Shift less than Immediate unsigned 
  parameter SLLI  = 7'b0010001; // shift left logical immediate 
  parameter SRLI  = 7'b0010010; // shift right logic immediate
  parameter SRAI  = 7'b0010011; // shift Right Arithmetic immediate
  parameter NOP   = 7'b0010100; //same as ADDI R0,R0,0
 
  
  // U type format for base isa 
  parameter LW  = 7'b0010101; //
  parameter LB  = 7'b0010110;// DONE
  parameter LH  = 7'b0010111; // DONE
  parameter LBU = 7'b0011000; //
  parameter LHU = 7'b0011001; //
  parameter LUI = 7'b0011010;  //
  parameter AUIPC = 7'b0011011; 
  parameter SW  = 7'b0011100; //
  parameter SB  = 7'b0011101;  //
  parameter SH  = 7'b0011110; 
  
  
  parameter BEQZ = 7'b0011111; 
  parameter BNEQZ= 7'b0100001; 
  parameter BLT  = 7'b0100010; 
  parameter BGE  = 7'b0100011; 
  parameter BLTU = 7'b0100100;
  parameter BGEU = 7'b0100101; 
  parameter JLR =  7'b0100110; 
  
  parameter HLT = 7'b1111111; 
  
  // M extenstion instruction ; 
  
  parameter MUL   = 7'b0100111; 
  parameter MULH  = 7'b0101000;
  parameter MULHU = 7'b0101001;
  parameter MULHSU= 7'b0101010;
  parameter DIV   = 7'b0101011; 
  parameter DIVU  = 7'b0101100;
  parameter REM   = 7'b0101101; 
  parameter REMU  = 7'b0101110; 
  
  
//Instruction type
  parameter RR_ALU  = 4'b0000;
  parameter RM_ALU  = 4'b0001;
  parameter LOAD    = 4'b0010;
  parameter STORE   = 4'b0011;
  parameter BRANCH  = 4'b0100;
  parameter HALT    = 4'b0101;
  parameter JUMP    = 4'b0110; 
  parameter LOAD_UPPER_Imm = 4'b1101; 

  
  
  //INSTRUCTION FETCH (IF) STAGE
  always@(posedge clk1)
    if (HALTED==0 && PC_Write_En==1'b1)///////-----------------------------PC_Write_En    =1'b1
      begin
        if ((( EX_MEM_IR[31:25] == BEQZ ) && (EX_MEM_cond == 1)) || 
            (( EX_MEM_IR[31:25] == BNEQZ ) && ( EX_MEM_cond == 0 ))||
            (( EX_MEM_IR[31:25] == BGE ) && ( EX_MEM_cond1 == 1 )) ||
            (( EX_MEM_IR[31:25] == BLT ) && ( EX_MEM_cond2 == 1 )) ||
            (( EX_MEM_IR[31:25] == BGEU) && ( EX_MEM_cond3 == 1 )) ||
            (( EX_MEM_IR[31:25] == BLTU) && ( EX_MEM_cond4 == 1 )) ||
            
            ( EX_MEM_IR[31:25] == JLR ))
            begin
              IF_ID_IR       <=#2 Mem[EX_MEM_ALUOut];
              TAKEN_BRANCH   <=#2 1'b1;
              IF_ID_NPC      <=#2 EX_MEM_ALUOut +1;
              PC             <=#2 EX_MEM_ALUOut +1;
            end
           else
             begin
               IF_ID_IR   <=#2 Mem[PC];
               IF_ID_NPC  <=#2 PC+1;
               PC         <=#2 PC+1;
             end
       end
  
  
  
  
              
  //INSTRUCTION DECODE (ID) Stage
  always @ (posedge clk2)
    begin
      if (HALTED == 0  && IF_ID_Write_En ==1'b1)/////----------IF_ID_Write_En =1'b1
        begin
                if (IF_ID_IR [24:20]==5'b00000)
                     ID_EX_A <= #2 0;
                else
                  ID_EX_A <=#2 Reg[IF_ID_IR[24:20]];
          
                if (IF_ID_IR [19:15]==5'b00000)
                     ID_EX_B <=#2 0;
                else
                  ID_EX_B <=#2 Reg[IF_ID_IR[19:15]];
                
                
                ID_EX_IR  <=  #2 IF_ID_IR;
                ID_EX_NPC <=  #2 IF_ID_NPC;
                ID_EX_Imm <=  #2 {{17{IF_ID_IR[14]}}, { IF_ID_IR[14:0]}};
          case (IF_ID_IR[31:25])               
            ADD,SUB,AND,OR,XOR,SLT,SLTU,SLL,SRL,SRA,MUL,MULH,MULHU,
            MULHSU,DIV,DIVU,REM,REMU: ID_EX_type <=#2 RR_ALU;  
               
            ADDI,SUBI,SLTI, SLTIU ,ANDI, ORI,XORI,SLLI,SRLI,SRAI,
            NOP  : ID_EX_type <=#2 RM_ALU;
            
            LW,LB,LH,LBU,LHU       : ID_EX_type <=#2 LOAD;
            
            LUI,AUIPC              : ID_EX_type <= #2LOAD_UPPER_Imm;
            
            SW,SB,SH	           : ID_EX_type <=#2 STORE;
            
            BEQZ,BNEQZ,BLT,BGE,BLTU,BGEU : ID_EX_type <=#2 BRANCH;
            
            JLR 				   : ID_EX_type <=#2 JUMP;
            
            HLT                    : ID_EX_type <=#2 HALT;
             
            
            default                : ID_EX_type <=#2 HALT;
                endcase         
              end
        
      
      
  ////////stall control unit/////////////
      if ((ID_EX_type == 4'b0010) && ((ID_EX_IR[19:15] == IF_ID_IR[24:20])|| (ID_EX_IR[19:15] == IF_ID_IR[19:15])))
  begin
  PC_Write_En=1'b0;
  IF_ID_Write_En=1'b0;
  Stall_flush =1'b1;
  end
  else
  begin
  PC_Write_En=1'b1;
  IF_ID_Write_En=1'b1;
  Stall_flush =1'b0;
  end
  ///////////////////////////////////////
  end
     
  
  
  
  
 // EXECUTION Stage
           
 always @ ( posedge clk1)

      if (HALTED == 0 && Stall_flush ==1'b0)
    begin

      
      ///////Forwarding unit-2/////////////////////////////////////////
      case (EX_MEM_type)
         RR_ALU         : begin
           if ((MEM_WB_FORWARDED_A==0) && (EX_MEM_IR[14:10]!=0) &&  (EX_MEM_IR[14:10] == ID_EX_IR[24:20]))
                           begin
                             ForwardA =2'b01;
                             ID_EX_A  = EX_MEM_ALUOut; 
                           end
                          if ((MEM_WB_FORWARDED_B==0) &&(EX_MEM_IR[14:10]!=0) &&  (EX_MEM_IR[14:10] == ID_EX_IR[19:15]))
                           begin
                             ForwardB=2'b01;
                             ID_EX_B = EX_MEM_ALUOut;  
                           end
                          end
         
          RM_ALU, LOAD_UPPER_Imm        : begin
           				  if ((MEM_WB_FORWARDED_A==0) &&(EX_MEM_IR[19:15]!=0) &&  (EX_MEM_IR[19:15] == ID_EX_IR[24:20]))
                           begin
                             ForwardA =2'b01;
                             ID_EX_A  = EX_MEM_ALUOut; 
                           end
                          if ((MEM_WB_FORWARDED_B==0) &&(EX_MEM_IR[19:15]!=0) &&  (EX_MEM_IR[19:15] == ID_EX_IR[19:15]))
                            begin
                             ForwardB=2'b01;
                             ID_EX_B = EX_MEM_ALUOut;  
                           end
                          end
        
         LOAD            : begin
           				  if ((MEM_WB_FORWARDED_A==0) &&(EX_MEM_IR[19:15]!=0) &&  (EX_MEM_IR[19:15] == ID_EX_IR[24:20]))
                           begin
                             ForwardA =2'b01;
                             ID_EX_A  = MEM_WB_LMD; 
                           end
                          if ((MEM_WB_FORWARDED_B==0) &&(EX_MEM_IR[19:15]!=0) &&  (EX_MEM_IR[19:15] == ID_EX_IR[19:15]))
                            begin
                             ForwardB=2'b01;
                             ID_EX_B = MEM_WB_LMD;  
                           end
                          end
        endcase

      
       if (ForwardA == 2'b00) 
         begin
           ID_EX_A <= ID_EX_A;
         end
     
       else if (ForwardA == 2'b01)
        begin
          ForwardA <=#2 2'b00;
        end
      
       else if (ForwardA == 2'b10)
        begin
          MEM_WB_FORWARDED_A <=#2 0;
          ForwardA <=#2 2'b00;
        end
          
                
      if (ForwardB == 2'b00) 
         begin
           ID_EX_B <= ID_EX_B;
         end
     
      else if (ForwardB == 2'b01)
        begin
          ForwardB <=#2 2'b00;
        end
      
      else if (ForwardB == 2'b10)
        begin
          MEM_WB_FORWARDED_B <=#2 0;
          ForwardB <=#2 2'b00;
        end
          
      //////////////////////////////////////////////////////////////////////////////
 
      
      
      EX_MEM_type  <=#2  ID_EX_type;
      EX_MEM_IR    <=#2  ID_EX_IR;
      TAKEN_BRANCH <=#2  0;
      #2;//to stop the execution until the value of ID_EX_A and ID_EX_B IS NOT CHANGED BY THE FORWARDING UNIT
      case ( ID_EX_type)
        
        RR_ALU: begin
        
          case( ID_EX_IR[31:25] )  //OPCODE
              ADD : EX_MEM_ALUOut  <=#2 ID_EX_A + ID_EX_B;
              SUB : EX_MEM_ALUOut  <=#2 ID_EX_A - ID_EX_B;
              AND : EX_MEM_ALUOut  <=#2 ID_EX_A & ID_EX_B;
              OR  : EX_MEM_ALUOut  <=#2 ID_EX_A | ID_EX_B; 
              XOR : EX_MEM_ALUOut  <=#2 ID_EX_A ^ ID_EX_B;
              SLT : EX_MEM_ALUOut  <=#2 ($signed(ID_EX_A) < $signed(ID_EX_B) )? 1:0;
              SLTU : EX_MEM_ALUOut  <=#2 (ID_EX_A < ID_EX_B )? 1:0;
              SLL : EX_MEM_ALUOut  <=#2 ID_EX_A << ID_EX_B;
              SRL : EX_MEM_ALUOut  <=#2 ID_EX_A >> ID_EX_B;
              SRA : EX_MEM_ALUOut  <=#2 ID_EX_A >>>ID_EX_B;
              MUL :  EX_MEM_ALUOut <=#2($signed(ID_EX_A)* $signed(ID_EX_B));  
            MULH : EX_MEM_ALUOut <=#2 ($signed(ID_EX_A)* $signed(ID_EX_B))>>32;  
            MULHU : EX_MEM_ALUOut <=#2 (ID_EX_A * ID_EX_B)>>32;  
            MULHSU :EX_MEM_ALUOut <=#2 ($signed(ID_EX_A) * ID_EX_B)>> 32 ; 
            DIV :  EX_MEM_ALUOut <=#2 ($signed(ID_EX_A)/ $signed(ID_EX_B)); 
            DIVU :  EX_MEM_ALUOut <=#2 (ID_EX_A/ ID_EX_B) ; 
            REM  :  EX_MEM_ALUOut <=#2 ($signed(ID_EX_A) % ID_EX_B); 
            REMU :  EX_MEM_ALUOut <=#2 (ID_EX_A % ID_EX_B) ; 
              
                default : EX_MEM_ALUOut <=#2 32'hxxxxxxxx;
              endcase
              end
        
        RM_ALU:  begin          
          case(ID_EX_IR[31:25])
                 ADDI : EX_MEM_ALUOut <=#2 ID_EX_A + ID_EX_Imm;
                 SUBI : EX_MEM_ALUOut <=#2 ID_EX_A - ID_EX_Imm;
                 SLTIU : EX_MEM_ALUOut <=#2 (ID_EX_A < ID_EX_Imm) ? 1:0;
                 SLTI : EX_MEM_ALUOut <=#2 ($signed(ID_EX_A) < $signed(ID_EX_Imm)) ? 1:0;
                 ANDI : EX_MEM_ALUOut <=#2 ID_EX_A & ID_EX_Imm;
                 ORI  : EX_MEM_ALUOut <=#2 ID_EX_A | ID_EX_Imm;
                 XORI : EX_MEM_ALUOut <=#2 ID_EX_A ^ ID_EX_Imm;
                 SLLI : EX_MEM_ALUOut <=#2 ID_EX_A << ID_EX_Imm;
                 SRLI : EX_MEM_ALUOut <=#2 ID_EX_A >> ID_EX_Imm;
                 SRAI : EX_MEM_ALUOut <=#2 ID_EX_A >>> ID_EX_Imm;
                 NOP  : EX_MEM_ALUOut <=#2 ID_EX_A +  ID_EX_Imm;
                 default:EX_MEM_ALUOut <=#2 32'hxxxxxxxx;
                 endcase
                 end
         LOAD, STORE : begin
                       EX_MEM_ALUOut <=#2 ID_EX_A + ID_EX_Imm; 
                       EX_MEM_B      <=#2 ID_EX_B;
                       end
         LOAD_UPPER_Imm : begin
           EX_MEM_ALUOut <=#2  {ID_EX_IR[24:21], ID_EX_IR[15:0],12'b0}; 
           EX_MEM_B      <=#2 ID_EX_B;
                       end
         BRANCH: begin
           
           EX_MEM_ALUOut <=#2   ID_EX_NPC + $signed(ID_EX_Imm);
           EX_MEM_cond   <=#2   (ID_EX_A ==0);// Condition for BEQZ , BNEQZ 
           EX_MEM_cond1 <= #2   ($signed(ID_EX_A) > $signed(ID_EX_B)) ; // Condition for BGE 
           
           EX_MEM_cond2 <= #2   ($signed(ID_EX_A) <= $signed(ID_EX_B)) ;  // Condition for BLT
           
           EX_MEM_cond3 <= #2   (ID_EX_A >= ID_EX_B) ; //BGEU
           EX_MEM_cond4 <= #2   (ID_EX_A < ID_EX_B); //BLTU
                 end
          JUMP: EX_MEM_ALUOut <=#2 ID_EX_NPC + ID_EX_Imm;
        
       endcase
    end
   
 // MEM STAGE
            
 always @ (posedge clk2)
   if (HALTED == 0)
     begin
       
       
       
       
       ////////////////////////////////FORWARDING UNIT-1/////////////////////////////////////
       case (MEM_WB_type)
         RR_ALU         : begin
           if ((MEM_WB_IR[14:10]!=0) && ( MEM_WB_IR[14:10] == IF_ID_IR[24:20]))
                           begin
                             ForwardA=2'b10;
                             ID_EX_A =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_A=1;
                           end
                          if ((MEM_WB_IR[14:10]!=0) && (MEM_WB_IR[14:10] == IF_ID_IR[20:16]))
                           begin
                             ForwardB=2'b10;
                             ID_EX_B =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_B=1;
                           end
                          end
         
          RM_ALU, LOAD_UPPER_Imm         : begin
            if ((MEM_WB_IR[19:15]!=0) && ( MEM_WB_IR[19:15] == IF_ID_IR[24:20]))
                           begin
                             ForwardA=2'b10;
                             ID_EX_A =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_A=1;
                           end
                          if ((MEM_WB_IR[19:15]!=0) && (MEM_WB_IR[19:15]  == IF_ID_IR[20:16]))
                           begin
                             ForwardB=2'b10;
                             ID_EX_B =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_B=1;
                           end
                          end
        endcase
       ///////////////////////////////////////////////////////////////////////////////////////////////
       
      
       
       MEM_WB_type <= #2 EX_MEM_type;
       MEM_WB_IR   <= #2 EX_MEM_IR;
       
       case (EX_MEM_type)
         RR_ALU, RM_ALU :   MEM_WB_ALUOut <=#2 EX_MEM_ALUOut;
         LOAD 			:   MEM_WB_LMD    <=#2 D_Mem[EX_MEM_ALUOut];
         
         LOAD_UPPER_Imm :   MEM_WB_ALUOut  <=#2 EX_MEM_ALUOut;
         
         STORE :  begin
           case( EX_MEM_IR[31:25] )        
             SW: begin 
               if (TAKEN_BRANCH == 0)
                 D_Mem [EX_MEM_ALUOut] <=#2 EX_MEM_B; end 
             SB : begin 
               if (TAKEN_BRANCH == 0) 
                 D_Mem [EX_MEM_ALUOut] <=#2{{24{EX_MEM_B[7]}},{EX_MEM_B[7:0]}}; end
             
             SH : begin 
               if (TAKEN_BRANCH == 0) 
                 D_Mem [EX_MEM_ALUOut] <=#2{{16{EX_MEM_B[15]}},{EX_MEM_B[15:0]}};end
           endcase 
             end
           				   
        endcase
     end
  
  
            
            
 //WB STAGE
 always @ (posedge clk1)
   begin
     if( TAKEN_BRANCH == 0)
       case (MEM_WB_type)
         RR_ALU: Reg[MEM_WB_IR[14:10]] <=#2 MEM_WB_ALUOut;
         RM_ALU: Reg[MEM_WB_IR[19:15]] <=#2 MEM_WB_ALUOut;
         
         LOAD_UPPER_Imm : begin 
           case( MEM_WB_IR[31:25] )  
             LUI : Reg[MEM_WB_IR[19:15]] <=#2 MEM_WB_ALUOut;
             AUIPC: Reg[MEM_WB_IR[19:15]] <=#2 MEM_WB_ALUOut +PC;
           endcase 
         end
         
         LOAD  : begin
           case( MEM_WB_IR[31:25] )   
             LW:  Reg[MEM_WB_IR[19:15]] <=#2 MEM_WB_LMD;
             LB: Reg[MEM_WB_IR[19:15]] <= #2 {{24{MEM_WB_LMD[7]}},  {MEM_WB_LMD[7:0]}};
             LH : Reg[MEM_WB_IR[19:15]] <= #2 {{16{MEM_WB_LMD[15]}}, { MEM_WB_LMD[15:0]}} ; 
             LBU: Reg[MEM_WB_IR[19:15]] <= #2 {24'b0,MEM_WB_LMD[7:0]};
             LHU : Reg[MEM_WB_IR[19:15]] <= #2 {16'b0,MEM_WB_LMD[15:0]};
           endcase 
         end
         
         HALT:   HALTED <=#2 1'b1;
       endcase
   end           
  endmodule
            
