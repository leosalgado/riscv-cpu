## Documentação da Memória de Dados e Testbench

Esta documentação descreve o módulo Verilog `memoria_dados` e seu testbench associado, `memoria_dados_tb`.

---

### Módulo: `memoria_dados`

Este módulo Verilog implementa uma **memória de dados síncrona de escrita e assíncrona de leitura**. Ele simula um bloco de memória que pode armazenar e recuperar palavras de 32 bits.

#### Parâmetros da Memória

* **Tamanho da Palavra**: 32 bits
* **Número de Palavras**: 1024 (endereços de 0 a 1023)
* **Capacidade Total**: 1024 palavras * 32 bits/palavra = 32768 bits = 4 KB

#### Entradas

* `rs` (`input [31:0]`): **Endereço de Leitura/Escrita**. Embora seja um sinal de 32 bits, apenas os bits menos significativos (`rs[9:0]`) são usados para indexar a memória, permitindo endereçar $2^{10} = 1024$ posições.
* `wd` (`input [31:0]`): **Dados de Escrita**. O valor de 32 bits a ser escrito na memória.
* `wr` (`input`): **Habilitador de Escrita (Write Enable)**. Quando `1` e na borda de subida (do pulso `wr`), habilita a operação de escrita.

#### Saídas

* `rd` (`output [31:0]`): **Dados de Leitura**. O valor de 32 bits lido da posição de memória especificada por `rs`.

#### Comportamento

1.  **Declaração da Memória**:
    ```verilog
    reg [31:0] memoria[0:1023];
    ```
    Declara um array de registradores chamado `memoria`. Cada elemento é um registrador de 32 bits, com 1024 elementos indexados de 0 a 1023.

2.  **Operação de Escrita Síncrona**:
    ```verilog
    always @(posedge wr) begin
        if (wr) begin
            memoria[rs[9:0]] <= wd;
        }
    end
    ```
    A escrita ocorre na **borda de subida** do sinal `wr`. O valor em `wd` é escrito na posição de memória indexada pelos 10 bits menos significativos de `rs` (`rs[9:0]`).

3.  **Operação de Leitura Assíncrona**:
    ```verilog
    assign rd = memoria[rs[9:0]];
    ```
    A leitura é **assíncrona**. O valor de `rd` é **imediatamente atualizado** sempre que o endereço `rs` muda, refletindo o conteúdo da posição de memória especificada por `rs[9:0]`.

#### Resumo Funcional

A memória de dados permite que se escrevam novos valores em uma posição específica na borda de subida do sinal `wr`. Simultaneamente, ela sempre disponibiliza o conteúdo da posição de memória atualmente endereçada em `rd`, independentemente do estado de `wr` (exceto durante o pulso de escrita, quando o valor recém-escrito se torna disponível).

---

### Testbench: `memoria_dados_tb`

Este módulo Verilog é um testbench funcional para o módulo `memoria_dados`. Ele simula operações de escrita e leitura para verificar o comportamento correto da memória.

#### Inclusões

* `` `timescale 1ps/1ps``: Define a unidade de tempo e precisão para 1 picosegundo.
* `` `include "memoria_dados.v"``: Inclui o código-fonte do módulo `memoria_dados`.

#### Sinais

* `rs` (`reg [31:0]`): Entrada de endereço para a Unidade Sob Teste (UUT).
* `wd` (`reg [31:0]`): Entrada de dados de escrita para a UUT.
* `wr` (`reg`): Entrada de habilitação de escrita para a UUT.
* `rd` (`wire [31:0]`): Saída de dados de leitura da UUT.

#### Instanciação da UUT

```verilog
memoria_dados uut(rs, wd, wr, rd);
````

#### Cenário de Teste (`initial` block)

O bloco `initial` define a sequência de eventos de teste:

1.  **Configuração de Dump de Ondas:**
    * `$dumpfile("memoria_dados_tb.vcd");`: Especifica o arquivo VCD para registro dos sinais de simulação.
    * `$dumpvars(0, memoria_dados_tb);`: Habilita o dump de todos os sinais no escopo do testbench.

2.  **Sequência de Teste:**
    O testbench aplica uma série de operações de escrita e leitura:

    * **Escrita na Posição 0:**
        ```verilog
        rs = 32'd0;         // Endereço 0
        wd = 32'hFEEDF00D;  // Dados
        wr = 1'b1;          // Ativa escrita
        #20;                // Aguarda 20ps
        wr = 1'b0;          // Desativa escrita
        ```

    * **Escrita na Posição 1:**
        ```verilog
        rs = 32'd1;         // Endereço 1
        wd = 32'hBEEFCAFE;  // Dados
        wr = 1'b1;          // Ativa escrita
        #20;                // Aguarda 20ps
        wr = 1'b0;          // Desativa escrita
        ```

    * **Leitura da Posição 0:**
        ```verilog
        rs = 32'd0; // Endereço 0 (wr já está em 0, é apenas leitura)
        #20;        // Aguarda 20ps para observar 'rd'
        ```
        `rd` deve exibir `0xFEEDF00D`.

    * **Leitura da Posição 1:**
        ```verilog
        rs = 32'd1; // Endereço 1
        #20;        // Aguarda 20ps
        ```
        `rd` deve exibir `0xBEEFCAFE`.

3.  **Finalização:**
    * `$display("Teste Completo");`: Exibe mensagem de conclusão no console.

#### Propósito do Testbench

O objetivo principal deste testbench é verificar:

1.  Se as **escritas** na memória são realizadas corretamente.
2.  Se as **leituras** da memória são corretas e assíncronas.

Observando as formas de onda no arquivo VCD, é possível confirmar que os valores lidos (`rd`) correspondem aos valores previamente escritos nas respectivas posições de memória.