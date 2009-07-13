library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity plaketa is
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6;
		reg_num : INTEGER := 8
	);
	port(
PIN_N2 : in std_logic;
PIN_V2 : in std_logic;
PIN_N25 : in std_logic;
PIN_N26 : in std_logic;
PIN_P25 : in std_logic;
PIN_AE14 : in std_logic;

PIN_AD12 : out std_logic;

PIN_AF10 : out std_logic;
PIN_AB12 : out std_logic;
PIN_AC12 : out std_logic;
PIN_AD11 : out std_logic;
PIN_AE11 : out std_logic;
PIN_V14 : out std_logic;
PIN_V13 : out std_logic;

PIN_V20: out std_logic;
PIN_V21: out std_logic;
PIN_W21: out std_logic;
PIN_Y22: out std_logic;
PIN_AA24: out std_logic;
PIN_AA23: out std_logic;
PIN_AB24: out std_logic;

PIN_AB23: out std_logic;
PIN_V22: out std_logic;
PIN_AC25: out std_logic;
PIN_AC26: out std_logic;
PIN_AB26: out std_logic;
PIN_AB25: out std_logic;
PIN_Y24: out std_logic;

PIN_Y23: out std_logic;
PIN_AA25: out std_logic;
PIN_AA26: out std_logic;
PIN_Y26: out std_logic;
PIN_Y25: out std_logic;
PIN_U22: out std_logic;
PIN_W24: out std_logic;

PIN_U9: out std_logic;
PIN_U1: out std_logic;
PIN_U2: out std_logic;
PIN_T4: out std_logic;
PIN_R7: out std_logic;
PIN_R6: out std_logic;
PIN_T3: out std_logic;

PIN_T2: out std_logic;
PIN_P6: out std_logic;
PIN_P7: out std_logic;
PIN_T9: out std_logic;
PIN_R5: out std_logic;
PIN_R4: out std_logic;
PIN_R3: out std_logic;

PIN_R2: out std_logic;
PIN_P4: out std_logic;
PIN_P3: out std_logic;
PIN_M2: out std_logic;
PIN_M3: out std_logic;
PIN_M5: out std_logic;
PIN_M4: out std_logic;

PIN_L3: out std_logic;
PIN_L2: out std_logic;
PIN_L9: out std_logic;
PIN_L6: out std_logic;
PIN_L7: out std_logic;
PIN_P9: out std_logic;
PIN_N9: out std_logic

);
end plaketa;

architecture struct of plaketa is
---------------------------------------------------------

component Processor IS 
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6;
		reg_num : INTEGER := 8
	);
	PORT(
		pipe_clock: in std_logic;
		clock : in std_logic;
		-------------------------------------------------------
		regOUT: out std_logic_vector(127+16 downto 0); --pros othoni (REGs + PC)
		--------------------------------------------------------
		instructionAD : out std_logic_vector(15 downto 0);
		instr: in std_logic_vector(15 downto 0):= x"0000";
		----------------------------------------------------------
		dataAD: out std_logic_vector(15 downto 0);
		fromData: in std_logic_vector(15 downto 0):= x"0000";
		toData: out std_logic_vector(15 downto 0);
		DataWriteFlag: out std_logic
	);
END component;

component data_memory IS
PORT(
	address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
	clock		: IN STD_LOGIC ;
	data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	wren		: IN STD_LOGIC ;
	q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
);
END component;

component instruction_memory IS
PORT(
	address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
	clock		: IN STD_LOGIC ;
	q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
);
END component;

