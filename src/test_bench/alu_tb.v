`timescale 1ns/1ps

module tb_alu;

parameter N = 8;

reg clk;
reg rst;

reg c_in;
reg ce;
reg mode;

reg [1:0] in_val;

reg [N-1:0] opa;
reg [N-1:0] opb;

reg [3:0] cmd;

wire oflow;
wire c_out;

wire G;
wire L;
wire E;

wire err;

wire [(2*N):0] res;

wire [(2*N):0] exp_res;
wire exp_oflow;
wire exp_c_out;

wire exp_G;
wire exp_L;
wire exp_E;

wire exp_err;

reg [16:0] exp_res_d1;
reg [16:0] exp_res_d2;

reg exp_oflow_d1;
reg exp_oflow_d2;

reg exp_err_d1;
reg exp_err_d2;

reg exp_G_d1;
reg exp_G_d2;

reg exp_L_d1;
reg exp_L_d2;

reg exp_E_d1;
reg exp_E_d2;

aluu dut
(
    .clk(clk),
    .rst(rst),

    .c_in(c_in),
    .ce(ce),
    .mode(mode),

    .in_val(in_val),

    .opa(opa),
    .opb(opb),

    .cmd(cmd),

    .oflow(oflow),
    .c_out(c_out),

    .G(G),
    .L(L),
    .E(E),

    .err(err),

    .res(res)
);

alu_reference_model ref_model
(
    .mode(mode),
    .cmd(cmd),

    .in_val(in_val),

    .opa(opa),
    .opb(opb),

    .c_in(c_in),

    .exp_res(exp_res),
    .exp_oflow(exp_oflow),
    .exp_c_out(exp_c_out),

    .exp_G(exp_G),
    .exp_L(exp_L),
    .exp_E(exp_E),

    .exp_err(exp_err)
);

always #5 clk = ~clk;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        exp_res_d1 <= 0;
        exp_res_d2 <= 0;

        exp_oflow_d1 <= 0;
        exp_oflow_d2 <= 0;

        exp_err_d1 <= 0;
        exp_err_d2 <= 0;

        exp_G_d1 <= 0;
        exp_G_d2 <= 0;

        exp_L_d1 <= 0;
        exp_L_d2 <= 0;

        exp_E_d1 <= 0;
        exp_E_d2 <= 0;

    end

    else
    begin

        exp_res_d1 <= exp_res;
        exp_res_d2 <= exp_res_d1;

        exp_oflow_d1 <= exp_oflow;
        exp_oflow_d2 <= exp_oflow_d1;

        exp_err_d1 <= exp_err;
        exp_err_d2 <= exp_err_d1;

        exp_G_d1 <= exp_G;
        exp_G_d2 <= exp_G_d1;

        exp_L_d1 <= exp_L;
        exp_L_d2 <= exp_L_d1;

        exp_E_d1 <= exp_E;
        exp_E_d2 <= exp_E_d1;

    end

end

task apply;

input t_mode;
input [3:0] t_cmd;
input [1:0] t_in_val;

input [7:0] t_opa;
input [7:0] t_opb;

input t_c_in;

begin

    @(negedge clk);

    mode   = t_mode;
    cmd    = t_cmd;

    in_val = t_in_val;

    opa    = t_opa;
    opb    = t_opb;

    c_in   = t_c_in;

    ce     = 1'b1;

    if(t_mode == 1 &&
      (t_cmd == 4'd9 || t_cmd == 4'd10))
    begin

        repeat(2)
        @(posedge clk);

        #1;

        if(
            (res    === exp_res_d2)    &&
            (oflow === exp_oflow_d2) &&
            (err    === exp_err_d2)    &&
            (G      === exp_G_d2)      &&
            (L      === exp_L_d2)      &&
            (E      === exp_E_d2)
          )

        begin

            $display(
            "PASS :: mode=%0d cmd=%0d in_val=%b opa=%0d opb=%0d res=%0d",
            t_mode,t_cmd,t_in_val,t_opa,t_opb,res);

        end

        else
        begin

            $display(
            "FAIL :: mode=%0d cmd=%0d in_val=%b opa=%0d opb=%0d",
            t_mode,t_cmd,t_in_val,t_opa,t_opb);

            $display(
            "DUT -> res=%0d oflow=%0d err=%0d G=%0d L=%0d E=%0d",
            res,oflow,err,G,L,E);

            $display(
            "REF -> res=%0d oflow=%0d err=%0d G=%0d L=%0d E=%0d",
            exp_res_d2,
            exp_oflow_d2,
            exp_err_d2,
            exp_G_d2,
            exp_L_d2,
            exp_E_d2);

        end

    end

    else
    begin

        @(posedge clk);

        #1;

        if(
            (res    === exp_res_d1)    &&
            (oflow === exp_oflow_d1) &&
            (err    === exp_err_d1)    &&
            (G      === exp_G_d1)      &&
            (L      === exp_L_d1)      &&
            (E      === exp_E_d1)
          )

        begin

            $display(
            "PASS :: mode=%0d cmd=%0d in_val=%b opa=%0d opb=%0d res=%0d",
            t_mode,t_cmd,t_in_val,t_opa,t_opb,res);

        end

        else
        begin

            $display(
            "FAIL :: mode=%0d cmd=%0d in_val=%b opa=%0d opb=%0d",
            t_mode,t_cmd,t_in_val,t_opa,t_opb);

            $display(
            "DUT -> res=%0d oflow=%0d err=%0d G=%0d L=%0d E=%0d",
            res,oflow,err,G,L,E);

            $display(
            "REF -> res=%0d oflow=%0d err=%0d G=%0d L=%0d E=%0d",
            exp_res_d1,
            exp_oflow_d1,
            exp_err_d1,
            exp_G_d1,
            exp_L_d1,
            exp_E_d1);

        end

    end

end

endtask

initial
begin

    clk = 0;

    rst = 1;

    c_in = 0;
    ce   = 0;

    mode = 0;

    in_val = 0;

    opa = 0;
    opb = 0;

    cmd = 0;

    #20;

    rst = 0;

    apply(0,4'd0,2'b11,8'hAA,8'h55,0);
    apply(0,4'd1,2'b11,8'hAA,8'h55,0);
    apply(0,4'd2,2'b11,8'hAA,8'h55,0);
    apply(0,4'd3,2'b11,8'hAA,8'h55,0);
    apply(0,4'd4,2'b11,8'hAA,8'h55,0);
    apply(0,4'd5,2'b11,8'hAA,8'h55,0);

    apply(0,4'd6,2'b01,8'h0F,8'h00,0);
    apply(0,4'd6,2'b11,8'hF0,8'h00,0);

    apply(0,4'd7,2'b10,8'h00,8'h0F,0);
    apply(0,4'd7,2'b11,8'h00,8'hF0,0);

    apply(0,4'd8,2'b01,8'd16,8'd0,0);
    apply(0,4'd9,2'b01,8'd16,8'd0,0);

    apply(0,4'd10,2'b10,8'd0,8'd16,0);
    apply(0,4'd11,2'b10,8'd0,8'd16,0);

    apply(0,4'd12,2'b11,8'd145,8'd0,0);
    apply(0,4'd12,2'b11,8'd145,8'd1,0);
    apply(0,4'd12,2'b11,8'd145,8'd2,0);
    apply(0,4'd12,2'b11,8'd145,8'd3,0);
    apply(0,4'd12,2'b11,8'd145,8'd4,0);
    apply(0,4'd12,2'b11,8'd145,8'd5,0);
    apply(0,4'd12,2'b11,8'd145,8'd6,0);
    apply(0,4'd12,2'b11,8'd145,8'd7,0);

    apply(0,4'd13,2'b11,8'd145,8'd0,0);
    apply(0,4'd13,2'b11,8'd145,8'd1,0);
    apply(0,4'd13,2'b11,8'd145,8'd2,0);
    apply(0,4'd13,2'b11,8'd145,8'd3,0);
    apply(0,4'd13,2'b11,8'd145,8'd4,0);
    apply(0,4'd13,2'b11,8'd145,8'd5,0);
    apply(0,4'd13,2'b11,8'd145,8'd6,0);
    apply(0,4'd13,2'b11,8'd145,8'd7,0);

    apply(1,4'd0,2'b11,8'd10,8'd20,0);
    apply(1,4'd0,2'b11,8'd255,8'd1,0);

    apply(1,4'd1,2'b11,8'd20,8'd10,0);
    apply(1,4'd1,2'b11,8'd10,8'd20,0);

    apply(1,4'd2,2'b11,8'd20,8'd10,1);
    apply(1,4'd2,2'b11,8'd255,8'd1,1);

    apply(1,4'd3,2'b11,8'd20,8'd10,1);
    apply(1,4'd3,2'b11,8'd0,8'd1,1);

    apply(1,4'd4,2'b01,8'd10,8'd0,0);
    apply(1,4'd4,2'b11,8'd255,8'd0,0);

    apply(1,4'd5,2'b01,8'd10,8'd0,0);
    apply(1,4'd5,2'b11,8'd0,8'd0,0);

    apply(1,4'd6,2'b10,8'd0,8'd10,0);
    apply(1,4'd6,2'b11,8'd0,8'd255,0);

    apply(1,4'd7,2'b10,8'd0,8'd10,0);
    apply(1,4'd7,2'b11,8'd0,8'd0,0);

    apply(1,4'd8,2'b11,8'd50,8'd20,0);
    apply(1,4'd8,2'b11,8'd10,8'd40,0);
    apply(1,4'd8,2'b11,8'd30,8'd30,0);

    apply(1,4'd9,2'b11,8'd5,8'd5,0);
    apply(1,4'd10,2'b11,8'd5,8'd5,0);

    apply(1,4'd11,2'b11,8'd127,8'd1,0);
    apply(1,4'd11,2'b11,8'd64,8'd64,0);

    apply(1,4'd12,2'b11,8'd128,8'd1,0);
    apply(1,4'd12,2'b11,8'd10,8'd20,0);

    repeat(200)
    begin

        mode = $urandom % 2;

        if(mode == 0)
        begin

            apply(
                mode,
                $urandom % 14,
                $urandom % 4,
                $urandom % 256,
                $urandom % 256,
                $urandom % 2
            );

        end

        else
        begin

            apply(
                mode,
                $urandom % 13,
                $urandom % 4,
                $urandom % 256,
                $urandom % 256,
                $urandom % 2
            );

        end

    end

    #100;

    $finish;

end

endmodule