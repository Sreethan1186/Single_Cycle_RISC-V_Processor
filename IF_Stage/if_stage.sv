module if_stage(
    input  logic        clk,                 // Clock signal
    input  logic        reset,               // Asynchronous active-high reset
    input  logic        stall,               // Stall signal to hold the PC
    input  logic        and_out,              // Selects branch/jump target
    input  logic [31:0] pc_signed_offset,     // Branch/jump target address

    output logic [31:0] address,              // Current program counter
    output logic [31:0] pc_new                // Next sequential PC (PC + 4)
);

    logic [31:0] next_pc;

    // Calculate PC + 4
    assign pc_new = address + 32'd4;

    // Select the next PC
    always_comb begin
        if (and_out)
            next_pc = pc_signed_offset;
        else
            next_pc = pc_new;
    end

    // Program Counter with asynchronous reset and stall support
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            address <= 32'h8000_0000;
        else if (!stall)
            address <= next_pc;
    end

endmodule


