-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

package components is 

-- PARTS --

component mux3to1 is
	generic (
		n : integer := 16
	);
	port ( 	
		x, y, z	: in std_logic_vector(n-1 downto 0);
		sel : in std_logic_vector(1 downto 0);
		q : out std_logic_vector(n-1 downto 0)
	);
end component;

component mux2to1 is
	generic (
		n : integer := 16
	);
	port ( 	
		x, y : in std_logic_vector(n-1 downto 0);
		sel : in std_logic;
		q : out std_logic_vector(n-1 downto 0)
	);
end component;

component mux8to1 is
	generic (
		n : integer := 16;
		s : integer := 3
	);
	port( 	
		x0, x1, x2, x3, x4, x5, x6, x7 : in std_logic_vector (n-1 downto 0);
		sel : in std_logic_vector (s-1 downto 0);
		q : out std_logic_vector (n-1 downto 0) 
	);
end component;

component registers is
	generic ( 
		n : integer := 16;
		r : integer := 8;
		k : integer := 3
	);			  
	port (	
		clk : in std_logic;
		enable : in std_logic_vector (r-1 downto 0);
		d : in std_logic_vector (n-1 downto 0);
		q : out std_logic_vector ( r*n-1 downto 0)
	);
end component;

component sign_ext is
	generic (
		n : integer := 16;
		k : integer := 6
	);
	port (	
		imm : in std_logic_vector (k-1 downto 0);
		ext : out std_logic_vector (n-1 downto 0)
	);
end component;

component forwarder is
	generic(
		addr_size : INTEGER := 3
	);
	port (
      		ALUSrc, EX_MEM_regwrite, MEM_WB_regwrite : IN STD_LOGIC;
      		ID_EX_rs, ID_EX_rt, EX_MEM_rd, MEM_WB_rd : IN STD_LOGIC_VECTOR(addr_size-1 downto 0);
      		SelA, SelB : OUT STD_LOGIC_VECTOR(1 downto 0)
	);
end component;

component PC is
	generic(
		n : INTEGER := 16
	);
	port(
		clk, pc_write : in  std_logic;
		inPC : in  std_logic_vector (n-1 downto 0);
		nextPC : out std_logic_vector (n-1 downto 0) 
	);
end component;

component Adder is
	generic(
		n : INTEGER := 16
	);
	port(
		A, B : in std_logic_vector(n-1 downto 0);
		carry : out std_logic;
		sum : out std_logic_vector(n-1 downto 0)
	);
end component;

component RegFile is
	generic ( 
		n : integer := 16;
		k : INTEGER := 3;
		reg_num : INTEGER := 8
	);
	port (	
		clock, RegWrite : in std_logic;
		data : in std_logic_vector (n-1 downto 0);
		rd_address, rs_address, rt_address : in std_logic_vector (k-1 downto 0);
		rs_out, rt_out : out std_logic_vector (n-1 downto 0);
		registers_out : out std_logic_vector(n*reg_num-1 downto 0)
	);
end component;

component AndGate is
	port(
		a, b : in std_logic;
		q : out std_logic
	);
end component;

component shift_left_2 is
	generic (
		n : INTEGER := 16
	);
	port (
		input : in STD_LOGIC_VECTOR (n-1 downto 0);
		output: out STD_LOGIC_VECTOR (n-1 downto 0)
	);
end component;

component Control is
	generic (
		opcode_size : integer := 4
	);
	port (
		opcode : in std_logic_vector(opcode_size-1 downto 0);
		RegDst : out std_logic;
		ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
		ALUSrc, Brnch, MemRead, MemWrite, MemtoReg, RegWrite : out STD_LOGIC 
	);
end component;

component FlushCtrl is
	port (
		inMemtoReg, inRegWrite : in std_logic;
		inBranch, inMemRead, inMemWrite : in std_logic;
		inRegDst : in std_logic;
		inALUop : in std_logic_vector(1 downto 0);
		inALUSrc : in std_logic;
		flush : IN STD_LOGIC;
		outMemtoReg, outRegWrite : out std_logic;
		outBranch, outMemRead, outMemWrite : out std_logic;
		outRegDst : out std_logic;
		outALUop : out std_logic_vector(1 downto 0);
		outALUSrc : out std_logic
	);
