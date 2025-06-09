BUILD_DIR = build
WAVEFORM_DIR = waveforms
SRC_DIR = src

IVERILOG = iverilog
VVP = vvp

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(WAVEFORM_DIR):
	mkdir -p $(WAVEFORM_DIR)

ula: $(BUILD_DIR) $(WAVEFORM_DIR)
	$(IVERILOG) -I $(SRC_DIR) -o $(BUILD_DIR)/$@_tb.vvp tb/$@_tb.v
	$(VVP) $(BUILD_DIR)/$@_tb.vvp

uc: $(BUILD_DIR) $(WAVEFORM_DIR)
	$(IVERILOG) -I $(SRC_DIR) -o $(BUILD_DIR)/$@_tb.vvp tb/$@_tb.v
	$(VVP) $(BUILD_DIR)/$@_tb.vvp

registradores: $(BUILD_DIR) $(WAVEFORM_DIR)
	$(IVERILOG) -I $(SRC_DIR) -o $(BUILD_DIR)/$@_tb.vvp tb/$@_tb.v
	$(VVP) $(BUILD_DIR)/$@_tb.vvp

memoria_instrucao: $(BUILD_DIR) $(WAVEFORM_DIR)
	$(IVERILOG) -I $(SRC_DIR) -o $(BUILD_DIR)/$@_tb.vvp tb/$@_tb.v
	$(VVP) $(BUILD_DIR)/$@_tb.vvp

memoria_dados: $(BUILD_DIR) $(WAVEFORM_DIR)
	$(IVERILOG) -I $(SRC_DIR) -o $(BUILD_DIR)/$@_tb.vvp tb/$@_tb.v
	$(VVP) $(BUILD_DIR)/$@_tb.vvp

mux: $(BUILD_DIR) $(WAVEFORM_DIR)
	$(IVERILOG) -I $(SRC_DIR) -o $(BUILD_DIR)/$@_tb.vvp tb/$@_tb.v
	$(VVP) $(BUILD_DIR)/$@_tb.vvp

all: ula uc registradores memoria_instrucao memoria_dados mux

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(WAVEFORM_DIR)

