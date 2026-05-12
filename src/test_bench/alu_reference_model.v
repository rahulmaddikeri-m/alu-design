`timescale 1ns/1ps

module alu_reference_model
(
    input mode,
    input [3:0] cmd,
    input [1:0] in_val,

    input [7:0] opa,
    input [7:0] opb,

    input c_in,

    output reg [16:0] exp_res,
    output reg exp_oflow,
    output reg exp_c_out,

    output reg exp_G,
    output reg exp_L,
    output reg exp_E,

    output reg exp_err
);

reg [8:0] temp;

always @(*)
begin

    exp_res    = 0;
    exp_oflow  = 0;
    exp_c_out  = 0;

    exp_G      = 0;
    exp_L      = 0;
    exp_E      = 0;

    exp_err    = 0;

    temp       = 0;

    case({mode,cmd})

    5'd0 :
    begin

        if(in_val == 2'b11)
            exp_res = opa & opb;

        else
            exp_err = 1;

    end

    5'd1 :
    begin

        if(in_val == 2'b11)
            exp_res = ~(opa & opb);

        else
            exp_err = 1;

    end

    5'd2 :
    begin

        if(in_val == 2'b11)
            exp_res = opa | opb;

        else
            exp_err = 1;

    end

    5'd3 :
    begin

        if(in_val == 2'b11)
            exp_res = ~(opa | opb);

        else
            exp_err = 1;

    end

    5'd4 :
    begin

        if(in_val == 2'b11)
            exp_res = opa ^ opb;

        else
            exp_err = 1;

    end

    5'd5 :
    begin

        if(in_val == 2'b11)
            exp_res = ~(opa ^ opb);

        else
            exp_err = 1;

    end

    5'd6 :
    begin

        if(in_val == 2'b11 || in_val == 2'b01)
            exp_res = ~opa;

        else
            exp_err = 1;

    end

    5'd7 :
    begin

        if(in_val == 2'b11 || in_val == 2'b10)
            exp_res = ~opb;

        else
            exp_err = 1;

    end

    5'd8 :
    begin

        if(in_val == 2'b11 || in_val == 2'b01)
            exp_res = opa >> 1;

        else
            exp_err = 1;

    end

    5'd9 :
    begin

        if(in_val == 2'b11 || in_val == 2'b01)
            exp_res = opa << 1;

        else
            exp_err = 1;

    end

    5'd10 :
    begin

        if(in_val == 2'b11 || in_val == 2'b10)
            exp_res = opb >> 1;

        else
            exp_err = 1;

    end

    5'd11 :
    begin

        if(in_val == 2'b11 || in_val == 2'b10)
            exp_res = opb << 1;

        else
            exp_err = 1;

    end

    5'd12 :
    begin

        if(in_val == 2'b11)
        begin

            casex(opb)

                8'b0000_X000:
                    exp_res = opa;

                8'b0000_X001:
                    exp_res = {opa[6:0],opa[7]};

                8'b0000_X010:
                    exp_res = {opa[5:0],opa[7:6]};

                8'b0000_X011:
                    exp_res = {opa[4:0],opa[7:5]};

                8'b0000_X100:
                    exp_res = {opa[3:0],opa[7:4]};

                8'b0000_X101:
                    exp_res = {opa[2:0],opa[7:3]};

                8'b0000_X110:
                    exp_res = {opa[1:0],opa[7:2]};

                8'b0000_X111:
                    exp_res = {opa[0],opa[7:1]};

                default:
                    exp_err = 1;

            endcase

        end

        else
            exp_err = 1;

    end

    5'd13 :
    begin

        if(in_val == 2'b11)
        begin

            casex(opb)

                8'b0000_X000:
                    exp_res = opa;

                8'b0000_X001:
                    exp_res = {opa[0],opa[7:1]};

                8'b0000_X010:
                    exp_res = {opa[1:0],opa[7:2]};

                8'b0000_X011:
                    exp_res = {opa[2:0],opa[7:3]};

                8'b0000_X100:
                    exp_res = {opa[3:0],opa[7:4]};

                8'b0000_X101:
                    exp_res = {opa[4:0],opa[7:5]};

                8'b0000_X110:
                    exp_res = {opa[5:0],opa[7:6]};

                8'b0000_X111:
                    exp_res = {opa[6:0],opa[7]};

                default:
                    exp_err = 1;

            endcase

        end

        else
            exp_err = 1;

    end

    5'd16 :
    begin

        if(in_val == 2'b11)
        begin

            temp = opa + opb;

            exp_res   = temp;
            exp_c_out = temp[8];

        end

        else
            exp_err = 1;

    end

    5'd17 :
    begin

        if(in_val == 2'b11)
        begin

            exp_res = opa - opb;

            if(opa < opb)
                exp_oflow = 1;

        end

        else
            exp_err = 1;

    end

    5'd18 :
    begin

        if(in_val == 2'b11)
        begin

            temp = opa + opb + c_in;

            exp_res   = temp;
            exp_c_out = temp[8];

        end

        else
            exp_err = 1;

    end

    5'd19 :
    begin

        if(in_val == 2'b11)
        begin

            exp_res = opa - opb - c_in;

            if(opa < (opb + c_in))
                exp_oflow = 1;

        end

        else
            exp_err = 1;

    end

    5'd20 :
    begin

        if(in_val == 2'b11 || in_val == 2'b01)
            exp_res = opa + 1;

        else
            exp_err = 1;

    end

    5'd21 :
    begin

        if(in_val == 2'b11 || in_val == 2'b01)
            exp_res = opa - 1;

        else
            exp_err = 1;

    end

    5'd22 :
    begin

        if(in_val == 2'b11 || in_val == 2'b10)
            exp_res = opb + 1;

        else
            exp_err = 1;

    end

    5'd23 :
    begin

        if(in_val == 2'b11 || in_val == 2'b10)
            exp_res = opb - 1;

        else
            exp_err = 1;

    end

    5'd24 :
    begin

        if(in_val == 2'b11)
        begin

            if(opa > opb)
                exp_G = 1;

            else if(opb > opa)
                exp_L = 1;

            else
                exp_E = 1;

        end

        else
            exp_err = 1;

    end

    5'd25 :
    begin

        if(in_val == 2'b11)
            exp_res = (opa + 1) * (opb + 1);

        else
            exp_err = 1;

    end

    5'd26 :
    begin

        if(in_val == 2'b11)
            exp_res = (opa << 1) * opb;

        else
            exp_err = 1;

    end

    5'd27 :
    begin

        if(in_val == 2'b11)
        begin

            temp = $signed(opa) + $signed(opb);

            exp_res = temp;

            exp_c_out = temp[8];

            if((opa[7] == opb[7]) &&
               (temp[7] != opa[7]))
                exp_oflow = 1;

            if($signed(opa) > $signed(opb))
                exp_G = 1;

            else if($signed(opa) < $signed(opb))
                exp_L = 1;

            else
                exp_E = 1;

        end

        else
            exp_err = 1;

    end

    5'd28 :
    begin

        if(in_val == 2'b11)
        begin

            temp = $signed(opa) - $signed(opb);

            exp_res = temp;

            exp_c_out = temp[8];

            if((opa[7] != opb[7]) &&
               (temp[7] != opa[7]))
                exp_oflow = 1;

            if($signed(opa) > $signed(opb))
                exp_G = 1;

            else if($signed(opa) < $signed(opb))
                exp_L = 1;

            else
                exp_E = 1;

        end

        else
            exp_err = 1;

    end

    default :
    begin

        exp_res = 0;
        exp_err = 1;

    end

    endcase

end

endmodule  