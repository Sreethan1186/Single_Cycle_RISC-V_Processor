module decoder(
    input  logic [31:0] instruction,  // 32-bit instruction from instruction memory

    output logic [4:0]  rs1,           // First source register address
    output logic [4:0]  rs2,           // Second source register address
    output logic [4:0]  rd,            // Destination register address
    output logic [6:0]  opcode,        // Instruction opcode [6:0]
    output logic [6:0]  imm11_5,      // Instruction bits [31:25], I-type ALU only
    output logic [2:0]  fn3,           // Function field [14:12]
    output logic [11:0] imm,           // I-type, S-type and B-type immediate
    output logic [19:0] imm_uj,        // U-type and J-type immediate
    output logic        fn7_5          // Instruction bit [30], R-type only
);

    always_comb begin

        // Default values for all decoded fields
        rs1     = 5'b0;
        rs2     = 5'b0;
        rd      = 5'b0;
        opcode  = instruction[6:0];
        imm11_5 = 7'b0;
        fn3     = 3'b0;
        imm     = 12'b0;
        imm_uj  = 20'b0;
        fn7_5   = 1'b0;

        case (instruction[6:0])

            // R-type instructions: ADD, SUB, shifts, logical and comparison
            7'b0110011: begin
                rd    = instruction[11:7];
                fn3   = instruction[14:12];
                rs1   = instruction[19:15];
                rs2   = instruction[24:20];
                fn7_5 = instruction[30];
            end

            // I-type ALU instructions: ADDI, SLTI, XORI, ORI, ANDI, shifts
            7'b0010011: begin
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                imm     = instruction[31:20];
                imm11_5 = instruction[31:25];
            end

            // Load instructions: LB, LH, LW, LBU, LHU
            7'b0000011: begin
                rd  = instruction[11:7];
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                imm = instruction[31:20];
            end

            // Store instructions: SB, SH, SW
            7'b0100011: begin
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                imm = {instruction[31:25], instruction[11:7]};
            end

            // Branch instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                imm = {
                    instruction[31],
                    instruction[7],
                    instruction[30:25],
                    instruction[11:8]
                };
            end

            // JAL instruction
            7'b1101111: begin
                rd = instruction[11:7];
                imm_uj = {
                    instruction[31],
                    instruction[19:12],
                    instruction[20],
                    instruction[30:21]
                };
            end

            // JALR instruction
            7'b1100111: begin
                rd  = instruction[11:7];
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                imm = instruction[31:20];
            end

            // LUI instruction
            7'b0110111: begin
                rd     = instruction[11:7];
                imm_uj = instruction[31:12];
            end

            // AUIPC instruction
            7'b0010111: begin
                rd     = instruction[11:7];
                imm_uj = instruction[31:12];
            end

            // Unsupported instruction: all fields except opcode remain zero
            default: begin
                rs1     = 5'b0;
                rs2     = 5'b0;
                rd      = 5'b0;
                imm11_5 = 7'b0;
                fn3     = 3'b0;
                imm     = 12'b0;
                imm_uj  = 20'b0;
                fn7_5   = 1'b0;
            end

        endcase
    end

endmodule


