library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_IF_ID is
	generic (
		n : INTEGER := 16
	);
	port (
  		inPC, inInstruction : IN std_logic_vector(n-1 downto 0);
  		clk, IF_Flush, IF_ID_Write : IN std_logic;
  		outPC, outInstruction : OUT std_logic_vector(n-1 downto 0)
	 );
end Register_IF_ID;


architecture behavior of Register_IF_ID is
begin

pc: process(clk)
begin
	if clk='1' and IF_ID_Write='1' then     -- rising edge
		outPC <= inPC;
      		outInstruction <= inInstruction;
    	elsif clk='1' and IF_Flush='1' then
      		outPC <= (OTHERS => '0');
      		outInstruction <= (OTHERS => '0');
    	end if;
end process pc;

end architecture behavior;

