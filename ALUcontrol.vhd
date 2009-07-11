-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity ALUcontrol is 
	generic (
		n : integer := 16
	);
	port (
		immediate : in std_logic_vector(5 downto 0);
		ALUop_in : in std_logic_vector(1 downto 0);
		ALUop_out : out std_logic_vector(2 downto 0)
	);
end ALUcontrol;


architecture behavior of ALUcontrol is
	signal func : std_logic_vector(2 downto 0) := immediate(2 downto 0);
	constant ADD_FUNC : std_logic_vector(2 downto 0) := "000";
	constant NOT_FUNC : std_logic_vector(2 downto 0) := "101";
begin
	process(ALUop_in)
	begin
		case ALUop_in(1) is
			when '1' => -- Rtype
				ALUop_out <= func;
			when '0' =>
				case ALUop_in(0) is
					when '0' => -- SW, LW
						ALUop_out <= ADD_FUNC;
					when '1' => -- Branch
						ALUop_out <= NOT_FUNC;
					when OTHERS =>
						ALUop_out <= (OTHERS => 'U');
				end case;
			when OTHERS =>
				ALUop_out <= (OTHERS => 'U');
		end case;
	end process;
end behavior;

