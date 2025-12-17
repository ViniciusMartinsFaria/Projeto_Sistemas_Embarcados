library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;


entity tb_matriz is
end tb_matriz;

architecture behavior of tb_matriz is
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

signal  entrada_sg    : matriz;
signal  entrada_0_sg  : matriz;
signal  entrada_1_sg  : matriz;
signal  saida_0_sg    : std_logic_vector(15 downto 0);
signal  saida_1_sg    : std_logic_vector(15 downto 0);

begin
inst_Gx: G_x
port map (
        entrada => entrada_0_sg,
        saida   => saida_0_sg
    );

inst_Gy: G_y
port map (
        entrada => entrada_1_sg,
        saida   => saida_1_sg
    );

    entrada_sg <= (
        0 => ( 0 => x"0A", 1 => x"09", 2 => x"09" ),
        1 => ( 0 => x"00", 1 => x"06", 2 => x"06" ),
        2 => ( 0 => x"05", 1 => x"09", 2 => x"08" )
    );

    entrada_0_sg <= entrada_sg;
    entrada_1_sg <= entrada_sg;

end behavior;