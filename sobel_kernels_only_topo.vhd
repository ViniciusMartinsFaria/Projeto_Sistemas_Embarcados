library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity sobel_topo is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        bloco               : in matriz;
        Gx_saida            : out std_logic_vector(15 downto 0);
        Gy_saida            : out std_logic_vector(15 downto 0) 
    );
end sobel_topo;

architecture RTL of sobel_topo is

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

    signal Gx_sg        : std_logic_vector(15 downto 0);
    signal Gy_sg        : std_logic_vector(15 downto 0);

begin

    inst_Gx: G_x
    port map (
        entrada => bloco,
        saida   => Gx_sg
    );

    inst_Gy: G_y
    port map (
        entrada => bloco,
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