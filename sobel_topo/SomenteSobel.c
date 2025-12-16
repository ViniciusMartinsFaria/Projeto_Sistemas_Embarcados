/*
 * SOBAEL FILTER - Main Application
 * Integração Nios II + Acelerador Hardware
 */

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_stdio.h"
#include <unistd.h>

// Inclui a imagem convertida (Vetor C)
#include "imagem_data.h"

// ============================================================================
// CONFIGURAÇÃO DOS ENDEREÇOS (Verifique seu system.h se der erro)
// ============================================================================
// Se o Eclipse reclamar que não existe, verifique no system.h o nome correto
// (Pode ser PIO_0_BASE, PIO_1_BASE, etc, se você não renomeou no Qsys)
#ifndef ENTRADA_1_BASE
    #define ENTRADA_1_BASE      ENTRADA_1_BASE // Substitua se o nome for diferente
    #define ENTRADA_2_BASE      ENTRADA_2_BASE
    #define ENTRADA_3_BASE      ENTRADA_3_BASE
    #define RESULTADO_BASE      RESULTADO_EXPORT_BASE // Ou SQRTX_EXPORT_BASE
    #define GO_BASE             GO_EXPORT_BASE
    #define DADOPRT_BASE        DADOPRT_EXPORT_BASE // Ou DADOPRT_BASE
#endif

// ============================================================================
// VARIÁVEIS GLOBAIS
// ============================================================================
// Buffer para guardar o resultado.
// Declarado fora da main para não estourar a pilha (Stack) da memória.
unsigned char img_out[WIDTH * HEIGHT];

// Macro para facilitar o acesso ao vetor 1D como se fosse 2D
// Retorna o pixel na posição (x,y)
unsigned char get_pixel(int x, int y) {
    // Proteção básica de borda (retorna 0 se sair da imagem)
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return 0;
    return imagem_raw[y * WIDTH + x];
}

// ============================================================================
// FUNÇÃO PRINCIPAL
// ============================================================================
int main()
{
    alt_putstr("\n=============================================\n");
    alt_putstr("      INICIANDO ACELERADOR SOBEL (FPGA)      \n");
    alt_putstr("=============================================\n");

    alt_printf("Imagem: %d x %d pixels\n", WIDTH, HEIGHT);
    alt_putstr("Processando...\n");

    int x, y;

    // Varre a imagem ignorando a borda de 1 pixel (janela 3x3)
    for(y = 1; y < HEIGHT - 1; y++) {
        for(x = 1; x < WIDTH - 1; x++) {

            // ----------------------------------------------------------------
            // 1. EMPACOTAMENTO DOS DADOS (32 bits por linha)
            // ----------------------------------------------------------------
            // Formato esperado pelo interface_bloco.vhd:
            // Bits [23..16] = Pixel Direita (x+1)
            // Bits [15..8]  = Pixel Centro  (x)
            // Bits [7..0]   = Pixel Esquerda(x-1)

            // Linha Superior (y-1)
            unsigned int l_cima = (get_pixel(x+1, y-1) << 16) |
                                  (get_pixel(x,   y-1) << 8)  |
                                   get_pixel(x-1, y-1);

            // Linha do Meio (y)
            unsigned int l_meio = (get_pixel(x+1, y)   << 16) |
                                  (get_pixel(x,   y)   << 8)  |
                                   get_pixel(x-1, y);

            // Linha Inferior (y+1)
            unsigned int l_baixo = (get_pixel(x+1, y+1) << 16) |
                                   (get_pixel(x,   y+1) << 8)  |
                                    get_pixel(x-1, y+1);

            // ----------------------------------------------------------------
            // 2. ENVIAR PARA O HARDWARE
            // ----------------------------------------------------------------
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_1_BASE, l_cima);
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_2_BASE, l_meio);
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_3_BASE, l_baixo);

            // ----------------------------------------------------------------
            // 3. EXECUTAR E LER
            // ----------------------------------------------------------------
            // Pulso de Start (Go = 1)
            IOWR_ALTERA_AVALON_PIO_DATA(GO_BASE, 1);

            // Leitura Imediata (Hardware combinacional é mais rápido que o Nios)
            // Não usamos 'while' para evitar deadlock, confiamos na velocidade do FPGA
            int resultado_raw = IORD_ALTERA_AVALON_PIO_DATA(RESULTADO_BASE);

            // Pulso de Stop (Go = 0)
            IOWR_ALTERA_AVALON_PIO_DATA(GO_BASE, 0);

            // ----------------------------------------------------------------
            // 4. SALVAR RESULTADO
            // ----------------------------------------------------------------
            // Mascara para pegar apenas os 8 bits finais
            img_out[y * WIDTH + x] = (unsigned char)(resultado_raw & 0xFF);
        }
    }

    alt_putstr("Concluido! Gerando saida para copia...\n");
    alt_putstr("\n--- COPIE A PARTIR DA LINHA ABAIXO ---\n");

    // Imprime a matriz formatada para você salvar num .txt
    for(y = 0; y < HEIGHT; y++) {
        for(x = 0; x < WIDTH; x++) {
            // Imprime em Hexadecimal (ex: 1A) com um espaço
            // Se o pixel for da borda (que pulamos), imprime 00
            if (y == 0 || y == HEIGHT-1 || x == 0 || x == WIDTH-1) {
                alt_putstr("00 ");
            } else {
                alt_printf("%x ", img_out[y * WIDTH + x]);
            }
        }
        alt_putstr("\n"); // Nova linha ao fim da linha da imagem
    }

    alt_putstr("--- FIM DOS DADOS ---\n");

    // Loop infinito para manter o console ativo
    while(1);

    return 0;
}
