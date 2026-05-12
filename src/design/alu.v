`timescale 1ns / 1ps
`default_nettype none

module aluu #(parameter N=8 ,parameter M=4)
(
    input wire clk,
    input wire rst,
    input wire [1:0] INP_VALID,
    input wire [M-1:0] CMD,
    input wire MODE,
    input wire CE,
    input wire [N-1:0] OPA,
    input wire [N-1:0] OPB,
    input wire CIN,

    output reg ERR,
    output reg [2*N-1:0] RES,
    output reg OFLOW,
    output reg COUT,
    output reg G,
    output reg L,
    output reg E
);

reg [1:0] count;
reg [N:0] temp;

reg [2*N-1:0] pipe_res;
reg pipe_oflow;
reg pipe_cout;
reg pipe_g;
reg pipe_l;
reg pipe_e;
reg pipe_err;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        RES         <= 0;
        OFLOW       <= 0;
        COUT        <= 0;
        G           <= 0;
        L           <= 0;
        E           <= 0;
        ERR         <= 0;

        pipe_res    <= 0;
        pipe_oflow  <= 0;
        pipe_cout   <= 0;
        pipe_g      <= 0;
        pipe_l      <= 0;
        pipe_e      <= 0;
        pipe_err    <= 0;

        count       <= 0;

    end

    else
    begin

        RES     <= pipe_res;
        OFLOW   <= pipe_oflow;
        COUT    <= pipe_cout;
        G       <= pipe_g;
        L       <= pipe_l;
        E       <= pipe_e;
        ERR     <= pipe_err;

        pipe_res    <= 0;
        pipe_oflow  <= 0;
        pipe_cout   <= 0;
        pipe_g      <= 0;
        pipe_l      <= 0;
        pipe_e      <= 0;
        pipe_err    <= 0;

        if(CE)
        begin

            if(MODE)
            begin

                case(INP_VALID)

                    2'b00:
                    begin
                        pipe_err <= 1;
                    end

                    2'b01:
                    begin

                        case(CMD)

                            4'b0100:
                                pipe_res <= OPA + 1;

                            4'b0101:
                                pipe_res <= OPA - 1;

                            default:
                                pipe_err <= 1;

                        endcase

                    end

                    2'b10:
                    begin

                        case(CMD)

                            4'b0110:
                                pipe_res <= OPB + 1;

                            4'b0111:
                                pipe_res <= OPB - 1;

                            default:
                                pipe_err <= 1;

                        endcase

                    end

                    2'b11:
                    begin

                        case(CMD)

                            4'b0000:
                            begin

                                temp = OPA + OPB;

                                pipe_res   <= temp;
                                pipe_cout  <= temp[N];
                                pipe_oflow <= temp[N];

                            end

                            4'b0001:
                            begin

                                pipe_res   <= OPA - OPB;
                                pipe_oflow <= (OPA < OPB);

                            end

                            4'b0010:
                            begin

                                temp = OPA + OPB + CIN;

                                pipe_res   <= temp;
                                pipe_cout  <= temp[N];
                                pipe_oflow <= temp[N];

                            end

                            4'b0011:
                            begin

                                pipe_res   <= OPA - OPB - CIN;
                                pipe_oflow <= (OPA < (OPB + CIN));

                            end

                            4'b0100:
                                pipe_res <= OPA + 1;

                            4'b0101:
                                pipe_res <= OPA - 1;

                            4'b0110:
                                pipe_res <= OPB + 1;

                            4'b0111:
                                pipe_res <= OPB - 1;

                            4'b1000:
                            begin

                                pipe_g <= (OPA > OPB);
                                pipe_l <= (OPA < OPB);
                                pipe_e <= (OPA == OPB);

                            end

                            4'b1001:
                            begin

                                if(count == 1)
                                begin

                                    pipe_res <= (OPA + 1) * (OPB + 1);

                                    count <= 0;

                                end

                                else
                                begin

                                    count <= count + 1;

                                end

                            end

                            4'b1010:
                            begin

                                if(count == 1)
                                begin

                                    pipe_res <= (OPA << 1) * OPB;

                                    count <= 0;

                                end

                                else
                                begin

                                    count <= count + 1;

                                end

                            end

                            4'b1011:
                            begin

                                temp = $signed(OPA) + $signed(OPB);

                                pipe_res <= temp;

                                pipe_cout <= temp[N];

                                pipe_oflow <=
                                (OPA[N-1] == OPB[N-1]) &&
                                (temp[N-1] != OPA[N-1]);

                                pipe_g <=
                                ($signed(OPA) > $signed(OPB));

                                pipe_l <=
                                ($signed(OPA) < $signed(OPB));

                                pipe_e <=
                                ($signed(OPA) == $signed(OPB));

                            end

                            4'b1100:
                            begin

                                temp = $signed(OPA) - $signed(OPB);

                                pipe_res <= temp;

                                pipe_cout <= temp[N];

                                pipe_oflow <=
                                (OPA[N-1] != OPB[N-1]) &&
                                (temp[N-1] != OPA[N-1]);

                                pipe_g <=
                                ($signed(OPA) > $signed(OPB));

                                pipe_l <=
                                ($signed(OPA) < $signed(OPB));

                                pipe_e <=
                                ($signed(OPA) == $signed(OPB));

                            end

                            default:
                                pipe_err <= 1;

                        endcase

                    end

                endcase

            end

            else
            begin

                case(INP_VALID)

                    2'b00:
                    begin
                        pipe_err <= 1;
                    end

                    2'b01:
                    begin

                        case(CMD)

                            4'b0110:
                                pipe_res <= ~OPA;

                            4'b1000:
                                pipe_res <= (OPA >> 1);

                            4'b1001:
                                pipe_res <= (OPA << 1);

                            default:
                                pipe_err <= 1;

                        endcase

                    end

                    2'b10:
                    begin

                        case(CMD)

                            4'b0111:
                                pipe_res <= ~OPB;

                            4'b1010:
                                pipe_res <= (OPB >> 1);

                            4'b1011:
                                pipe_res <= (OPB << 1);

                            default:
                                pipe_err <= 1;

                        endcase

                    end

                    2'b11:
                    begin

                        case(CMD)

                            4'b0000: pipe_res <= OPA & OPB;
                            4'b0001: pipe_res <= ~(OPA & OPB);
                            4'b0010: pipe_res <= OPA | OPB;
                            4'b0011: pipe_res <= ~(OPA | OPB);
                            4'b0100: pipe_res <= OPA ^ OPB;
                            4'b0101: pipe_res <= ~(OPA ^ OPB);

                            4'b0110: pipe_res <= ~OPA;
                            4'b0111: pipe_res <= ~OPB;

                            4'b1000: pipe_res <= (OPA >> 1);
                            4'b1001: pipe_res <= (OPA << 1);

                            4'b1010: pipe_res <= (OPB >> 1);
                            4'b1011: pipe_res <= (OPB << 1);

                            4'b1100:
                            begin

                                casex(OPB)

                                    8'b0000_X000:
                                        pipe_res <= OPA;

                                    8'b0000_X001:
                                        pipe_res <= {OPA[N-2:0],OPA[N-1]};

                                    8'b0000_X010:
                                        pipe_res <= {OPA[N-3:0],OPA[N-1:N-2]};

                                    8'b0000_X011:
                                        pipe_res <= {OPA[N-4:0],OPA[N-1:N-3]};

                                    8'b0000_X100:
                                        pipe_res <= {OPA[N-5:0],OPA[N-1:N-4]};

                                    8'b0000_X101:
                                        pipe_res <= {OPA[N-6:0],OPA[N-1:N-5]};

                                    8'b0000_X110:
                                        pipe_res <= {OPA[N-7:0],OPA[N-1:N-6]};

                                    8'b0000_X111:
                                        pipe_res <= {OPA[0],OPA[N-1:1]};

                                    default:
                                        pipe_err <= 1;

                                endcase

                            end

                            4'b1101:
                            begin

                                casex(OPB)

                                    8'b0000_X000:
                                        pipe_res <= OPA;

                                    8'b0000_X001:
                                        pipe_res <= {OPA[0],OPA[N-1:1]};

                                    8'b0000_X010:
                                        pipe_res <= {OPA[1:0],OPA[N-1:2]};

                                    8'b0000_X011:
                                        pipe_res <= {OPA[2:0],OPA[N-1:3]};

                                    8'b0000_X100:
                                        pipe_res <= {OPA[3:0],OPA[N-1:4]};

                                    8'b0000_X101:
                                        pipe_res <= {OPA[4:0],OPA[N-1:5]};

                                    8'b0000_X110:
                                        pipe_res <= {OPA[5:0],OPA[N-1:6]};

                                    8'b0000_X111:
                                        pipe_res <= {OPA[6:0],OPA[N-1]};

                                    default:
                                        pipe_err <= 1;

                                endcase

                            end

                            default:
                                pipe_err <= 1;

                        endcase

                    end

                endcase

            end

        end

    end

end

endmodule