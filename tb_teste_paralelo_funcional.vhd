library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;             
use ieee.std_logic_textio.all;  
use work.array_bidimensional.all; -- Certifique-se que este package define 'matriz' se ainda for usado internamente, embora o topo use std_logic_vector

entity tb_sobel is
end tb_sobel;

architecture sim of tb_sobel is
    
    -- Definição da imagem completa na memória do TB (64x64)
    type t_memoria_img is array (0 to 63, 0 to 63) of std_logic_vector(7 downto 0);
    signal img_rom : t_memoria_img;
    
    -- Matriz para armazenar o resultado (inteiros para facilitar a escrita)
    type t_memoria_res is array (0 to 63, 0 to 63) of integer range 0 to 255;
    shared variable matriz_saida : t_memoria_res := (others => (others => 0));

    signal clock_sg    : std_logic := '0';
    signal reset_sg    : std_logic := '1';

    -- SINAIS PARA O NOVO DESIGN PARALELO
    -- O design pede 4 entradas de 32 bits (cada uma contendo 3 pixels verticais + padding)
    signal s_entrada_1 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_entrada_2 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_entrada_3 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_entrada_4 : std_logic_vector(31 downto 0) := (others => '0');
    
    -- O design devolve 2 pixels por vez
    signal s_pixel_0   : std_logic_vector(7 downto 0);
    signal s_pixel_1   : std_logic_vector(7 downto 0);

    -- COMPONENTE ATUALIZADO
    component sobel_paralelo_topo is
    port (
        clock       : in std_logic;
        reset       : in std_logic;
        entrada_1   : in std_logic_vector(31 downto 0);
        entrada_2   : in std_logic_vector(31 downto 0);
        entrada_3   : in std_logic_vector(31 downto 0);
        entrada_4   : in std_logic_vector(31 downto 0);
        pixel_0     : out std_logic_vector(7 downto 0);
        pixel_1     : out std_logic_vector(7 downto 0)
    );
    end component;

begin

    -- INSTÂNCIA DO DUT (Design Under Test)
    inst_Sobel_Paralelo: sobel_paralelo_topo
    port map (
        clock     => clock_sg,
        reset     => reset_sg,
        entrada_1 => s_entrada_1,
        entrada_2 => s_entrada_2,
        entrada_3 => s_entrada_3,
        entrada_4 => s_entrada_4,
        pixel_0   => s_pixel_0,
        pixel_1   => s_pixel_1
    );

    -- GERAÇÃO DE CLOCK (10ns high, 10ns low = 20ns período)
    clock_sg <= not clock_sg after 10 ns;

    -- PROCESSO PRINCIPAL
    process
        -- Ajuste os caminhos dos arquivos conforme necessário para o seu computador
        file arquivo_entrada : text open read_mode is "C:\Users\Asus\Desktop\Kernels\imagem_matriz_hex.txt";
        file arquivo_saida   : text open write_mode is "C:\Users\Asus\Desktop\Kernels\resultado_sobel.txt";
        
        variable linha_texto : line;
        variable temp_byte   : std_logic_vector(7 downto 0);
        
        variable v_p0_int : integer;
        variable v_p1_int : integer;
        
    begin
        -- 1. CARREGAR A IMAGEM DE ENTRADA NA MEMÓRIA ROM
        report "Carregando imagem de entrada...";
        for y in 0 to 63 loop
            if not endfile(arquivo_entrada) then
                readline(arquivo_entrada, linha_texto);
                for x in 0 to 63 loop
                    hread(linha_texto, temp_byte);
                    img_rom(y, x) <= temp_byte;
                end loop;
            end if;
        end loop;

        -- Reset do sistema
        wait for 20 ns;
        reset_sg <= '0';
        wait for 20 ns;

        -- 2. PROCESSAMENTO (Hardware Sobel Paralelo)
        report "Iniciando processamento Sobel Paralelo...";
        
        -- Loop Y: Percorre as linhas (necessário 3 linhas para formar janela 3x3)
        -- Vai de 0 a 61 (acessa y, y+1, y+2)
        for y in 0 to 61 loop
            
            -- Loop X: Percorre as colunas.
            -- IMPORTANTE: Avança de 2 em 2 (step 2) porque calculamos 2 pixels por ciclo.
            -- Vai de 0 a 60 (acessa x, x+1, x+2, x+3)
            -- Ex: x=0 usa colunas 0,1,2,3 e gera pixels das posições 1 e 2.
            for x in 0 to 30 loop -- Loop lógico (0 a 30), multiplicaremos por 2 no índice
                
                -- Construção dos vetores de entrada (Colunas verticais de 3 pixels)
                -- Estrutura assumida: x"00" & pixel(y+2) & pixel(y+1) & pixel(y)
                -- O bit mais significativo é 0 (padding), pois 3 pixels * 8 bits = 24 bits.
                
                s_entrada_1 <= x"00" & img_rom(y+2, x*2)   & img_rom(y+1, x*2)   & img_rom(y, x*2);
                s_entrada_2 <= x"00" & img_rom(y+2, x*2+1) & img_rom(y+1, x*2+1) & img_rom(y, x*2+1);
                s_entrada_3 <= x"00" & img_rom(y+2, x*2+2) & img_rom(y+1, x*2+2) & img_rom(y, x*2+2);
                s_entrada_4 <= x"00" & img_rom(y+2, x*2+3) & img_rom(y+1, x*2+3) & img_rom(y, x*2+3);
                
                -- Aguarda o clock para o hardware processar
                wait until rising_edge(clock_sg);
                -- Aguarda propagação
                wait for 1 ns; 

                -- 3. CAPTURA DO RESULTADO
                v_p0_int := to_integer(unsigned(s_pixel_0));
                v_p1_int := to_integer(unsigned(s_pixel_1));

                -- Salva na matriz de saída
                -- Pixel 0 corresponde ao centro da janela formada por Col 1,2,3 -> Posição (y+1, x*2+1)
                matriz_saida(y+1, x*2+1) := v_p0_int;
                
                -- Pixel 1 corresponde ao centro da janela formada por Col 2,3,4 -> Posição (y+1, x*2+2)
                matriz_saida(y+1, x*2+2) := v_p1_int;
                
            end loop;
        end loop;

        -- 4. ESCRITA DO ARQUIVO FINAL
        report "Escrevendo arquivo de saída: resultado_sobel.txt";
        for y in 0 to 63 loop
            -- Limpa a linha antes de escrever
            write(linha_texto, string'("")); 
            
            for x in 0 to 63 loop
                -- Escreve o valor em Hexadecimal
                hwrite(linha_texto, std_logic_vector(to_unsigned(matriz_saida(y,x), 8)));
                
                -- Adiciona espaço entre números
                if x < 63 then
                    write(linha_texto, string'(" "));
                end if;
            end loop;
            writeline(arquivo_saida, linha_texto);
        end loop;

        report "Simulação Concluída!";
        wait;
    end process;

end sim;