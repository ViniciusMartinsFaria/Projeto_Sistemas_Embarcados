library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity sobel_topo is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        bloco               : in matriz;
        pixel               : out std_logic_vector(15 downto 0) 
    );
end sobel_topo;

architecture RTL of sobel_topo is

    signal REG_gx : std_logic_vector(15 downto 0);
    signal REG_gy : std_logic_vector(15 downto 0);

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

    component pitagoras is
    port(
        Gx          : in  std_logic_vector(15 downto 0);
        Gy          : in  std_logic_vector(15 downto 0);
        saida       : out std_logic_vector(15 downto 0));
    end component;

    signal Gx_sg        : std_logic_vector(15 downto 0);
    signal Gy_sg        : std_logic_vector(15 downto 0);
    signal saida_sg     : std_logic_vector(15 downto 0);

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

    inst_teorema_de_pitagoras: pitagoras
    port map (
        Gx      => REG_gx,
        Gy      => REG_gy,
        saida   => saida_sg
    );
    

    process (clock, reset)
    begin
        if (reset = '1') then
            REG_gx <= (others => '0');
            REG_gy <= (others => '0');
            pixel <= (others => '0');
        else
            if (rising_edge(clock)) then

                REG_gx <= Gx_sg;
                REG_gy <= Gy_sg;
                
                pixel <= saida_sg;
            end if;
        end if;
    end process;

end RTL;