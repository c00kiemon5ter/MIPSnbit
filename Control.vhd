-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity Control is
	generic (
		opcode_size : integer := 4
	);
	port (
		opcode : in std_logic_vector(opcode_size-1 downto 0);
		RegDst : out std_logic;
		ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
		ALUSrc, Brnch, MemRead, MemWrite, MemtoReg, RegWrite : out STD_LOGIC 
		-- NOTE: ALUSrc isn't used, instead we use the imporoved branch prediction and the 'branch and equal' gate
	);
end Control;


architecture behavioral of Control is
	-- opcode values
	constant R_TYPE : std_logic_vector(3 downto 0) := "0000";
	constant BRANCH : std_logic_vector(3 downto 0) := "0100";
	constant LW : std_logic_vector(3 downto 0) := "0010";
	constant SW : std_logic_vector(3 downto 0) := "0001";
	constant EOR : std_logic_vector(3 downto 0) := "0110";
	-- ALUop opcodes
	constant ALUsw, ALUlw : std_logic_vector(1 downto 0) := "00";
	constant ALUrtype : std_logic_vector(1 downto 0) := "10";
	constant ALUbranch : std_logic_vector(1 downto 0) := "01";
begin
	process(opcode)
	begin
		-- examine the opcode
		case opcode is
			when R_TYPE =>
				ALUOp <= ALUrtype;
				RegDst <= '1';
				ALUSrc <= '0';
				MemtoReg <= '0';
				RegWrite <= '1';
				MemRead <= '0';
				MemWrite <= '0';
				Brnch <= '0';
			when LW =>
				ALUOp <= ALUlw;
				RegDst <= '0';
				ALUSrc <= '1';
				MemtoReg <= '1';
				RegWrite <= '1';
				MemRead <= '1';
				MemWrite <= '0';
				Brnch <= '0';
			when SW =>
				ALUOp <= ALUsw;
				RegDst <= 'X';
				ALUSrc <= '1';
				MemtoReg <= 'X';
				RegWrite <= '0';
				MemRead <= '0';
				MemWrite <= '1';
				Brnch <= '0';
			when BRANCH =>
				ALUOp <= ALUbranch;
				RegDst <= 'X';
				ALUSrc <= '0';
				MemtoReg <= 'X';
				RegWrite <= '0';
				MemRead <= '0';
				MemWrite <= '0';
				Brnch <= '1';
			when others =>
				-- Undefined opcodes
				ALUOp <= "UU";
				RegDst <= 'U';
				ALUSrc <= 'U';
				MemtoReg <= 'U';
				RegWrite <= 'U';
				MemRead <= 'U';
				MemWrite <= 'U';
				Brnch <= 'U';
		end case;
	end process;
end behavioral;
