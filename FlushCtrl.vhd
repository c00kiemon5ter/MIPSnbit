library IEEE;
use IEEE.std_logic_1164.all;

entity FlushCtrl is
	port (
		inMemtoReg, inRegWrite : in std_logic;
		inBranch, inMemRead, inMemWrite : in std_logic;
		inRegDst : in std_logic;
		inALUop : in std_logic_vector(1 downto 0);
		inALUSrc : in std_logic;
		flush : IN STD_LOGIC;
		outMemtoReg, outRegWrite : out std_logic;
		outBranch, outMemRead, outMemWrite : out std_logic;
		outRegDst : out std_logic;
		outALUop : out std_logic_vector(1 downto 0);
		outALUSrc : out std_logic
	);
end FlushCtrl;


architecture behavioral of FlushCtrl is
begin

process (flush)
begin
	if flush = '1' then 	-- flush
		outMemtoReg <= '0';
		outRegWrite <= '0';
		outBranch <= '0';
		outMemRead <= '0';
		outMemWrite <= '0';
		outRegDst <= '0';
		outALUop <= "00";
		outALUSrc <= '0';
	else 	-- do not interfere
		outMemtoReg <= inMemtoReg;
		outRegWrite <= inRegWrite;
		outBranch <= inBranch;
		outMemRead <= inMemRead;
		outMemWrite <= inMemWrite;
		outRegDst <= inRegDst;
		outALUop <= inALUop;
		outALUSrc <= inALUSrc;

	end if;
end process;

end behavioral;

