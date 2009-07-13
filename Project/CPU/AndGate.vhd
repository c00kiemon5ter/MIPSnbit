-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

ENTITY AndGate IS
	port(
		a, b : in std_logic;
		q : out std_logic
	);
END AndGate;

ARCHITECTURE behav OF AndGate IS
BEGIN
	q <= a AND b;
END behav;

