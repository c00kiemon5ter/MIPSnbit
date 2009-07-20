library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_ID_EX is
	generic (
		n : INTEGER := 16;
		addr_size : INTEGER := 3
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
end Register_ID_EX;


architecture behavior of Register_ID_EX is
begin

pc: process(clk)
begin
	if clk='1' then     -- rising edge
		outMemtoReg <= inMemtoReg;
		outRegWrite <= inRegWrite;
		outBranch <= inBranch;
		outMemRead <= inMemRead;
		outMemWrite <= inMemWrite;
		outRegDst <= inRegDst;
		outALUop <= inALUop;
		outALUSrc <= inALUSrc;
		outPC <= inPC;
    		outRead_data1 <= inRead_data1;
    		outRead_data2 <= inRead_data2;
    		outExtnd <= inExtnd;
    		outRS <= inRS;
    		outRT <= inRT;
    		outRD <= inRD;
    	end if;
end process pc;

end architecture behavior;
