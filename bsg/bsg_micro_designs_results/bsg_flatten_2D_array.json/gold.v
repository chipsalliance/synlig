

module top
(
  i,
  o
);

  input [159:0] i;
  output [159:0] o;

  bsg_flatten_2D_array
  wrapper
  (
    .i(i),
    .o(o)
  );


endmodule



module bsg_flatten_2D_array
(
  i,
  o
);

  input [159:0] i;
  output [159:0] o;
  wire [159:0] o;
  assign o[159] = i[159];
  assign o[158] = i[158];
  assign o[157] = i[157];
  assign o[156] = i[156];
  assign o[155] = i[155];
  assign o[154] = i[154];
  assign o[153] = i[153];
  assign o[152] = i[152];
  assign o[151] = i[151];
  assign o[150] = i[150];
  assign o[149] = i[149];
  assign o[148] = i[148];
  assign o[147] = i[147];
  assign o[146] = i[146];
  assign o[145] = i[145];
  assign o[144] = i[144];
  assign o[143] = i[143];
  assign o[142] = i[142];
  assign o[141] = i[141];
  assign o[140] = i[140];
  assign o[139] = i[139];
  assign o[138] = i[138];
  assign o[137] = i[137];
  assign o[136] = i[136];
  assign o[135] = i[135];
  assign o[134] = i[134];
  assign o[133] = i[133];
  assign o[132] = i[132];
  assign o[131] = i[131];
  assign o[130] = i[130];
  assign o[129] = i[129];
  assign o[128] = i[128];
  assign o[127] = i[127];
  assign o[126] = i[126];
  assign o[125] = i[125];
  assign o[124] = i[124];
  assign o[123] = i[123];
  assign o[122] = i[122];
  assign o[121] = i[121];
  assign o[120] = i[120];
  assign o[119] = i[119];
  assign o[118] = i[118];
  assign o[117] = i[117];
  assign o[116] = i[116];
  assign o[115] = i[115];
  assign o[114] = i[114];
  assign o[113] = i[113];
  assign o[112] = i[112];
  assign o[111] = i[111];
  assign o[110] = i[110];
  assign o[109] = i[109];
  assign o[108] = i[108];
  assign o[107] = i[107];
  assign o[106] = i[106];
  assign o[105] = i[105];
  assign o[104] = i[104];
  assign o[103] = i[103];
  assign o[102] = i[102];
  assign o[101] = i[101];
  assign o[100] = i[100];
  assign o[99] = i[99];
  assign o[98] = i[98];
  assign o[97] = i[97];
  assign o[96] = i[96];
  assign o[95] = i[95];
  assign o[94] = i[94];
  assign o[93] = i[93];
  assign o[92] = i[92];
  assign o[91] = i[91];
  assign o[90] = i[90];
  assign o[89] = i[89];
  assign o[88] = i[88];
  assign o[87] = i[87];
  assign o[86] = i[86];
  assign o[85] = i[85];
  assign o[84] = i[84];
  assign o[83] = i[83];
  assign o[82] = i[82];
  assign o[81] = i[81];
  assign o[80] = i[80];
  assign o[79] = i[79];
  assign o[78] = i[78];
  assign o[77] = i[77];
  assign o[76] = i[76];
  assign o[75] = i[75];
  assign o[74] = i[74];
  assign o[73] = i[73];
  assign o[72] = i[72];
  assign o[71] = i[71];
  assign o[70] = i[70];
  assign o[69] = i[69];
  assign o[68] = i[68];
  assign o[67] = i[67];
  assign o[66] = i[66];
  assign o[65] = i[65];
  assign o[64] = i[64];
  assign o[63] = i[63];
  assign o[62] = i[62];
  assign o[61] = i[61];
  assign o[60] = i[60];
  assign o[59] = i[59];
  assign o[58] = i[58];
  assign o[57] = i[57];
  assign o[56] = i[56];
  assign o[55] = i[55];
  assign o[54] = i[54];
  assign o[53] = i[53];
  assign o[52] = i[52];
  assign o[51] = i[51];
  assign o[50] = i[50];
  assign o[49] = i[49];
  assign o[48] = i[48];
  assign o[47] = i[47];
  assign o[46] = i[46];
  assign o[45] = i[45];
  assign o[44] = i[44];
  assign o[43] = i[43];
  assign o[42] = i[42];
  assign o[41] = i[41];
  assign o[40] = i[40];
  assign o[39] = i[39];
  assign o[38] = i[38];
  assign o[37] = i[37];
  assign o[36] = i[36];
  assign o[35] = i[35];
  assign o[34] = i[34];
  assign o[33] = i[33];
  assign o[32] = i[32];
  assign o[31] = i[31];
  assign o[30] = i[30];
  assign o[29] = i[29];
  assign o[28] = i[28];
  assign o[27] = i[27];
  assign o[26] = i[26];
  assign o[25] = i[25];
  assign o[24] = i[24];
  assign o[23] = i[23];
  assign o[22] = i[22];
  assign o[21] = i[21];
  assign o[20] = i[20];
  assign o[19] = i[19];
  assign o[18] = i[18];
  assign o[17] = i[17];
  assign o[16] = i[16];
  assign o[15] = i[15];
  assign o[14] = i[14];
  assign o[13] = i[13];
  assign o[12] = i[12];
  assign o[11] = i[11];
  assign o[10] = i[10];
  assign o[9] = i[9];
  assign o[8] = i[8];
  assign o[7] = i[7];
  assign o[6] = i[6];
  assign o[5] = i[5];
  assign o[4] = i[4];
  assign o[3] = i[3];
  assign o[2] = i[2];
  assign o[1] = i[1];
  assign o[0] = i[0];

endmodule

