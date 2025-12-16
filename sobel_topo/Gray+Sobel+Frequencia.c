#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_stdio.h"
#include <unistd.h>
#include "altera_avalon_performance_counter.h"

// Inclui o arquivo gerado pelo Python (64x64)
#include "imagem_rgb.h"

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
// Buffers
unsigned char img_gray_input[WIDTH * HEIGHT]; // Buffer para o Cinza
unsigned char img_out[WIDTH * HEIGHT];        // Buffer final do Sobel

// Função de Conversão (Formula rápida)
unsigned char rgb_to_gray(unsigned char r, unsigned char g, unsigned char b) {
    // (77R + 150G + 29B) >> 8
    unsigned int temp = (77 * r) + (150 * g) + (29 * b);
    return (unsigned char)(temp >> 8);
}

// Função auxiliar para pegar do buffer cinza
unsigned char get_pixel_gray(int x, int y) {
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return 0;
    return img_gray_input[y * WIDTH + x];
}

int main()
{
    alt_putstr("=== SOBEL 64x64: RGB Separado -> Gray -> HW ===\n");

    PERF_RESET(PCM_BASE);
    PERF_START_MEASURING(PCM_BASE);

    int x, y, i;

    // =================================================================
    // 1. CONVERSÃO RGB -> GRAY (SOFTWARE)
    // =================================================================
    PERF_BEGIN(PCM_BASE, 1);

    // O loop agora acessa os 3 vetores separados que o Python criou
    for(i = 0; i < WIDTH * HEIGHT; i++) {
        unsigned char r = R_raw[i];
        unsigned char g = G_raw[i];
        unsigned char b = B_raw[i];

        img_gray_input[i] = rgb_to_gray(r, g, b);
    }

    PERF_END(PCM_BASE, 1);

    // =================================================================
    // 2. FILTRO SOBEL (HARDWARE)
    // =================================================================
    PERF_BEGIN(PCM_BASE, 2);

    for(y = 1; y < HEIGHT - 1; y++) {
        for(x = 1; x < WIDTH - 1; x++) {

            unsigned int l_cima  = (get_pixel_gray(x+1, y-1) << 16) | (get_pixel_gray(x, y-1) << 8) | get_pixel_gray(x-1, y-1);
            unsigned int l_meio  = (get_pixel_gray(x+1, y)   << 16) | (get_pixel_gray(x, y)   << 8) | get_pixel_gray(x-1, y);
            unsigned int l_baixo = (get_pixel_gray(x+1, y+1) << 16) | (get_pixel_gray(x, y+1) << 8) | get_pixel_gray(x-1, y+1);

            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_1_BASE, l_cima);
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_2_BASE, l_meio);
            IOWR_ALTERA_AVALON_PIO_DATA(ENTRADA_3_BASE, l_baixo);

            IOWR_ALTERA_AVALON_PIO_DATA(GO_BASE, 1);
            int resultado = IORD_ALTERA_AVALON_PIO_DATA(RESULTADO_BASE);
            IOWR_ALTERA_AVALON_PIO_DATA(GO_BASE, 0);

            img_out[y * WIDTH + x] = (unsigned char)(resultado & 0xFF);
        }
    }

    PERF_END(PCM_BASE, 2);
    PERF_STOP_MEASURING(PCM_BASE);

    // =================================================================
    // RESULTADOS
    // =================================================================
    alt_putstr("\n--- PERFORMANCE (64x64) ---\n");
    perf_print_formatted_report((void*) PCM_BASE, ALT_CPU_FREQ, 2, "RGB_to_Gray", "Sobel_HW");

    // Imprime a matriz para você copiar
    alt_putstr("\n--- SAIDA SOBEL (HEX) ---\n");
    for(y = 0; y < HEIGHT; y++) {
        for(x = 0; x < WIDTH; x++) {
            if (y==0 || y==HEIGHT-1 || x==0 || x==WIDTH-1) alt_putstr("00 ");
            else alt_printf("%x ", img_out[y * WIDTH + x]);
        }
        alt_putstr("\n");
    }

    while(1);
    return 0;
}
