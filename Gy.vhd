library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_bidimensional.all;

entity G_y is
    port(
        entrada     : in matriz;
        saida       : out std_logic_vector(15 downto 0)
        );
end G_y;

architecture RTL of G_y is

    signal inv_sinal_0      : signed(15 downto 0); 
    signal inv_sinal_1      : signed(15 downto 0); 
    signal inv_sinal_shift  : signed(15 downto 0); 
    signal shift            : signed(15 downto 0); 
    signal sinal_0          : signed(15 downto 0); 
    signal sinal_1          : signed(15 downto 0);

begin

    inv_sinal_0     <=  resize ( - signed(entrada(2,0)), 16 );          --[LINHA,COLUNA]
    inv_sinal_1     <=  resize ( - signed(entrada(2,2)), 16 );          --[LINHA,COLUNA]
    inv_sinal_shift <=  resize ( (- signed(entrada(2,1)) & '0'), 16 );  --[LINHA,COLUNA]
    shift           <=  resize ( (signed(entrada(0,1)) & '0'), 16 );    --[LINHA,COLUNA]     
    sinal_0         <=  resize (signed(entrada(0,0)), 16 );             --[LINHA,COLUNA]
    sinal_1         <=  resize (signed(entrada(0,2)), 16 );            --[LINHA,COLUNA]
    saida           <=  std_logic_vector((inv_sinal_0 + inv_sinal_1 + inv_sinal_shift + shift + sinal_0 + sinal_1));          --Soma de todos os sinais

end RTL;