library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity pitagoras is
    port(
        Gx          : in  std_logic_vector(15 downto 0);
        Gy          : in  std_logic_vector(15 downto 0);
        saida       : out std_logic_vector(7 downto 0)
        );
end pitagoras;

architecture RTL of pitagoras is

    signal clamping :std_logic_vector(15 downto 0);

begin

    -- Soma aproximada de magnitude(Vinícius)
    clamping    <= std_logic_vector(abs(signed(Gx)) + abs(signed(Gy)));
    saida       <= 	"11111111" when clamping(15 downto 8) /= "00000000" else
				    clamping(7 downto 0);

end RTL;
