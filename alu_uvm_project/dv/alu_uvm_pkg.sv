package alu_uvm_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

  //---------------------------------------
  // ALU BUS WIDTHS
  //---------------------------------------
  parameter INPUT_WIDTH   = 5;
  parameter OUTPUT_WIDTH  = 6;
  parameter A_OP_WIDTH    = 3;
  parameter B_OP_WIDTH    = 2;
  parameter CLK_PERIOD    = 5;

  //---------------------------------------
  // ALU Operation Mode ENUM
  //---------------------------------------
  typedef enum {
    MODE_IDLE,  // No operation mode (when both a_en and b_en are 0)
    MODE_A,     // Operation set A (when a_en = 1, b_en = 0)
    MODE_B01,    // Operation set B1 (when a_en = 0, b_en = 1)
    MODE_B11     // Operation set B2 (when a_en = 1, b_en = 1)
  } OP_MODE_t;

  //---------------------------------------
  // ALU Device State ENUM
  //---------------------------------------
  typedef enum {
    ALU_OFF,    // ALU is disabled (when ALU_en = 0)
    ALU_ON      // ALU is enabled (when ALU_en = 1)
  } ALU_EN_STATE_t;

  //---------------------------------------
  // Op A ENUM
  //---------------------------------------
  typedef enum bit [2:0] {
    A_ADD   ,
    A_SUB   ,
    A_XOR   ,
    A_AND1  ,
    A_AND2  ,
    A_OR    ,
    A_XNOR  ,
    A_NULL  
  } OP_A_t;

  //---------------------------------------
  // Op B1 ENUM (Set 1)
  //---------------------------------------
  typedef enum bit [1:0] {
    B01_NAND  ,
    B01_ADD1  ,
    B01_ADD2  ,
    B01_NULL  
  } OP_B01_t;

  //---------------------------------------
  // Op B2 ENUM (Set 2)
  //---------------------------------------
  typedef enum bit [1:0] {
    B11_XOR     ,
    B11_XNOR    ,
    B11_A_SUB_1 ,
    B11_B_ADD_2 
  } OP_B11_t;

import rst_uvm_pkg::*;

`include "test_cfg.sv"
`include "env_cfg.sv"

/************************************
***********Sequence Items********
************************************/
// `include "rst_seq_item.sv"
`include "sequence_item.sv"
`include "error_sequence_item.sv"

// `include "rst_driver.sv"
// `include "rst_monitor.sv"
// `include "rst_sequencer.sv"


/************************************
**********ALU Agent Components*******
************************************/
`include "alu_driver.sv"
`include "alu_monitor_in.sv"
`include "alu_monitor_out.sv"
`include "alu_sequencer.sv"

/************************************
*************Agents Configs**********
************************************/
`include "alu_agnt_cfg.sv"
// `include "rst_agnt_cfg.sv"

/************************************
********Environment Components******
************************************/
// `include "rst_agent.sv"

/************************************
********Scoreboard Components********
************************************/
`include "alu_agent.sv"
`include "comparator.sv"
`include "predictor.sv"

`include "scoreboard.sv"
`include "subscriber.sv"

/************************************
**********Virtual Sequencer**********
************************************/
`include "v_sequencer.sv"

/************************************
************Test Components*********
************************************/

`include "env.sv"

/************************************
***************Sequences************
************************************/
`include "rst_sequence.sv"
`include "random_sequence.sv"
`include "repitition_sequence.sv"
`include "error_sequence.sv"

/************************************
***********Virtual Sequences********
************************************/



`include "base_v_seq.sv"
`include "random_v_seq.sv"
`include "repi_v_seq.sv"
`include "error_v_seq.sv"

/************************************
****************Tests****************
************************************/
`include "base_test.sv"
`include "random_test.sv"
`include "repitition_test.sv"
`include "error_test.sv"

endpackage : alu_uvm_pkg