end component;

component Hazard is
	port (
		rs : in STD_LOGIC_VECTOR(2 downto 0);  	   -- if/id source register s
		rt : in STD_LOGIC_VECTOR(2 downto 0);  	   -- if/id source register t
		prevRt : in STD_LOGIC_VECTOR(2 downto 0);  -- id/ex source register t
		isBranch : in STD_LOGIC; 	-- if a branch is being taken
		wasLw : in STD_LOGIC; 		-- if load word was performed :: If ( ID_EX_Reg_MemRead='1' ) 
		reset : in STD_LOGIC; 		-- reset all values, no hazard
		clk : in STD_LOGIC;
		pcUpdate : out STD_LOGIC; 	-- if PC should update
		pcSel : out STD_LOGIC; 		-- update the pc with +4 or branch
		IF_ID_Clear : out STD_LOGIC;	-- clear the If/Id register
		flush : out STD_LOGIC 		-- if flush should take place
	);
end component;

component ALU is
	generic ( 
		n : INTEGER := 16
	);
	port(
		a, b : in std_logic_vector(n-1 downto 0);
		func : in std_logic_vector(2 downto 0);
		zero : out std_logic;
		f : out std_logic_vector(n-1 downto 0)
	);
end component;

component ALUcontrol is 
	generic (
		n : integer := 16
	);
	port (
		extended : in std_logic_vector(n-1 downto 0);
		ALUop_in : in std_logic_vector(1 downto 0);
		ALUop_out : out std_logic_vector(2 downto 0)
	);
end component;

component compare is
	generic(
		n : integer := 16
	);
        port (
		a, b : in std_logic_vector(n-1 downto 0);
		f : out std_logic
	);
end component;

-- PIPE REGISTERS --

component Register_IF_ID is
	generic (
		n : INTEGER := 16
	);
	port (
  		inPC, inInstruction : IN std_logic_vector(n-1 downto 0);
  		clk, IF_Flush, IF_ID_Write : IN std_logic;
 		outPC, outInstruction : OUT std_logic_vector(n-1 downto 0)
	);
end component;

component Register_ID_EX is
	generic (
		n : INTEGER := 16;
		addr_size : INTEGER := 4
	);
	port (
		inMemtoReg, inRegWrite : in std_logic;
		inBranch, inMemRead, inMemWrite : in std_logic;
		inRegDst : in std_logic;
		inALUop : in std_logic_vector(1 downto 0);
		inALUSrc : in std_logic;
  		inPC, inRead_data1, inRead_data2, inExtnd : IN std_logic_vector(n-1 downto 0);
  		inRS, inRT, inRD : IN std_logic_vector(addr_size-1 downto 0);
  		clk : IN std_logic;
		outMemtoReg, outRegWrite : out std_logic;
		outBranch, outMemRead, outMemWrite : out std_logic;
		outRegDst : out std_logic;
		outALUop : out std_logic_vector(1 downto 0);
		outALUSrc : out std_logic;
		outPC, outRead_data1, outRead_data2, outExtnd : OUT std_logic_vector(n-1 downto 0);
  		outRS, outRT, outRD : OUT std_logic_vector(addr_size-1 downto 0)
	);
end component;

component Register_EX_MEM is
generic (
		n : INTEGER := 16;
		addr_size : INTEGER := 3
	);
	port (
		inMemtoReg, inRegWrite : in std_logic;
		inBranch, inMemRead, inMemWrite : in std_logic;
  	 	inPC, inALUResult : IN std_logic_vector(n-1 downto 0);
		inZero : in std_logic;
		inRead_data2 : IN std_logic_vector(n-1 downto 0);
  	 	inRD : IN std_logic_vector(addr_size-1 downto 0);
  	 	clk : IN std_logic;
		outMemtoReg, outRegWrite : out std_logic;
		outBranch, outMemRead, outMemWrite : out std_logic;
  	 	outPC, outALUResult : OUT std_logic_vector(n-1 downto 0);
		outZero : OUT std_logic;
		outRead_data2 : OUT std_logic_vector(n-1 downto 0);
  	 	outRD : OUT std_logic_vector(addr_size-1 downto 0)
	 );