component GraphicCard IS PORT(
dataAll :IN STD_LOGIC_VECTOR(143 DOWNTO 0):=x"000000000000000000000000000000000000";
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
END component;

-------------------------------------------------------
-- pins signals
-------------------------------------------------------


signal RealClock,clockin: std_logic;
signal clockOut: std_logic;

signal who: STD_LOGIC_VECTOR(3 DOWNTO 0);

signal decoded0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded4 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded5 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded6 : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decoded7 : STD_LOGIC_VECTOR(6 DOWNTO 0);

-------------------------------------------------------

-------------------------------------------------------
signal pipe_clock, test_clock : std_logic;
signal counter: std_logic_vector(63 downto 0):=x"0000000000000000";

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
signal dataAll: std_logic_vector(127+16 downto 0);
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
signal nextInstr: std_logic_vector(15 downto 0);
signal instr: std_logic_vector(15 downto 0);
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
signal dataAddr:std_logic_vector(15 downto 0);
signal fromData:std_logic_vector(15 downto 0);
signal toData: std_logic_vector(15 downto 0);
signal DataWriteFlag: std_logic;
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
---------------------------------------------------------

begin

pipe_clock <= clockin;
test_clock <= RealClock AND pipe_clock;

inm: instruction_memory port map(nextInstr(13 DOWNTO 1),RealClock, instr);
data: data_memory port map(dataAddr(14 DOWNTO 1),RealClock,toData,DataWriteFlag,fromData);


processorM: Processor 	generic map(n, addr_size, opcode_size, imm_size, reg_num)
			port map( pipe_clock, test_clock, dataAll,
				 --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
				  nextInstr, instr,
				 --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
				  dataAddr, fromData, toData, DataWriteFlag
				 --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
				);

GC: GraphicCard PORT MAP(
dataAll,
who,
decoded0,
decoded1,
decoded2,
decoded3,
decoded4,
decoded5,
decoded6,
decoded7
);

clockOut<=pipe_clock;

----------------------------------------
--               PINS           {     --
----------------------------------------

RealClock<=PIN_N2;
clockin<=PIN_V2;

who(0)<=PIN_N25;
who(1)<=PIN_N26;
who(2)<=PIN_P25;
who(3)<=PIN_AE14;

PIN_AD12<=clockOut;

PIN_AF10 <=decoded0(0);
PIN_AB12 <=decoded0(1);
PIN_AC12 <=decoded0(2);
PIN_AD11 <=decoded0(3);
PIN_AE11 <=decoded0(4);
PIN_V14 <=decoded0(5);
PIN_V13 <=decoded0(6);

PIN_V20<=decoded1(0);
PIN_V21<=decoded1(1);
PIN_W21<=decoded1(2);
PIN_Y22<=decoded1(3);
PIN_AA24<=decoded1(4);
PIN_AA23<=decoded1(5);
PIN_AB24<=decoded1(6);

PIN_AB23<=decoded2(0);
PIN_V22<=decoded2(1);
PIN_AC25<=decoded2(2);
PIN_AC26<=decoded2(3);
PIN_AB26<=decoded2(4);
PIN_AB25<=decoded2(5);
PIN_Y24<=decoded2(6);

PIN_Y23<=decoded3(0);
PIN_AA25<=decoded3(1);
PIN_AA26<=decoded3(2);
PIN_Y26<=decoded3(3);
PIN_Y25<=decoded3(4);
PIN_U22<=decoded3(5);
PIN_W24<=decoded3(6);

PIN_U9<=decoded4(0);
PIN_U1<=decoded4(1);
PIN_U2<=decoded4(2);
PIN_T4<=decoded4(3);
PIN_R7<=decoded4(4);
PIN_R6<=decoded4(5);
PIN_T3<=decoded4(6);

PIN_T2<=decoded5(0);
PIN_P6<=decoded5(1);
PIN_P7<=decoded5(2);
PIN_T9<=decoded5(3);
PIN_R5<=decoded5(4);
PIN_R4<=decoded5(5);
PIN_R3<=decoded5(6);

PIN_R2<=decoded6(0);
PIN_P4<=decoded6(1);
PIN_P3<=decoded6(2);
PIN_M2<=decoded6(3);
PIN_M3<=decoded6(4);
PIN_M5<=decoded6(5);
PIN_M4<=decoded6(6);

PIN_L3<=decoded7(0);
PIN_L2<=decoded7(1);
PIN_L9<=decoded7(2);
PIN_L6<=decoded7(3);
PIN_L7<=decoded7(4);
PIN_P9<=decoded7(5);
PIN_N9<=decoded7(6);

----------------------------------------
----- } -------- PINS ------------------
----------------------------------------

end struct;
