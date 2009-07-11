-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity mux8to1 is
	generic (
		n : integer := 16;
		s : integer := 3
	);
	port( 	
		x0, x1, x2, x3, x4, x5, x6, x7	: in std_logic_vector (n-1 downto 0);
		sel : in std_logic_vector (s-1 downto 0);
		q : out std_logic_vector (n-1 downto 0) 
	);
end mux8to1;


architecture behavior of mux8to1 is
begin
	with sel select
		q <= 	x0 when "000",
			x1 when "001",
			x2 when "010",
			x3 when "011",
			x4 when "100",
			x5 when "101",
			x6 when "110",
			x7 when OTHERS;
end behavior;

