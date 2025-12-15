library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;


entity interface_bloco_paralelo is
    port (
        pin_1               : in std_logic_vector(31 downto 0);
        pin_2               : in std_logic_vector(31 downto 0);
        pin_3               : in std_logic_vector(31 downto 0);
        pin_4               : in std_logic_vector(31 downto 0);
        bloco_0             : out matriz;
        bloco_1             : out matriz
        );
end interface_bloco_paralelo;

architecture RTL of interface_bloco_paralelo is

    signal pos_0      : std_logic_vector(7 downto 0);
    signal pos_1      : std_logic_vector(7 downto 0);
    signal pos_2      : std_logic_vector(7 downto 0);
    signal pos_3      : std_logic_vector(7 downto 0);
    signal pos_4      : std_logic_vector(7 downto 0);
    signal pos_5      : std_logic_vector(7 downto 0);
    signal pos_6      : std_logic_vector(7 downto 0);
    signal pos_7      : std_logic_vector(7 downto 0);
    signal pos_8      : std_logic_vector(7 downto 0);
    signal pos_9      : std_logic_vector(7 downto 0);
    signal pos_10     : std_logic_vector(7 downto 0);
    signal pos_11     : std_logic_vector(7 downto 0);
    signal pos_12     : std_logic_vector(7 downto 0);
    signal pos_13     : std_logic_vector(7 downto 0);
    signal pos_14     : std_logic_vector(7 downto 0);

    begin

        pos_0   <=  pin_1(31 downto 24);
        pos_1   <=  pin_1(23 downto 16);
        pos_2   <=  pin_1(15 downto 8 );
        pos_3   <=  pin_1(7  downto 0 );
        pos_4   <=  pin_2(31 downto 24);
        pos_5   <=  pin_2(23 downto 16);
        pos_6   <=  pin_2(15 downto 8 );
        pos_7   <=  pin_2(7  downto 0 );
        pos_8   <=  pin_3(31 downto 24);
        pos_9   <=  pin_3(23 downto 16);
        pos_10  <=  pin_3(15 downto 8 );
        pos_11  <=  pin_3(7  downto 0 );
        pos_12  <=  pin_4(31 downto 24);
        pos_13  <=  pin_4(23 downto 16);
        pos_14  <=  pin_4(15 downto 8);

        bloco_0(0,0)    <=  pos_0;
        bloco_0(0,1)    <=  pos_1;
        bloco_0(0,2)    <=  pos_2;
        bloco_0(1,0)    <=  pos_5;
        bloco_0(1,1)    <=  pos_6;
        bloco_0(1,2)    <=  pos_7;
        bloco_0(2,0)    <=  pos_10;
        bloco_0(2,1)    <=  pos_11;
        bloco_0(2,2)    <=  pos_12;

        bloco_1(0,0)    <=  pos_2;
        bloco_1(0,1)    <=  pos_3;
        bloco_1(0,2)    <=  pos_4;
        bloco_1(1,0)    <=  pos_7;
        bloco_1(1,1)    <=  pos_8;
        bloco_1(1,2)    <=  pos_9;
        bloco_1(2,0)    <=  pos_12;
        bloco_1(2,1)    <=  pos_13;
        bloco_1(2,2)    <=  pos_14;

end RTL;