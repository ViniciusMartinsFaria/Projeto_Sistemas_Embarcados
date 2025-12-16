library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Intro is
    port (
        osc_clk     : in std_logic;
        reset_n     : in std_logic;
        led         : out std_logic_vector(3 downto 0);
        button      : in std_logic_vector(3 downto 0)
    );
end entity; 

architecture rtl of Intro is

    signal conn_entrada_1 : std_logic_vector(31 downto 0);
    signal conn_entrada_2 : std_logic_vector(31 downto 0); 
    signal conn_entrada_3 : std_logic_vector(31 downto 0);

    -- Sinais de controle
    signal conn_dadoprt   : std_logic; 
    signal conn_go        : std_logic;           
    signal conn_resetproc : std_logic;

    -- Sinais dos pixeis de saida
    signal fio_pixel : std_logic_vector(7 downto 0);

    -- =======================================================================
    -- COMPONENTE DO QSYS (MyFirstSOC)
    -- =======================================================================
    component MyFirstSOC is
        port (
            clk_clk          : in  std_logic := '0';              
            reset_reset_n    : in  std_logic := '0';
            
            -- PIOs de Saída (Nios -> FPGA)
            entrada_1_export : out std_logic_vector(31 downto 0);
            entrada_2_export : out std_logic_vector(31 downto 0); 
            entrada_3_export : out std_logic_vector(31 downto 0);
        
            -- Sinais de Controle
            dadoprt_export   : in  std_logic := '0';              
            go_export        : out std_logic;                                 
            resetproc_export : out std_logic;
            
            -- PIOs de Leitura (FPGA -> Nios)
            pixel_export   : in std_logic_vector(7 downto 0);
        );
    end component MyFirstSOC;

    -- =======================================================================
    -- COMPONENTE DO ACELERADOR
    -- =======================================================================
    component sobel_paralelo_topo is
        port (
            clock     : in std_logic;
            reset     : in std_logic;
            entrada_1 : in std_logic_vector(31 downto 0);
            entrada_2 : in std_logic_vector(31 downto 0);
            entrada_3 : in std_logic_vector(31 downto 0);
            pixel   : out std_logic_vector(7 downto 0);
        );
    end component;
    
begin

    -- Instância do Sistema Qsys (Processador)
    MySoC: MyFirstSOC port map (
        clk_clk          => osc_clk,
        reset_reset_n    => reset_n,
        
        -- Conectando as 4 linhas que vêm do processador
        entrada_1_export => conn_entrada_1,
        entrada_2_export => conn_entrada_2,
        entrada_3_export => conn_entrada_3, 
        
        dadoprt_export   => conn_dadoprt,  
        go_export        => conn_go,    
        resetproc_export => conn_resetproc, 
        
        pixel_export   => fio_pixel,
    );


    -- Instância do Acelerador Sobel
    inst_Sobel: sobel_paralelo_topo
        port map (
            clock     => osc_clk,
            reset     => conn_resetproc,
            entrada_1 => conn_entrada_1,   
            entrada_2 => conn_entrada_2,    
            entrada_3 => conn_entrada_3,
            
            -- Saídas
            pixel   => fio_pixel,
        );

    -- Handshake simples:
    conn_dadoprt <= conn_go;

end rtl;