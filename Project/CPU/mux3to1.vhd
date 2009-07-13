-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity mux3to1 is
	generic (
		n : integer := 16
	);
	port ( 	
		x, y, z	: in std_logic_vector(n-1 downto 0);
		sel : in std_logic_vector(1 downto 0);
		q : out std_logic_vector(n-1 downto 0)
	);
end mux3to1;


architecture behavior of mux3to1 is
begin
	with sel select
		q <= 	x when "00",
			y when "01",
			z when OTHERS;
end behavior;

