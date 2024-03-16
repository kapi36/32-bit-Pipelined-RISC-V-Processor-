module RISCV_32(clk1,clk2);
  input clk1,clk2;  //Two phase clock
  
  reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
  reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
  reg [3:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
  reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B, EX_MEM_cond;
  reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
  reg [31:0] EX_MEM_cond1 , EX_MEM_cond2, EX_MEM_cond3,EX_MEM_cond4;
 
  
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
  parameter ADD = 6'b000000; //
  parameter SUB = 6'b000001; //
  parameter MUL = 6'b000010; //
  parameter DIV = 6'b000011;
  parameter AND = 6'b000100; //
  parameter OR  = 6'b000101; //
  parameter XOR = 6'b000110; //
  
 
  parameter LW  = 6'b000111; //
  parameter SW  = 6'b001000; //
  parameter SLT = 6'b001001; //
  
  parameter SLL =  6'b001010; //
  parameter SRL =  6'b001011; //
  parameter SRA =  6'b001100; //
  parameter SLLI = 6'b001101; //
  parameter SRLI = 6'b001110; //
  parameter SRAI = 6'b001111; //
  
  parameter BEQZ=  6'b010000; //
  parameter BNEQZ= 6'b010001; //
  
  parameter ADDI=  6'b010010; //
  parameter SUBI=  6'b010011; //
  parameter ANDI=  6'b010100; //
  parameter ORI=   6'b010101; //
  parameter XORI=  6'b010110; //
  parameter SLTI=  6'b010111; //
  
  parameter MOVE=  6'b011000; //MOVE R1, R2;---R1<---R2+R0// ADDD R1, R2,R0
  parameter NOP =  6'b011001; //same as ADDI R0,R0,0
  parameter JMP =  6'b011010;// Jump instruction 
  
  parameter LB  =  6'b011011; // DONE
  parameter LH  =  6'b011100; // DONE
  parameter LBU =  6'b011101; //
  parameter LHU =  6'b011110; //
  
  parameter SB  =  6'b011111; //
  parameter SH  =  6'b100000; //
   
  parameter SLTU = 6'b100001; //
  parameter SLTIU = 6'b100010; //
  
  parameter BLT = 6'b100011; //
  parameter BGE = 6'b100100; //
  parameter BLTU = 6'b100101; //
  parameter BGEU = 6'b100110; //
  
  parameter LUI = 6'b100111;  //
  parameter AUIPC = 6'b101000; //
  
  parameter HLT   = 6'b111111; //
  
  
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
        if ((( EX_MEM_IR[31:26] == BEQZ ) && (EX_MEM_cond == 1)) || (( EX_MEM_IR[31:26] == BNEQZ ) && ( EX_MEM_cond == 0 ))||
(( EX_MEM_IR[31:26] == BGE ) && ( EX_MEM_cond1 == 1 )) ||
(( EX_MEM_IR[31:26] == BLT ) && ( EX_MEM_cond2 == 1 )) ||
(( EX_MEM_IR[31:26] == BGEU) && ( EX_MEM_cond3 == 1 )) ||
(( EX_MEM_IR[31:26] == BLTU) && ( EX_MEM_cond4 == 1 )) ||
            
 ( EX_MEM_IR[31:26] == JMP ))
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
                    if (IF_ID_IR [25:21]==5'b00000)
                     ID_EX_A <= #2 0;
                    else
                     ID_EX_A <=#2 Reg[IF_ID_IR[25:21]];
                  
               
                    if (IF_ID_IR [20:16]==5'b00000)
                     ID_EX_B <=#2 0;
                    else
                      ID_EX_B <=#2 Reg[IF_ID_IR[20:16]];
                 
                
                ID_EX_IR  <=  #2 IF_ID_IR;
                ID_EX_NPC <=  #2 IF_ID_NPC;
                ID_EX_Imm <=  #2 {{16{IF_ID_IR[15]}}, { IF_ID_IR[15:0]}};
                
   
      case (IF_ID_IR[31:26])
        ADD, SUB, MUL,AND,OR,XOR,SLT,SLTU, MOVE,SLL,SRL,SRA: ID_EX_type <=#2 RR_ALU;
        ADDI,SUBI,SLTI, SLTIU ,ANDI, ORI,XORI, SLLI,SRLI,SRAI,NOP  : ID_EX_type <=#2 RM_ALU;
        LW,LB,LH,LBU,LHU       : ID_EX_type <=#2 LOAD;
        LUI,AUIPC              : ID_EX_type <= #2 LOAD_UPPER_Imm;
        SW,SB,SH	           : ID_EX_type <=#2 STORE;
       
        
        BEQZ,BNEQZ,BLT,BGE,BLTU,BGEU : ID_EX_type <=#2 BRANCH;
        JMP 				   : ID_EX_type <=#2 JUMP;
        HLT                    : ID_EX_type <=#2 HALT;
        default                : ID_EX_type <=#2 HALT;
      endcase         
  end
        
      
      
  ////////stall control unit/////////////
  if ((ID_EX_type == 4'b0010) && ((ID_EX_IR[20:16] == IF_ID_IR[25:21])|| (ID_EX_IR[20:16] == IF_ID_IR[20:16])))
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
                          if ((MEM_WB_FORWARDED_A==0) && (EX_MEM_IR[15:11]!=0) &&  (EX_MEM_IR[15:11] == ID_EX_IR[25:21]))
                           begin
                             ForwardA =2'b01;
                             ID_EX_A  = EX_MEM_ALUOut; 
                           end
                          if ((MEM_WB_FORWARDED_B==0) &&(EX_MEM_IR[15:11]!=0) &&  (EX_MEM_IR[15:11] == ID_EX_IR[20:16]))
                           begin
                             ForwardB=2'b01;
                             ID_EX_B = EX_MEM_ALUOut;  
                           end
                          end
         
          RM_ALU, LOAD_UPPER_Imm        : begin
           				  if ((MEM_WB_FORWARDED_A==0) &&(EX_MEM_IR[20:16]!=0) &&  (EX_MEM_IR[20:16] == ID_EX_IR[25:21]))
                           begin
                             ForwardA =2'b01;
                             ID_EX_A  = EX_MEM_ALUOut; 
                           end
                          if ((MEM_WB_FORWARDED_B==0) &&(EX_MEM_IR[20:16]!=0) &&  (EX_MEM_IR[20:16] == ID_EX_IR[20:16]))
                            begin
                             ForwardB=2'b01;
                             ID_EX_B = EX_MEM_ALUOut;  
                           end
                          end
        
         LOAD            : begin
           				  if ((MEM_WB_FORWARDED_A==0) &&(EX_MEM_IR[20:16]!=0) &&  (EX_MEM_IR[20:16] == ID_EX_IR[25:21]))
                           begin
                             ForwardA =2'b01;
                             ID_EX_A  = MEM_WB_LMD; 
                           end
                          if ((MEM_WB_FORWARDED_B==0) &&(EX_MEM_IR[20:16]!=0) &&  (EX_MEM_IR[20:16] == ID_EX_IR[20:16]))
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
        
              case( ID_EX_IR[31:26] )  //OPCODE
              ADD : EX_MEM_ALUOut  <=#2 ID_EX_A + ID_EX_B;
              SUB : EX_MEM_ALUOut  <=#2 ID_EX_A - ID_EX_B;
              MUL : EX_MEM_ALUOut  <=#2 ID_EX_A * ID_EX_B;
              AND : EX_MEM_ALUOut  <=#2 ID_EX_A & ID_EX_B;
              OR  : EX_MEM_ALUOut  <=#2 ID_EX_A | ID_EX_B; 
              XOR : EX_MEM_ALUOut  <=#2 ID_EX_A ^ ID_EX_B;
              SLT : EX_MEM_ALUOut  <=#2 ($signed(ID_EX_A) < $signed(ID_EX_B) )? 1:0;
              SLTU : EX_MEM_ALUOut  <=#2 (ID_EX_A < ID_EX_B )? 1:0;
              MOVE: EX_MEM_ALUOut  <=#2 ID_EX_A + ID_EX_B;
              SLL : EX_MEM_ALUOut  <=#2 ID_EX_A << ID_EX_B;
              SRL : EX_MEM_ALUOut  <=#2 ID_EX_A >> ID_EX_B;
              SRA : EX_MEM_ALUOut  <=#2 ID_EX_A >>>ID_EX_B;
              
                default : EX_MEM_ALUOut <=#2 32'hxxxxxxxx;
              endcase
              end
        RM_ALU:  begin
                 case(ID_EX_IR[31:26])
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
                          if ((MEM_WB_IR[15:11]!=0) && ( MEM_WB_IR[15:11] == IF_ID_IR[25:21]))
                           begin
                             ForwardA=2'b10;
                             ID_EX_A =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_A=1;
                           end
                          if ((MEM_WB_IR[15:11]!=0) && (MEM_WB_IR[15:11] == IF_ID_IR[20:16]))
                           begin
                             ForwardB=2'b10;
                             ID_EX_B =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_B=1;
                           end
                          end
         
          RM_ALU, LOAD_UPPER_Imm         : begin
           				  if ((MEM_WB_IR[20:16]!=0) && ( MEM_WB_IR[20:16] == IF_ID_IR[25:21]))
                           begin
                             ForwardA=2'b10;
                             ID_EX_A =  MEM_WB_ALUOut;
                             MEM_WB_FORWARDED_A=1;
                           end
                          if ((MEM_WB_IR[20:16]!=0) && (MEM_WB_IR[20:16]  == IF_ID_IR[20:16]))
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
           case( EX_MEM_IR[31:26] )        
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
         RR_ALU: Reg[MEM_WB_IR[15:11]] <=#2 MEM_WB_ALUOut;
         RM_ALU: Reg[MEM_WB_IR[20:16]] <=#2 MEM_WB_ALUOut;
         
         LOAD_UPPER_Imm : begin 
           case( MEM_WB_IR[31:26] )  
             LUI : Reg[MEM_WB_IR[20:16]] <=#2 MEM_WB_ALUOut;
             AUIPC: Reg[MEM_WB_IR[20:16]] <=#2 MEM_WB_ALUOut +PC;
           endcase 
         end
         
         LOAD  : begin
           case( MEM_WB_IR[31:26] )   
             LW:  Reg[MEM_WB_IR[20:16]] <=#2 MEM_WB_LMD;
             LB: Reg[MEM_WB_IR[20:16]] <= #2 {{24{MEM_WB_LMD[7]}},  {MEM_WB_LMD[7:0]}};
             LH : Reg[MEM_WB_IR[20:16]] <= #2 {{16{MEM_WB_LMD[15]}}, { MEM_WB_LMD[15:0]}} ; 
             LBU: Reg[MEM_WB_IR[20:16]] <= #2 {24'b0,MEM_WB_LMD[7:0]};
             LHU : Reg[MEM_WB_IR[20:16]] <= #2 {16'b0,MEM_WB_LMD[15:0]};
           endcase 
         end
         
         HALT:   HALTED <=#2 1'b1;
       endcase
   end           
  endmodule
            
 
