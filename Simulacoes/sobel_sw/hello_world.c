#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_stdio.h"
#include <unistd.h>
#include "altera_avalon_performance_counter.h"
#include <stdlib.h>

#include "imagem_rgb.h"

#ifndef PCM_BASE
    #ifdef PERFORMANCE_COUNTER_0_BASE
        #define PCM_BASE PERFORMANCE_COUNTER_0_BASE
    #else
        #define PCM_BASE 0x0
    #endif
#endif

#ifndef WIDTH
    #define WIDTH 64
    #define HEIGHT 64
#endif

// Buffers na Memória
unsigned char img_gray[WIDTH * HEIGHT]; // Buffer intermediário (Cinza)
unsigned char img_out[WIDTH * HEIGHT];  // Buffer final (Sobel)

// Converte RGB para Escala de Cinza (Método Rápido)
unsigned char rgb_to_gray(unsigned char r, unsigned char g, unsigned char b) {
    // Fórmula: (77R + 150G + 29B) / 256
    unsigned int temp = (77 * r) + (150 * g) + (29 * b);
    return (unsigned char)(temp >> 8);
}

// Pega pixel com segurança (retorna 0 se for borda/fora)
unsigned char get_pixel(int x, int y) {
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return 0;
    return img_gray[y * WIDTH + x];
}

int main()
{
    alt_putstr("=== PROCESSAMENTO TOTAL EM SOFTWARE (NIOS II) ===\n");

    // Reinicia o contador de performance
    PERF_RESET(PCM_BASE);
    PERF_START_MEASURING(PCM_BASE);

    int i, x, y;

    // CONVERSÃO RGB -> GRAY (SOFTWARE)
    PERF_BEGIN(PCM_BASE, 1);

    for(i = 0; i < WIDTH * HEIGHT; i++) {
        img_gray[i] = rgb_to_gray(R_raw[i], G_raw[i], B_raw[i]);
    }

    PERF_END(PCM_BASE, 1);

    // FILTRO SOBEL (SOFTWARE PURO)
    PERF_BEGIN(PCM_BASE, 2);

    for(y = 1; y < HEIGHT - 1; y++) {
        for(x = 1; x < WIDTH - 1; x++) {

            int p00 = get_pixel(x-1, y-1);
            int p01 = get_pixel(x,   y-1);
            int p02 = get_pixel(x+1, y-1);

            int p10 = get_pixel(x-1, y);
            // int p11 = get_pixel(x, y); // Centro não é usado no cálculo
            int p12 = get_pixel(x+1, y);

            int p20 = get_pixel(x-1, y+1);
            int p21 = get_pixel(x,   y+1);
            int p22 = get_pixel(x+1, y+1);

            int gx = (p02 + 2*p12 + p22) - (p00 + 2*p10 + p20);

            int gy = (p20 + 2*p21 + p22) - (p00 + 2*p01 + p02);

            int magnitude = (int) sqrt((double)(gx*gx + gy*gy));

            // 4. Saturação (Clamp) para 8 bits
            if (magnitude > 255) {
                magnitude = 255;
            }

            img_out[y * WIDTH + x] = (unsigned char)magnitude;
        }
    }

    PERF_END(PCM_BASE, 2);
    PERF_STOP_MEASURING(PCM_BASE);


    alt_putstr("\n--- TEMPOS DE EXECUCAO (Ciclos de Clock) ---\n");
    // Seção 1 = RGB->Gray, Seção 2 = Sobel SW
    perf_print_formatted_report((void*) PCM_BASE, ALT_CPU_FREQ, 2, "RGB_Gray_SW", "Sobel_SW");

    alt_putstr("\n--- DADOS DA IMAGEM PROCESSADA (HEX) ---\n");
    // Imprime a matriz completa para verificação externa
    for(i = 0; i < WIDTH * HEIGHT; i++) {
        alt_printf("%x ", img_out[i]);

        if ((i + 1) % WIDTH == 0) {
            alt_putstr("\n");
        }
    }
    alt_putstr("\n--- FIM DOS DADOS ---\n");

    while(1);

    return 0;
}
