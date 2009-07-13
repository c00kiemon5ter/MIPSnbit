library IEEE;
use IEEE.std_logic_1164.all;

entity shift_left_2 is
	generic (
		n : INTEGER := 16
	);
	port (
		input : in STD_LOGIC_VECTOR (n-1 downto 0);
		output: out STD_LOGIC_VECTOR (n-1 downto 0)
	);
end shift_left_2;

architecture behavioral of shift_left_2 is
begin
  output(n-1 downto 0) <= "00" & input(n-3 downto 0);
end behavioral;
