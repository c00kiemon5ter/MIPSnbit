LIBRARY ieee;
USE ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY RegPlay IS PORT(
short :IN STD_LOGIC_VECTOR(15 DOWNTO 0):=x"0000";

decoded0 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded1 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded2 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
decoded3 :OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
END RegPlay;

ARCHITECTURE Structure OF RegPlay IS

component DigitD IS PORT(
num :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
decoded :OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
end component;

BEGIN

dig0: DigitD port map(short(3 downto 0), decoded0 );
dig1: DigitD port map(short(7 downto 4), decoded1 );
dig2: DigitD port map(short(11 downto 8), decoded2 );
dig3: DigitD port map(short(15 downto 12), decoded3 );

END Structure;
