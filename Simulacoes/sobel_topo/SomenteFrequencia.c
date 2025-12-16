#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_stdio.h"
#include <unistd.h>
#include "imagem_data.h"

// Biblioteca de Performance
#include "altera_avalon_performance_counter.h"

// =================================================================
// 1. DEFINIÇÕES DE NOMES (Corrigido conforme seu pedido)
// =================================================================
// Verifique no system.h se o contador se chama PERFORMANCE_COUNTER_0_BASE
// ou PCM_BASE. Ajuste aqui se necessário.
#ifndef PCM_BASE
    #ifdef PERFORMANCE_COUNTER_0_BASE
        #define PCM_BASE PERFORMANCE_COUNTER_0_BASE
    #else
        #define PCM_BASE 0x0
    #endif
#endif

// Definições de Hardware (Qsys)
#ifndef ENTRADA_1_BASE
    // Ajuste estes nomes conforme seu system.h
    #define ENTRADA_1_BASE      ENTRADA_1_BASE
    #define ENTRADA_2_BASE      ENTRADA_2_BASE
    #define ENTRADA_3_BASE      ENTRADA_3_BASE
    #define RESULTADO_BASE      RESULTADO_BASE
    #define GO_BASE             GO_BASE
#endif

unsigned char img_out[WIDTH * HEIGHT];

unsigned char get_pixel(int x, int y) {
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return 0;
    return imagem_raw[y * WIDTH + x];
}

int main()
{
    alt_putstr("=== SOBEL PERFORMANCE TEST ===\n");

    // Reset e Início
    PERF_RESET(PCM_BASE);
    PERF_START_MEASURING(PCM_BASE);

    int x, y;

    // --- MEDIÇÃO TOTAL (Seção 2) ---
    PERF_BEGIN(PCM_BASE, 2);

    for(y = 1; y < HEIGHT - 1; y++) {
        for(x = 1; x < WIDTH - 1; x++) {

            unsigned int l_cima  = (get_pixel(x+1, y-1) << 16) | (get_pixel(x, y-1) << 8) | get_pixel(x-1, y-1);
            unsigned int l_meio  = (get_pixel(x+1, y)   << 16) | (get_pixel(x, y)   << 8) | get_pixel(x-1, y);
            unsigned int l_baixo = (get_pixel(x+1, y+1) << 16) | (get_pixel(x, y+1) << 8) | get_pixel(x-1, y+1);

            // --- MEDIÇÃO UNITÁRIA (Seção 1: Pixel Central) ---
            if (x == WIDTH/2 && y == HEIGHT/2) {
                PERF_BEGIN(PCM_BASE, 1);
            }

            // Envia
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_1_BASE, l_cima);
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_2_BASE, l_meio);
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_3_BASE, l_baixo);

            // Processa
            IOWR_ALTERA_AVALON_PIO_DATA(GO_BASE, 1);
            int resultado = IORD_ALTERA_AVALON_PIO_DATA(RESULTADO_BASE);
            IOWR_ALTERA_AVALON_PIO_DATA(GO_BASE, 0);

            if (x == WIDTH/2 && y == HEIGHT/2) {
                PERF_END(PCM_BASE, 1);
            }

            img_out[y * WIDTH + x] = (unsigned char)(resultado & 0xFF);
        }
    }

    PERF_END(PCM_BASE, 2);
    PERF_STOP_MEASURING(PCM_BASE);

    alt_putstr("\nRelatorio de Performance:\n");
    perf_print_formatted_report((void*) PCM_BASE, ALT_CPU_FREQ, 2, "Pixel_Unico", "Imagem_Total");

    // CORREÇÃO DO PRINT DA FREQUÊNCIA
    // alt_printf tem dificuldade com inteiros grandes. Vamos imprimir em HEX ou quebrar o número.
    // Ou assumir que se ALT_CPU_FREQ falhar, imprimimos o valor manual apenas para constar.
    alt_putstr("\nFrequencia da CPU (Hex): ");
    alt_printf("%x", (int)ALT_CPU_FREQ); // Imprime em Hexadecimal (ex: 2FAF080 = 50MHz)
    alt_putstr(" Hz\n");

    while(1);
    return 0;
}
