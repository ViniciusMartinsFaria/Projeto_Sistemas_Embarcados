#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_stdio.h"
#include "sys/alt_cache.h"
#include <unistd.h>
#include "altera_avalon_performance_counter.h"

#include "imagem_rgb.h"

#define PIO_RESET_BASE  RESETPROC_BASE
#define PIO_GO_BASE     GO_BASE
#define PIO_DONE_BASE   DADOPRT_BASE
#define PIO_IN1_BASE    ENTRADA_1_BASE
#define PIO_IN2_BASE    ENTRADA_2_BASE
#define PIO_IN3_BASE    ENTRADA_3_BASE
#define PIO_IN4_BASE    ENTRADA_4_BASE
#define PIO_OUT0_BASE   PIXEL_0_BASE
#define PIO_OUT1_BASE   PIXEL_1_BASE

#ifndef PCM_BASE
    #ifdef PERFORMANCE_COUNTER_0_BASE
        #define PCM_BASE PERFORMANCE_COUNTER_0_BASE
    #else
        #define PCM_BASE 0x0
    #endif
#endif

// Buffers
unsigned char img_gray[WIDTH * HEIGHT];
unsigned char img_sobel[WIDTH * HEIGHT];

// Função RGB -> Gray
unsigned char to_gray(unsigned char r, unsigned char g, unsigned char b) {
    return (unsigned char)((77 * r + 150 * g + 29 * b) >> 8);
}

unsigned char get_px(int x, int y) {
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return 0;
    return img_gray[y * WIDTH + x];
}

int main()
{
    alt_putstr("=== SOBEL PARALELO (2 PIXELS/CLOCK) ===\n");

    // Resetar Hardware (Pulso no ResetProc)
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_RESET_BASE, 1);
    usleep(10);
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_RESET_BASE, 0);

    // Inicializar Contador
    PERF_RESET(PCM_BASE);
    PERF_START_MEASURING(PCM_BASE);

    // SEÇÃO 1: Software (RGB -> Gray)
    PERF_BEGIN(PCM_BASE, 1);

    int i, x, y;
    for(i = 0; i < WIDTH * HEIGHT; i++) {
        img_gray[i] = to_gray(R_raw[i], G_raw[i], B_raw[i]);
    }

    PERF_END(PCM_BASE, 1);

    // SEÇÃO 2: Hardware
    PERF_BEGIN(PCM_BASE, 2);

    // Loop pulando de 2 em 2 pixels, pois calculamos 2 por vez
    // Começamos em 1 e vamos até WIDTH-3 para ter vizinhos válidos

    // Loop principal: O x deve ser o centro do primeiro Sobel (Sobel 0)
        for(y = 1; y < HEIGHT - 1; y++) {
            // x começa em 1, e pula de 2 em 2
            // O último pixel lido no pacote é x+2 (se for WIDTH-1, é o limite)
            for(x = 1; x < WIDTH - 2; x += 2) {

                // 1. Preparar os dados (Janela 3x3 + 1 extra por linha)
                // Lemos 4 pixels (x-1, x, x+1, x+2) por linha (total 12)

                // Linha Cima (y-1)
                unsigned int pixels_cima =
                    (get_px(x-1, y-1) << 24) |
                    (get_px(x,   y-1) << 16) |
                    (get_px(x+1, y-1) << 8)  |
                    get_px(x+2, y-1); // P0 a P3

                // Linha Meio (y)
                unsigned int pixels_meio =
                    (get_px(x-1, y)   << 24) |
                    (get_px(x,   y)   << 16) |
                    (get_px(x+1, y)   << 8)  |
                    get_px(x+2, y); // P4 a P7

                // Linha Baixo (y+1)
                unsigned int pixels_baixo =
                    (get_px(x-1, y+1) << 24) |
                    (get_px(x,   y+1) << 16) |
                    (get_px(x+1, y+1) << 8)  |
                    get_px(x+2, y+1); // P8 a P11

                // PIO ENTRADA 4: Necessário para fornecer P12, P13, P14
                // P12, P13, P14 são lidos de Pin_4 (31:24), (23:16), (15:8)
                // Eles não têm relação com a janela 3x3 atual, então preenchemos com ZEROs.
                // Se o VHDL estiver configurado para um Sobel 4x4, isso precisaria de 4 linhas.

                // Usamos 0 para evitar que lixo de memória cause o ruído claro
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_IN4_BASE, 0);

                // Escrever nos PIOs
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_IN1_BASE, pixels_cima);
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_IN2_BASE, pixels_meio);
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_IN3_BASE, pixels_baixo);
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_IN4_BASE, 0); // PIO 4 com zeros.

                // Dar Pulso de Start
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_GO_BASE, 1);
                while(IORD_ALTERA_AVALON_PIO_DATA(PIO_DONE_BASE) == 0);

                // Ler Resultado
                unsigned char res0 = IORD_ALTERA_AVALON_PIO_DATA(PIO_OUT0_BASE);
                unsigned char res1 = IORD_ALTERA_AVALON_PIO_DATA(PIO_OUT1_BASE);
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_GO_BASE, 0);

                // Salvar no buffer de saída:
                // Sobel 0 usa (x-1, x, x+1) -> centrado em x
                img_sobel[y * WIDTH + x] = res0;

                // Sobel 1 usa (x, x+1, x+2) -> centrado em x+1
                img_sobel[y * WIDTH + (x+1)] = res1;
            }
        }

    PERF_END(PCM_BASE, 2);
    PERF_STOP_MEASURING(PCM_BASE);

    // Relatório 
    alt_putstr("\n--- PERFORMANCE ---\n");
    perf_print_formatted_report((void*) PCM_BASE, ALT_CPU_FREQ, 2, "RGB_SW", "SOBEL_HW_2X");

    // Imprimir
    alt_putstr("\n--- SAIDA SOBEL (HEX) ---\n");
    for(y = 0; y < HEIGHT; y++) {
        for(x = 0; x < WIDTH; x++) {
            if (y==0 || y==HEIGHT-1 || x==0 || x==WIDTH-1) alt_putstr("00 ");
            else alt_printf("%x ", img_sobel[y * WIDTH + x]);
        }
        alt_putstr("\n");
    }

    while(1);
    return 0;
}
