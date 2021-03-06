-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity Hazard is
	port (
		rs : in STD_LOGIC_VECTOR(2 downto 0);  	   -- if/id source register s
		rt : in STD_LOGIC_VECTOR(2 downto 0);  	   -- if/id source register t
		prevRt : in STD_LOGIC_VECTOR(2 downto 0);  -- id/ex source register t
		isBranch : in STD_LOGIC; 	-- if a branch is being taken
		wasLw : in STD_LOGIC; 		-- if load word was performed :: If ( ID_EX_Reg_MemRead='1' ) 
		reset : in STD_LOGIC; 		-- reset all values, no hazard
		clk : in STD_LOGIC;
		pcUpdate : out STD_LOGIC; 	-- if PC should update
		pcSel : out STD_LOGIC; 		-- update the pc with +4 or branch
		IF_ID_Clear : out STD_LOGIC;	-- clear the If/Id register
		flush : out STD_LOGIC 		-- if flush should take place
	);
end Hazard;


architecture behavior of Hazard is
begin
	Hazard_detect : process(rs, rt, prevRt, isBranch, wasLw, reset, clk)
	begin
		if (reset='0') then  -- reset all values
			IF_ID_Clear <= '0';
			pcUpdate <= '1'; -- update the pc
			pcSel <= '0';    -- next pc value should be pc+4
			flush <= '0';	 -- do not flush, use next instruction normally
		elsif (wasLw = '1') then  -- look for common registers
			if (rs = prevRt) or (rt = prevRt) then
				IF_ID_Clear <= '1';
				pcUpdate <= '0';  -- do not update pc
				pcSel <= '0';     -- next pc value is pc+4
				flush <= '1';	 -- flush instruction
			else  -- reset, all normal, no hazard
				IF_ID_Clear <= '0';
				pcUpdate <= '1'; -- update the pc
				pcSel <= '0';    -- next pc value should be pc+4
				flush <= '0';	 -- do not flush, use next instruction normally
			end if;
		elsif (isBranch = '1') then -- a branch or jump takes place
			IF_ID_Clear <= '1';
			pcUpdate <= '1'; -- update pc
			pcSel <= '1'; 	 -- next pc value is branch
			flush <= '1'; 	 -- flush instruction
		else  -- reset, no hazards
			IF_ID_Clear <= '0';
			pcUpdate <= '1'; -- update the pc
			pcSel <= '0';    -- next pc value should be pc+4
			flush <= '0';	 -- do not flush, use next instruction normally
		end if;
	end process Hazard_detect;

-- NOTE: This may be needed, different timing, half cycles, etc. 
-- NOTE: Check Waveform and use, replacing the IF_ID_Clear sigs above 
-- NOTE: with appropriate values for the clearFlag
--	-- handle updating the clear flag
--	clear_id_if_reg : process( clearFlag, clk, reset ) begin
--		-- don't clear on a reset
--		if( reset = '0' ) then
--			if_id_clr <= '0'; -- dont clear
--		else
--			-- if we switched to low for the first time, then clear the reg
--			if( clearFlag = '1' ) then
--				if_id_clr <= '1';
--			end if;
--			-- if we've received an ack, stop clearing
--			if( clearFlag = '0' ) then
--				if_id_clr <= '0';
--			end if; 
--		end if;
--	end process clear_id_if_reg;
end behavior;

