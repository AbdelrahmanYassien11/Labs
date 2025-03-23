#!/bin/bash

# Script configuration
MAKEFILE="alu_make.make"
LOG_DIR="logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/regression_${TIMESTAMP}.log"

# Tool selection - can be overridden at command line
WAVEFORM_VIEWER=${WAVEFORM_VIEWER:-"dve"}  # Default to verdi if not specified
COVERAGE_MERGE_TOOL=${COVERAGE_MERGE_TOOL:-"vcs"}  # Default to vcs if not specified

# Function to log messages
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

# Function to run a command with error checking
run_cmd() {
    log "EXECUTING: $1"
    eval "$1" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        log "ERROR: Command failed: $1"
        exit 1
    fi
}

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                 Display this help message"
    echo "  -m, --makefile MAKEFILE    Specify the makefile to use (default: alu_make.make)"
    echo "  -w, --waveform-viewer TOOL Select waveform viewer: verdi or dve (default: dve)"
    echo "  -c, --coverage-tool TOOL   Select coverage merge tool: vcs or verdi (default: vcs)"
    echo "  -i, --interactive          Run in interactive mode, prompting for tool choices"
    exit 0
}

# Parse command line arguments
INTERACTIVE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            ;;
        -m|--makefile)
            MAKEFILE="$2"
            shift 2
            ;;
        -w|--waveform-viewer)
            WAVEFORM_VIEWER="$2"
            shift 2
            ;;
        -c|--coverage-tool)
            COVERAGE_MERGE_TOOL="$2"
            shift 2
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
done

# Validate tool selections
if [[ "$WAVEFORM_VIEWER" != "verdi" && "$WAVEFORM_VIEWER" != "dve" ]]; then
    echo "ERROR: Invalid waveform viewer specified. Must be 'verdi' or 'dve'."
    exit 1
fi

if [[ "$COVERAGE_MERGE_TOOL" != "vcs" && "$COVERAGE_MERGE_TOOL" != "verdi" ]]; then
    echo "ERROR: Invalid coverage merge tool specified. Must be 'vcs' or 'verdi'."
    exit 1
fi

# Create log directory
mkdir -p "$LOG_DIR"
log "Starting regression test suite"
log "Using makefile: $MAKEFILE"
log "Waveform viewer: $WAVEFORM_VIEWER"
log "Coverage merge tool: $COVERAGE_MERGE_TOOL"

# Interactive tool selection
if $INTERACTIVE; then
    echo "Would you like to select a different waveform viewer? [verdi/dve/no] (default: $WAVEFORM_VIEWER): "
    read viewer_choice
    if [[ "$viewer_choice" == "verdi" || "$viewer_choice" == "dve" ]]; then
        WAVEFORM_VIEWER="$viewer_choice"
        log "Changed waveform viewer to: $WAVEFORM_VIEWER"
    fi
    
    echo "Would you like to select a different coverage merge tool? [vcs/verdi/no] (default: $COVERAGE_MERGE_TOOL): "
    read coverage_choice
    if [[ "$coverage_choice" == "vcs" || "$coverage_choice" == "verdi" ]]; then
        COVERAGE_MERGE_TOOL="$coverage_choice"
        log "Changed coverage merge tool to: $COVERAGE_MERGE_TOOL"
    fi
fi

# Clean environment
log "Cleaning environment"
run_cmd "make -f $MAKEFILE clean"

# Run tests
log "Running random_test"
run_cmd "make -f $MAKEFILE TEST_NAME=random_test full-sim"

log "Running repiition_test"
run_cmd "make -f $MAKEFILE TEST_NAME=repiition_test full-sim"

log "Running error_test"
run_cmd "make -f $MAKEFILE TEST_NAME=error_test full-sim"

# Generate reports with specified tools
log "Generating coverage reports using $COVERAGE_MERGE_TOOL for merging"
run_cmd "make -f $MAKEFILE TEST_NAME1=random_test TEST_NAME2=repitition_test TEST_NAME3=error_test COVERAGE_MERGE_TOOL=$COVERAGE_MERGE_TOOL generate-reports"

# Optionally view a waveform if in interactive mode
if $INTERACTIVE; then
    echo "Would you like to view a waveform? [yes/no]: "
    read view_choice
    if [[ "$view_choice" == "yes" || "$view_choice" == "y" ]]; then
        echo "Which test would you like to view? [random_test/repitition_test/error_test]: "
        read test_choice
        run_cmd "make -f $MAKEFILE TEST_NAME=$test_choice WAVEFORM_VIEWER=$WAVEFORM_VIEWER view-waveform"
    fi
    
    echo "Would you like to view coverage results? [yes/no]: "
    read cov_choice
    if [[ "$cov_choice" == "yes" || "$cov_choice" == "y" ]]; then
        echo "Which coverage would you like to view? [valid/error/all]: "
        read cov_type
        case "$cov_type" in
            valid)
                run_cmd "make -f $MAKEFILE view-coverage-valid"
                ;;
            error)
                run_cmd "make -f $MAKEFILE view-coverage-error"
                ;;
            all)
                run_cmd "make -f $MAKEFILE view-coverage-all"
                ;;
            *)
                log "Invalid coverage type selected. Skipping coverage view."
                ;;
        esac
    fi
fi

# Summarize results
log "Regression test suite completed successfully"
log "Log file: $LOG_FILE"

# Extract coverage metrics from reports and display summary
if [ -d "coverage_closure" ]; then
    log "Coverage Summary:"
    # Extract and display coverage metrics
    if [ -f "coverage_closure/valid_tests_cov_merged/overall_coverage.rpt" ]; then
        valid_cov=$(grep "Overall Coverage" coverage_closure/valid_tests_cov_merged/overall_coverage.rpt | awk '{print $3}')
        log "Valid Tests Coverage: $valid_cov"
    fi
    
    if [ -f "coverage_closure/error_injection_cov_merged/overall_coverage.rpt" ]; then
        error_cov=$(grep "Overall Coverage" coverage_closure/error_injection_cov_merged/overall_coverage.rpt | awk '{print $3}')
        log "Error Tests Coverage: $error_cov"
    fi
fi

exit 0