# Projeto Final: Processador RISC-V de Ciclo Único em Verilog

Este repositório contém a implementação de um processador RISC-V de ciclo único em Verilog, desenvolvido como projeto final para a disciplina de Arquitetura de Computadores. O projeto visa simular o comportamento de um processador RISC-V real, capaz de executar um conjunto básico de instruções.

## Estrutura do Projeto

O projeto é dividido em módulos Verilog, cada um responsável por uma parte funcional do processador.

### 1. Módulo Datapath (`datapath.v`)

O módulo `datapath` é o componente central do processador de ciclo único RISC-V. [cite_start]Ele orquestra o fluxo de dados entre os diferentes blocos funcionais do processador, como a Unidade Lógica Aritmética (ULA), registradores, memórias e multiplexadores, conforme ilustrado no diagrama de blocos do processador de ciclo único RISC-V.

**Entradas:**

* `clk`: Sinal de clock que sincroniza as operações sequenciais do processador.
* `reset`: Sinal de reset assíncrono que inicializa o estado do processador (e.g., PC para 0).

**Componentes Internos (Módulos Instanciados):**

1.  **Program Counter (PC):** Um registrador interno (`pc_current`) que armazena o endereço da instrução atual. Ele é atualizado no flanco de subida do clock.
    * `pc_plus_4`: Calcula o endereço da próxima instrução sequencial (`PC + 4`).
2.  **Memória de Instrução (`memoria_instrucao`):** Responsável por buscar as instruções da memória. Recebe o endereço do PC e retorna a instrução de 32 bits.
3.  **Unidade de Controle (`unidade_controle`):** A "mente" do processador. [cite_start]Recebe o `opcode` e `funct3` da instrução e gera todos os sinais de controle necessários para os outros blocos do `datapath`.
    * Sinais de saída incluem `alu_op` (4 bits), `mem_read`, `mem_write`, `reg_write`, `mem_to_reg`, `alu_src`, e `branch`.
4.  **Banco de Registradores (`registradores`):** Armazena 32 endereços de memória contendo 32 bits[cite: 14]. [cite_start]Possui entradas para os endereços `rs1` (5 bits) [cite: 15][cite_start], `rs2` (5 bits)  [cite_start]para leitura (`read_data1`, `read_data2`)  [cite_start]e o endereço `rd` (5 bits) com o dado a ser escrito (`wr_data`) quando `wr` (write enable) está ativo.
5.  **Gerador de Imediato (`imediato`):** De acordo com a instrução, realiza o ajuste para gerar o valor do imediato, com até 12 bits.
6.  **Unidade Lógica Aritmética (ULA - `ula`):** Realiza as operações de acordo com os sinais de controle. [cite_start]Recebe 2 operandos de 32 bits como entrada e produz um resultado de 32 bits. [cite_start]Produz também uma flag de controle de 1 bit que deve ser ativada quando a operação do branch for verdadeira.
7.  **Memória de Dados (`memoria_dados`):** Serão 1024 endereços de memória com 32 bits. [cite_start]Recebe `rs` (32 bits de endereço), `wd` (32 bits para dado a ser armazenado), `rd` (32 bits para acessar um dado), e `wr` (sinal de controle para habilitar a escrita na memória de dados).
8.  **Multiplexadores (`multiplexadores`):** A partir do sinal de seleção de 1 bit, seleciona qual das duas entradas será transmitida para a saída.
    * `alu_src_mux`: Seleciona o segundo operando da ULA (do registrador `read_data2` ou do imediato).
    * `mem_to_reg_mux`: Seleciona o dado a ser escrito de volta nos registradores (o resultado da ULA ou o dado lido da memória).
    * `pc_mux`: Seleciona o próximo valor do PC (PC+4 para a próxima instrução sequencial ou o endereço de branch para saltos).

**Fluxo de Dados (Operação Principal):**

