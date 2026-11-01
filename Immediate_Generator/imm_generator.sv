module imm_generator(
    input  logic [11:0] imm_input,       // 12-bit immediate from decoder
    input  logic [2:0]  fn3,             // Function field
    input  logic [6:0]  opcode,          // Opcode of the instruction
    input  logic [19:0] imm_input_uj,    // 20-bit U/J immediate

    output logic [31:0] imm_output      // Generated 32-bit immediate
);

    always_comb begin

        // Default immediate
        imm_output = 32'b0;

        case (opcode)

            // Branch instructions
            7'b1100011: begin
                imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};
            end

            // JAL instruction
            7'b1101111: begin
                imm_output = {{11{imm_input_uj[19]}}, imm_input_uj, 1'b0};
            end

            // LUI and AUIPC instructions
            7'b0110111,
            7'b0010111: begin
                imm_output = {imm_input_uj, 12'b0};
            end

            // JALR instruction
            7'b1100111: begin
                imm_output = {{20{imm_input[11]}}, imm_input};
            end

            // I-type arithmetic and logical instructions
            7'b0010011: begin
                if ((fn3 == 3'b001) || (fn3 == 3'b101))
                    imm_output = {27'b0, imm_input[4:0]};
                else
                    imm_output = {{20{imm_input[11]}}, imm_input};
            end

            // Load and store instructions
            default: begin
                imm_output = {{20{imm_input[11]}}, imm_input};
            end

        endcase
    end

endmodule


