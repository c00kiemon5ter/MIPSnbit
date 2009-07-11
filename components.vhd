-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

package components is 

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
		k : integer := 6;
	 	n : integer := 16
	);
	port (	
		imm : in std_logic_vector (k-1 downto 0);
		ext : out std_logic_vector (n-1 downto 0)
	);
end component;

component forwarder is
	port (  
		rs, rt : in std_logic_vector(2 downto 0);
        	ex_mem, mem_wb : in std_logic_vector(2 downto 0);
        	sel_a, sel_b : out std_logic_vector(1 downto 0)
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
		k : INTEGER := 3
	);
	port (	
		clock, RegWrite : in std_logic;
		data : in std_logic_vector (n-1 downto 0);
		rd_address, rs_address, rt_address : in std_logic_vector (k-1 downto 0);
		rs_out, rt_out : out std_logic_vector (n-1 downto 0)
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
		RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Brnch : out STD_LOGIC;
		ALUOp : out STD_LOGIC_VECTOR (1 downto 0)
	);
end component;

component FlushCtrl is
	port (
		in_wb : in std_logic_vector(1 downto 0);
		in_mem : in std_logic_vector(2 downto 0);
		in_ex : in std_logic_vector(3 downto 0);
		sel : IN STD_LOGIC;
		out_wb : out std_logic_vector(1 downto 0);
		out_mem : out std_logic_vector(2 downto 0);
		out_ex : out std_logic_vector(3 downto 0)
	);
end component;

component hazard is
	port (
		rs : in STD_LOGIC_VECTOR(2 downto 0);  	   -- if/id source register s
		rt : in STD_LOGIC_VECTOR(2 downto 0);  	   -- if/id source register t
		prevRt : in STD_LOGIC_VECTOR(2 downto 0);  -- id/ex source register t
		branchTaken : in STD_LOGIC;  -- is a branch being taken
		wasLw : in STD_LOGIC;        -- if load word was performed
		reset : in STD_LOGIC;        -- reset all values, no hazard
		clk : in STD_LOGIC;	
		pcUpdate : out STD_LOGIC;    -- if PC should update
		pcSel : out STD_LOGIC;       -- update the pc with +4 or branch
		if_id_clr : out STD_LOGIC;   -- clear the If/Id register
		flush : out STD_LOGIC  	     -- if flush should take place
	);
end component;




end components;

