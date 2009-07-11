library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_MEM_WB is
	port (
		inWB_ctrl : IN std_logic_vector(1 downto 0);
  	 	inData_read, inALUResult : IN std_logic_vector(31 downto 0);
  	 	inRD : IN std_logic_vector(4 downto 0);
  	 	clk : IN std_logic;
  	 	outWB_ctrl : OUT std_logic_vector(1 downto 0);
  	 	outData_read, outALUResult : OUT std_logic_vector(31 downto 0);
  	 	outRD : OUT std_logic_vector(4 downto 0)
	 );
end Register_MEM_WB;

architecture behavior of Register_MEM_WB is
begin

pc: process(clk)
begin
	if clk='1' then     -- rising edge
		outWB_ctrl <= inWB_ctrl;
		outData_read <= inData_read;
		outALUResult <= inALUResult;
		outRD <= inRD;
	end if;
end process pc;

end architecture behavior;

