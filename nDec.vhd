-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY nDec IS
	GENERIC (
	 	s : INTEGER := 3
	 );
	PORT (	
		sel : IN STD_LOGIC_VECTOR(s-1 DOWNTO 0);
		q : OUT STD_LOGIC_VECTOR(2**s-1 DOWNTO 0)
	);
END nDec;


ARCHITECTURE behavior OF nDec IS
	signal pos : integer;
BEGIN
	pos <= to_integer( unsigned(sel) );
	q <= (2**s-1 downto pos-1 => '0') & '1' & (pos-1 downto 0 => '0');
END behavior;


