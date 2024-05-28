// `timescale 1ns / 1ps

// `include "transaction.sv"

// class scoreboard;
//     transaction trans;
//     mailbox #(transaction) mon2scb_mbox;
//     event gen_next_event;

//     int total_cnt, pass_cnt, fail_cnt, write_cnt;
//     reg [7:0] scb_fifo[$:7];    // $ == queue(fifo), :8 없이 사용하면 무한대 공간
//     reg [7:0] scb_fifo_data;

//     function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
//         this.mon2scb_mbox   = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;

//         total_cnt           = 0;
//         pass_cnt            = 0;
//         fail_cnt            = 0;
//         write_cnt           = 0;
//     endfunction

//     task run();
//         forever begin
//             mon2scb_mbox.get(trans);
//             trans.display("SCB");

//             if (trans.wr_en) begin
//                 scb_fifo.push_back(trans.wdata);  // 뒤로 push
//                 $display(" ---> WRITE! fifo_data %x, queue size: %x, %p\n",
//                          trans.wdata, scb_fifo.size(), scb_fifo);
//                 write_cnt++;

//             end else if (trans.rd_en) begin
//                 scb_fifo_data = scb_fifo.pop_front();  // 앞에서 pop

//                 if (scb_fifo_data == trans.rdata) begin
//                     $display(" ---> PASS! fifo_data %x == rdata %x, queue size: %x, %p\n",
//                              scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
//                     pass_cnt++;
//                 end else begin
//                     $display(" ---> FAIL! fifo_data %x != rdata %x, queue size: %x, %p\n",
//                              scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
//                     fail_cnt++;
//                 end

//             end
//             total_cnt++;
//             ->gen_next_event;
//         end
//     endtask
// endclass



`timescale 1ns / 1ps

`include "transaction.sv"

class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt, write_cnt;
    reg [7:0] scb_fifo[$];    // 동적 배열 선언
    reg [7:0] scb_fifo_data;
    int max = 8;    // 최대 크기를 8로 설정

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.gen_next_event = gen_next_event;

        total_cnt           = 0;
        pass_cnt            = 0;
        fail_cnt            = 0;
        write_cnt           = 0;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");

            if (trans.wr_en) begin
                if (scb_fifo.size() < max) begin
                    scb_fifo.push_back(trans.wdata);  // 뒤로 push
                    $display(" ---> WRITE! fifo_data %x, queue size: %x, %p\n",
                             trans.wdata, scb_fifo.size(), scb_fifo);
                    write_cnt++;
                end else begin
                    $display(" ---> FIFO FULL! Cannot write data. fifo_data %x, queue size: %x, %p\n",
                             trans.wdata, scb_fifo.size(), scb_fifo);
                end

            end else if (trans.rd_en) begin
                if (scb_fifo.size() > 0) begin
                    scb_fifo_data = scb_fifo.pop_front();  // 앞에서 pop

                    if (scb_fifo_data == trans.rdata) begin
                        $display(" ---> PASS! fifo_data %x == rdata %x, queue size: %x, %p\n",
                                 scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
                        pass_cnt++;
                    end else begin
                        $display(" ---> FAIL! fifo_data %x != rdata %x, queue size: %x, %p\n",
                                 scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
                        fail_cnt++;
                    end
                end else begin
                    $display(" ---> FIFO EMPTY! Cannot read data.");
                end

            end
            total_cnt++;
            ->gen_next_event;
        end
    endtask
endclass
