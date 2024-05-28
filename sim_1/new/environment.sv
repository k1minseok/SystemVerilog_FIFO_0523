`timescale 1ns / 1ps

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "interface.sv"


  class environment;  // OOP AP_main같은 느낌...(각 class 인스턴스화, 초기화, task 실행)
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    event                  gen_next_event;

    function new(virtual fifo_interface fifo_intf);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, fifo_intf);
        mon = new(mon2scb_mbox, fifo_intf);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction


    task report();
        $display("=============================");
        $display("==       Final Report      ==");
        $display("=============================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("Write Count : %d", scb.write_cnt);
        $display("FULL Count : %d", scb.full_cnt);
        $display("EMPTY Count : %d", scb.empty_cnt);
        $display("=============================");
        $display("== test bench is finished! ==");
        $display("=============================");
    endtask


    task pre_run();
        drv.reset();
    endtask

    task run(int count);
        fork
            gen.run(count);
            drv.run();
            mon.run();
            scb.run();
        join_any

        report();
        #10 $finish;
    endtask

    task run_test(int count);
        pre_run();
        run(count);
    endtask
endclass