## Documentação do Gerador Imediato e Testbench

Esta documentação descreve o módulo Verilog `imediato` e seu testbench associado, `imediato_tb`.

---

### Módulo: `imediato`

Este módulo Verilog implementa um **gerador de valores imediatos (Immediate Generator)**, comum em arquiteturas RISC-V. Ele extrai e estende o sinal de diferentes campos de uma instrução de 32 bits para produzir o valor imediato correto, dependendo do tipo de instrução (determinado pelo `opcode`).

#### Entradas

* `instrucao` (`input [31:0]`): A **instrução completa** de 32 bits da qual o valor imediato deve ser extraído e estendido.

#### Saídas

* `imediato_out` (`output [31:0]`): O **valor imediato de 32 bits**, estendido por sinal, gerado a partir da instrução.

#### Sinais Internos

* `opcode` (`wire [6:0]`): Extraído dos bits `instrucao[6:0]`. Este campo determina o tipo da instrução e, consequentemente, o formato do imediato.
* `funct3` (`wire [2:0]`): Extraído dos bits `instrucao[14:12]`. Embora declarado, este sinal não é usado na lógica `case` atual para determinar o formato do imediato. Ele é tipicamente usado para decodificação adicional dentro de certos tipos de instrução (como R-Type ou I-Type).
* `temp_imediato` (`reg [31:0]`): Um registrador temporário usado para armazenar o valor imediato gerado dentro do bloco `always` antes de ser atribuído à saída final.

#### Comportamento

O módulo `imediato` é **combinacional**. A lógica é implementada em um bloco `always @(*)` que se atualiza sempre que a entrada `instrucao` muda. Uma estrutura `case` decodifica o `opcode` da instrução para determinar como o valor imediato deve ser extraído e estendido por sinal.

##### Formatos de Imediato (Baseado no `opcode`):

* **`7'b0000011` (LOAD - Tipo I)**:
    ```verilog
    temp_imediato = {{20{instrucao[31]}}, instrucao[31:20]};
    ```
    O imediato é formado pelos bits `instrucao[31:20]`. O bit mais significativo (`instrucao[31]`) é estendido por sinal 20 vezes para preencher os bits superiores do imediato de 32 bits.

* **`7'b0100011` (STORE - Tipo S)**:
    ```verilog
    temp_imediato = {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]};
    ```
    O imediato é montado a partir de duas partes da instrução: `instrucao[31:25]` (bits 11:5 do imediato) e `instrucao[11:7]` (bits 4:0 do imediato). O bit mais significativo (`instrucao[31]`) é estendido por sinal 20 vezes.

* **`7'b1100011` (BRANCH - Tipo B)**:
    ```verilog
    temp_imediato = {{20{instrucao[31]}}, instrucao[31], instrucao[7], instrucao[30:25], instrucao[11:8], 1'b0};
    ```
    O imediato de branch é complexo, sendo montado de várias partes da instrução e sempre terminando com um bit `0` (indicando que os alvos de branch são sempre alinhados a 2 bytes). As partes são:
    * Bit 31: `instrucao[31]` (bit 12 do imediato)
    * Bit 7: `instrucao[7]` (bit 11 do imediato)
    * Bits 30:25: `instrucao[30:25]` (bits 10:5 do imediato)
    * Bits 11:8: `instrucao[11:8]` (bits 4:1 do imediato)
    O bit de sinal (`instrucao[31]`) é estendido por sinal 20 vezes.

* **`7'b0110011` (R-TYPE)**:
    ```verilog
    temp_imediato = 32'h0;
    ```
    Instruções do tipo R (Register-Register) não utilizam valores imediatos, portanto, o `imediato_out` é definido como `32'h0`.

* **`default` (Outros/Inválido)**:
    ```verilog
    temp_imediato = 32'h0;
    ```
    Para qualquer outro `opcode` não explicitamente mapeado, o `imediato_out` é definido como `32'h0`.

#### Resumo Funcional

O módulo `imediato` é um componente essencial na fase de decodificação de um pipeline de processador. Ele garante que o valor imediato correto seja extraído da instrução e estendido por sinal para ser usado por outras unidades (como a ULA ou a unidade de controle de branch), dependendo do tipo de instrução RISC-V.

---

### Testbench: `imediato_tb`

Este módulo Verilog é um testbench funcional para o módulo `imediato`. Ele aplica diferentes valores de instruções (com vários opcodes e campos imediatos) para verificar se o gerador imediato extrai e estende corretamente o valor.

#### Inclusões

* `` `timescale 1ps/1ps``: Define a unidade de tempo de simulação como 1 picosegundo (ps) e a precisão de tempo como 1 ps.
* `` `include "imediato.v"``: Inclui o código-fonte do módulo `imediato`, tornando-o disponível para instanciação no testbench.

#### Sinais

