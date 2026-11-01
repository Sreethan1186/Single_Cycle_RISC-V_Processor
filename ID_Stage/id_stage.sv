module id_stage(
    input  logic        clk,           // Clock signal
    input  logic        reset,         // Asynchronous active-high reset
    input  logic        stall,         // Stall signal
    input  logic [31:0] instruction,   // Instruction from instruction memory
    input  logic [31:0] wb_data,       // Writeback data from WB stage

    output logic [31:0] rs1_data,      // First source register data
    output logic [31:0] rs2_data,      // Second source register data
    output logic [31:0] imm_out,       // Generated 32-bit immediate

    output logic [6:0]  opcode_out_d,  // Decoded instruction opcode
    output logic [6:0]  imm11_5,       // Instruction bits [31:25]
    output logic [2:0]  fn3_out_d,     // Instruction function field
    output logic        fn7_5,         // Instruction bit [30]

    output logic [2:0]  aluop,         // ALU operation class
    output logic [1:0]  memtoreg,      // Writeback data selection
    output logic        branch,        // Conditional branch control
    output logic        mem_write,     // Data memory write enable
    output logic        mem_read,      // Data memory read enable
    output logic        alu_src,       // ALU second operand selection
    output logic        mux_inp        // JALR target selection
);

    // Internal decoded register addresses
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    // Internal immediate fields from the decoder
    logic [11:0] imm;
    logic [19:0] imm_uj;

    // Internal register write enable from Main Control
    logic reg_write;

    // ------------------------------------------------
    // Instruction Decoder
    // Extracts register addresses, opcode and immediates
    // ------------------------------------------------
    decoder instruction_decoder(
        .instruction(instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .opcode(opcode_out_d),
        .imm11_5(imm11_5),
        .fn3(fn3_out_d),

        .imm(imm),
        .imm_uj(imm_uj),

        .fn7_5(fn7_5)
    );

    // ------------------------------------------------
    // Immediate Generator
    // Converts decoded immediate fields into 32 bits
    // ------------------------------------------------
    imm_generator immediate_generator(
        .imm_input(imm),
        .fn3(fn3_out_d),
        .opcode(opcode_out_d),
        .imm_input_uj(imm_uj),

        .imm_output(imm_out)
    );

    // ------------------------------------------------
    // Main Control Unit
    // Generates datapath control signals from opcode
    // ------------------------------------------------
    main_control main_control_unit(
        .opcode(opcode_out_d),
        .fn3(fn3_out_d),

        .memtoreg(memtoreg),
        .branch(branch),
        .mux_inp(mux_inp),
        .memread(mem_read),
        .memwrite(mem_write),
        .alusrc(alu_src),
        .reg_write(reg_write),
        .aluop(aluop)
    );

    // ------------------------------------------------
    // Register File
    // Reads rs1 and rs2 and writes back to rd
    // Register write is disabled during a stall
    // ------------------------------------------------
    regfile register_file(
        .clk(clk),
        .reset(reset),
        .we3(reg_write && !stall),
        .a1(rs1),
        .a2(rs2),
        .a3(rd),
        .wd3(wb_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

endmodule


