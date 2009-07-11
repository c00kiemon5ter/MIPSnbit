library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Pipelined is
port(
	clock1: in std_logic; -- IF_ID | ID_DEC | DEC_EX | EX_MEM | MEM_WB + !PC 
	clock2: in std_logic; -- all other units
	---------------------------------------------------------
	regOUT: out std_logic_vector(127+16 downto 0); -- pros othoni (REGs + PC)
	---------------------------------------------------------
	instructionAD : out std_logic_vector(15 downto 0);	 -- PC_OUT
	instr: in std_logic_vector(15 downto 0):= x"0000";	 -- INSTR_MEM_OUT | insrtuction
	---------------------------------------------------------
	dataAD: out std_logic_vector(15 downto 0);		 -- DATA_MEM_Address_to_{write|read}
	fromData: in std_logic_vector(15 downto 0):= x"0000";	 -- DATA_MEM_OUT | eg. lw..
	toData: out std_logic_vector(15 downto 0);		 -- DATA_MEM_IN | eg. sw..
	DataWriteFlag: out std_logic 					 -- DATA_MEM_Write_access
);

end MIPS_Pipelined;

architecture structural of MIPS_Pipelined is
  component controlUnit
      port (Instruction: in STD_LOGIC_VECTOR (31 downto 0);
            RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch: out STD_LOGIC;
		      ALUOp: out STD_LOGIC_VECTOR (1 downto 0));
  end component;
  component controlALU is
      port (func : in STD_LOGIC_VECTOR (5 downto 0);
            ALUOp1, ALUOp0 : in STD_LOGIC;
            ALUCtrl: out STD_LOGIC_VECTOR (2 downto 0) );
  end component;
  component alu32bit is
      port (a, b : in std_logic_vector(31 downto 0);	-- a and b are busses
		      op : in std_logic_vector(2 downto 0);
		      zero : out std_logic;
	         f : out std_logic_vector(31 downto 0));
  end component;
  component instruction_mem is
      port (address : IN std_logic_vector(31 downto 0);
            instruction : OUT std_logic_vector(31 downto 0));
  end component;
  component memory2 is
      port (address, write_data : in std_logic_vector(31 downto 0);
            MemWrite, MemRead : in std_logic;
            clk : in std_logic;
            read_data : out std_logic_vector(31 downto 0));
  end component;
  component register_banc is
      port (clock2 : in std_logic;
            reset : in std_logic;
            aRegister : in std_logic_vector(31 downto 0);
            -- register addresses (for reading)
            read_register1 : in std_logic_vector(4 downto 0);
            read_register2 : in std_logic_vector(4 downto 0);    
            -- register address (for writing)
            write_register : in std_logic_vector(4 downto 0);
            write_data : in std_logic_vector(31 downto 0);
            -- write signal
            reg_write : in std_logic;
            -- register bank data
            read_data1 : out std_logic_vector(31 downto 0);
            read_data2 : out std_logic_vector(31 downto 0));
  end component;
  component pc is
      port (clk, pc_write    : in  std_logic;
            inPC  : in  std_logic_vector (31 downto 0);
            nextPC : out std_logic_vector (31 downto 0));
  end component;
  component sign_extend is
      port (input16 : in STD_LOGIC_VECTOR (15 downto 0);
            output32 : out STD_LOGIC_VECTOR (31 downto 0));
  end component;
  component shift_left_2 is
      port (input : in STD_LOGIC_VECTOR (31 downto 0);
            output: out STD_LOGIC_VECTOR (31 downto 0));
  end component;
  component Register_IF_ID is
      port (inPC, inInstruction : IN std_logic_vector(31 downto 0);
          clk, IF_Flush, IF_ID_Write : IN std_logic;
          outPC, outInstruction : OUT std_logic_vector(31 downto 0));
  end component;
  component Register_ID_EX is
      port (inWB_ctrl : IN std_logic_vector(1 downto 0);
            inMEM_ctrl : IN std_logic_vector(2 downto 0);
            inEX_ctrl : IN std_logic_vector(3 downto 0);
            inPC, inRead_data1, inRead_data2, inMEMAddress : IN std_logic_vector(31 downto 0);
            inRS, inRT, inRD : IN std_logic_vector(4 downto 0);
            clk : IN std_logic;
            outWB_ctrl : OUT std_logic_vector(1 downto 0);
            outMEM_ctrl : OUT std_logic_vector(2 downto 0);
            outEX_ctrl : OUT std_logic_vector(3 downto 0);
            outPC, outRead_data1, outRead_data2, outMEMAddress : OUT std_logic_vector(31 downto 0);
            outRS, outRT, outRD : OUT std_logic_vector(4 downto 0));
  end component;
  component Register_EX_MEM is
      port (inWB_ctrl : IN std_logic_vector(1 downto 0);
            inMEM_ctrl : IN std_logic_vector(2 downto 0);
            inPC, inALUResult, inRead_data2 : IN std_logic_vector(31 downto 0);
            inRD : IN std_logic_vector(4 downto 0);
            clk, inZero : IN std_logic;
            outWB_ctrl : OUT std_logic_vector(1 downto 0);
            outMEM_ctrl : OUT std_logic_vector(2 downto 0);
            outPC, outALUResult, outRead_data2 : OUT std_logic_vector(31 downto 0);
            outRD : OUT std_logic_vector(4 downto 0);
            outZero : OUT std_logic);
  end component;
  component Register_MEM_WB is
      port (inWB_ctrl : IN std_logic_vector(1 downto 0);
            inData_read, inALUResult : IN std_logic_vector(31 downto 0);
            inRD : IN std_logic_vector(4 downto 0);
            clk : IN std_logic;
            outWB_ctrl : OUT std_logic_vector(1 downto 0);
            outData_read, outALUResult : OUT std_logic_vector(31 downto 0);
            outRD : OUT std_logic_vector(4 downto 0));
  end component;
  component hazardDetection is
      port    (rs         : in STD_LOGIC_VECTOR(4 downto 0); -- current Rs
               rt         : in STD_LOGIC_VECTOR(4 downto 0); -- current RT
               prevRt     : in STD_LOGIC_VECTOR(4 downto 0); -- previous RT
               prevMemRead: in STD_LOGIC;         -- the previous instruction's mem read
               braTaken   : in STD_LOGIC;         -- is  a branch being taken
               reset      : in STD_LOGIC;         -- reset me
               clk        : in STD_LOGIC;
      
   
               pcUpdateEnable : out STD_LOGIC;    -- allows the PC to update
               pcUpdateVal    : out STD_LOGIC;    -- update the pc with pc+4 or branch
               ifIdRegClr_L   : out STD_LOGIC;    -- clears the ifId register
               noopControl    : out STD_LOGIC );  -- controls the mux that sends all
                                      -- zeros through
  end component;
  component forwardingUnit is
      port (ALUSrc, EX_MEM_regwrite, MEM_WB_regwrite : IN STD_LOGIC;
      EX_MEM_rd, MEM_WB_rd, ID_EX_rs, ID_EX_rt : IN STD_LOGIC_VECTOR(4 downto 0);
      ForwardA, ForwardB : OUT STD_LOGIC_VECTOR(1 downto 0));
  end component;
  component comparator is
      generic(n: natural :=32);
      port (A, B :	in std_logic_vector(n-1 downto 0);
            EQ:	out std_logic);
  end component;
  component ADDER is
      generic(n: natural :=32);
      port (A, B :	in std_logic_vector(n-1 downto 0);
            carry:	out std_logic;
            sum:	out std_logic_vector(n-1 downto 0));
  end component;
  component gateander is
      port (x: in std_logic;
            y: in std_logic;
            F: out std_logic);
  end component;
  component mux_2to1_nbit is
      generic(n: natural := 5);
      port (A, B : in STD_LOGIC_VECTOR (n-1 downto 0);
            S : in STD_LOGIC;
            C: out STD_LOGIC_VECTOR (n-1 downto 0));
  end component;
  
  component mux_3to1_nbit is
      generic(n: natural := 5);
	   port (
		A, B, C : in STD_LOGIC_VECTOR (n-1 downto 0);
		S : in STD_LOGIC_VECTOR (1 downto 0);
		D: out STD_LOGIC_VECTOR (n-1 downto 0));
  end component;
		
