## Documentação da Memória de Instrução e Testbench

Esta documentação detalha o módulo Verilog `memoria_instrucao` e seu respectivo testbench, `memoria_instrucao_tb`.

---

### Módulo: `memoria_instrucao`

Este módulo Verilog implementa uma **memória de instrução ROM (Read-Only Memory)**. Ele armazena instruções pré-definidas e as disponibiliza de forma assíncrona com base em um endereço de entrada.

#### Parâmetros da Memória

* **Tamanho da Palavra**: 32 bits (para armazenar uma instrução completa).
* **Número de Palavras**: 256 (endereços de 0 a 255).
* **Capacidade Total**: 256 palavras * 32 bits/palavra = 8192 bits = 1 KB.

#### Entradas

* `endereco` (`input [7:0]`): O **endereço** de 8 bits da instrução a ser lida. Este valor de 8 bits permite endereçar $2^8 = 256$ posições únicas na memória.

#### Saídas

* `dado` (`output reg [31:0]`): A **instrução** de 32 bits lida da posição de memória especificada por `endereco`. É declarado como `reg` porque seu valor é atribuído dentro de um bloco `always`.

#### Comportamento

1.  **Declaração da Memória Interna**:
    ```verilog
    reg [31:0] memoria[0:255];
    ```
    Isso declara um array de registradores chamado `memoria`. Cada elemento do array é um registrador de 32 bits, e há 256 elementos, indexados de 0 a 255.

2.  **Inicialização da Memória (Conteúdo ROM)**:
    ```verilog
    initial begin
        memoria[0] = 32'h001101B3; // Exemplo de instrução em hexadecimal
        memoria[1] = 32'd12;      // Exemplo de instrução em decimal
        memoria[2] = 32'h5fd3;    // Outro exemplo em hexadecimal
    end
    ```
    O bloco `initial` é executado apenas uma vez, no início da simulação. Ele pré-carrega algumas posições específicas da memória com valores fixos. Isso simula o conteúdo de uma ROM onde as instruções são gravadas permanentemente.

3.  **Operação de Leitura Assíncrona**:
    ```verilog
    always @(*) begin
        dado = memoria[endereco];
    end
    ```
    Este bloco `always @(*)` descreve a lógica de leitura. A leitura é **assíncrona**, o que significa que o valor da saída `dado` é **imediatamente atualizado** sempre que o valor da entrada `endereco` muda. O `dado` de 32 bits é lido diretamente da posição da `memoria` especificada pelo `endereco`.

#### Resumo Funcional

A `memoria_instrucao` atua como um repositório para as instruções do processador. Uma vez inicializada, ela fornece o conteúdo da posição de memória endereçada de forma instantânea (assíncrona), simulando a leitura de instruções de uma ROM.

---

### Testbench: `memoria_instrucao_tb`

Este módulo Verilog é um testbench funcional para o módulo `memoria_instrucao`. Ele testa a funcionalidade de leitura da memória, aplicando diferentes endereços e verificando as saídas.

#### Inclusões

* `` `timescale 1ps/1ps``: Define a unidade de tempo de simulação como 1 picosegundo (ps) e a precisão de tempo como 1 ps.
* `` `include "memoria_instrucao.v"``: Inclui o código-fonte do módulo `memoria_instrucao`, tornando-o disponível para instanciação.

#### Sinais

* `endereco` (`reg [7:0]`): Um registrador que atua como entrada para o endereço da Unidade Sob Teste (UUT). O testbench atribui valores a este registrador.
* `dado` (`wire [31:0]`): Um fio (wire) que recebe a saída de instrução (`dado`) da UUT.

#### Instanciação da UUT

```verilog
memoria_instrucao uut(endereco, dado);
```

Esta linha instancia o módulo `memoria_instrucao` dentro do testbench, conectando as entradas e saídas do testbench aos portos correspondentes do módulo.

#### Cenário de Teste (`initial` block)

O bloco `initial` define a sequência de eventos de teste que serão aplicados à `memoria_instrucao`.

1.  **Configuração de Dump de Ondas:**
    * `$dumpfile("memoria_instrucao_tb.vcd");`: Especifica o nome do arquivo Value Change Dump (VCD) onde os sinais de simulação serão registrados. Este arquivo pode ser visualizado com ferramentas como GTKWave para análise do comportamento.
    * `$dumpvars(0, memoria_instrucao_tb);`: Habilita o dump de todos os sinais no escopo do módulo `memoria_instrucao_tb` para o arquivo VCD.

2.  **Sequência de Teste:**
    O testbench aplica uma série de operações de leitura. **Observação**: A forma original de atribuir valores ao `endereco` (`endereco[0] = ...`) estava incorreta para definir o endereço completo. O método correto é atribuir o valor diretamente ao registrador `endereco`.

    * **Leitura da Posição 0:**
        ```verilog
        endereco = 8'd0; // Define o endereço para 0
        #10;             // Aguarda 10ps para observar 'dado' (deve ser 32'h001101B3)
        ```

    * **Leitura da Posição 1:**
        ```verilog
        endereco = 8'd1; // Define o endereço para 1
        #10;             // Aguarda 10ps para observar 'dado' (deve ser 32'd12)
        ```

    * **Leitura da Posição 2:**
        ```verilog
        endereco = 8'd2; // Define o endereço para 2
        #10;             // Aguarda 10ps para observar 'dado' (deve ser 32'h5fd3)
        ```

    * **Leitura de Posição Não Inicializada (Exemplo):**
        ```verilog
        endereco = 8'd3; // Endereço com conteúdo não inicializado (geralmente 'X' ou 0)
        #10;
        ```

3.  **Finalização:**
    * `$display("Teste Completo");`: Exibe uma mensagem no console da simulação indicando que a sequência de teste foi concluída.

#### Propósito do Testbench

O objetivo principal deste testbench é verificar se o módulo `memoria_instrucao` **lê e disponibiliza corretamente** o conteúdo previamente inicializado da memória quando um `endereco` específico é fornecido. Ao observar as formas de onda no arquivo VCD, é possível confirmar se o `dado` de saída corresponde à instrução esperada para cada endereço.
