library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_EX_MEM is
	generic (
		n : INTEGER := 16
	);
	port (
		inWB_ctrl : IN std_logic_vector(1 downto 0);
    		inMEM_ctrl : IN std_logic_vector(2 downto 0);
  	 	inPC, inALUResult, inRead_data2 : IN std_logic_vector(n-1 downto 0);
  	 	inRD : IN std_logic_vector(4 downto 0);
  	 	clk, inZero : IN std_logic;
  	 	outWB_ctrl : OUT std_logic_vector(1 downto 0);
  	 	outMEM_ctrl : OUT std_logic_vector(2 downto 0);
  	 	outPC, outALUResult, outRead_data2 : OUT std_logic_vector(n-1 downto 0);
  	 	outRD : OUT std_logic_vector(4 downto 0);
  	 	outZero : OUT std_logic
	 );
end Register_EX_MEM;


architecture behavior of Register_EX_MEM is
begin

pc: process(clk)
begin
	if clk='1' then     -- rising edge
	        outWB_ctrl <= inWB_ctrl;
	        outMEM_ctrl <= inMEM_ctrl;
	        outPC <= inPC;
        	outALUResult <= inALUResult;
        	outRead_data2 <= inRead_data2;
        	outRD <= inRD;
        	outZero <= inZero;
	end if;
end process pc;

end architecture behavior;

