-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee; 
use ieee.std_logic_1164.all;

entity Forwarder is
	port (
      		ALUSrc, EX_MEM_regwrite, MEM_WB_regwrite : IN STD_LOGIC;
      		EX_MEM_rd, MEM_WB_rd, ID_EX_rs, ID_EX_rt : IN STD_LOGIC_VECTOR(2 downto 0);
      		SelA, SelB : OUT STD_LOGIC_VECTOR(1 downto 0));
end entity Forwarder;


architecture behave of Forwarder is
begin
	process (EX_MEM_regwrite, MEM_WB_regwrite, EX_MEM_rd, MEM_WB_rd, ID_EX_rs, ID_EX_rt) 
	begin
		-- just set it to 00 for the default case
		SelA <= "00";  -- select id_ex_rs
		SelB <= "00";  -- select id_ex_rt
		-- change the ALU input mux's if needed
		if (EX_MEM_regwrite = '1') then
			if (ID_EX_rs = EX_MEM_rd) then
				SelA <= "01";  -- select ex_mem_rs
			else
				if (MEM_WB_regwrite='1' and ID_EX_rs = MEM_WB_rd) then
					SelA<="10";  -- select mem_wb_rs
				end if;
		end if;
			if (ID_EX_rt = EX_MEM_rd) then
				SelB <= "01";  -- select ex_mem_rt
			else
				if (MEM_WB_regwrite = '1' and ID_EX_rt = MEM_WB_rd) then
					SelA<="10";  -- select mem_wb_rt
				end if;
			end if;
		end if;
		-- use immediate if ALUSrc is set
		if ALUSrc='1' then
			SelB <= "11";  -- select immediate
		end if;
	end process;
end architecture behave;