* `instrucao` (`reg [31:0]`): Um registrador que atua como entrada para a instrução completa da Unidade Sob Teste (UUT).
* `imediato_out` (`wire [31:0]`): Um fio (wire) que recebe a saída do valor imediato gerado pela UUT.

#### Instanciação da UUT

```verilog
imediato uut (instrucao, imediato_out);
```

Esta linha instancia o módulo `imediato` dentro do testbench, conectando a entrada (`instrucao`) e a saída (`imediato_out`) do testbench aos portos correspondentes do módulo.

#### Cenário de Teste (`initial` block)

O bloco `initial` define a sequência de eventos de teste que serão aplicados ao módulo `imediato`.

1.  **Configuração de Dump de Ondas:**
    * `$dumpfile("imediato_tb.vcd");`: Especifica o nome do arquivo Value Change Dump (VCD) onde os sinais de simulação serão registrados. Este arquivo pode ser visualizado com ferramentas como GTKWave para análise do comportamento.
    * `$dumpvars(0, imediato_tb);`: Habilita o dump de todos os sinais no escopo do módulo `imediato_tb` para o arquivo VCD.

2.  **Execução das Operações de Teste:**
    O testbench aplica uma série de diferentes instruções para verificar a extração do imediato. É importante notar que o testbench original contém algumas atribuições sequenciais ao `instrucao` dentro do mesmo `#10;` que podem sobrescrever valores antes de serem observados. A estrutura ideal seria uma atribuição seguida de um atraso para cada teste. Vou detalhar o comportamento esperado para cada instrução.

    * **Teste 1: Inicialização e Default (instrucao = 0x0)**
        ```verilog
        instrucao = 32'h0;
        #10;
        // imediato_out deve ser 32'h0 (caso 'default' para opcode 7'b0000000)
        ```

    * **Teste 2: Várias Atribuições (Observação do comportamento)**
        ```verilog
        instrucao = 32'h0001210B; // opcode 7'b0001011 (desconhecido, deve ser default)
        instrucao = 32'h0123000B; // opcode 7'b0001011 (desconhecido, deve ser default)
        instrucao = 32'h01230000 | 7'b0000011; // Isso define o opcode para 7'b0000011 (LOAD)
        #10;
        // Para a última instrução (LOAD), imediato_out deve ser o resultado da extensão de sinal de instrucao[31:20]
        // Exemplo: se instrucao = 32'h01230013 (LOAD), instrucao[31:20] = 0x012, imediato_out = 0x00000012
        ```
        É crucial observar que apenas a **última atribuição** antes do `#10;` terá seu efeito observado na simulação para um módulo combinacional.

    * **Teste 3: Instrução STORE (Tipo S)**
        ```verilog
        // Exemplo de instrução STORE: 0xFEF08023 (imm = -20)
        // Imediato esperado: {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]}
        // Para 0xFEF08023: instrucao[31]=1, instrucao[31:25]=1111100, instrucao[11:7]=00010.
        // Resulta em 0xFFFFFEE0 (-20 decimal).
        instrucao = 32'hFEF08023;
        #10;
        // imediato_out deve ser 32'hFFFFFEEC (-20 decimal)
        ```

    * **Teste 4: Instrução BRANCH (Tipo B)**
        ```verilog
        // Exemplo de instrução BRANCH: 0xFE0000E3 (imm = -32)
        // Imediato esperado: {{20{instrucao[31]}}, instrucao[31], instrucao[7], instrucao[30:25], instrucao[11:8], 1'b0}
        // Para 0xFE0000E3: instrucao[31]=1, instrucao[7]=0, instrucao[30:25]=111110, instrucao[11:8]=0000.
        // Resulta em 0xFFFFFFE0 (-32 decimal)
        instrucao = 32'hFE0000E3;
        #10;
        // imediato_out deve ser 32'hFFFFFE0 (-32 decimal)
        ```

    * **Teste 5: Outra Instrução BRANCH (Tipo B) - Imediato Positivo**
        ```verilog
        // Exemplo: 0x00A000E3 (imm = +10)
        instrucao = 32'h00A000E3;
        #10;
        // imediato_out deve ser 32'h0000000A (+10 decimal)
        ```

    * **Teste 6: Instrução R-TYPE**
        ```verilog
        instrucao = 32'h00310133; // Exemplo de instrução R-TYPE (ADD x2, x2, x3)
        #10;
        // imediato_out deve ser 32'h0 (para R-Type)
        ```

3.  **Finalização:**
    * `$display("Teste Completo");`: Exibe uma mensagem no console da simulação indicando que a sequência de teste foi concluída.

#### Propósito do Testbench

O objetivo principal deste testbench é verificar se o módulo `imediato` decodifica e gera corretamente os valores imediatos para diferentes tipos de instruções RISC-V (I-Type, S-Type, B-Type e R-Type). Ao observar as formas de onda no arquivo VCD, é possível confirmar se o `imediato_out` corresponde ao valor esperado para cada instrução de entrada.
