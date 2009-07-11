-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity RegFile is
	generic ( 
		n : integer := 16;
		k : INTEGER := 3
	);
	port (	
		clock, RegWrite : in std_logic;
		data : in std_logic_vector (n-1 downto 0);
		rd_address, rs_address, rt_address : in std_logic_vector (k-1 downto 0);
		rs_out, rt_out : out std_logic_vector (n-1 downto 0)
	);
END RegFile;


ARCHITECTURE behavior of RegFile is
	type register_tab is array (1 to n-1) of std_logic_vector(n-1 downto 0); -- reg$zero is always 0
	signal registers : register_tab;
	signal sig_rs_add, sig_rt_add, sig_rd_add : integer range 0 to n-1;
BEGIN 
	sig_rs_add <= to_integer( unsigned(rs_address) );
	sig_rt_add <= to_integer( unsigned(rt_address) );
	sig_rd_add <= to_integer( unsigned(rd_address) );

	rs_out <= (others => '0') when sig_rs_add = 0 -- reg$zero is always 0
		else registers(sig_rs_add);
	rt_out <= (others => '0') when sig_rt_add = 0 -- reg$zero is always 0
		else registers(sig_rt_add);

PROCESS (clock)
BEGIN
	IF clock = '1' AND clock'event THEN	-- write at the second half 
		IF RegWrite = '1' AND sig_rd_add /= 0 THEN -- we never write to reg$zero
			registers(sig_rd_add) <= data;
		END IF;
	END IF;
END PROCESS;

END behavior;

