library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;            
use ieee.std_logic_textio.all; 
use work.array_bidimensional.all;

entity tb_sobel is
end tb_sobel;

architecture sim of tb_sobel is
    
    type t_memoria_img is array (0 to 63, 0 to 63) of std_logic_vector(7 downto 0);
    signal img_rom : t_memoria_img;
    type t_memoria_res is array (0 to 63, 0 to 63) of integer range 0 to 255;
    shared variable matriz_saida : t_memoria_res := (others => (others => 0));

    signal  clock_sg    : std_logic := '0';
    signal  reset_sg    : std_logic := '1';
    signal  bloco_sg    : matriz;
    signal  pixel_sg    : std_logic_vector(7 downto 0);

    component sobel_topo is
    port (
        clock               : in std_logic;
        reset               : in std_logic;
        bloco               : in matriz;
        pixel               : out std_logic_vector(7 downto 0));
    end component;

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
        file arquivo_entrada : text open read_mode is "C:\Users\Asus\Desktop\Kernels\imagem_matriz_hex.txt"; -- arquivo de entrada
        file arquivo_saida   : text open write_mode is "C:\Users\Asus\Desktop\Kernels\resultado_sobel.txt";   -- arquivo a ser criado
        
        variable linha_texto : line;
        variable temp_byte   : std_logic_vector(7 downto 0);
        variable v_pixel_int : integer;
        variable v_pixel_sat : integer; 
    begin
        report "Carregando imagem de entrada...";
        for y in 0 to 63 loop
            readline(arquivo_entrada, linha_texto);
            for x in 0 to 63 loop
                hread(linha_texto, temp_byte);
                img_rom(y, x) <= temp_byte;
            end loop;
        end loop;

        wait for 20 ns;
        reset_sg <= '0';
        wait for 20 ns;

        report "Iniciando processamento Sobel...";
        
        for y in 0 to 61 loop
            for x in 0 to 61 loop
                
                bloco_sg(0,0) <= img_rom(y,   x);
                bloco_sg(0,1) <= img_rom(y,   x+1);
                bloco_sg(0,2) <= img_rom(y,   x+2);
                
                bloco_sg(1,0) <= img_rom(y+1, x);
                bloco_sg(1,1) <= img_rom(y+1, x+1);
                bloco_sg(1,2) <= img_rom(y+1, x+2);
                
                bloco_sg(2,0) <= img_rom(y+2, x);
                bloco_sg(2,1) <= img_rom(y+2, x+1);
                bloco_sg(2,2) <= img_rom(y+2, x+2);

                wait until rising_edge(clock_sg);
                
                wait for 1 ns; 
                v_pixel_int := to_integer(unsigned(pixel_sg));

                matriz_saida(y+1, x+1) := v_pixel_int;
                
            end loop;
        end loop;

        report "Escrevendo arquivo de saída: resultado_sobel.txt";
        
        for y in 0 to 63 loop
            for x in 0 to 63 loop
                hwrite(linha_texto, std_logic_vector(to_unsigned(matriz_saida(y,x), 8)));
                
                if x < 63 then
                    write(linha_texto, string'(" "));
                end if;
            end loop;
            writeline(arquivo_saida, linha_texto);
        end loop;

        report "Simulação e Geração de Arquivo Concluídas com Sucesso!";
        wait;
    end process;

end sim;