component mux_ctrl_flush is
   generic(n: natural := 5);
	port (in_wb1, in_wb0, in_m2, in_m1, in_m0, in_ex3, in_ex2, in_ex1, in_ex0, S : IN STD_LOGIC;
	      out_wb1, out_wb0, out_m2, out_m1, out_m0, out_ex3, out_ex2, out_ex1, out_ex0 : OUT STD_LOGIC);
end component;

component mux_4to1_nbit
generic(n: natural := 5);
	port (
		A, B, C, D : in STD_LOGIC_VECTOR (n-1 downto 0);
		S : in STD_LOGIC_VECTOR (1 downto 0);
		E: out STD_LOGIC_VECTOR (n-1 downto 0));
end component;

  --External control signals for the MIPS Processor
  -- XXX clock2
  --signal clock2 : std_logic;
  signal reset : std_logic;
  
  --Control Unit
  signal RegDst,ALUSrc, MemtoReg, RegWrite,MemRead,MemWrite,Branch : std_logic;
  signal ALUOp: std_logic_vector(1 downto 0);
  
  --MUX_ctrl_flush
  signal out_wb1, out_wb0, out_m2, out_m1, out_m0, out_ex3, out_ex2, out_ex1, out_ex0 : std_logic;
 
  --ALUControl Unit
  signal ALUCtrl : std_logic_vector(2 downto 0);
 
  --Instruction memory 
  signal instruction : std_logic_vector(31 downto 0);
 
  --Program Counter 
  signal nextPC : std_logic_vector(31 downto 0);
 
  --Adder0 -angel need a better name for sum_signal
  signal carry : std_logic;
  signal sum : std_logic_vector(31 downto 0);
   
  --Register IF_ID 
  signal outPC, outInstruction : std_logic_vector(31 downto 0);
 
  --Register_banc 
  signal readData1, readData2 : std_logic_vector(31 downto 0);
  
  --shift_left_2
  signal SL2_output : std_logic_vector(31 downto 0);
  
  --Comparator
  signal equal : std_logic;
  
  -- adder1 signals
  signal sum_adder1 : std_logic_vector(31 downto 0);
  signal carry_adder1 : std_logic;
 
  --Sign Extend 
  signal output32 : std_logic_vector(31 downto 0);
 
  --Control_Unit 
  signal ALUOp_signal : std_logic_vector(1 downto 0);
  
  --Concatenation Signals for ID/EX register
  signal concatWB : std_logic_vector(1 downto 0);
  signal concatMEM: std_logic_vector( 2 downto 0);
  signal concatEX: std_logic_vector( 3 downto 0);
  --ID/EX register
  signal outWB_ctrlID_EX : std_logic_vector(1 downto 0);
  signal outMEM_ctrlID_EX : std_logic_vector(2 downto 0);
  signal outEX_ctrlID_EX : std_logic_vector(3 downto 0);
  signal outPCID_EX, outRead_data1ID_EX, outRead_data2ID_EX, outMEMAddressID_EX : std_logic_vector(31 downto 0);
  signal outRSID_EX, outRTID_EX, outRDID_EX : std_logic_vector(4 downto 0);
 
 --Hazard Detection 
 signal pcUpdateEnable, pcUpdateVal,ifIdRegClr_L, noopControl : std_logic;
 
 -- mux3-1-1 signal
