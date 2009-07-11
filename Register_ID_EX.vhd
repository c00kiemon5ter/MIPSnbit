library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register_ID_EX is
	generic (
		n : INTEGER := 16
	);
	port (
    		inWB_ctrl : IN std_logic_vector(1 downto 0);
    		inMEM_ctrl : IN std_logic_vector(2 downto 0);
    		inEX_ctrl : IN std_logic_vector(3 downto 0);
  		inPC, inRead_data1, inRead_data2, inMEMAddress : IN std_logic_vector(n-1 downto 0);
  		inRS, inRT, inRD : IN std_logic_vector(4 downto 0);
  		clk : IN std_logic;
  		outWB_ctrl : OUT std_logic_vector(1 downto 0);
  		outMEM_ctrl : OUT std_logic_vector(2 downto 0);
		outEX_ctrl : OUT std_logic_vector(3 downto 0);
		outPC, outRead_data1, outRead_data2, outMEMAddress : OUT std_logic_vector(n-1 downto 0);
  		outRS, outRT, outRD : OUT std_logic_vector(4 downto 0)
	 );
end Register_ID_EX;


architecture behavior of Register_ID_EX is
begin

pc: process(clk)
begin
	if clk='1' then     -- rising edge
		outWB_ctrl<= inWB_ctrl;
    		outMEM_ctrl <= inMEM_ctrl;
    		outEX_ctrl <= inEX_ctrl;
    		outPC <= inPC;
    		outRead_data1 <= inRead_data1;
    		outRead_data2 <= inRead_data2;
    		outMEMAddress <= inMEMAddress;
    		outRS <= inRS;
    		outRT <= inRT;
    		outRD <= inRD;
    	end if;
end process pc;

end architecture behavior;
