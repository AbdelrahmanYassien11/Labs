# Define variables
VCS := vcs
DESIGN_FILE := dut.f
TESTBENCH_FILE := tb.f
TIME_SCALE := 1ns/1ps
OUTPUT_DIR := ./output
VDB_OUTPUT_DIR := ./vdb_output
COVERAGE_DIR := coverage_closure
VERDI := verdi
DVE := dve

# Define the default test names (can be overridden via command line)
TEST_NAME  ?= random_test  # Default test name if not specified
TEST_NAME1 ?= random_test
TEST_NAME2 ?= repitition_test
TEST_NAME3 ?= error_test

# Default tools
WAVEFORM_VIEWER ?= verdi  # Default waveform viewer (can be 'verdi' or 'dve')
COVERAGE_MERGE_TOOL ?= vcs  # Default coverage merge tool (can be 'vcs' or 'verdi')

# Derived variables based on TEST_NAME
SIM_EXEC := $(TEST_NAME)_simulation_executable
VPD_FILE := $(TEST_NAME).vpd
COMPILE_LOG := $(TEST_NAME)_compile.log
SIM_LOG := $(TEST_NAME)_sim.log
COVERAGE_DB := $(SIM_EXEC).vdb

# Compilation and simulation flags
FILE_LIST_FLAGS := -f
COVERAGE_FLAGS := -cm branch+cond+tgl+line+assert
VCS_UVM_LIB_FLAG := -ntb_opts uvm-1.2
VCS_FLAGS := -full64 -sverilog $(VCS_UVM_LIB_FLAG) -timescale=$(TIME_SCALE) $(COVERAGE_FLAGS) -l $(COMPILE_LOG) -debug_access+r +R
VPD_FLAGS := -vpd $(OUTPUT_DIR)/$(VPD_FILE)
UVM_TESTNAME := +UVM_TESTNAME=
VERBOSITY_LEVEL ?= UVM_LOW
UVM_VERBOSITY := +UVM_VERBOSITY=

# Create necessary directories
$(OUTPUT_DIR) $(COVERAGE_DIR) $(VDB_OUTPUT_DIR):
	@mkdir -p $@
	@echo "Created directory: $@"

# Compile the design and testbench with the specified test name
compile: $(OUTPUT_DIR) $(VDB_OUTPUT_DIR) $(DESIGN_FILE) $(TESTBENCH_FILE)
	@echo "Compiling design and testbench for test: $(TEST_NAME)..."
	@$(VCS) $(VCS_FLAGS) $(FILE_LIST_FLAGS) $(DESIGN_FILE) $(FILE_LIST_FLAGS) $(TESTBENCH_FILE) -l $(OUTPUT_DIR)/$(COMPILE_LOG) -vdb_dir $(VDB_OUTPUT_DIR) -o $(SIM_EXEC) || { echo "Compilation failed"; exit 1; }
	@echo "Compilation complete for $(TEST_NAME)."

# Run the simulation and dump the VPD file with the test-specific name
run: compile
	@echo "Running simulation for test: $(TEST_NAME)..."
	@./$(SIM_EXEC) $(COVERAGE_FLAGS) $(UVM_TESTNAME)$(TEST_NAME) $(UVM_VERBOSITY)$(VERBOSITY_LEVEL) +ntb_random_automatic -l $(OUTPUT_DIR)/$(SIM_LOG) $(VPD_FLAGS) || { echo "Simulation failed"; exit 1; }
	@echo "Simulation complete. VPD file dumped to $(OUTPUT_DIR)/$(VPD_FILE)."

# View waveform with selected viewer (verdi or dve)
view-waveform: $(OUTPUT_DIR)
	@if [ "$(WAVEFORM_VIEWER)" = "verdi" ]; then \
		echo "Opening $(TEST_NAME) waveform with Verdi..."; \
		$(VERDI) -vpd $(OUTPUT_DIR)/$(VPD_FILE); \
	elif [ "$(WAVEFORM_VIEWER)" = "dve" ]; then \
		echo "Opening $(TEST_NAME) waveform with DVE..."; \
		$(DVE) -vpd $(OUTPUT_DIR)/$(VPD_FILE); \
	else \
		echo "Error: Invalid waveform viewer specified. Use WAVEFORM_VIEWER=verdi or WAVEFORM_VIEWER=dve"; \
		exit 1; \
	fi

# Select waveform viewer interactively
choose-viewer:
	@echo "Which waveform viewer would you like to use? (Enter 'verdi' or 'dve'): "
	@read viewer; \
	if [ "$$viewer" = "verdi" ] || [ "$$viewer" = "dve" ]; then \
		echo "Please enter the test name to view:"; \
		read test_name; \
		$(MAKE) TEST_NAME=$$test_name WAVEFORM_VIEWER=$$viewer view-waveform; \
	else \
		echo "Invalid option. Please enter either 'verdi' or 'dve'."; \
		exit 1; \
	fi

# Merge test VDBs using selected tool (vcs or verdi)
vdb-merge-valid: $(COVERAGE_DIR)
	@echo "Merging valid test VDBs using $(COVERAGE_MERGE_TOOL)..."
	@if [ "$(COVERAGE_MERGE_TOOL)" = "vcs" ]; then \
		$(VCS) -vdb_merge -o $(COVERAGE_DIR)/valid_tests_cov.vdb $(TEST_NAME1)_simulation_executable.vdb $(TEST_NAME2)_simulation_executable.vdb; \
	elif [ "$(COVERAGE_MERGE_TOOL)" = "verdi" ]; then \
		$(VERDI) -vdb_merge -o $(COVERAGE_DIR)/valid_tests_cov.vdb $(TEST_NAME1)_simulation_executable.vdb $(TEST_NAME2)_simulation_executable.vdb; \
	else \
		echo "Error: Invalid coverage merge tool specified. Use COVERAGE_MERGE_TOOL=vcs or COVERAGE_MERGE_TOOL=verdi"; \
		exit 1; \
	fi