signal ALU_inputA : std_logic_vector(31 downto 0);
  
 -- mux3-1-2 signal
signal ALU_inputB : std_logic_vector(31 downto 0);
 
 -- alu signals
 signal zero : std_logic;
 signal ALU0_32bitoutput  : std_logic_vector(31 downto 0);
 --mux  2-1-0 signal
 signal inPC : std_logic_vector(31 downto 0);
 -- mux 2-1-1 signal
 signal inRD_forEX_MEM : std_logic_vector(4 downto 0);
 -- mux 2-1-2 signal
 signal lastMux_signal : std_logic_vector(31 downto 0);
 
 --and gate gignal
 signal resultHERE : std_logic;
 
 -- memory signals
 signal send_that_memory_data : std_logic_vector(31 downto 0);
 
 --ex/mem register
 signal outWB_ctrl_EXMEM : std_logic_vector(1 downto 0);
 signal outMEM_ctrl_EXMEM : std_logic_vector(2 downto 0);
 signal outPC_EXMEM,outALUResult_EXMEM,outRead_data2_EXMEM : std_logic_vector(31 downto 0);
 signal outRD_EXMEM : std_logic_vector(4 downto 0);
 signal outZero_EXMEM : std_logic;
        
--ME/WB register
signal outwB_ctrl_MEWB : std_logic_vector(1 downto 0);
signal outData_readout_MEWB, outALUResult_MEWB : std_logic_vector(31 downto 0);
signal outRD_MEWB : std_logic_vector(4 downto 0);