end component;

component Register_MEM_WB is
	generic(
		n : INTEGER := 16;
		addr_size : INTEGER := 3
	);
	port (
		inMemtoReg, inRegWrite : in std_logic;
  	 	inData_read, inALUResult : IN std_logic_vector(n-1 downto 0);
  	 	inRD : IN std_logic_vector(addr_size-1 downto 0);
  	 	clk : IN std_logic;
  	 	outMemtoReg, outRegWrite : out std_logic;
		outData_read, outALUResult : OUT std_logic_vector(n-1 downto 0);
  	 	outRD : OUT std_logic_vector(addr_size-1 downto 0)
	 );
end component;

-- STAGES --

component Fetch is
	generic(
		n : INTEGER := 16
	);
	port(
		PCSrc, PCWrite : in std_logic;
		branch_pc : in std_logic_vector(n-1 downto 0);
		pipe_clock : in std_logic;
		PCtoIMem, PCtoIF_ID : out std_logic_vector(n-1 downto 0)
	);
end component;

component Decode is
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6;
		reg_num : INTEGER := 8
	);
	PORT(
		instruction, IF_ID_PC, data : in std_logic_vector(n-1 downto 0);
		rd_addr_from_MEM_WB : in std_logic_vector(addr_size-1 downto 0);
		RegWrite, isBranch, clock : in std_logic;
		opcode : out std_logic_vector(opcode_size-1 downto 0);
		ID_EX_rs_data, ID_EX_rt_data, ID_EX_extended, branch_pc : out std_logic_vector(n-1 downto 0);
		ID_EX_rs_addr, ID_EX_rt_addr, ID_EX_rd_addr : out std_logic_vector(addr_size-1 downto 0);
		PCSrc : out std_logic;
		registers : out std_logic_vector(n*reg_num-1 downto 0)
	);
end component;

component Controls is
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4
	);
	PORT(
		instruction : in std_logic_vector(n-1 downto 0);
		ID_EX_rt_addr : in std_logic_vector(addr_size-1 downto 0);
		prev_ID_EX_MemRead, clock : in std_logic;  	-- if previously we had a 'lw' command
		PCWrite, PCSrc, IF_ID_Write : out std_logic;
		ID_EX_RegDst : out std_logic;
		ID_EX_ALUop : out std_logic_vector(1 downto 0);
		ID_EX_ALUSrc, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_RegWrite : out std_logic
	);
end component;

component Execute is
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3
	);
	PORT(
		ALUop_from_ID_EX : in std_logic_vector(1 downto 0);
		ALUSrc_from_ID_EX, RegDst_from_ID_EX, MemReg_from_ID_EX, RegWrite_from_ID_EX : in std_logic;
		Branch_from_ID_EX, MemRead_from_ID_EX, MemWrite_from_ID_EX : std_logic;
		extended_from_ID_EX : in std_logic_vector(n-1 downto 0);
		ID_EX_rs_data, ID_EX_rt_data : in std_logic_vector(n-1 downto 0);
		EX_MEM_ALUresult, MEM_WB_data : in std_logic_vector(n-1 downto 0);
		ID_EX_rs_addr, ID_EX_rt_addr : in std_logic_vector(addr_size-1 downto 0);
		ID_EX_rd_addr, EX_MEM_rd_addr, MEM_WB_rd_addr : in std_logic_vector(addr_size-1 downto 0);
		EX_MEM_RegWrite, MEM_WB_RegWrite, clock : in std_logic;
		zero : out std_logic;
		ALUresult : out std_logic_vector(n-1 downto 0);
		MemtoReg_to_EX_MEM, RegWrite_to_EX_MEM : out std_logic;
		Branch_to_EX_MEM, MemRead_to_EX_MEM, MemWrite_to_EX_MEM : out std_logic;
		rd_addr_to_EX_MEM : out std_logic_vector(addr_size-1 downto 0)
	);
end component;

component DataMem is
 end component;

component WriteBack is
 end component;

end components;

