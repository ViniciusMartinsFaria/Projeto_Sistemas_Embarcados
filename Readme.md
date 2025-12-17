# O Projeto

O projeto é feito em cima do repositório base para sistemas embarcados com FPGA e processador Nios II (SQRTAccel).
Ele implementa um acelerador de hardware para o filtro Sobel, utilizado para detecção de bordas em imagens. O projeto inclui tanto a parte de hardware (VHDL) quanto a parte de software (C) para controlar o acelerador e processar as imagens.

## Estrutura do Projeto

- `Simulações` Contém os arquivos necessários para simular o sistema em cada arquitetura, sendo que as arquiteturas acabam tendo a mesma pinagem em alguns momentos:
  - `sobel_topo e sobel_2_estagios` Contém a mesma pinagem e utilizam o mesmo software.
  - `sobel_paralelo e sobel_paralelo_pipeline` Contém a mesma pinagem e utilizam o mesmo software.
    - `sobel_sw` Contém o software em C utilizado para processar a imagem utilizando apenas o processador Nios II, sem o acelerador de hardware. Esse software é útil para comparar o desempenho do sistema com e sem o acelerador. 

## Como trocar de arquitetura

Para trocar de arquitetura, basta abrir o projeto no Quartus e selecionar o arquivo de topologia desejado na pasta `Simulações`. Cada topologia possui seus arquivos `.qpf, Intro.vhd e MyFirstSOC.qsys` correspondente que pode ser aberto diretamente para carregar o projeto com a arquitetura correta.
Depois de selecionar a topologia desejada, é necessário abrir a ferramente Qsys, gerar os arquivos automáticos pelo menu "Generate" e logo após, recompilar o projeto no Quartus para gerar os arquivos de configuração do FPGA. Após a compilação, o software em C pode ser ajustado se necessário para se comunicar com o acelerador de hardware implementado na topologia escolhida.

É necessário também ajustar os arquivos do projeto sempre que trocar de arquitetura, no menu do Quartus. Todos as arquiteturas utilizam como base os arquivos, na respectiva ordem: `array_bidimensional.vhd`, `Gx.vhd`, `Gy.vhd`, `pitagoras.vhd`.

Para cada arquitetura, muda-se o topo respectivo. Exemplo: `sobel_topo.vhd`, `sobel_2_estagios.vhd`, `sobel_paralelo.vhd`, `sobel_paralelo_pipeline.vhd`.

- `sobel_topo e sobel_2_estagios` Utilizam o arquivo `interface_bloco.vhd`
- `sobel_paralelo e sobel_paralelo_pipeline` Utilizam o arquivo `interface_bloco_paralelo.vhd`

## Arquivo de imagem

A imagem modelo utilizada em todos as arquiteturas é a mesma e está localizada na pasta `Simulações/image_rgb.h`. Ela é uma imagem RGB de 64x64 pixels, onde cada pixel é representado por bytes (R, G, B). O software converte essa imagem para escala de cinza antes de aplicar o filtro Sobel.

A saída do processamento é uma imagem em escala de cinza com filtro sobel aplicado, a matriz resultante é impressa no console em formato hexadecimal para verificação. Para poder visualizar a imagem final, é necessário converter a matriz hexadecimal de volta para uma imagem utilizando uma ferramenta externa.
