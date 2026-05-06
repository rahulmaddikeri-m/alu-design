`timescale 1ns / 1ps
`default_nettype none

module aluu #(parameter N = 8,parameter M = 4)
(   input  wire  clk,
    input  wire  rst,
    input  wire  CIN,
    input  wire  MODE,
    input  wire  CE,
    input  wire [1:0] INP_VALID,
    input  wire [N-1:0] OPA,
    input  wire [N-1:0] OPB,
    input  wire [M-1:0] CMD,
    output reg  OFLOW,
    output reg  COUT,
    output reg  G,
    output reg  L,
    output reg  E,
    output reg  ERR,
    output reg [2*N-1:0] RES
);

    reg [1:0] count;
    reg [N:0] temp;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            RES    <= 0;
            OFLOW <= 0;
            COUT  <= 0;
            G     <= 0;
            L     <= 0;
            E     <= 0;
            ERR   <= 0;
            count <= 0;
        end

        else
        begin
            if(CE)
            begin
                ERR    <= 0;
                OFLOW <= 0;
                COUT  <= 0;
                G     <= 0;
                L     <= 0;
                E     <= 0;

                if(MODE)
                begin
                    case(INP_VALID)

                        2'b00:
                        begin
                            ERR <= 1;
                            RES <= 0;
                        end

                        2'b01:
                        begin
                            case(CMD)

                                4'b0100:
                                    RES <= OPA + 1;

                                4'b0101:
                                    RES <= OPA - 1;

                                default:
                                begin
                                    ERR <= 1;
                                    RES <= 0;
                                end

                            endcase
                        end

                        2'b10:
                        begin
                            case(CMD)

                                4'b0110:
                                    RES <= OPB + 1;

                                4'b0111:
                                    RES <= OPB - 1;

                                default:
                                begin
                                    ERR <= 1;
                                    RES <= 0;
                                end

                            endcase
                        end

                        2'b11:
                        begin
                            case(CMD)

                                4'b0000:
                                begin
                                    temp = OPA + OPB;
                                    RES   <= temp;
                                    COUT  <= temp[N];
                                    OFLOW <= temp[N];
                                end

                                4'b0001:
                                begin
                                    RES   <= OPA - OPB;
                                    OFLOW <= (OPA < OPB);
                                end

                                4'b0010:
                                begin
                                    temp = OPA + OPB + CIN;
                                    RES   <= temp;
                                    COUT  <= temp[N];
                                    OFLOW <= temp[N];
                                end

                                4'b0011:
                                begin
                                    RES   <= OPA - OPB - CIN;
                                    OFLOW <= (OPA < (OPB + CIN));
                                end

                                4'b0100:
                                    RES <= OPA + 1;

                                4'b0101:
                                    RES <= OPA - 1;

                                4'b0110:
                                    RES <= OPB + 1;

                                4'b0111:
                                    RES <= OPB - 1;

                                4'b1000:
                                begin
                                    G <= (OPA > OPB);
                                    L <= (OPA < OPB);
                                    E <= (OPA == OPB);
                                end

                                4'b1001:
                                begin
                                    if(count == 2)
                                    begin
                                        RES   <= (OPA + 1) * (OPB + 1);
                                        count <= 0;
                                    end
                                    else
                                    begin
                                        count <= count + 1;
                                    end
                                end

                                4'b1010:
                                begin
                                    if(count == 2)
                                    begin
                                        RES   <= (OPA << 1) * OPB;
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

                                    RES <= temp;

                                    OFLOW <=
                                    (OPA[N-1] == OPB[N-1]) &&
                                    (temp[N-1] != OPA[N-1]);

                                    G <= ($signed(OPA) > $signed(OPB));
                                    L <= ($signed(OPA) < $signed(OPB));
                                    E <= ($signed(OPA) == $signed(OPB));
                                end

                                4'b1100:
                                begin
                                    temp = $signed(OPA) - $signed(OPB);

                                    RES <= temp;

                                    OFLOW <=
                                    (OPA[N-1] != OPB[N-1]) &&
                                    (temp[N-1] != OPA[N-1]);

                                    G <= ($signed(OPA) > $signed(OPB));
                                    L <= ($signed(OPA) < $signed(OPB));
                                    E <= ($signed(OPA) == $signed(OPB));
                                end

                                default:
                                begin
                                    ERR <= 1;
                                    RES <= 0;
                                end

                            endcase
                        end

                    endcase
                end

                else
                begin
                    case(INP_VALID)

                        2'b00:
                        begin
                            ERR <= 1;
                            RES <= 0;
                        end

                        2'b01:
                        begin
                            case(CMD)

                                4'b0110: RES <= ~OPA;
                                4'b1000: RES <= (OPA >> 1);
                                4'b1001: RES <= (OPA << 1);

                                default:
                                begin
                                    ERR <= 1;
                                    RES <= 0;
                                end

                            endcase
                        end

                        2'b10:
                        begin
                            case(CMD)

                                4'b0111: RES <= ~OPB;
                                4'b1010: RES <= (OPB >> 1);
                                4'b1011: RES <= (OPB << 1);

                                default:
                                begin
                                    ERR <= 1;
                                    RES <= 0;
                                end

                            endcase
                        end

                        2'b11:
                        begin
                            case(CMD)

                                4'b0000: RES <= OPA & OPB;
                                4'b0001: RES <= ~(OPA & OPB);
                                4'b0010: RES <= OPA | OPB;
                                4'b0011: RES <= ~(OPA | OPB);
                                4'b0100: RES <= OPA ^ OPB;
                                4'b0101: RES <= ~(OPA ^ OPB);

                                4'b0110: RES <= ~OPA;
                                4'b0111: RES <= ~OPB;

                                4'b1000: RES <= (OPA >> 1);
                                4'b1001: RES <= (OPA << 1);

                                4'b1010: RES <= (OPB >> 1);
                                4'b1011: RES <= (OPB << 1);

                                4'b1100:
                                begin
                                    RES <=
                                    (OPA << OPB[2:0]) |
                                    (OPA >> (N - OPB[2:0]));
                                end

                                4'b1101:
                                begin
                                    RES <=
                                    (OPA >> OPB[2:0]) |
                                    (OPA << (N - OPB[2:0]));
                                end

                                default:
                                begin
                                    ERR <= 1;
                                    RES <= 0;
                                end

                            endcase
                        end

                    endcase
                end
            end
        end
    end

endmodule


