module regfile(
    input  logic        clk,       // Clock signal
    input  logic        reset,     // Asynchronous active-high reset
    input  logic        we3,       // Register write enable
    input  logic [4:0]  a1,        // First source register address (rs1)
    input  logic [4:0]  a2,        // Second source register address (rs2)
    input  logic [4:0]  a3,        // Destination register address (rd)
    input  logic [31:0] wd3,       // Data to be written into register

    output logic [31:0] rd1,       // First register read data
    output logic [31:0] rd2        // Second register read data
);

    // 32 registers, each 32 bits wide
    logic [31:0] rf [0:31];

    integer i;

    // ------------------------------------------------
    // Sequential write operation and asynchronous reset
    // ------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            // Clear all 32 registers asynchronously
            for (i = 0; i < 32; i = i + 1) begin
                rf[i] <= 32'b0;
            end

        end

        else begin

            // Write only when enabled and destination is not x0
            if (we3 && (a3 != 5'd0)) begin
                rf[a3] <= wd3;
            end

        end

    end

    // ------------------------------------------------
    // Combinational read operation
    // Register x0 always returns zero
    // ------------------------------------------------
    always_comb begin

        // First read port
        if (a1 == 5'd0)
            rd1 = 32'b0;
        else
            rd1 = rf[a1];

        // Second read port
        if (a2 == 5'd0)
            rd2 = 32'b0;
        else
            rd2 = rf[a2];

    end

endmodule


