// Your code
module CPU(clk,
            rst_n,
            // For mem_D (data memory)
            wen_D,
            addr_D,
            wdata_D,
            rdata_D,
            // For mem_I (instruction memory (text))
            addr_I,
            rdata_I);

    input         clk, rst_n ;
    // For mem_D
    output reg       wen_D  ;
    output reg [31:0] addr_D ;
    output reg [31:0] wdata_D;
    input  [31:0] rdata_D;
    // For mem_I
    output [31:0] addr_I ;
    input  [31:0] rdata_I;
    
    //---------------------------------------//
    // Do not modify this part!!!            //
    // Exception: You may change wire to reg //
    reg    [31:0] PC          ;              //
    reg   [31:0] PC_nxt      ;              //
    reg          regWrite    ;              //
    wire   [ 4:0] rs1, rs2, rd;              //
    wire   [31:0] rs1_data    ;              //
    wire   [31:0] rs2_data    ;              //
    reg   [31:0] rd_data     ;              //
    //---------------------------------------//

    // Todo: other wire/reg
    wire [6:0] opcode, funct7;
    wire [2:0] funct3;
    wire [11:0] imm12;
    wire signed [31:0] imm_signed, offset, immj, rs1_signed, rs2_signed;
    wire [31:0] immu, imms;
    wire ready;
    reg valid, first;
    reg [3:0] mode;
    wire [63:0] out_muldiv;

    //---------------------------------------//
    // Do not modify this part!!!            //
    reg_file reg0(                           //
        .clk(clk),                           //
        .rst_n(rst_n),                       //
        .wen(regWrite),                      //
        .a1(rs1),                            //
        .a2(rs2),                            //
        .aw(rd),                             //
        .d(rd_data),                         //
        .q1(rs1_data),                       //
        .q2(rs2_data));                      //
    //---------------------------------------//
// clk, rst_n, valid, ready, mode, in_A, in_B, out
    mulDiv muldiv0(                           
        .clk(clk),                           
        .rst_n(rst_n),                       
        .valid(valid),                      
        .ready(ready),                            
        .mode(mode),                            
        .in_A(rs1_data), 
        .in_B(rs2_data),                            
        .out(out_muldiv));                         

