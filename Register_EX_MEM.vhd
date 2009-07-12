library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_EX_MEM is
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
end Register_EX_MEM;


architecture behavior of Register_EX_MEM is
begin

pc: process(clk)
begin
	if clk='1' then     -- rising edge
		outMemtoReg <= inMemtoReg;
		outRegWrite <= inRegWrite;
		outBranch <= inBranch;
		outMemRead <= inMemRead;
		outMemWrite <= inMemWrite;
	        outPC <= inPC;
        	outALUResult <= inALUResult;
        	outRead_data2 <= inRead_data2;
        	outRD <= inRD;
        	outZero <= inZero;
	end if;
end process pc;

end architecture behavior;

