 LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.components.all;

ENTITY Execute IS
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6
	);
	PORT(
		pipe_clock : in std_logic;		 -- IF_ID | ID_DEC | DEC_EX | EX_MEM | MEM_WB + !PC 
		clock : in std_logic;			 -- used by all other units
		regOUT : out std_logic_vector(n*8-1+n downto 0); 	 -- pros othoni (REGs + PC) | 127+16
		instructionAD : out std_logic_vector(n-1 downto 0);	 -- PC_OUT
		instr : in std_logic_vector(n-1 downto 0):= x"0000";	 -- INSTR_MEM_OUT | insrtuction
		dataAD : out std_logic_vector(n-1 downto 0);		 -- DATA_MEM_Address_to_{write|read}
		fromData : in std_logic_vector(n-1 downto 0):= x"0000";	 -- DATA_MEM_OUT | eg. lw..
		toData : out std_logic_vector(n-1 downto 0);		 -- DATA_MEM_IN | eg. sw..
		DataWriteFlag : out std_logic 				 -- DATA_MEM_Write_access
	);
END Execute;


ARCHITECTURE structure OF Execute IS
BEGIN

END structure;

