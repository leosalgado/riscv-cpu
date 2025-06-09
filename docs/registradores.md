## Documentação do Módulo de Registradores e Testbench

Esta documentação detalha o módulo Verilog `registradores`, que simula um banco de registradores para um processador, e seu testbench associado, `registradores_tb`.

---

### Módulo: `registradores`

Este módulo Verilog implementa um **banco de registradores** com 32 registradores de 32 bits, similar ao conjunto de registradores de uso geral de arquiteturas como RISC-V. Ele suporta duas portas de leitura assíncronas e uma porta de escrita síncrona.

#### Parâmetros do Banco de Registradores

* **Número de Registradores**: 32 (indexados de 0 a 31).
* **Tamanho de Cada Registrador**: 32 bits.
* **Comportamento do Registrador Zero (x0)**: Hardwired para 0, não pode ser escrito.

#### Entradas

* `rs1` (`input [4:0]`): **Endereço do Primeiro Registrador de Leitura**. Um valor de 5 bits que seleciona um dos 32 registradores para leitura.
* `rs2` (`input [4:0]`): **Endereço do Segundo Registrador de Leitura**. Um valor de 5 bits que seleciona outro registrador para leitura.
* `rd` (`input [4:0]`): **Endereço do Registrador de Escrita**. Um valor de 5 bits que seleciona o registrador para onde `wr_data` será escrito.
* `wr_data` (`input [31:0]`): **Dados de Escrita**. O valor de 32 bits a ser escrito no registrador especificado por `rd`.
* `wr` (`input`): **Habilitador de Escrita (Write Enable)**. Quando `1` e detectado em sua **borda de subida**, habilita a operação de escrita.

#### Saídas

* `read1` (`output [31:0]`): **Dados Lidos do Registrador 1**. Contém o valor de 32 bits do registrador selecionado por `rs1`.
* `read2` (`output [31:0]`): **Dados Lidos do Registrador 2**. Contém o valor de 32 bits do registrador selecionado por `rs2`.

#### Comportamento

1.  **Declaração do Banco de Registradores**:
    ```verilog
    reg [31:0] registradores[0:31];
    ```
    Isso declara um array de registradores chamado `registradores`. Cada elemento do array é um registrador de 32 bits, e há 32 elementos, indexados de 0 a 31.

2.  **Operação de Escrita Síncrona**:
    ```verilog
    always @(posedge wr) begin
        if (wr) begin
            // Condição para evitar escrita no registrador 0 (x0 em RISC-V), que é hardwired para zero
            if (rd != 5'h0) begin
                registradores[rd] <= wr_data; // Escreve o dado 'wr_data' no registrador 'rd'
            end
        end
    end
    ```
    Este bloco `always` descreve a lógica de escrita. A escrita ocorre na **borda de subida** do sinal `wr`. O `if (wr)` interno garante que a escrita só aconteça se `wr` for `1`.
    Uma condição crucial é `if (rd != 5'h0)`: ela **previne a escrita no registrador de endereço 0 (`registradores[0]`)**. Isso é um comportamento comum em arquiteturas como RISC-V, onde o registrador `x0` é hardwired para o valor zero e não pode ser alterado.

3.  **Operação de Leitura Assíncrona**:
    ```verilog
    assign read1 = (rs1 == 5'h0) ? 32'h0 : registradores[rs1];
    assign read2 = (rs2 == 5'h0) ? 32'h0 : registradores[rs2];
    ```
    Estas atribuições `assign` descrevem a lógica de leitura. As leituras são **assíncronas**, o que significa que os valores de `read1` e `read2` são **imediatamente atualizados** sempre que os endereços `rs1` ou `rs2` mudam.
    Para ambos os `read1` e `read2`, há uma verificação condicional:
    * Se o endereço de leitura (`rs1` ou `rs2`) for `5'h0` (o registrador zero), a saída será **sempre `32'h0`**.
    * Caso contrário, a saída será o valor armazenado no registrador correspondente (`registradores[rs1]` ou `registradores[rs2]`).

#### Resumo Funcional

O módulo `registradores` modela um banco de registradores básico. Ele permite a leitura de dois registradores simultaneamente a qualquer momento (assíncrona) e a escrita em um registrador específico na borda de subida do sinal de escrita, com a proteção de não escrever no registrador zero.

---

### Testbench: `registradores_tb`

Este módulo Verilog é um testbench funcional para o módulo `registradores`. Ele simula diferentes operações de escrita e leitura para verificar o comportamento correto do banco de registradores.

#### Inclusões

* `` `timescale 1ps/1ps``: Define a unidade de tempo de simulação como 1 picosegundo (ps) e a precisão de tempo como 1 ps.
* `` `include "registradores.v"``: Inclui o código-fonte do módulo `registradores`, tornando-o disponível para instanciação.

#### Sinais

