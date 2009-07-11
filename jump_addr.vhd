-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use work.components.sign_ext;

entity jump_addr is
	generic (
		n : integer := 16;
		k : integer := 12
	);
	port (
		in_addr : in std_logic_vector(k-1 downto 0);
		pc : in std_logic_vector(n-1 downto 0);
		pc_out : out std_logic_vector(n-1 downto 0) 
	);
end jump_addr;


architecture behavior of jump_addr is
	signal tmp : std_logic_vector (n - 1 downto 0);
begin
	-- sign extender instance, respects the sign
	instance : sign_ext
		generic map ( k => 12, n => 16)
		port map (in_addr, tmp);
	-- sift left logical by one : sll pc,1;
	pc_out <= tmp(n - 1 downto 1)&'0' + pc;
end behavior;

