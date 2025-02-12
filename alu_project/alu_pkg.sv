package alu_pkg;
	parameter INPUT_WIDTH  = 5;
	parameter OUTPUT_WIDTH = 6;
	parameter A_OFF_B_OFF = 2'b00, A_ON_B_OFF = 2'b10, A_OFF_B_ON = 2'b01, A_ON_B_ON = 2'b11;


	`include "transaction.svh"

	`include "driver.svh"
	`include "inputMonitor.svh"
	`include "outputMonitor.svh"

	`include "predictor.svh"
	`include "comparator.svh"
	`include "scoreboard.svh"
	`include "coverage.svh"

	`include "generator.svh"
	`include "env.svh"
	`include "test.svh"
endpackage