* `rs1` (`reg [4:0]`): Entrada de endereço do primeiro registrador de leitura para a UUT.
* `rs2` (`reg [4:0]`): Entrada de endereço do segundo registrador de leitura para a UUT.
* `rd` (`reg [4:0]`): Entrada de endereço do registrador de escrita para a UUT.
* `wr_data` (`reg [31:0]`): Entrada de dados a serem escritos na UUT.
* `wr` (`reg`): Entrada de habilitação de escrita para a UUT.
* `read1` (`wire [31:0]`): Saída dos dados lidos do registrador 1 da UUT.
* `read2` (`wire [31:0]`): Saída dos dados lidos do registrador 2 da UUT.

#### Instanciação da UUT

```verilog
registradores uut(rs1, rs2, rd, wr_data, wr, read1, read2);
```

Esta linha instancia o módulo `registradores` dentro do testbench, conectando as entradas e saídas do testbench aos portos correspondentes do módulo.

#### Cenário de Teste (`initial` block)

O bloco `initial` define a sequência de eventos de teste que serão aplicados ao módulo `registradores`.

1.  **Configuração de Dump de Ondas:**
    * `$dumpfile("registradores_tb.vcd");`: Especifica o nome do arquivo Value Change Dump (VCD) onde os sinais de simulação serão registrados. Este arquivo pode ser visualizado com ferramentas como GTKWave para análise do comportamento.
    * `$dumpvars(0, registradores_tb);`: Habilita o dump de todos os sinais no escopo do módulo `registradores_tb` para o arquivo VCD.

2.  **Inicialização e Verificação do Registrador Zero (x0):**
    ```verilog
    rs1 = 5'd0;       // Tenta ler o registrador 0
    rs2 = 5'd0;       // Tenta ler o registrador 0
    rd  = 5'd0;       // Tenta escrever no registrador 0
    wr_data = 32'h0;  // Dados para tentar escrever
    wr = 1'b0;        // Escrita desabilitada inicialmente
    #10;              // Aguarda 10ps - read1 e read2 devem ser 0
    // Tentar escrever no registrador 0, o que não deve ter efeito
    wr = 1'b1;        
    wr_data = 32'hDEADBEEF; // Um valor diferente de 0 para testar
    #10;
    wr = 1'b0;
    // read1 e read2 ainda devem ser 0, confirmando que x0 não é escrito
    ```
    Este passo inicializa todos os sinais e verifica se o registrador x0 (`registradores[0]`) se comporta como hardwired para zero, mesmo tentando escrever nele.

3.  **Escrita no Registrador 10 (x10) e Leitura:**
    ```verilog
    rd      = 5'd10;         // Endereço do registrador de destino (x10)
    wr_data = 32'hAAAABBBB;  // Dados a serem escritos
    wr       = 1'b1;          // Ativa a escrita
    #10;                     // Aguarda 10ps para a escrita síncrona
    wr      = 1'b0;          // Desativa a escrita

    rs1 = 5'd10;             // Tenta ler o registrador x10
    rs2 = 5'd20;             // Tenta ler um registrador não escrito (x20)
    #10;                     // Aguarda 10ps para observar as leituras
    // read1 deve ser 32'hAAAABBBB
    // read2 deve ser 32'h0 (ou X, dependendo da inicialização padrão do simulador para registradores não escritos)
    ```
    Aqui, o valor `0xAAAABBBB` é escrito no registrador x10. Em seguida, x10 é lido via `read1` e x20 (que ainda não foi escrito) é lido via `read2`.

4.  **Escrita no Registrador 20 (x20) e Leitura Mista:**
    ```verilog
    rd      = 5'd20;         // Endereço do registrador de destino (x20)
    wr_data = 32'hCCCCDDDD;  // Novos dados
    wr      = 1'b1;          // Ativa a escrita
    #10;                     // Aguarda 10ps
    wr      = 1'b0;          // Desativa a escrita

    rs1 = 5'd0;              // Tenta ler o registrador x0 (deve ser 0)
    rs2 = 5'd20;             // Tenta ler o registrador x20 (recém-escrito)
    #10;                     // Aguarda 10ps
    // read1 deve ser 32'h0
    // read2 deve ser 32'hCCCCDDDD
    ```
    Neste passo, `0xCCCCDDDD` é escrito em x20. Em seguida, x0 é lido via `read1` (verificando novamente seu comportamento de zero) e x20 é lido via `read2`.

5.  **Finalização:**
    * `$display("Teste Completo");`: Exibe uma mensagem no console da simulação.

#### Propósito do Testbench

O objetivo principal deste testbench é verificar:

1.  A **escrita síncrona** de dados nos registradores na borda de subida de `wr`.
2.  A **proteção de escrita** do registrador x0 (registrador de endereço 0), garantindo que ele sempre permaneça com valor zero.
3.  A **leitura assíncrona** correta dos valores dos registradores, incluindo o comportamento de leitura do registrador x0.

Ao observar as formas de onda no arquivo VCD, é possível confirmar se os valores lidos (`read1`, `read2`) correspondem aos valores esperados após as operações de escrita e considerando o comportamento especial do registrador zero.