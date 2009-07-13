library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_MEM_WB is
	generic (
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
end Register_MEM_WB;

architecture behavior of Register_MEM_WB is
begin

pc: process(clk)
begin
	if clk='1' then     -- rising edge
		outMemtoReg <= inMemtoReg;
		outRegWrite <= inRegWrite;
		outData_read <= inData_read;
		outALUResult <= inALUResult;
		outRD <= inRD;
	end if;
end process pc;

end architecture behavior;