vdb-merge-error: $(COVERAGE_DIR)
	@echo "Merging error test VDBs using $(COVERAGE_MERGE_TOOL)..."
	@if [ "$(COVERAGE_MERGE_TOOL)" = "vcs" ]; then \
		$(VCS) -vdb_merge -o $(COVERAGE_DIR)/error_tests_cov.vdb $(TEST_NAME3)_simulation_executable.vdb; \
	elif [ "$(COVERAGE_MERGE_TOOL)" = "verdi" ]; then \
		$(VERDI) -vdb_merge -o $(COVERAGE_DIR)/error_tests_cov.vdb $(TEST_NAME3)_simulation_executable.vdb; \
	else \
		echo "Error: Invalid coverage merge tool specified. Use COVERAGE_MERGE_TOOL=vcs or COVERAGE_MERGE_TOOL=verdi"; \
		exit 1; \
	fi


# Choose coverage merge tool interactively
choose-merge-tool:
	@echo "Which tool would you like to use for merging coverage? (Enter 'vcs' or 'verdi'): "
	@read merge_tool; \
	if [ "$$merge_tool" = "vcs" ] || [ "$$merge_tool" = "verdi" ]; then \
		$(MAKE) COVERAGE_MERGE_TOOL=$$merge_tool vdb-merge-all; \
	else \
		echo "Invalid option. Please enter either 'vcs' or 'verdi'."; \
		exit 1; \
	fi

# Open VDB coverage reports
view-coverage-valid:
	@echo "Opening valid tests coverage with DVE..."
	@$(DVE) -cov $(COVERAGE_DIR)/valid_tests_cov.vdb

view-coverage-error:
	@echo "Opening error tests coverage with DVE..."
	@$(DVE) -cov $(COVERAGE_DIR)/error_tests_cov.vdb


# Generate coverage reports
generate-reports: $(COVERAGE_DIR) vdb-merge-valid vdb-merge-error
	@echo "Generating coverage reports..."
	@urg -dir $(TEST_NAME1)_simulation_executable.vdb $(TEST_NAME2)_simulation_executable.vdb -format text -elfile random_test.el -report $(COVERAGE_DIR)/valid_tests_cov_merged || { echo "Failed to generate valid tests report"; exit 1; }
	@urg -dir $(TEST_NAME3)_simulation_executable.vdb -format text -elfile error_test.el -report $(COVERAGE_DIR)/error_injection_cov_merged || { echo "Failed to generate error tests report"; exit 1; }
	@echo "Coverage reports generated in $(COVERAGE_DIR)."

# Run all tests sequentially
run-all-tests:
	@echo "Running all tests sequentially..."
	@$(MAKE) TEST_NAME=$(TEST_NAME1) run
	@$(MAKE) TEST_NAME=$(TEST_NAME2) run
	@$(MAKE) TEST_NAME=$(TEST_NAME3) run
	@echo "All tests completed."

clean:
	@echo "Cleaning up..."
	@rm -rf $(OUTPUT_DIR)/* $(COVERAGE_DIR)/* \
		$(TEST_NAME1)_simulation_executable \
		$(TEST_NAME2)_simulation_executable \
		$(TEST_NAME3)_simulation_executable \
		$(TEST_NAME1)_simulation_executable.daidir \
		$(TEST_NAME2)_simulation_executable.daidir \
		$(TEST_NAME3)_simulation_executable.daidir \
		$(TEST_NAME1)_simulation_executable.vdb \
		$(TEST_NAME2)_simulation_executable.vdb \
		$(TEST_NAME3)_simulation_executable.vdb
	@echo "Clean up complete."

# Full build and simulation flow
full-sim: compile run

# Help target
help:
	@echo "Available targets:"
	@echo "  compile            - Compile design and testbench for TEST_NAME"
	@echo "  run                - Run simulation for TEST_NAME"
	@echo "  full-sim           - Compile and run simulation for TEST_NAME"
	@echo "  run-all-tests      - Run all defined tests sequentially"
	@echo "  view-waveform      - Open TEST_NAME waveform with specified viewer (WAVEFORM_VIEWER)"
	@echo "  choose-viewer      - Interactive selection of waveform viewer"
	@echo "  vdb-merge-valid    - Merge valid test VDBs with specified tool (COVERAGE_MERGE_TOOL)"
	@echo "  vdb-merge-error    - Merge error test VDBs with specified tool (COVERAGE_MERGE_TOOL)"
	@echo "  choose-merge-tool  - Interactive selection of coverage merge tool"
	@echo "  view-coverage-valid - View valid tests coverage"
	@echo "  view-coverage-error - View error tests coverage"
	@echo "  generate-reports   - Generate coverage reports"
	@echo "  clean              - Clean up generated files"
	@echo "  help               - Display this help message"
	@echo ""
	@echo "Variables that can be overridden:"
	@echo "  TEST_NAME          - Currently: $(TEST_NAME)"
	@echo "  TEST_NAME1         - Currently: $(TEST_NAME1)"
	@echo "  TEST_NAME2         - Currently: $(TEST_NAME2)"
	@echo "  TEST_NAME3         - Currently: $(TEST_NAME3)"
	@echo "  VERBOSITY_LEVEL    - Currently: $(VERBOSITY_LEVEL)"
	@echo "  WAVEFORM_VIEWER    - Currently: $(WAVEFORM_VIEWER) (options: verdi, dve)"
	@echo "  COVERAGE_MERGE_TOOL - Currently: $(COVERAGE_MERGE_TOOL) (options: vcs, verdi)"

# Default target
all: full-sim generate-reports