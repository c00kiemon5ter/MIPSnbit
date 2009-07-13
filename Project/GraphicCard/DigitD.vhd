LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DigitD IS PORT(
num :IN STD_LOGIC_VECTOR(3 DOWNTO 0):="1111";
decoded :OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
END DigitD;
--           __ 0
--         5|__|1     6_
--         4|__|2
--            3
--

ARCHITECTURE Structure OF DigitD IS
BEGIN

process(num)
begin
case num is
	when x"0" =>
		decoded<="1000000";
	when x"1" =>
		decoded<="1111001";
	when x"2" =>
		decoded<="0100100";
	when x"3" =>
		decoded<="0110000";
	when x"4" =>
		decoded<="0011001";
	when x"5" =>
		decoded<="0010010";
	when x"6" =>
		decoded<="0000010";
	when x"7" =>
		decoded<="1111000";
	when x"8" =>
		decoded<="0000000";
	when x"9" =>
		decoded<="0010000";
	when x"A" =>
		decoded<="0001000";
	when x"B" =>
		decoded<="0000011";
	when x"C" =>
		decoded<="1000110";
	when x"D" =>
		decoded<="0100001";
	when x"E" =>
		decoded<="0000110";
	when x"F" =>
		decoded<="0001110";
	when others =>
		decoded<="1111111";
end case;
end process;

END Structure;
