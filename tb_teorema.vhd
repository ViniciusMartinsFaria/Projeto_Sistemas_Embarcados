library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;


entity tb_teorema is
end tb_teorema;

architecture behavior of tb_teorema is
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
inst_teorema_de_pitagoras: pitagoras
port map (
        Gx      => Gx_sg,
        Gy      => Gy_sg,
        saida   => saida_sg
    );

    stim_proc : process
    begin

        Gx_sg <= x"000E"; Gy_sg <= x"0006"; wait for 10 ns; -- 14 , 6
        Gx_sg <= x"FFEE"; Gy_sg <= x"0002"; wait for 10 ns; -- -18 , 2
        Gx_sg <= x"FFEA"; Gy_sg <= x"FFFE"; wait for 10 ns; -- -22 , -2
        Gx_sg <= x"000A"; Gy_sg <= x"FFFC"; wait for 10 ns; -- 10 , -4
        Gx_sg <= x"FFF1"; Gy_sg <= x"0001"; wait for 10 ns; -- -15 , 1
        Gx_sg <= x"FFF0"; Gy_sg <= x"FFFC"; wait for 10 ns; -- -16 , -4
        Gx_sg <= x"FFFF"; Gy_sg <= x"FFFB"; wait for 10 ns; -- -1 , -5
        Gx_sg <= x"FFF4"; Gy_sg <= x"FFFE"; wait for 10 ns; -- -12 , -2
        Gx_sg <= x"FFEF"; Gy_sg <= x"0001"; wait for 10 ns; -- -17 , 1

        wait; -- finaliza o processo

    end process;
end behavior;