// Todo: any combinational/sequential circuit
    assign rs1 = rdata_I[19:15];
    assign rs2 = rdata_I[24:20];
    assign rd = rdata_I[11:7];
    assign opcode = rdata_I[6:0];
    assign funct3 = rdata_I[14:12];
    assign funct7 = rdata_I[31:25];
    assign imm12 = rdata_I[31:20];
    assign immu = rdata_I[31:12];
    assign imm_signed = {{20{imm12[11]}}, imm12}; //I-type
    assign offset = {{20{rdata_I[31]}}, rdata_I[7], rdata_I[30:25], rdata_I[11:8], 1'b0}; // B-type
    assign immj = {{12{rdata_I[31]}}, rdata_I[19:12], rdata_I[20], rdata_I[30:21], 1'b0}; // J-tyoe
    assign imms = {{20{rdata_I[31]}}, rdata_I[31:25], rdata_I[11:7]};
    assign addr_I = PC;
    assign rs1_signed = rs1_data;
    assign rs2_signed = rs2_data;


// Decoder
    always @(*) begin
        if (opcode == 7'd35) begin //sw, write mem
            wen_D = 1'b1;
        end
        else begin
            wen_D = 1'b0;
        end
    end

    always @(*) begin
        if (opcode == 7'd35) begin //sw, write mem
            wdata_D = rs2_data;
        end
        else begin
            wdata_D = 1'b0;
        end
    end

    always @(*) begin //mem's addr
        if (opcode == 7'd3) begin 
            addr_D = rs1_data + imm_signed;
        end
        else if (opcode == 7'd35)begin
            addr_D = rs1_data + imms;
        end
        else begin
            addr_D = 32'd0;
        end
    end

    always @(*) begin //write register
        if (rd == 0) begin 
            regWrite = 1'b0; // just read
        end
        else begin
            case(opcode)
                7'd3: regWrite = 1'b1;
                7'd35: regWrite = 1'b0;
                7'd51: begin
                    if (funct7[0]) begin
                        regWrite = ready ? 1'b1 : 1'b0;
                    end
                    else begin
                        regWrite = 1'b1;
                    end
                end
                7'd19: regWrite = 1'b1;
                7'd111: regWrite = 1'b1;
                7'd103: regWrite = 1'b1;
                7'd23: regWrite = 1'b1;
                7'd55: regWrite = 1'b1;
                default: regWrite = 1'b0;
            endcase
        end
    end

    always @(*) begin
        if (opcode == 7'd51 && funct7[0]) begin //mode setting
            case(funct3)
                3'b000: mode = 4'b1001;
                3'b101, 3'b111: mode = 4'b1010;
                default: mode = 4'd0;
            endcase
        end
        else begin
            mode = 1'b0;
        end
    end

    always @(*) begin
        case(opcode)
                7'd3: begin //lw
                    PC_nxt = PC + 32'd4;
                    rd_data = rdata_D;
                end
                7'd35: begin //sw
                    PC_nxt = PC + 32'd4;
                    rd_data = 32'd0;
                end
                7'd51: begin //R-type
                    if (funct7[0]) begin // mul, div
                        case(funct3)
                            3'b000: begin // mul
                                if (ready) begin
                                    rd_data = out_muldiv[31:0];
                                    PC_nxt = PC + 32'd4;
                                end
                                else begin
                                    rd_data = 32'd0;
                                    PC_nxt = PC;
                                end 
                            end 
                            3'b101: begin // div
                                if (ready) begin
                                    rd_data = out_muldiv[31:0];
                                    PC_nxt = PC + 32'd4;
                                end
                                else begin
                                    rd_data = 32'd0;
                                    PC_nxt = PC;
                                end
                            end
                            3'b111: begin // remu
                                if (ready) begin
                                    rd_data = out_muldiv[63:32];
                                    PC_nxt = PC + 32'd4; 
                               end
                               else begin
                                    rd_data = 32'd0;
                                    PC_nxt = PC;
                               end
                            end
                            default: begin
                                PC_nxt = PC + 32'd4;
                                rd_data = 32'd0;
                            end
                        endcase
                    end
                    else begin
                        if (funct7[5])begin// sub
                            rd_data = rs1_data - rs2_data;
                            PC_nxt = PC + 32'd4;
                        end
                        else begin // add                 
                            rd_data = rs1_data + rs2_data;
                            PC_nxt = PC + 32'd4;
                        end
                    end
                end
                7'd19: begin //I-type
                    case(funct3)
                        3'b000: begin //addi
                            rd_data = rs1_data + imm_signed;
                            PC_nxt = PC + 32'd4;
                        end
                        3'b001: begin //slli
                            rd_data = rs1_data << imm12[4:0];
                            PC_nxt = PC + 32'd4;
                        end
                        3'b101: begin
                            if (funct7[6]) begin //srai
                                rd_data = rs1_data >>> imm12[4:0];
                                PC_nxt = PC + 32'd4;
                            end
                            else begin //srli
                                rd_data = rs1_data >> imm12[4:0];
                                PC_nxt = PC + 32'd4;
                            end
                        end
                        3'b010: begin //slti
                            rd_data = (rs1_signed < imm_signed)? 1:0;
                            PC_nxt = PC + 32'd4;
                        end
                        default: begin
                            rd_data = 32'd0;
                            PC_nxt = PC;
                        end
                    endcase
                end
                7'd99: begin //B-type
                    case(funct3)
                        3'b000: begin // beq
                            if (rs1_signed == rs2_signed) begin
                                PC_nxt =  PC + offset;
                                rd_data = 32'd0;
                            end
                            else begin
                               PC_nxt = PC + 32'd4;
                               rd_data = 32'd0;
                            end 
                        end
                        3'b001: begin //bne
                            if (rs1_signed != rs2_signed) begin
                                PC_nxt =  PC + offset;
                                rd_data = 32'd0;
                            end
                            else begin
                               PC_nxt = PC + 32'd4;
                               rd_data = 32'd0;
                            end 
                        end
                        3'b101: begin //bge
                            if (rs1_signed >= rs2_signed) begin
                                PC_nxt =  PC + offset;
                                rd_data = 32'd0;
                            end
                            else begin
                               PC_nxt = PC + 32'd4;
                               rd_data = 32'd0;
                            end 
                        end
                        3'b100: begin //blt
                            if (rs1_signed < rs2_signed) begin
                                PC_nxt =  PC + offset;
                                rd_data = 32'd0;
                            end
                            else begin
                               PC_nxt = PC + 32'd4;
                               rd_data = 32'd0;
                            end 
                        end
                        default: begin
                            PC_nxt = PC;
                            rd_data = 32'd0;
                        end
                    endcase
                end
                7'd111: begin // jal
                    rd_data = PC + 32'd4;
                    PC_nxt = PC + immj;
                end
                7'd103: begin // jalr
                    rd_data = PC + 32'd4;
                    PC_nxt = (rs1_data + imm_signed) & ~1;
                end
                7'd23: begin //auipc
                    rd_data = PC + (immu << 12);
                    PC_nxt = PC + 32'd4;
                end
                7'd55: begin //lui
                    rd_data = immu << 12;
                    PC_nxt = PC + 32'd4;
                end
                default: begin
                    rd_data = 32'd0;
                    PC_nxt = PC;
                end
        endcase
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'h00010000; // Do not modify this value!!!        
        end
        else begin
            PC <= PC_nxt;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 0;
            first <= 0;        
        end
        else if (first)begin
            valid <= 1'b0;
            if (ready) begin
                first <= 0;
            end
            else begin
                first <= 1'b1;
            end
        end 
        else if (opcode == 51 && funct7[0])  begin
            first <= 1'b1;
            valid <= 1'b1;          
        end
        else begin
            valid <= 1'b0;
        end
    end

endmodule

// Do not modify the reg_file!!!
module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);

    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth

    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0] q1, q2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'hbffffff0;
                    32'd3: mem[i] <= 32'h10008000;
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end
    end
endmodule

module mulDiv(clk, rst_n, valid, ready, mode, in_A, in_B, out);
    // Todo: your HW2
    input           clk;
    input           rst_n;
    input           valid;
    input   [31:0]  in_A;
    input   [31:0]  in_B;
    input   [3:0]   mode;
    output          ready;
    output  [63:0]  out;

    reg [63:0] out_data_temp;
    reg [31:0] temp, temp_mul; 
    reg [64:0] prod_rem;
    reg [5:0] count;
    reg [31:0] A_temp,B_temp;
    reg ready_0;

// ===============================================

    assign ready = ready_0;
    assign out = out_data_temp;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_0 <= 0;
            out_data_temp <= 0;
            prod_rem <= 65'd0;
            count <= 0;
        end 
        else if (valid) begin  
            count <= 0;
            ready_0 <= 0;
            case (mode)
                4'b1001: begin
                    ready_0 <= 0;
                    A_temp <= in_A;
                    if (in_B[0]) begin
                        prod_rem <= ({1'b0, in_A, in_B} >> 1'b1);
                    end 
                    else prod_rem <= ({33'd0, in_B} >> 1'b1);
                end
                4'b1010: begin
                    ready_0 <= 0;
                    B_temp <= in_B;
                    temp_mul <= {31'd0, in_A[31]}; //need revise
                        if ( temp_mul >= in_B) begin
                            prod_rem <= {1'b0, {31'd0, in_A[31]} - in_B, 31'd0, 1'b1};
                        end 
                        else prod_rem <=  {32'd0, in_A, 1'b0};
                end
                default: ready_0 <= 0;
            endcase
        end 
        else begin
            count <= count + 1;
            case(mode)
                4'b1001: begin//mul
                    if (count < 31) begin //shift 32 times
                        ready_0 <= 0;
                        if (prod_rem[0]) begin
                            prod_rem <= ({{1'b0, prod_rem[63:32]} + {1'b0, A_temp}, prod_rem[31:0]} >> 1'b1);
                        end 
                        else prod_rem <= (prod_rem >> 1'b1);
                    end 
                    else if (count == 31) begin
                        ready_0 <= 1;
                        out_data_temp <= prod_rem[63:0];
                        count <= 0;
                        A_temp <= 0;
                        prod_rem <= 0;
                    end 
                    else begin 
                        ready_0 <= 0;
                        prod_rem <= 0;
                    end
                end
                4'b1010:begin //div
                    if (count < 31) begin //shift 32 times
                        ready_0 <= 0;
                        if (prod_rem[62:31] >= B_temp) begin
                            prod_rem <= {1'b0, prod_rem[62:31] - B_temp, prod_rem[30:0], 1'b1};
                        end 
                        else prod_rem <= (prod_rem << 1'b1);
                    end 
                    else if (count == 31) begin
                        ready_0 <= 1;
                        out_data_temp <= prod_rem[63:0];
                        count <= 0;
                        B_temp <= 0;
                        temp <= 0;
                        prod_rem <= 0;
                    end 
                    else begin
                        ready_0 <= 0;
                        prod_rem <= 0;
                    end
                end
                default: begin
                    out_data_temp <= 0;
                    ready_0 <= 0;
                end
            endcase   
        end
    end
endmodule