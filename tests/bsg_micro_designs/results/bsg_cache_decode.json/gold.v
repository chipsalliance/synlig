

module top
(
  opcode_i,
  decode_o
);

  input [5:0] opcode_i;
  output [20:0] decode_o;

  bsg_cache_decode
  wrapper
  (
    .opcode_i(opcode_i),
    .decode_o(decode_o)
  );


endmodule



module bsg_cache_decode
(
  opcode_i,
  decode_o
);

  input [5:0] opcode_i;
  output [20:0] decode_o;
  wire [20:0] decode_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,N41,
  N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,N59,N60,N61,
  N62,N63,N64,N65,N66,N67,N68,N69,N70,N71,N72,N73,N74,N75,N76,N77,N78,N79,N80,N81,
  N82,N83,N84,N85,N86,N87,N88,N89,N90,N91,N92,N93,N94,N95,N96,N97,N98,N99,N100,N101,
  N102,N103,N104,N105,N106,N107,N108,N109,N110,N111,N112,N113,N114,N115,N116,N117,
  N118,N119,N120,N121,N122,N123,N124,N125,N126,N127,N128,N129,N130,N131,N132,N133,
  N134,N135,N136,N137,N138,N139,N140,N141,N142,N143,N144,N146,N147,N148,N150,N152,
  N153,N154,N155,N156,N158,N160,N161,N163,N165,N166,N167,N168,N170,N171,N172,N173,
  N174,N175,N176,N177,N178,N179,N180,N181,N182,N183,N184,N185,N186,N187,N188,N189,
  N190,N191,N192,N193,N194,N195,N196,N197,N198,N199,N200,N201,N202,N203,N204,N205,
  N206,N207,N208,N209,N210,N211,N212,N214,N215,N216,N217,N218,N219,N220,N221,N222,
  N223,N224,N225,N226,N227,N228,N229,N230,N231,N232,N233,N234,N235,N236,N237,N238,
  N239,N240,N241,N242,N243,N244,N245,N246,N247,N248,N249,N250,N251,N252,N253,N254,
  N255,N256,N257,N258,N259,N260,N261,N262,N263,N264,N265,N266,N267,N268,N269,N270,
  N271,N272,N273,N274,N275,N276,N277,N278,N279,N280,N281,N282,N283,N284,N285,N286,
  N287,N288,N289,N290,N291,N292,N293,N294,N295,N296,N297;
  assign N17 = N80 | N138;
  assign N18 = opcode_i[3] | opcode_i[2];
  assign N19 = opcode_i[1] | opcode_i[0];
  assign N20 = N17 | N18;
  assign N21 = N20 | N19;
  assign N22 = opcode_i[1] | N139;
  assign N23 = N20 | N22;
  assign N24 = N146 | N139;
  assign N25 = N20 | N24;
  assign N26 = opcode_i[3] | N165;
  assign N27 = N17 | N26;
  assign N28 = N27 | N19;
  assign N29 = N146 | opcode_i[0];
  assign N30 = N20 | N29;
  assign N31 = N27 | N22;
  assign N32 = N27 | N29;
  assign N33 = N27 | N24;
  assign N34 = N152 | opcode_i[2];
  assign N35 = N17 | N34;
  assign N36 = N35 | N19;
  assign N37 = opcode_i[5] | opcode_i[4];
  assign N38 = N37 | N18;
  assign N39 = N38 | N24;
  assign N40 = N37 | N34;
  assign N41 = N40 | N24;
  assign N42 = N37 | N26;
  assign N43 = N42 | N24;
  assign N45 = N80 | opcode_i[4];
  assign N46 = N45 | N18;
  assign N47 = N46 | N19;
  assign N48 = N46 | N22;
  assign N49 = N46 | N24;
  assign N50 = N45 | N26;
  assign N51 = N50 | N19;
  assign N52 = N46 | N29;
  assign N53 = N50 | N22;
  assign N54 = N50 | N29;
  assign N55 = N50 | N24;
  assign N56 = N45 | N34;
  assign N57 = N56 | N19;
  assign N58 = N38 | N29;
  assign N59 = N40 | N29;
  assign N60 = N42 | N29;
  assign N62 = N38 | N22;
  assign N63 = N40 | N22;
  assign N64 = N42 | N22;
  assign N66 = N80 & N138;
  assign N67 = N152 & N165;
  assign N68 = N146 & N139;
  assign N69 = N66 & N67;
  assign N70 = N69 & N68;
  assign N71 = N40 | N19;
  assign N72 = N42 | N19;
  assign N74 = opcode_i[5] & opcode_i[3];
  assign N75 = N74 & opcode_i[0];
  assign N76 = N74 & opcode_i[1];
  assign N77 = opcode_i[3] & opcode_i[2];
  assign N78 = N80 & opcode_i[4];
  assign N81 = N138 & N152;
  assign N82 = N165 & N146;
  assign N83 = N81 & N82;
  assign N84 = N83 & N139;
  assign N85 = N138 | opcode_i[3];
  assign N86 = opcode_i[2] | opcode_i[1];
  assign N87 = N85 | N86;
  assign N88 = N87 | opcode_i[0];
  assign N90 = opcode_i[4] | opcode_i[3];
  assign N91 = N90 | N86;
  assign N92 = N91 | N139;
  assign N93 = N87 | N139;
  assign N95 = opcode_i[2] | N146;
  assign N96 = N90 | N95;
  assign N97 = N96 | opcode_i[0];
  assign N98 = N85 | N95;
  assign N99 = N98 | opcode_i[0];
  assign N101 = N96 | N139;
  assign N102 = N98 | N139;
  assign N104 = N165 | opcode_i[1];
  assign N105 = N90 | N104;
  assign N106 = N105 | opcode_i[0];
  assign N107 = N85 | N104;
  assign N108 = N107 | opcode_i[0];
  assign N110 = N105 | N139;
  assign N111 = N107 | N139;
  assign N113 = N165 | N146;
  assign N114 = N90 | N113;
  assign N115 = N114 | opcode_i[0];
  assign N116 = N85 | N113;
  assign N117 = N116 | opcode_i[0];
  assign N119 = N114 | N139;
  assign N120 = N116 | N139;
  assign N122 = opcode_i[4] | N152;
  assign N123 = N122 | N86;
  assign N124 = N123 | opcode_i[0];
  assign N125 = N138 | N152;
  assign N126 = N125 | N86;
  assign N127 = N126 | opcode_i[0];
  assign N129 = opcode_i[3] & opcode_i[0];
  assign N130 = opcode_i[3] & opcode_i[1];
  assign N138 = ~opcode_i[4];
  assign N139 = ~opcode_i[0];
  assign N140 = N138 | opcode_i[5];
  assign N141 = opcode_i[3] | N140;
  assign N142 = opcode_i[2] | N141;
  assign N143 = opcode_i[1] | N142;
  assign N144 = N139 | N143;
  assign decode_o[13] = ~N144;
  assign N146 = ~opcode_i[1];
  assign N147 = N146 | N142;
  assign N148 = opcode_i[0] | N147;
  assign decode_o[12] = ~N148;
  assign N150 = N139 | N147;
  assign decode_o[11] = ~N150;
  assign N152 = ~opcode_i[3];
  assign N153 = N152 | N140;
  assign N154 = opcode_i[2] | N153;
  assign N155 = opcode_i[1] | N154;
  assign N156 = opcode_i[0] | N155;
  assign decode_o[10] = ~N156;
  assign N158 = N139 | N155;
  assign decode_o[9] = ~N158;
  assign N160 = N146 | N154;
  assign N161 = opcode_i[0] | N160;
  assign decode_o[8] = ~N161;
  assign N163 = N139 | N160;
  assign decode_o[7] = ~N163;
  assign N165 = ~opcode_i[2];
  assign N166 = N165 | N153;
  assign N167 = opcode_i[1] | N166;
  assign N168 = opcode_i[0] | N167;
  assign decode_o[6] = ~N168;
  assign N170 = opcode_i[4] | opcode_i[5];
  assign N171 = opcode_i[3] | N170;
  assign N172 = opcode_i[2] | N171;
  assign N173 = opcode_i[1] | N172;
  assign N174 = opcode_i[0] | N173;
  assign N175 = ~N174;
  assign N176 = N139 | N173;
  assign N177 = ~N176;
  assign N178 = N146 | N172;
  assign N179 = opcode_i[0] | N178;
  assign N180 = ~N179;
  assign N181 = N139 | N178;
  assign N182 = ~N181;
  assign N183 = N152 | N170;
  assign N184 = N165 | N183;
  assign N185 = opcode_i[1] | N184;
  assign N186 = opcode_i[0] | N185;
  assign N187 = ~N186;
  assign N188 = N139 | N185;
  assign N189 = ~N188;
  assign N190 = N165 | N171;
  assign N191 = opcode_i[1] | N190;
  assign N192 = opcode_i[0] | N191;
  assign N193 = ~N192;
  assign N194 = N139 | N191;
  assign N195 = ~N194;
  assign N196 = N146 | N190;
  assign N197 = opcode_i[0] | N196;
  assign N198 = ~N197;
  assign N199 = N139 | N196;
  assign N200 = ~N199;
  assign N201 = opcode_i[2] | N183;
  assign N202 = opcode_i[1] | N201;
  assign N203 = opcode_i[0] | N202;
  assign N204 = ~N203;
  assign N205 = N139 | N202;
  assign N206 = ~N205;
  assign N207 = N146 | N201;
  assign N208 = opcode_i[0] | N207;
  assign N209 = ~N208;
  assign N210 = N139 | N207;
  assign N211 = ~N210;
  assign N212 = opcode_i[0] | N143;
  assign decode_o[14] = ~N212;
  assign decode_o[20:19] = (N0)? { 1'b1, 1'b1 } : 
                           (N1)? { 1'b1, 1'b0 } : 
                           (N2)? { 1'b0, 1'b1 } : 
                           (N3)? { 1'b0, 1'b0 } : 
                           (N4)? { 1'b0, 1'b0 } : 1'b0;
  assign N0 = N44;
  assign N1 = N61;
  assign N2 = N65;
  assign N3 = N73;
  assign N4 = N79;
  assign { N135, N134, N133, N132 } = (N5)? { 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                      (N6)? { 1'b0, 1'b0, 1'b0, 1'b1 } : 
                                      (N7)? { 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                      (N8)? { 1'b0, 1'b0, 1'b1, 1'b1 } : 
                                      (N9)? { 1'b0, 1'b1, 1'b0, 1'b0 } : 
                                      (N10)? { 1'b0, 1'b1, 1'b0, 1'b1 } : 
                                      (N11)? { 1'b0, 1'b1, 1'b1, 1'b0 } : 
                                      (N12)? { 1'b0, 1'b1, 1'b1, 1'b1 } : 
                                      (N13)? { 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                      (N14)? { 1'b0, 1'b0, 1'b0, 1'b0 } : 1'b0;
  assign N5 = N89;
  assign N6 = N94;
  assign N7 = N100;
  assign N8 = N103;
  assign N9 = N109;
  assign N10 = N112;
  assign N11 = N118;
  assign N12 = N121;
  assign N13 = N128;
  assign N14 = N131;
  assign decode_o[4:0] = (N15)? { N137, N135, N134, N133, N132 } : 
                         (N16)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 1'b0;
  assign N15 = opcode_i[5];
  assign N16 = N80;
  assign N44 = N234 | N235;
  assign N234 = N232 | N233;
  assign N232 = N230 | N231;
  assign N230 = N228 | N229;
  assign N228 = N226 | N227;
  assign N226 = N224 | N225;
  assign N224 = N222 | N223;
  assign N222 = N220 | N221;
  assign N220 = N218 | N219;
  assign N218 = N216 | N217;
  assign N216 = N214 | N215;
  assign N214 = ~N21;
  assign N215 = ~N23;
  assign N217 = ~N25;
  assign N219 = ~N28;
  assign N221 = ~N30;
  assign N223 = ~N31;
  assign N225 = ~N32;
  assign N227 = ~N33;
  assign N229 = ~N36;
  assign N231 = ~N39;
  assign N233 = ~N41;
  assign N235 = ~N43;
  assign N61 = N256 | N257;
  assign N256 = N254 | N255;
  assign N254 = N252 | N253;
  assign N252 = N250 | N251;
  assign N250 = N248 | N249;
  assign N248 = N246 | N247;
  assign N246 = N244 | N245;
  assign N244 = N242 | N243;
  assign N242 = N240 | N241;
  assign N240 = N238 | N239;
  assign N238 = N236 | N237;
  assign N236 = ~N47;
  assign N237 = ~N48;
  assign N239 = ~N49;
  assign N241 = ~N51;
  assign N243 = ~N52;
  assign N245 = ~N53;
  assign N247 = ~N54;
  assign N249 = ~N55;
  assign N251 = ~N57;
  assign N253 = ~N58;
  assign N255 = ~N59;
  assign N257 = ~N60;
  assign N65 = N260 | N261;
  assign N260 = N258 | N259;
  assign N258 = ~N62;
  assign N259 = ~N63;
  assign N261 = ~N64;
  assign N73 = N263 | N264;
  assign N263 = N70 | N262;
  assign N262 = ~N71;
  assign N264 = ~N72;
  assign N79 = N75 | N266;
  assign N266 = N76 | N265;
  assign N265 = N77 | N78;
  assign decode_o[17] = N187 | N189;
  assign decode_o[18] = N269 | decode_o[4];
  assign N269 = N268 | N182;
  assign N268 = N267 | N180;
  assign N267 = N175 | N177;
  assign decode_o[16] = N276 | N187;
  assign N276 = N275 | N200;
  assign N275 = N274 | N198;
  assign N274 = N273 | N195;
  assign N273 = N272 | N193;
  assign N272 = N271 | N182;
  assign N271 = N270 | N180;
  assign N270 = N175 | N177;
  assign decode_o[15] = N279 | N189;
  assign N279 = N278 | N211;
  assign N278 = N277 | N209;
  assign N277 = N204 | N206;
  assign decode_o[5] = ~decode_o[14];
  assign N80 = ~opcode_i[5];
  assign N89 = N84 | N280;
  assign N280 = ~N88;
  assign N94 = N281 | N282;
  assign N281 = ~N92;
  assign N282 = ~N93;
  assign N100 = N283 | N284;
  assign N283 = ~N97;
  assign N284 = ~N99;
  assign N103 = N285 | N286;
  assign N285 = ~N101;
  assign N286 = ~N102;
  assign N109 = N287 | N288;
  assign N287 = ~N106;
  assign N288 = ~N108;
  assign N112 = N289 | N290;
  assign N289 = ~N110;
  assign N290 = ~N111;
  assign N118 = N291 | N292;
  assign N291 = ~N115;
  assign N292 = ~N117;
  assign N121 = N293 | N294;
  assign N293 = ~N119;
  assign N294 = ~N120;
  assign N128 = N295 | N296;
  assign N295 = ~N124;
  assign N296 = ~N127;
  assign N131 = N129 | N297;
  assign N297 = N130 | N77;
  assign N136 = ~N131;
  assign N137 = N136;

endmodule

