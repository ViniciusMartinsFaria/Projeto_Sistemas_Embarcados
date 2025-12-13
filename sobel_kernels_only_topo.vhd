library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity sobel_topo is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        entrada_1           : in std_logic_vector(31 downto 0);
        entrada_2           : in std_logic_vector(31 downto 0);
        entrada_3           : in std_logic_vector(31 downto 0);
        Gx_saida            : out std_logic_vector(15 downto 0);
        Gy_saida            : out std_logic_vector(15 downto 0) 
    );
end sobel_topo;

architecture RTL of sobel_topo is

    component interface_bloco is
    port(
        pin_1               : in std_logic_vector(31 downto 0);
        pin_2               : in std_logic_vector(31 downto 0);
        pin_3               : in std_logic_vector(31 downto 0);
        bloco               : out matriz);
    end component;

    component G_x is
    port(
        entrada     : in matriz;
        saida       : out std_logic_vector(15 downto 0));
    end component;

    component G_y is
    port(
        entrada     : in matriz;
        saida       : out std_logic_vector(15 downto 0));
    end component;

    signal bloco_sg     : matriz;
    signal Gx_sg        : std_logic_vector(15 downto 0);
    signal Gy_sg        : std_logic_vector(15 downto 0);

begin

    inst_interface_bloco: interface_bloco
    port map (
        pin_1   => entrada_1,
        pin_2   => entrada_2,
        pin_3   => entrada_3,
        bloco   => bloco_sg
    );

    inst_Gx: G_x
    port map (
        entrada => bloco_sg,
        saida   => Gx_sg
    );

    inst_Gy: G_y
    port map (
        entrada => bloco_sg,
        saida   => Gy_sg
    );
    

    process (clock, reset)
    begin
        if (reset = '1') then
            Gx_saida <= (others => '0');
            Gy_saida <= (others => '0');
        else
            if (rising_edge(clock)) then
                
                Gx_saida <= Gx_sg;
                Gy_saida <= Gy_sg;

            end if;
        end if;
    end process;

end RTL;
