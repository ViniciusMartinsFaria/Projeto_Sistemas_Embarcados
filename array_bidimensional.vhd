--Pacote feito para possibilitar o uso de matrizes em vhd

library ieee;
use ieee.std_logic_1164.all;

package array_bidimensional is
    type matriz is array (0 to 2, 0 to 2) of std_logic_vector(7 downto 0);
end package array_bidimensional;