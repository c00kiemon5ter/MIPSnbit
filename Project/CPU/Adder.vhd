library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Adder is
	generic(
		n : INTEGER := 16
	);
	port(
		A, B : in std_logic_vector(n-1 downto 0);
		carry : out std_logic;
		sum : out std_logic_vector(n-1 downto 0)
	);
end Adder;


architecture behv of Adder is
	signal result: std_logic_vector(n downto 0);
begin					  
	result <= ('0' & A)+('0' & B);
    	sum <= result(n-1 downto 0);
    	carry <= result(n);
end behv;

