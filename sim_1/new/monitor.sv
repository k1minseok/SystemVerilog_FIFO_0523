`timescale 1ns / 1ps

`include "transaction.sv"
`include "interface.sv"

class monitor;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    virtual fifo_interface fifo_intf;

    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual fifo_interface fifo_intf);
        this.mon2scb_mbox = mon2scb_mbox;
        this.fifo_intf = fifo_intf;
    endfunction

    task run();
        forever begin
            trans       = new();
            #1;
            trans.wr_en = fifo_intf.wr_en;
            trans.rd_en = fifo_intf.rd_en;
            trans.wdata = fifo_intf.wdata;
            trans.rdata = fifo_intf.rdata;  //??

            @(posedge fifo_intf.clk);
            trans.full  = fifo_intf.full;
            trans.empty = fifo_intf.empty;

            mon2scb_mbox.put(trans);
            trans.display("MON");
        end
    endtask
endclass
