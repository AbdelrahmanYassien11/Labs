# Define variables
VCS = vcs
SIM_EXEC = $(TEST_NAME)_simulation_executable  # Name of your simulation executable based on TEST_NAME
DESIGN_FILE = dut.f
TESTBENCH_FILE = tb.f
VPD_FILE = $(TEST_NAME).vpd  # VPD file name based on TEST_NAME
OUTPUT_DIR = ./output # Output directory based on TEST_NAME
VERDI = verdi
DVE = dve
FILE_LIST_FLAGS = -f
COVERAGE_FLAGS = -cm cond+tgl+line+assert
VCS_FLAGS = -full64 -sverilog $(COVERAGE_FLAGS) -debug_access+r +R
VPD_FLAGS = -vpd $(OUTPUT_DIR)/$(VPD_FILE)
#COMP_DATA_DIR = $(TEST_NAME)_simulation_executable.daidir
COVERAGE_DB = $(SIM_EXEC).vdb
COVERAGE_DIR = coverage_closure

# Define the default test name (can be overridden via command line)
TEST_NAME  ?= RANDOM_TEST  # Default test name if not specified
TEST_NAME1 ?= RANDOM_TEST
TEST_NAME2 ?= RANDOM_RESET_THRICE_TEST
TEST_NAME3 ?= RANDOM_ERROR_INJECTION_TEST

# Compile the design and testbench with the specified test name
compile: $(DESIGN_FILE) $(TESTBENCH_FILE)
	@echo "Compiling design and testbench for test: $(TEST_NAME)..."
	$(VCS) $(VCS_FLAGS) $(FILE_LIST_FLAGS) $(DESIGN_FILE) $(FILE_LIST_FLAGS) $(TESTBENCH_FILE) -o $(SIM_EXEC)
	@echo "Compilation complete."

# Run the simulation and dump the VPD file with the test-specific name
run: compile
	@echo "Running simulation for test: $(TEST_NAME)..."
	./$(SIM_EXEC) $(COVERAGE_FLAGS) +$(TEST_NAME) $(VPD_FLAGS)
	@echo "Simulation complete. VPD file dumped to $(OUTPUT_DIR)/$(VPD_FILE)."

# Check if user wants to use Verdi or DVE
#check-viewer:
	#@echo "Would you like to use Verdi or DVE to view the waveform? (Enter verdi or dve)"
	#@read viewer; \
	#if [ $$viewer = "verdi" ]; then \
	#	$(VERDI) -vpd $(OUTPUT_DIR)/$(VPD_FILE); \
	#elif [ $$viewer = "dve" ]; then \
	#	$(DVE) -vpd $(OUTPUT_DIR)/$(VPD_FILE); \
	#else \
	#	echo "Invalid option, please enter either 'verdi' or 'dve'."; \
	#fi

check-viewer:
	@echo "Which waveform viewer would you like to use? (Enter 'verdi' or 'dve'): " ; \
	read viewer; \
	case "$$viewer" in \
		verdi) PROG="$(VERDI)" ;; \
		dve)   PROG="$(DVE)"   ;; \
		*) echo "Invalid option. Please enter either 'verdi' or 'dve'."; exit 1 ;; \
	esac; \
	echo "Which test waveform (VPD file) would you like to use? (e.g., RANDOM_TEST.vpd): " ; \
	read chosen_vpd; \
	# Optionally assign the chosen VPD file name to TEST_NAME for informational purposes  
	TEST_NAME="$$chosen_vpd"; \
	echo "Using test waveform: $$TEST_NAME"; \
	$$PROG -vpd $(OUTPUT_DIR)/$(VPD_FILE)


# Generate coverage reports
generate-reports:
	@echo "Generating coverage reports......"
	urg -dir $(TEST_NAME1)_simulation_executable.vdb $(TEST_NAME2)_simulation_executable.vdb -format text -report $(COVERAGE_DIR)/valid_tests_cov_merged.txt
	urg -dir $(TEST_NAME3)_simulation_executable.vdb -format text -report $(COVERAGE_DIR)/error_injection_cov_merged.txt

clean:
	@echo "Cleaning up..."
	@rm -rf "$(OUTPUT_DIR)"/* "$(COVERAGE_DIR)"/* \
	         "$(TEST_NAME1)" \
	         "$(TEST_NAME2)" \
	         "$(TEST_NAME3)_simulation_executable" \
	         "$(TEST_NAME1)_simulation_executable.daidir" \
	         "$(TEST_NAME2)_simulation_executable.daidir" \
	         "$(TEST_NAME3)_simulation_executable.daidir" \
	         "$(TEST_NAME1)_simulation_executable.vdb" \
	         "$(TEST_NAME2)_simulation_executable.vdb" \
	         "$(TEST_NAME3)_simulation_executable.vdb"
	@echo "Clean up complete."


# Full build and simulation flow
full-sim: compile run

# Default target
all: full-sim generate-reports
