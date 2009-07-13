library IEEE;
use IEEE.std_logic_1164.all;

entity compare is
	generic(
		n : integer := 16
	);
        port (
		a, b : in std_logic_vector(n-1 downto 0);
		f : out std_logic
	);
end compare;


architecture behav of compare is
begin
	f <= '1' when (a=b) else '0';
end behav;

