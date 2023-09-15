
//author: Srikanth Vaddepally
//Date: Sep 15th 2023
//Simple synchronous fifo with one write port and one read port
//Designed for simluation purposes

// this duplicate module file is to support icarus verilog simulator
// which doesnt support 'bit part select in always_*' and 'assertions'

module sync_fifo_1w1r #(
    parameter DATA_WIDTH = 32,
    parameter NDEPTH = 8, //rounding to 2*n aligned depth
    parameter DEPTH = 8  //any length <= NDEPTH
)
(
    input rstn,
    input clk,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] wr_data,
    output [DATA_WIDTH-1:0] rd_data,
    
    output logic full,
    output valid 
);

logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

logic [$clog2(NDEPTH)-1:0] wr_ptr;
logic [$clog2(NDEPTH)-1:0] rd_ptr;

logic empty;
logic wwrap;
logic rwrap;

assign valid = ~empty;

always_comb begin : empty_full
    full = 0;
    empty = 0;
    if(wr_ptr == rd_ptr) begin
        if(rwrap == wwrap) begin
            empty = 1;
        end
        else begin
            full = 1;
        end
    end
end

always@(posedge clk) begin : wr_ptr_p
    if(~rstn) begin
        wr_ptr <= 0;
        wwrap <= 0;
    end
    else if(push) begin
        if(DEPTH < NDEPTH) begin
            if(wr_ptr+1 == DEPTH)
                {wwrap,wr_ptr} <= {wwrap,wr_ptr}+(NDEPTH-DEPTH+1); //wrap
            else 
                {wwrap,wr_ptr} <= {wwrap,wr_ptr}+1;
        end
        else begin
            {wwrap,wr_ptr} <= {wwrap,wr_ptr}+1;
        end
    end
end

always@(posedge clk) begin : rd_ptr_p
    if(~rstn) begin
        rd_ptr <= 0;
        rwrap <= 0;
    end
    else if(pop) begin
        if(DEPTH < NDEPTH) begin
            if(rd_ptr+1 == DEPTH)
                {rwrap,rd_ptr} <= {rwrap,rd_ptr}+(NDEPTH-DEPTH+1); //wrap
            else 
                {rwrap,rd_ptr} <= {rwrap,rd_ptr}+1;
        end
        else begin
            {rwrap,rd_ptr} <= {rwrap,rd_ptr}+1;
        end
    end
end

//fifo_push_when_full:assert property(@(posedge clk) ~(full&push));
//fifo_pop_when_empty:assert property(@(posedge clk) ~(empty&pop));

always @(posedge clk) begin
    if(~(full&push))
      $error("fifo_push_when_full");
    if(~(empty&pop))
      $error("fifo_pop_when_empty");
end

endmodule