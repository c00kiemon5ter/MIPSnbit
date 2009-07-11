library IEEE;
use IEEE.std_logic_1164.all;

entity pc is
	generic(
		n : INTEGER := 16
	);
	port(
		clk, pc_write : in  std_logic;
		inPC : in  std_logic_vector (n-1 downto 0);
		nextPC : out std_logic_vector (n-1 downto 0) 
	);
end entity pc;


architecture behavior of pc is
begin

pc: process(clk)
begin
	if clk = '1' and pc_write = '1' then     -- rising edge
		nextPC <= inPC;
	end if;
end process pc;

end architecture behavior;
