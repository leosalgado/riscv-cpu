### Documentação Unidade de Controle

Esta documentação descreve o módulo Verilog unidade_controle e seu testbench associado, unidade_controle_tb.

**Módulo: unidade_controle**

Este módulo Verilog implementa a lógica de controle para um processador simples, gerando sinais de controle com base em um código de operação (opcode) de 7 bits.

**Entradas**
- opcode (input [6:0]): O código de operação da instrução atual. Este valor de 7 bits determina quais sinais de controle serão ativados.

**Saídas**

As saídas são registradores (reg) que armazenam os sinais de controle gerados. Eles são definidos como reg para que possam reter seus valores dentro do bloco always.

- alu_op (output reg [1:0]): Sinal de 2 bits que controla a operação da Unidade Lógica e Aritmética (ULA).
    - 2'b00: Operação de carga/armazenamento (Load/Store).
    - 2'b01: Operação de Branch.
    - 2'b10: Operação de tipo R (Register-Register).
- mem_read (output reg): Sinal de controle para leitura de memória.
    - 1'b1: Habilita a leitura da memória.
    - 1'b0: Desabilita a leitura da memória.
- mem_write (output reg): Sinal de controle para escrita na memória.
    - 1'b1: Habilita a escrita na memória.
    - 1'b0: Desabilita a escrita na memória.
- reg_write (output reg): Sinal de controle para escrita no banco de registradores.
    - 1'b1: Habilita a escrita em um registrador.
    - 1'b0: Desabilita a escrita em um registrador.
- mem_to_reg (output reg): Sinal de controle para multiplexador que seleciona a fonte de dados para escrita no registrador.
    - 1'b1: O dado lido da memória é escrito no registrador.
    - 1'b0: O resultado da ULA é escrito no registrador.
- alu_src (output reg): Sinal de controle para multiplexador que seleciona o segundo operando da ULA.
    - 1'b1: O segundo operando da ULA é um valor imediato (extensão de sinal).
    - 1'b0: O segundo operando da ULA é o valor de um registrador.
- branch (output reg): Sinal de controle para operação de desvio (branch).
    - 1'b1: Indica uma instrução de desvio.
    - 1'b0: Não é uma instrução de desvio.

**Comportamento**

O módulo unidade_controle utiliza um bloco always @(*) sensível a todas as entradas para gerar os sinais de controle. Isso significa que as saídas são atualizadas sempre que opcode muda.

Dentro do bloco always, as saídas são inicialmente definidas para valores padrão (muitas vezes '0' ou 'xx' para alu_op). Em seguida, uma estrutura case é usada para decodificar o opcode e atribuir os valores apropriados aos sinais de controle para diferentes tipos de instrução.

**Mapeamento de Opcodes e Sinais de Controle:**

| Opcode      | Tipo de Instrução/Finalidade | `alu_op` | `mem_read` | `mem_write` | `reg_write` | `mem_to_reg` | `alu_src` | `branch` |
| :---------- | :--------------------------- | :------- | :--------- | :---------- | :---------- | :----------- | :-------- | :------- |
| `7'b0000011` | **LOAD (Tipo I - Load)** | `2'b00`  | `1'b1`     | `1'b0`      | `1'b1`      | `1'b1`       | `1'b1`    | `1'b0`   |
| `7'b0100011` | **STORE (Tipo S)** | `2'b00`  | `1'b0`     | `1'b1`      | `1'b0`      | `1'b0`       | `1'b1`    | `1'b0`   |
| `7'b1100011` | **BRANCH (Tipo B)** | `2'b01`  | `1'b0`     | `1'b0`      | `1'b0`      | `1'b0`       | `1'b0`    | `1'b1`   |
| `7'b0110011` | **R-TYPE (Tipo R)** | `2'b10`  | `1'b0`     | `1'b0`      | `1'b1`      | `1'b0`       | `1'b0`    | `1'b0`   |
| `default`   | **Outros/Inválido** | `2'b00`  | `1'b0`     | `1'b0`      | `1'b0`      | `1'b0`       | `1'b0`    | `1'b0`   |

### **Testbench: unidade_controle_tb**

Este módulo Verilog é um testbench funcional para o módulo unidade_controle. Ele simula diferentes valores de opcode e verifica se os sinais de controle de saída são gerados corretamente.

**Inclusões**
- `timescale 1ps/1ps: Define a unidade de tempo de simulação como 1 picosegundo (ps) e a precisão de tempo como 1 ps.
- `include "unidade_controle.v": Inclui o código-fonte do módulo unidade_controle, tornando-o disponível para instanciação no testbench.

**Sinais**
- opcode (reg [6:0]): Um registrador que atua como entrada para a Unidade Sob Teste (UUT). O testbench atribui valores a este registrador.
- alu_op (wire [1:0]): Um fio (wire) que recebe a saída alu_op da UUT.
- mem_read (wire): Um fio que recebe a saída mem_read da UUT.
- mem_write (wire): Um fio que recebe a saída mem_write da UUT.
- reg_write (wire): Um fio que recebe a saída reg_write da UUT.
- mem_to_reg (wire): Um fio que recebe a saída mem_to_reg da UUT.
- alu_src (wire): Um fio que recebe a saída alu_src da UUT.
- branch (wire): Um fio que recebe a saída branch da UUT.

**Instanciação da UUT**

unidade_controle uut (opcode, alu_op, mem_read, mem_write, reg_write, mem_to_reg, alu_src, branch);

Esta linha instancia o módulo unidade_controle dentro do testbench, conectando as entradas e saídas do testbench aos portos correspondentes do módulo.

**Cenário de Teste (initial block)**

O bloco initial define a sequência de eventos de teste que serão aplicados à unidade_controle.

1. **Configuração de Dump de Ondas:**

    - $dumpfile("unidade_controle_tb.vcd");: Especifica o nome do arquivo Value Change Dump (VCD) onde os sinais de simulação serão registrados. Este arquivo pode ser visualizado com ferramentas como GTKWave para análise do comportamento.
    - $dumpvars(0, unidade_controle_tb);: Habilita o dump de todos os sinais no escopo do módulo unidade_controle_tb para o arquivo VCD.

2. **Sequência de Teste:**
O testbench aplica uma série de opcodes ao módulo e aguarda por 10 unidades de tempo (#10) após cada alteração para permitir que a lógica da unidade de controle se estabilize e as saídas sejam propagadas.

    - opcode = 7'b0000000; #10;: Testa um opcode inicial (provavelmente o caso default).
    - opcode = 7'b0000011; #10;: Testa o opcode para uma instrução LOAD.
    - opcode = 7'b0100011; #10;: Testa o opcode para uma instrução STORE.
    - opcode = 7'b1100011; #10;: Testa o opcode para uma instrução BRANCH.
    - opcode = 7'b0110011; #10;: Testa o opcode para uma instrução R-TYPE.
    - opcode = 7'b1111111; #10;: Testa outro opcode inválido (caso default).

3. **Finalização:**

    - $display("Teste Completo");: Exibe uma mensagem no console da simulação indicando que a sequência de teste foi concluída.

**Propósito do Testbench**

O objetivo principal deste testbench é verificar se o módulo unidade_controle produz os sinais de controle corretos para cada opcode de entrada, conforme especificado na tabela de mapeamento de instruções. Ao observar as formas de onda no arquivo VCD, é possível confirmar a funcionalidade esperada da unidade de controle.