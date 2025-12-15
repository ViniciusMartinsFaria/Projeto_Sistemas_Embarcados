library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;


entity interface_bloco is
    port (
        pin_1               : in std_logic_vector(31 downto 0);
        pin_2               : in std_logic_vector(31 downto 0);
        pin_3               : in std_logic_vector(31 downto 0);
        bloco               : out matriz
        );
end interface_bloco;

architecture RTL of interface_bloco is

    signal pos_0      : std_logic_vector(7 downto 0);
    signal pos_1      : std_logic_vector(7 downto 0);
    signal pos_2      : std_logic_vector(7 downto 0);
    signal pos_3      : std_logic_vector(7 downto 0);
    signal pos_4      : std_logic_vector(7 downto 0);
    signal pos_5      : std_logic_vector(7 downto 0);
    signal pos_6      : std_logic_vector(7 downto 0);
    signal pos_7      : std_logic_vector(7 downto 0);
    signal pos_8      : std_logic_vector(7 downto 0);

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

        bloco(0,0)    <=  pos_0;
        bloco(0,1)    <=  pos_1;
        bloco(0,2)    <=  pos_2;
        bloco(1,0)    <=  pos_3;
        bloco(1,1)    <=  pos_4;
        bloco(1,2)    <=  pos_5;
        bloco(2,0)    <=  pos_6;
        bloco(2,1)    <=  pos_7;
        bloco(2,2)    <=  pos_8;


end RTL;