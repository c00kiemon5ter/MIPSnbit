-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity sign_ext is
	generic (
		n : integer := 16;
		k : integer := 6
	);
	port (	
		imm : in std_logic_vector (k-1 downto 0);
		ext : out std_logic_vector (n-1 downto 0)
	);
end sign_ext;


architecture behavior of sign_ext is
begin
	-- the last $k bits are the same
	-- ext(k-1 downto 0) <= imm;
	-- check the first bit and set the rest bits as that one
	-- ext(n-1 downto k) <= (n-1 downto k => imm(k-1));	
	ext <=(n-1 downto k => imm(k-1)) & (imm);
end behavior;

