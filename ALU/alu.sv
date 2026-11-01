module alu #(
    parameter int DATA_WIDTH = 32
)(
    input  logic [4:0]              alu_control, // ALU operation control
    input  logic [DATA_WIDTH-1:0]   rs1_data,    // First operand
    input  logic [DATA_WIDTH-1:0]   rs2_data,    // Second operand

    output logic [DATA_WIDTH-1:0]   alu_out,     // ALU result
    output logic                   zero         // Branch comparison result
);

    always_comb begin

        // Default outputs
        alu_out = '0;
        zero    = 1'b0;

        case (alu_control)

            // ADD: rs1 + rs2
            5'b00000: begin
                alu_out = rs1_data + rs2_data;
            end

            // SUB: rs1 - rs2
            5'b00001: begin
                alu_out = rs1_data - rs2_data;
            end

            // XOR
            5'b00010: begin
                alu_out = rs1_data ^ rs2_data;
            end

            // OR
            5'b00011: begin
                alu_out = rs1_data | rs2_data;
            end

            // AND
            5'b00100: begin
                alu_out = rs1_data & rs2_data;
            end

            // SLL: Shift left logical
            5'b00101: begin
                alu_out = rs1_data << rs2_data[4:0];
            end

            // SRL: Shift right logical
            5'b00110: begin
                alu_out = rs1_data >> rs2_data[4:0];
            end

            // SRA: Shift right arithmetic
            5'b00111: begin
                alu_out = $signed(rs1_data) >>> rs2_data[4:0];
            end

            // SLT: Set less than (signed)
            5'b01000: begin
                alu_out = ($signed(rs1_data) < $signed(rs2_data)) ? 32'd1 : 32'd0;
            end

            // SLTU: Set less than (unsigned)
            5'b01001: begin
                alu_out = (rs1_data < rs2_data) ? 32'd1 : 32'd0;
            end

            // BEQ: Branch if equal
            5'b01010: begin
                zero = (rs1_data == rs2_data);
            end

            // BNE: Branch if not equal
            5'b01011: begin
                zero = (rs1_data != rs2_data);
            end

            // BLT: Branch if less than (signed)
            5'b01100: begin
                zero = ($signed(rs1_data) < $signed(rs2_data));
            end

            // BGE: Branch if greater than or equal (signed)
            5'b01101: begin
                zero = ($signed(rs1_data) >= $signed(rs2_data));
            end

            // BLTU: Branch if less than (unsigned)
            5'b01110: begin
                zero = (rs1_data < rs2_data);
            end

            // BGEU: Branch if greater than or equal (unsigned)
            5'b01111: begin
                zero = (rs1_data >= rs2_data);
            end

            // Unsupported operation
            default: begin
                alu_out = '0;
                zero    = 1'b0;
            end

        endcase
    end

endmodule


