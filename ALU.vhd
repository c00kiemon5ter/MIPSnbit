-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY ALU IS
	generic ( 
		n : INTEGER := 16
	);
	port(
		a, b : in std_logic_vector(n-1 downto 0);
		func : in std_logic_vector(2 downto 0);
		zero : out std_logic;
		f : out std_logic_vector(n-1 downto 0));
END ALU;


architecture behavioral of ALU is
	constant ADD_FUNC : std_logic_vector(2 downto 0) := "000";
	constant SUB_FUNC : std_logic_vector(2 downto 0) := "001";
	constant AND_FUNC : std_logic_vector(2 downto 0) := "010";
	constant OR_FUNC  : std_logic_vector(2 downto 0) := "011";
	constant GEQ_FUNC : std_logic_vector(2 downto 0) := "100";
	constant NOT_FUNC : std_logic_vector(2 downto 0) := "101";
begin	
process(func)
		variable temp: std_logic_vector(n-1 downto 0);
	begin
		case func is
			when ADD_FUNC =>
				temp := a + b;
			when SUB_FUNC =>
				temp := a - b;
			when AND_FUNC =>
				temp := a and b;
			when OR_FUNC =>
				temp := a or b;
			when GEQ_FUNC =>
				-- if msb(a) is set, then a is negative 
				temp := (OTHERS => NOT(a(n-1)));
			when NOT_FUNC =>
				-- implements if_zero
				if (a = (n-1 downto 0 => '0')) then
					temp := (OTHERS => '0');
				else
					temp := (OTHERS => '1');
				end if;
			when others =>
				temp := a - b;
		end case;
		if temp = (n-1 downto 0 => '0') then
			zero <= '1';
		else
			zero <= '0';
		end if;
		f <= temp;
	end process;
end behavioral;

