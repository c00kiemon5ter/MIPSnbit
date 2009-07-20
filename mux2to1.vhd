-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
	generic ( 
		n : integer := 16
	);
	port (
		x, y : in std_logic_vector(n-1 downto 0);
		sel	: in std_logic;
		q : out std_logic_vector(n-1 downto 0)
	);
end mux2to1;


architecture behavior of mux2to1 is
begin
	with sel select
		q <=	x when '0',
			y when OTHERS;
end behavior;

