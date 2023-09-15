
//author: Srikanth Vaddepally
//Date: Sep 15th 2023
//Simple synchronous fifo with one write port and one read port
//Designed for simluation purposes

module sync_fifo_1w1r #(
    parameter DATA_WIDTH = 32,
    parameter NDEPTH = 8, //2*n aligned depth
    parameter DEPTH = 8  //any length <= NDEPTH
)
(
    input logic rstn,
    input logic clk,
    input logic push,
    input logic pop,
    input logic [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data,

    output logic full,
    output logic valid 
);

logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

logic [$clog2(NDEPTH):0] wr_ptr;
logic [$clog2(NDEPTH):0] rd_ptr;

logic empty;

assign valid = ~empty;

always_comb begin : empty_full
    full = 0;
    empty = 0;
    if(wr_ptr[$clog2(NDEPTH)-1:0] == rd_ptr[$clog2(NDEPTH)-1:0]) begin
        if(wr_ptr[$clog2(NDEPTH)] == rd_ptr[$clog2(NDEPTH)]) begin
            empty = 1;
        end
        else begin
            full = 1;
        end
    end
end

always@(posedge clk) begin : wr_ptr_p
    if(~rstn)
        wr_ptr <= 0;
    else if(push) begin
        if(DEPTH < NDEPTH) begin
            if(wr_ptr[$clog2(NDEPTH)-1:0]+1 == DEPTH)
                wr_ptr <= wr_ptr+(NDEPTH-DEPTH+1); //wrap
            else 
                wr_ptr <= wr_ptr+1;
        end
        else begin
            wr_ptr <= wr_ptr+1;
        end
    end
end

always@(posedge clk) begin : rd_ptr_p
    if(~rstn)
        rd_ptr <= 0;
    else if(push) begin
        if(DEPTH < NDEPTH) begin
            if(rd_ptr[$clog2(NDEPTH)-1:0]+1 == DEPTH)
                rd_ptr <= rd_ptr+(NDEPTH-DEPTH+1); //wrap
            else 
                rd_ptr <= rd_ptr+1;
        end
        else begin
            rd_ptr <= rd_ptr+1;
        end
    end
end

fifo_push_when_full:assert property(@(posedge clk) ~(full&push));
fifo_pop_when_empty:assert property(@(posedge clk) ~(empty&pop));

endmodule