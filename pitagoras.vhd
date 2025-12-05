library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity pitagoras is
    port(
        Gx          : in  std_logic_vector(15 downto 0);
        Gy          : in  std_logic_vector(15 downto 0);
        saida       : out std_logic_vector(15 downto 0)
        );
end pitagoras;

architecture RTL of pitagoras is


begin

    -- Soma aproximada de magnitude(Vinícius)
    saida <= std_logic_vector(abs(signed(Gx)) + abs(signed(Gy)));

end RTL;