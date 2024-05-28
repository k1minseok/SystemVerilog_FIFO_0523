`ifndef __INTERFACE_SV_     // define 중복 방지 macro
`define __INTERFACE_SV_

`timescale 1ns / 1ps

interface fifo_interface;
    logic       clk;
    logic       reset;

    logic       wr_en;
    logic       full;
    logic [7:0] wdata;

    logic       rd_en;
    logic       empty;
    logic [7:0] rdata;
endinterface

`endif