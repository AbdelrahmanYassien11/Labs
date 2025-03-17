package alu_pkg;

	import base_classes_pkg::*;

	`include "config/alu_config.svh"
	alu_config alu_cfg = new();


	//parameter INPUT_WIDTH  	= alu_cfg.INPUT_WIDTH;
	//parameter OUTPUT_WIDTH 	= alu_cfg.OUTPUT_WIDTH;
	//parameter A_OP_WIDTH 		= alu_cfg.A_OP_WIDTH;
	//parameter B_OP_WIDTH 		= alu_cfg.B_OP_WIDTH;
	//parameter EN_WIDTH 		= alu_cfg.EN_WIDTH;
	// parameter CLK_PERIOD 	= alu_cfg.CLK_PERIOD;

	parameter INPUT_WIDTH = 5;
	parameter OUTPUT_WIDTH = 6;
	parameter A_OP_WIDTH  = 3;
	parameter B_OP_WIDTH  = 2;
 	parameter CLK_PERIOD  = 5;
	//parameter EN_WIDTH = 0;
	parameter A_OFF_B_OFF 	= 2'b00, A_ON_B_OFF = 2'b10, A_OFF_B_ON = 2'b01, A_ON_B_ON = 2'b11;

	typedef enum {RANDOM, RANDOM_ERROR_INJECTION, RANDOM_RESET_THRICE} TEST_TYPE;

	`include "transaction_base.svh"

	`include "transaction.svh"

	`include "driver.svh"
	`include "inputMonitor.svh"
	`include "outputMonitor.svh"

	`include "predictor.svh"
	`include "comparator.svh"
	`include "scoreboard.svh"
	`include "coverage.svh"

	`include "reset_generator.svh"
	`include "error_injection_generator.svh"
	`include "random_reset_thrice_generator.svh"
	`include "random_generator.svh"

	`include "env.svh"

	`include "random_test.svh"
	`include "random_error_injection_test.svh"
	`include "random_reset_thrice_test.svh"
endpackage