1.  **Busca de Instrução:** O `pc_current` aponta para uma instrução na `memoria_instrucao`.
2.  **Decodificação/Geração de Controle:** A instrução é enviada para a `unidade_controle`, que gera os sinais de controle apropriados. O `opcode` e `funct3` são cruciais para essa geração.
3.  **Leitura de Registradores:** Os campos `rs1` e `rs2` da instrução são usados para ler dados do `banco_registradores`.
4.  **Cálculo do Endereço/Operação ULA:**
    * Para instruções de load/store, a ULA calcula o endereço de memória base + offset (imediato).
    * Para instruções aritméticas, a ULA executa a operação nos operandos lidos dos registradores.
    * Para `beq`, a ULA subtrai os dois operandos para verificar a igualdade, e o sinal `alu_zero` é usado para decidir o branch.
5.  **Acesso à Memória de Dados:** Se for uma instrução de load ou store, a `memoria_dados` é acessada para leitura ou escrita.
6.  **Escrita de Volta em Registradores:** O resultado final (da ULA ou da memória de dados) é escrito de volta no `banco_registradores`, se `reg_write` estiver ativo.
7.  **Próximo PC:** O `pc_current` é atualizado para o `pc_plus_4` ou para o `branch_target` (se a condição de branch for verdadeira e o sinal `branch` estiver ativo).

### 2. Módulo Testbench (`testbench_datapath.v`)

O módulo `testbench_datapath` é responsável por testar e verificar o funcionamento do módulo `datapath`. [cite_start]Ele não faz parte do hardware do processador, mas sim um ambiente de simulação para validar o design. 

**Propósito:**

* Fornecer os sinais de entrada necessários (`clk` e `reset`) para o `datapath`.
* Instanciar o `datapath` e conectá-lo aos sinais de teste.
* Controlar a sequência de simulação (reset, tempo de execução).
* Gerar um arquivo de `Value Change Dump` (VCD) para visualização das formas de onda no GTKWave.

**Componentes Chave:**

1.  **Geração de Clock:** Um bloco `initial` usa um laço `forever` e um atraso (`#5`) para gerar um sinal de clock contínuo com um período de 10ns (100MHz).
2.  **Geração de Reset e Sequência de Teste:**
    * Um segundo bloco `initial` ativa o sinal de `reset` no início da simulação e o desativa após um curto período, permitindo que o processador comece a executar a partir de um estado conhecido.
    * Após o reset, um atraso (`#50;`) é introduzido para permitir que algumas instruções sejam executadas. [cite_start]Ele previamente carrega os valores dos registradores e da memória para executar as operações.
3.  **Instanciação do DUT (Device Under Test):** O módulo `datapath` é instanciado como `dut` (Device Under Test) e suas portas são conectadas aos sinais `clk` e `reset` definidos no testbench.
4.  **Geração de Arquivo VCD:** As diretivas `$dumpfile` e `$dumpvars` são usadas para gravar os valores de todos os sinais dentro do `dut` em um arquivo chamado `datapath_waves.vcd`. Este arquivo é essencial para a depuração e visualização do comportamento do circuito com ferramentas como o GTKWave.
5.  **Finalização da Simulação:** A diretiva `$finish` encerra a simulação após o tempo de teste definido.

## Como Compilar e Simular

Para compilar e simular o projeto, você pode usar o Icarus Verilog para compilação e o GTKWave para visualização das formas de onda.

1.  Clone o projeto
    ```bash
    git clone https://github.com/leosalgado/riscv-cpu.git
    cd riscv-cpu/
    ```

2.  Compile o projeto com **make**
    ```bash
    make all
    ```
3.  **Execute a simulação:**
    ```bash
    gtkwave waveforms/datapath_tb.vcd
    ```
    ou
    ```bash
    vvp build/datapath_tb.vv
    ```
Este procedimento permitirá que você observe o comportamento do processador e verifique a execução das instruções definidas na `memoria_instrucao`.