--forwarding unit
signal forwardA,forwardB : std_logic_vector(1 downto 0);

begin

		PC1: PC port map( NOT clock2, pcUpdateEnable, inPC,nextPC);
		                  
		mux_2to1_nbit0: mux_2to1_nbit generic map (32)
		                              port map(sum,sum_adder1,resultHERE,inPC);
		-- XXX PC 
		instructionAD <= inPC;
		
		adder0: adder port map (nextPC, "00000000000000000000000000000100",carry, sum);
		                        
		-- XXX INSTR
		-- instruction_mem1: instruction_mem port map (nextPC, instruction);
		register_IF_ID1: register_IF_ID port map ( sum, instr, clock1,
		                                           ifIdRegClr_L, pcUpdateVal,
		                                           outPC, outInstruction);
		
-----------------------------------------------------------------------------------------------------------------
		register_banc1: register_banc port map (clock2, reset, outInstruction, outInstruction(25 downto 21),
		                                        outInstruction(20 downto 16), outInstruction(15 downto 11),
		                                        lastMux_signal,outwB_ctrl_MEWB (1), readData1, readData2);

gateanderaaaaa: gateander (equal, out_m2, resultHERE);
signextensA: sign_extend port map ( outInstruction (15 downto 0), output32);
comparator1: comparator generic map(32)
			port map (readData1, readData2,equal);
shift_left_2A: shift_left_2 port map ( output32,SL2_output);
adder1: adder port map (SL2_output, outPC,carry_adder1, sum_adder1);
controlUnit1: controlUnit port map ( outInstruction, RegDst,ALUSrc, MemtoReg, RegWrite,MemRead,MemWrite,Branch,ALUOp);
mux_ctrl_flush1: mux_ctrl_flush port map ( RegWrite, MemtoReg, Branch, MemRead,MemWrite, RegDst,ALUOp(1),ALUOp(0),ALUSrc,noopControl,out_wb1, out_wb0, out_m2, out_m1, out_m0, out_ex3, out_ex2, out_ex1, out_ex0);
hazardDetection1:hazardDetection port map ( outInstruction(25 downto 21), outInstruction(20 downto 16), outRTID_EX,outWB_ctrlID_EX(1),Branch,Reset, clock2, pcUpdateEnable, pcUpdateVal,ifIdRegClr_L, noopControl);

