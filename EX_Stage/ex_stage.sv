module ex_stage(
    // Inputs from the decode stage
    input  logic [31:0] rs1_data,        // First register operand
    input  logic [31:0] rs2_data,        // Second register operand
    input  logic [31:0] imm_out,         // Generated immediate
    input  logic [31:0] address,         // Current program counter

    // Control signals from the decode stage
    input  logic        branch,          // Conditional branch flag
    input  logic        alu_src,         // ALU source select
    input  logic        fn7_5,           // Instruction bit [30]
    input  logic        mux_inp,         // JALR selection signal
    input  logic [2:0]  fn3,             // Function field
    input  logic [6:0]  imm11_5,         // Instruction bits [31:25]
    input  logic [2:0]  aluop,           // ALU operation selector
    input  logic [6:0]  opcode,          // Instruction opcode

    // Outputs
    output logic        and_out_ex,      // Branch/jump decision
    output logic [31:0] alu_out,         // ALU result
    output logic [31:0] pc_ex_out        // Branch/jump target address
);

    logic [31:0] alu_operand2;
    logic [4:0] control_out;
    logic zero;

    // Select the second ALU operand
    always_comb begin
        if (alu_src)
            alu_operand2 = imm_out;
        else
            alu_operand2 = rs2_data;
    end

    // Generate ALU control signals
    alu_control alu_control_unit(
        .alu_op(aluop),
        .fn3(fn3),
        .imm11_5(imm11_5),
        .fn7_5(fn7_5),
        .control_out(control_out)
    );

    // Instantiate the ALU
    alu #(
        .DATA_WIDTH(32)
    ) alu_unit(
        .alu_control(control_out),
        .rs1_data(rs1_data),
        .rs2_data(alu_operand2),
        .alu_out(alu_out),
        .zero(zero)
    );

    // Calculate branch/jump target address
    always_comb begin
        if (mux_inp)
            pc_ex_out = {alu_out[31:1], 1'b0};
        else
            pc_ex_out = address + imm_out;
    end

    // Generate branch/jump decision
    always_comb begin
        and_out_ex = (branch && zero) ||
                     (opcode == 7'h6F) ||
                     (opcode == 7'h67);
    end

endmodule


