library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity sobel_paralelo_topo is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        entrada_1           : in std_logic_vector(31 downto 0);
        entrada_2           : in std_logic_vector(31 downto 0);
        entrada_3           : in std_logic_vector(31 downto 0);
        entrada_4           : in std_logic_vector(31 downto 0);
        pixel_0             : out std_logic_vector(7 downto 0);
        pixel_1             : out std_logic_vector(7 downto 0)
    );
end sobel_paralelo_topo;

architecture RTL of sobel_paralelo_topo is

    component interface_bloco_paralelo is
    port(
        pin_1               : in std_logic_vector(31 downto 0);
        pin_2               : in std_logic_vector(31 downto 0);
        pin_3               : in std_logic_vector(31 downto 0);
        pin_4               : in std_logic_vector(31 downto 0);
        bloco_0             : out matriz;
        bloco_1             : out matriz
        );
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

    component pitagoras is
    port(
        Gx          : in  std_logic_vector(15 downto 0);
        Gy          : in  std_logic_vector(15 downto 0);
        saida       : out std_logic_vector(7 downto 0));
    end component;

    signal bloco_0_sg   : matriz;
    signal bloco_1_sg   : matriz;
    signal Gx_0_sg      : std_logic_vector(15 downto 0);
    signal Gy_0_sg      : std_logic_vector(15 downto 0);
    signal Gx_1_sg      : std_logic_vector(15 downto 0);
    signal Gy_1_sg      : std_logic_vector(15 downto 0);
    signal saida_0_sg   : std_logic_vector(7 downto 0);
    signal saida_1_sg   : std_logic_vector(7 downto 0);

begin

    inst_interface_bloco: interface_bloco_paralelo
    port map (
        pin_1   => entrada_1,
        pin_2   => entrada_2,
        pin_3   => entrada_3,
        pin_4   => entrada_4,
        bloco_0 => bloco_0_sg,
        bloco_1 => bloco_1_sg
    );

    inst_Gx_0: G_x
    port map (
        entrada => bloco_0_sg,
        saida   => Gx_0_sg
    );

    inst_Gy_0: G_y
    port map (
        entrada => bloco_0_sg,
        saida   => Gy_0_sg
    );

    inst_Gx_1: G_x
    port map (
        entrada => bloco_1_sg,
        saida   => Gx_1_sg
    );

    inst_Gy_1: G_y
    port map (
        entrada => bloco_1_sg,
        saida   => Gy_1_sg
    );

    inst_teorema_de_pitagoras_0: pitagoras
    port map (
        Gx      => Gx_0_sg,
        Gy      => Gy_0_sg,
        saida   => saida_0_sg
    );

    inst_teorema_de_pitagoras_1: pitagoras
    port map (
        Gx      => Gx_1_sg,
        Gy      => Gy_1_sg,
        saida   => saida_1_sg
    );
    

    process (clock, reset)
    begin
        if (reset = '1') then

                pixel_0 <= (others => '0');
                pixel_1 <= (others => '0');

        else
            if (rising_edge(clock)) then
                
                pixel_0 <= saida_0_sg;
                pixel_1 <= saida_1_sg;
            
            end if;
        end if;
    end process;

end RTL;