concatWB <= out_wb1 & out_wb0;
concatMEM <= out_m2 & out_m1 & out_m0;
concatEX <=  out_ex3 & out_ex2 & out_ex1 & out_ex0;

register_ID_EX1: register_ID_EX port map (concatWB, concatMEM, concatEX, "00000000000000000000000000000000",readData1, readData2,output32,outInstruction(25 downto 21), outInstruction(20 downto 16), outInstruction(15 downto 11),clock1, outWB_ctrlID_EX, outMEM_ctrlID_EX, outEX_ctrlID_EX, outPCID_EX, outRead_data1ID_EX, outRead_data2ID_EX,outMEMAddressID_EX, outRSID_EX, outRTID_EX, outRDID_EX);
-------------------------------------------------------------------------------------------------------------------------------                       
		mux_3to1_nbit1: mux_3to1_nbit generic map (32)
		                              port map ( outRead_data1ID_EX,lastMux_signal, outALUResult_EXMEM,
		                                         forwardA,
		                                         ALU_inputA);
 		mux_4to1_nbit1: mux_4to1_nbit  generic map (32)
		                               port map ( outRead_data2ID_EX,lastMux_signal,outALUResult_EXMEM,outMEMAddressID_EX,
		                                          forwardB,ALU_inputB);
		controlALU1: controlALU port map ( outMEMAddressID_EX (5 downto 0),outEX_ctrlID_EX (2), outEX_ctrlID_EX (1),
		                                   ALUCtrl);   
		                                   
		alu32bit1: alu32bit port map ( ALU_inputA, ALU_inputB,
		                               ALUCtrl, 
		                               zero,ALU0_32bitoutput);
		
		mux_2to1_nbit1: mux_2to1_nbit generic map (5)
		                              port map(outRTID_EX, outRDID_EX,outEX_ctrlID_EX (3),inRD_forEX_MEM);
		      
		                                
		forwardingunit1: forwardingUnit port map (out_ex0,outWB_ctrl_EXMEM(1), outwB_ctrl_MEWB(1),outRD_EXMEM,outRD_MEWB,outRSID_EX,outRTID_EX,
		                                          ForwardA, ForwardB);
		                         
		Register_EX_MEM1: Register_EX_MEM port map ( outWB_ctrlID_EX, outMEM_ctrlID_EX,"00000000000000000000000000000000", ALU0_32bitoutput,
		                                             outRead_data2ID_EX,inRD_forEX_MEM,clock1, '0',
		                                             outWB_ctrl_EXMEM,outMEM_ctrl_EXMEM,outPC_EXMEM,outALUResult_EXMEM,outRead_data2_EXMEM,
		                                             outRD_EXMEM,outZero_EXMEM);
		
		------------------------------------------------------------------------------------------------------------------------------------                                             
		   
		-- XXX DATA_MEM
		-- memory2A: memory2 port map (outALUResult_EXMEM, outRead_data2_EXMEM, 	-- address 	 | data
		-- 					outMEM_ctrl_EXMEM (1), outMEM_ctrl_EXMEM (0), 	-- mem-write | mem-read
		-- 					clock2, send_that_memory_data); 			-- clock 	 | read-data
		DataWriteFlag <= outMEM_ctrl_EXMEM(1);
		dataAD <= outALUResult_EXMEM;
		toData <= outRead_data2_EXMEM;
		
		Register_MEM_WB1: Register_MEM_WB port map (outWB_ctrl_EXMEM, fromData, 
									outALUResult_EXMEM, outRD_EXMEM, clock1, 
									outwB_ctrl_MEWB, outData_readout_MEWB,
		                        		   	outALUResult_MEWB, outRD_MEWB); 
		--------------------------------------------------------------------------------------------------------------------------------------------------
		
		mux_2to1_nbitlast: mux_2to1_nbit generic map (32)
		                              port map(outData_readout_MEWB,outALUResult_MEWB,outwB_ctrl_MEWB(0), lastMux_signal);
		
		
end structural;


