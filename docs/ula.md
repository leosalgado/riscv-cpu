## Documentação da Unidade Lógica e Aritmética (ULA) e Testbench

Esta documentação descreve o módulo Verilog `ula` e seu testbench associado, `ula_tb`.

---

### Módulo: `ula`

Este módulo Verilog implementa uma **Unidade Lógica e Aritmética (ULA)** que realiza operações básicas de 32 bits, como AND, OR, adição e subtração, com base em um código de operação (`UlaOp`).

#### Entradas

* `A` (`input [31:0]`): O **primeiro operando** para a operação da ULA. É um valor de 32 bits.
* `B` (`input [31:0]`): O **segundo operando** para a operação da ULA. É um valor de 32 bits.
* `UlaOp` (`input [3:0]`): O **código de operação da ULA**. Este valor de 4 bits determina qual operação será executada.

#### Saídas

* `Out` (`output reg [31:0]`): O **resultado** da operação da ULA. É um valor de 32 bits. Declarado como `reg` porque seu valor é atribuído dentro de um bloco `always`.

#### Comportamento

O módulo `ula` utiliza um bloco `always @(*)` sensível a todas as entradas (`A`, `B`, `UlaOp`) para realizar a operação. Isso significa que a saída `Out` é **imediatamente atualizada** sempre que qualquer uma das entradas muda, tornando-a uma ULA **combinacional**.

Dentro do bloco `always`, uma estrutura `case` é usada para decodificar o `UlaOp` e atribuir o resultado da operação apropriada à saída `Out`.

##### Mapeamento de `UlaOp` e Operações:

| `UlaOp`    | Operação (Verilog) | Descrição          |
| :--------- | :----------------- | :----------------- |
| `4'b0000`  | `A & B`            | **AND bit a bit** |
| `4'b0001`  | `A \| B`           | **OR bit a bit** |
| `4'b0010`  | `A + B`            | **Adição** |
| `4'b0110`  | `A - B`            | **Subtração** |
| `default`  | `32'bz`            | **Alta impedância** (Z), indicando uma operação não suportada ou estado indefinido. |

---

### Testbench: `ula_tb`

Este módulo Verilog é um testbench funcional para o módulo `ula`. Ele simula diferentes combinações de operandos (`A`, `B`) e códigos de operação (`UlaOp`) para verificar se a ULA produz os resultados esperados.

#### Inclusões

* `` `timescale 1ps/1ps``: Define a unidade de tempo de simulação como 1 picosegundo (ps) e a precisão de tempo como 1 ps.
* `` `include "ula.v"``: Inclui o código-fonte do módulo `ula`, tornando-o disponível para instanciação no testbench.

#### Sinais

* `A` (`reg [31:0]`): Um registrador que atua como entrada para o operando A da Unidade Sob Teste (UUT).
* `B` (`reg [31:0]`): Um registrador que atua como entrada para o operando B da UUT.
* `UlaOp` (`reg [3:0]`): Um registrador que atua como entrada para o código de operação da UUT.
* `S` (`wire [31:0]`): Um fio (wire) que recebe a saída (`Out`) da UUT. A saída `Out` do módulo `ula` está conectada ao fio `S` no testbench.

#### Instanciação da UUT

```verilog
ula uut(A, B, UlaOp, S);
```

Esta linha instancia o módulo `ula` dentro do testbench, conectando as entradas (`A`, `B`, `UlaOp`) e a saída (`Out` conectada a `S`) do testbench aos portos correspondentes do módulo.

#### Cenário de Teste (`initial` block)

O bloco `initial` define a sequência de eventos de teste que serão aplicados ao módulo `ula`.

1.  **Configuração de Dump de Ondas:**
    * `$dumpfile("ula_tb.vcd");`: Especifica o nome do arquivo Value Change Dump (VCD) onde os sinais de simulação serão registrados. Este arquivo pode ser visualizado com ferramentas como GTKWave para análise do comportamento.
    * `$dumpvars(0, ula_tb);`: Habilita o dump de todos os sinais no escopo do módulo `ula_tb` para o arquivo VCD.

2.  **Execução das Operações de Teste:**
    O testbench define os operandos `A` e `B` uma única vez e, em seguida, itera através dos diferentes códigos de operação (`UlaOp`), aguardando 20ps após cada mudança para observar o resultado.

    * **Inicialização:**
        ```verilog
        A = 32'd20; // A = 20 (decimal)
        B = 32'd12; // B = 12 (decimal)
        ```
    * **Teste AND (`4'b0000`):**
        ```verilog
        UlaOp = 4'b0000; // Operação A & B (20 & 12 = 8)
        #20              // Aguarda 20ps. S deve ser 32'd8.
        ```
    * **Teste OR (`4'b0001`):**
        ```verilog
        UlaOp = 4'b0001; // Operação A | B (20 | 12 = 28)
        #20              // Aguarda 20ps. S deve ser 32'd28.
        ```
    * **Teste Adição (`4'b0010`):**
        ```verilog
        UlaOp = 4'b0010; // Operação A + B (20 + 12 = 32)
        #20              // Aguarda 20ps. S deve ser 32'd32.
        ```
    * **Teste Subtração (`4'b0110`):**
        ```verilog
        UlaOp = 4'b0110; // Operação A - B (20 - 12 = 8)
        #20              // Aguarda 20ps. S deve ser 32'd8.
        ```
    * **Teste Default/Inválido (`4'b1111`):**
        ```verilog
        UlaOp = 4'b1111; // Operação não definida no case (default)
        #20              // Aguarda 20ps. S deve ser 32'bz.
        ```

3.  **Finalização:**
    * `$display("Teste Completo");`: Exibe uma mensagem no console da simulação indicando que a sequência de teste foi concluída.

#### Propósito do Testbench

O objetivo principal deste testbench é verificar se o módulo `ula` executa corretamente as operações lógicas e aritméticas para as quais foi projetado. Ao observar as formas de onda no arquivo VCD, é possível confirmar se o resultado (`S`) para cada combinação de `A`, `B` e `UlaOp` corresponde ao valor esperado, e se o `default` retorna alta impedância.