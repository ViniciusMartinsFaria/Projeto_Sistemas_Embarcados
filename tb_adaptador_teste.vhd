library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;


entity tb_adaptador is
end tb_adaptador;

architecture behavior of tb_adaptador is
component sobel_paralelo_pipeline_topo is
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
end component;

signal clock_sg     : std_logic := '0';
signal reset_sg     : std_logic := '1';
signal entrada_1_sg : std_logic_vector(31 downto 0);
signal entrada_2_sg : std_logic_vector(31 downto 0);
signal entrada_3_sg : std_logic_vector(31 downto 0);
signal entrada_4_sg : std_logic_vector(31 downto 0);
signal pixel_0_sg   : std_logic_vector(7 downto 0);
signal pixel_1_sg   : std_logic_vector(7 downto 0);

begin
inst_Sobel: sobel_paralelo_pipeline_topo
port map (
        clock       => clock_sg,
        reset       => reset_sg,
        entrada_1   => entrada_1_sg,
        entrada_2   => entrada_2_sg,
        entrada_3   => entrada_3_sg,
        entrada_4   => entrada_4_sg,
        pixel_0     => pixel_0_sg,
        pixel_1     => pixel_1_sg
    );

clock_sg <= not clock_sg after 10 ns;

process
begin
    wait for 5 ns;
        reset_sg <= '0';
    wait for 10 ns;

        entrada_1_sg(31 downto 24) <= x"0A"; -- pos_0
        entrada_1_sg(23 downto 16) <= x"09"; -- pos_1
        entrada_1_sg(15 downto 8 ) <= x"09"; -- pos_2 (Compartilhado: Fim do Bloco 0 / Início do Bloco 1)
        entrada_1_sg(7  downto 0 ) <= x"09"; -- pos_3 
        entrada_2_sg(31 downto 24) <= x"0A"; -- pos_4

        -- Linha 1 da matriz 5x3 (pos_5 a pos_9)
        entrada_2_sg(23 downto 16) <= x"00"; -- pos_5
        entrada_2_sg(15 downto 8 ) <= x"06"; -- pos_6
        entrada_2_sg(7  downto 0 ) <= x"06"; -- pos_7 (Compartilhado: Fim do Bloco 0 / Início do Bloco 1)
        entrada_3_sg(31 downto 24) <= x"06"; -- pos_8
        entrada_3_sg(23 downto 16) <= x"00"; -- pos_9 (Exemplo)

        -- Linha 2 da matriz 5x3 (pos_10 a pos_14)
        entrada_3_sg(15 downto 8 ) <= x"05"; -- pos_10
        entrada_3_sg(7  downto 0 ) <= x"09"; -- pos_11
        entrada_4_sg(31 downto 24) <= x"08"; -- pos_12 (Compartilhado: Fim do Bloco 0 / Início do Bloco 1)
        entrada_4_sg(23 downto 16) <= x"09"; -- pos_13
        entrada_4_sg(15 downto 8 ) <= x"05"; -- pos_14

wait;
end process;

end behavior;