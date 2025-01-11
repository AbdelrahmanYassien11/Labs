# Define variables
VCS = vcs
SIM_EXEC = simulation_executable  # Name of your simulation executable after compilation
DESIGN_FILE = dut.f
TESTBENCH_FILE = tb.f
VPD_FILE = simpleadder.vpd  # Default VPD file name
OUTPUT_DIR = ./output
VERDI = verdi
DVE = dve
FILE_LIST_FLAGS = -f
VCS_FLAGS = -full64 -sverilog -debug_access+r
VPD_FLAGS = -vpd $(OUTPUT_DIR)/$(VPD_FILE)
COMP_DATA_DIR = simulation_executable.daidir  

# Compile the design and testbench
compile: $(DESIGN_FILE) $(TESTBENCH_FILE)
	@echo "Compiling design and testbench..."
	$(VCS) $(FILE_LIST_FLAGS) $(VCS_FLAGS) $(DESIGN_FILE) $(TESTBENCH_FILE) -o $(SIM_EXEC)
	@echo "Compilation complete."

 #Run the simulation and dump the VPD file
run: compile
	@echo "Running simulation..."
	./$(SIM_EXEC) $(VPD_FLAGS)
	@echo "Simulation complete. VPD file dumped to $(OUTPUT_DIR)/$(VPD_FILE)."

# Check if user wants to use Verdi or DVE
check-viewer:
	@echo "Would you like to use Verdi or DVE to view the waveform? (Enter verdi or dve)"
	@read viewer; \
	if [ $$viewer = "verdi" ]; then \
		$(VERDI) -vpd $(OUTPUT_DIR)/$(VPD_FILE); \
	elif [ $$viewer = "dve" ]; then \
		$(DVE) -vpd $(OUTPUT_DIR)/$(VPD_FILE); \
	else \
		echo "Invalid option, please enter either 'verdi' or 'dve'."; \
	fi

# Clean up previous simulation files
clean:
	@echo "Cleaning up..."
	rm -rf $(OUTPUT_DIR)/* $(SIM_EXEC) $(COMP_DATA_DIR)
	@echo "Clean up complete."

# Full build and simulation flow
full-sim: compile run check-viewer

# Default target
all: full-sim
