LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.components.all;

ENTITY Execute IS
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
END Execute;


ARCHITECTURE structure OF Execute IS
	signal ALUrs, ALUrt : std_logic_vector(n-1 downto 0);
	signal selectA, selectB : std_logic_vector(1 downto 0);
	signal func : std_logic_vector(2 downto 0);

BEGIN
	Fwd : Forwarder 	generic map(addr_size)
				port map(ALUSrc_from_ID_EX, EX_MEM_RegWrite, MEM_WB_RegWrite, 
					 ID_EX_rs_addr, ID_EX_rt_addr, EX_MEM_rd_addr, MEM_WB_rd_addr,
					 selectA, selectB);

	selectorA : mux3to1 	generic map(n)
				port map (ID_EX_rs_data, EX_MEM_ALUresult, MEM_WB_data, selectA, ALUrs);
	
	selectorB : mux3to1 	generic map(n)
				port map (ID_EX_rt_data, EX_MEM_ALUresult, MEM_WB_data, selectB, ALUrt);

	ALUctrl : ALUcontrol 	generic map(n)
				port map(extended_from_ID_EX, ALUop_from_ID_EX, func);
	
	ALU_unit : ALU 		generic map(n)
				port map(ALUrs, ALUrt, func, zero, ALUresult);
	
	RegDstMux : mux2to1	generic map(addr_size)
				port map(ID_EX_rt_addr, ID_EX_rd_addr, RegDst_from_ID_EX, rd_addr_to_EX_MEM);
	
	MemtoReg_to_EX_MEM <= MemReg_from_ID_EX;
	RegWrite_to_EX_MEM <= RegWrite_from_ID_EX;
	Branch_to_EX_MEM <= Branch_from_ID_EX;
	MemRead_to_EX_MEM <= MemRead_from_ID_EX;
	MemWrite_to_EX_MEM <= MemWrite_from_ID_EX;
END structure;

