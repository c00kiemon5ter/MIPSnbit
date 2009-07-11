library IEEE;
use IEEE.std_logic_1164.all;

entity FlushCtrl is
	port (
		in_wb : in std_logic_vector(1 downto 0);
		in_mem : in std_logic_vector(2 downto 0);
		in_ex : in std_logic_vector(3 downto 0);
		sel : IN STD_LOGIC;
		out_wb : out std_logic_vector(1 downto 0);
		out_mem : out std_logic_vector(2 downto 0);
		out_ex : out std_logic_vector(3 downto 0)
	);
end FlushCtrl;


architecture behavioral of FlushCtrl is
begin

process (sel)
begin
	if sel = '1' then 	-- flush
		out_wb <= (OTHERS => '0');
		out_mem <= (OTHERS => '0');
		out_ex <= (OTHERS => '0');
	else 	-- do not interfere
		out_wb <= in_wb;
		out_mem <= in_mem;
		out_ex <= in_ex;
	end if;
end process;

end behavioral;
