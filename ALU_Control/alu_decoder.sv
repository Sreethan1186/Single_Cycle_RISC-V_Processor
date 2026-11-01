module alu_control(
    input  logic [2:0] alu_op,       // Operation class from Main Control
    input  logic [2:0] fn3,          // Instruction function field [14:12]
    input  logic [6:0] imm11_5,      // Instruction bits [31:25], I-type shift qualifier
    input  logic       fn7_5,        // Instruction bit [30], R-type SUB/SRA qualifier

    output logic [4:0] control_out   // 5-bit ALU operation control
);

    always_comb begin

        // Default operation is ADD
        control_out = 5'b00000;

        case (alu_op)

            // R-type instructions
            3'b000: begin
                case (fn3)

                    // ADD / SUB
                    3'b000: begin
                        if (fn7_5)
                            control_out = 5'b00001; // SUB
                        else
                            control_out = 5'b00000; // ADD
                    end

                    // SLL
                    3'b001: control_out = 5'b00101;

                    // SLT (signed)
                    3'b010: control_out = 5'b01000;

                    // SLTU (unsigned)
                    3'b011: control_out = 5'b01001;

                    // XOR
                    3'b100: control_out = 5'b00010;

                    // SRL / SRA
                    3'b101: begin
                        if (fn7_5)
                            control_out = 5'b00111; // SRA
                        else
                            control_out = 5'b00110; // SRL
                    end

                    // OR
                    3'b110: control_out = 5'b00011;

                    // AND
                    3'b111: control_out = 5'b00100;

                    default: control_out = 5'b00000;

                endcase
            end

            // I-type arithmetic and logical instructions
            3'b001: begin
                case (fn3)

                    // ADDI
                    3'b000: control_out = 5'b00000;

                    // SLLI
                    3'b001: control_out = 5'b00101;

                    // SLTI
                    3'b010: control_out = 5'b01000;

                    // SLTIU
                    3'b011: control_out = 5'b01001;

                    // XORI
                    3'b100: control_out = 5'b00010;

                    // SRLI / SRAI
                    3'b101: begin
                        if (imm11_5 == 7'h20)
                            control_out = 5'b00111; // SRAI
                        else
                            control_out = 5'b00110; // SRLI
                    end

                    // ORI
                    3'b110: control_out = 5'b00011;

                    // ANDI
                    3'b111: control_out = 5'b00100;

                    default: control_out = 5'b00000;

                endcase
            end

            // Load instructions: address calculation uses ADD
            3'b010: begin
                control_out = 5'b00000;
            end

            // Store instructions: address calculation uses ADD
            3'b011: begin
                control_out = 5'b00000;
            end

            // Branch instructions
            3'b100: begin
                case (fn3)

                    // BEQ
                    3'b000: control_out = 5'b01010;

                    // BNE
                    3'b001: control_out = 5'b01011;

                    // BLT (signed)
                    3'b100: control_out = 5'b01100;

                    // BGE (signed)
                    3'b101: control_out = 5'b01101;

                    // BLTU (unsigned)
                    3'b110: control_out = 5'b01110;

                    // BGEU (unsigned)
                    3'b111: control_out = 5'b01111;

                    // Unsupported branch function defaults to ADD
                    default: control_out = 5'b00000;

                endcase
            end

            // JAL / LUI operation class: ADD
            3'b110: begin
                control_out = 5'b00000;
            end

            // Unsupported operation classes default to ADD
            default: begin
                control_out = 5'b00000;
            end

        endcase
    end

endmodule


