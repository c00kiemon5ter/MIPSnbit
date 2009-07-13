LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY GraphicCard IS PORT(
dataAll :IN STD_LOGIC_VECTOR(16*9-1 DOWNTO 0):=x"000000000000000000000000000000000000";
who  :IN STD_LOGIC_VECTOR(3 DOWNTO 0):=x"0";

decoded0 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded1 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded2 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded3 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded4 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded5 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded6 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded7 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0)

);
END GraphicCard;

ARCHITECTURE Structure OF GraphicCard IS

---------------------------------------------------------
component RegPlay IS PORT(
short :IN STD_LOGIC_VECTOR(15 DOWNTO 0);

decoded0 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded1 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded2 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded3 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
END component;

component DigitD IS PORT(
num :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
decoded :OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
end component;
-------------------------------------------------------------------
SIGNAL data   : STD_LOGIC_VECTOR(15 DOWNTO 0):=x"0000";
SIGNAL whoout : STD_LOGIC_VECTOR(6 DOWNTO 0):=x"0" &"000";
-------------------------------------------------------------------
BEGIN

process(who,dataAll)
begin
case who is
	when x"0" =>
		data<=dataAll(15 DOWNTO 0);
	when x"1" =>
		data<=dataAll(31 DOWNTO 16);
	when x"2" =>
		data<=dataAll(47 DOWNTO 32);
	when x"3" =>
		data<=dataAll(63 DOWNTO 48);
	when x"4" =>
		data<=dataAll(79 DOWNTO 64);
	when x"5" =>
		data<=dataAll(95 DOWNTO 80);
	when x"6" =>
		data<=dataAll(111 DOWNTO 96);
	when x"7" =>
		data<=dataAll(127 DOWNTO 112);
	when others =>
		data<=dataAll(143 DOWNTO 128);
end case;
end process;


rp: RegPlay port map(
data,
decoded0,
decoded1,
decoded2,
decoded3
);

decoded4 <="1111111";
decoded5 <="1111111";
decoded6 <="1111111";

WhoWas: DigitD PORT MAP(who,whoout);

process(who,whoout)
begin
case who(3) is
	when '0' =>
		decoded7<=whoout;
	when others =>
		decoded7<="0111111";
end case;
end process;

END Structure;
