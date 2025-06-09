## Documentação do Módulo Multiplexador e Testbench

Esta documentação descreve o módulo Verilog `multiplexadores` e seu testbench associado, `multiplexadores_tb`.

---

### Módulo: `multiplexadores`

Este módulo Verilog implementa um **multiplexador de 2 para 1** para dados de 32 bits. Ele seleciona uma das duas entradas de dados (`in0` ou `in1`) com base no valor de um sinal de seleção (`sel`) e a direciona para a saída.

#### Entradas

* `in0` (`input [31:0]`): A **primeira entrada de dados** (selecionada quando `sel` é `0`). É um valor de 32 bits.
* `in1` (`input [31:0]`): A **segunda entrada de dados** (selecionada quando `sel` é `1`). É um valor de 32 bits.
* `sel` (`input`): O **sinal de seleção**. Este bit controla qual das entradas é direcionada para a saída.
    * `0`: Seleciona `in0`.
    * `1`: Seleciona `in1`.

#### Saídas

* `out` (`output [31:0]`): O **dado de saída** selecionado. É um valor de 32 bits.

#### Comportamento

O módulo `multiplexadores` é totalmente **combinacional**, o que significa que a saída `out` é atualizada **imediatamente** sempre que qualquer uma das entradas (`in0`, `in1`, ou `sel`) muda.

A lógica é implementada usando um operador condicional (`assign out = sel ? in1 : in0;`), que é uma forma concisa de descrever um multiplexador:
* Se `sel` for `1` (verdadeiro), `out` recebe o valor de `in1`.
* Se `sel` for `0` (falso), `out` recebe o valor de `in0`.

---

### Testbench: `multiplexadores_tb`

Este módulo Verilog é um testbench funcional para o módulo `multiplexadores`. Ele aplica diferentes combinações de entradas (`in0`, `in1`, `sel`) para verificar se o multiplexador seleciona a saída correta.

#### Inclusões

* `` `timescale 1ps/1ps``: Define a unidade de tempo de simulação como 1 picosegundo (ps) e a precisão de tempo como 1 ps.
* `` `include "multiplexadores.v"``: Inclui o código-fonte do módulo `multiplexadores`, tornando-o disponível para instanciação no testbench.

#### Sinais

* `in0` (`reg [31:0]`): Um registrador que atua como entrada `in0` para a Unidade Sob Teste (UUT).
* `in1` (`reg [31:0]`): Um registrador que atua como entrada `in1` para a UUT.
* `sel` (`reg`): Um registrador que atua como entrada `sel` para a UUT.
* `out` (`wire [31:0]`): Um fio (wire) que recebe a saída `out` da UUT.

#### Instanciação da UUT

```verilog
multiplexadores uut (in0, in1, sel, out);
```

Esta linha instancia o módulo `multiplexadores` dentro do testbench, conectando as entradas (`in0`, `in1`, `sel`) e a saída (`out`) do testbench aos portos correspondentes do módulo.

#### Cenário de Teste (`initial` block)

O bloco `initial` define a sequência de eventos de teste que serão aplicados ao módulo `multiplexadores`.

1.  **Configuração de Dump de Ondas:**
    * `$dumpfile("multiplexadores_tb.vcd");`: Especifica o nome do arquivo Value Change Dump (VCD) onde os sinais de simulação serão registrados. Este arquivo pode ser visualizado com ferramentas como GTKWave para análise do comportamento.
    * `$dumpvars(0, multiplexadores_tb);`: Habilita o dump de todos os sinais no escopo do módulo `multiplexadores_tb` para o arquivo VCD.

2.  **Execução das Operações de Teste:**
    O testbench aplica uma série de combinações de entradas e aguarda 10ps após cada mudança para observar o resultado na saída `out`.

    * **Teste 1: Seleção `in0` (in0=0xAAAA0000, in1=0xBBBB1111, sel=0)**
        ```verilog
        in0 = 32'hAAAA0000; // Define o valor da entrada 0
        in1 = 32'hBBBB1111; // Define o valor da entrada 1
        sel = 1'b0;         // Seleciona in0
        #10;                // Aguarda 10ps. 'out' deve ser 32'hAAAA0000.
        ```

    * **Teste 2: Seleção `in1` (in0=0xAAAA0000, in1=0xBBBB1111, sel=1)**
        ```verilog
        sel = 1'b1;         // Muda a seleção para in1
        #10;                // Aguarda 10ps. 'out' deve ser 32'hBBBB1111.
        ```

    * **Teste 3: Mudança de Entradas com `sel`=1 (in0=0xCCCC2222, in1=0xDDDD3333, sel=1)**
        ```verilog
        in0 = 32'hCCCC2222; // Muda o valor da entrada 0
        in1 = 32'hDDDD3333; // Muda o valor da entrada 1
        #10;                // Aguarda 10ps. Como 'sel' ainda é 1, 'out' deve ser 32'hDDDD3333.
        ```

    * **Teste 4: Seleção `in0` com Novas Entradas (in0=0xCCCC2222, in1=0xDDDD3333, sel=0)**
        ```verilog
        sel = 1'b0;         // Muda a seleção de volta para in0
        #10;                // Aguarda 10ps. 'out' deve ser 32'hCCCC2222.
        ```

3.  **Finalização:**
    * `$display("Teste Completo");`: Exibe uma mensagem no console da simulação indicando que a sequência de teste foi concluída.

#### Propósito do Testbench

O objetivo principal deste testbench é verificar se o módulo `multiplexadores` funciona corretamente como um multiplexador 2 para 1. Ao observar as formas de onda no arquivo VCD, é possível confirmar se a saída (`out`) reflete a entrada (`in0` ou `in1`) que foi selecionada pelo sinal `sel` em cada etapa do teste.