library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;


entity tb_sobel_topo is
end tb_sobel_topo;

architecture behavior of tb_sobel_topo is
component sobel_topo is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        bloco               : in matriz;
        pixel               : out std_logic_vector(15 downto 0));
end component;

signal  clock_sg    : std_logic := '0';
signal  reset_sg    : std_logic := '1';
signal  bloco_sg    : matriz;
signal  pixel_sg    : std_logic_vector(15 downto 0);

begin
inst_Sobel: sobel_topo
port map (
        clock   => clock_sg,
        reset   => reset_sg,
        bloco   => bloco_sg,
        pixel   => pixel_sg
    );

clock_sg <= not clock_sg after 10 ns;

process
begin
    wait for 5 ns;
        reset_sg <= '0';
    wait for 10 ns;
        bloco_sg <= (
        0 => ( 0 => x"0A", 1 => x"09", 2 => x"09" ),
        1 => ( 0 => x"00", 1 => x"06", 2 => x"06" ),
        2 => ( 0 => x"05", 1 => x"09", 2 => x"08" )
    );
wait;
end process;

end behavior;