module main_control(
    input  logic [6:0] opcode,       // Instruction opcode
    input  logic [2:0] fn3,          // Instruction function field

    output logic [1:0] memtoreg,     // Writeback data selector
    output logic       branch,       // Conditional branch enable
    output logic       mux_inp,      // JALR target selection
    output logic       memread,      // Data memory read enable
    output logic       memwrite,     // Data memory write enable
    output logic       alusrc,       // ALU second operand selector
    output logic       reg_write,    // Register file write enable
    output logic [2:0] aluop         // ALU operation class
);

    always_comb begin

        // Default control values
        memtoreg  = 2'b00;
        branch    = 1'b0;
        mux_inp   = 1'b0;
        memread   = 1'b0;
        memwrite  = 1'b0;
        alusrc    = 1'b0;
        reg_write = 1'b0;
        aluop     = 3'b000;

        case (opcode)

            // R-type
            7'b0110011: begin
                reg_write = 1'b1;
                aluop     = 3'b000;
            end

            // I-type ALU
            7'b0010011: begin
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b001;
            end

            // Load
            7'b0000011: begin
                memtoreg  = 2'b01;
                memread   = 1'b1;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b010;
            end

            // Store
            7'b0100011: begin
                memtoreg = 2'b11;
                memwrite = 1'b1;
                alusrc   = 1'b1;
                aluop    = 3'b011;
            end

            // Branch
            7'b1100011: begin
                branch = 1'b1;
                aluop  = 3'b100;
            end

            // JAL
            7'b1101111: begin
                memtoreg  = 2'b10;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b110;
            end

            // JALR
            7'b1100111: begin
                memtoreg  = 2'b10;
                mux_inp   = 1'b1;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b001;
            end

            // LUI
            7'b0110111: begin
                memtoreg  = 2'b10;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b110;
            end

            // AUIPC
            7'b0010111: begin
                memtoreg  = 2'b10;
                alusrc    = 1'b1;
                reg_write = 1'b1;
                aluop     = 3'b000;
            end

            // Unsupported instruction
            default: begin
                memtoreg  = 2'b00;
                branch    = 1'b0;
                mux_inp   = 1'b0;
                memread   = 1'b0;
                memwrite  = 1'b0;
                alusrc    = 1'b0;
                reg_write = 1'b0;
                aluop     = 3'b000;
            end

        endcase
    end

endmodule


