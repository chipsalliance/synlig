package otp_ctrl_part_pkg; // verilog_lint: waive package-filename
  parameter int NumPart = 2;
  parameter int OtpByteAddrWidth = 11;
  parameter int ConstSelWidth = 3;
  typedef enum logic [ConstSelWidth-1:0] {
    Secret0Key,
    Secret1Key,
    Secret2Key
  } key_sel_e;
  typedef enum logic [1:0] {
    Unbuffered,
    Buffered,
    LifeCycle
  } part_variant_e;
  typedef struct packed {
    part_variant_e variant;
    // Offset and size within the OTP array, in Bytes.
    logic [OtpByteAddrWidth-1:0] offset;
    logic [OtpByteAddrWidth-1:0] size;
    // Key index to use for scrambling.
    key_sel_e key_sel;
    // Attributes
    logic secret;     // Whether the partition is secret (and hence scrambled)
    logic hw_digest;  // Whether the partition has a hardware digest
    logic write_lock; // Whether the partition is write lockable (via digest)
    logic read_lock;  // Whether the partition is read lockable (via digest)
    logic ecc_fatal;  // Whether the an ECC uncorrectable error leads to a fatal alert
  } part_info_t;

  parameter part_info_t PartInfoDefault = '{
      variant:    Unbuffered,
      offset:     '0,
      size:       OtpByteAddrWidth'('hFF),
      key_sel:    key_sel_e'('0),
      secret:     1'b0,
      hw_digest:  1'b0,
      write_lock: 1'b0,
      read_lock:  1'b0,
      ecc_fatal:  1'b0
  };
  localparam part_info_t PartInfo [NumPart] = '{
    // VENDOR_TEST
    '{
      variant:    Unbuffered,
      offset:     11'd0,
      size:       64,
      key_sel:    key_sel_e'('0),
      secret:     1'b0,
      hw_digest:  1'b0,
      write_lock: 1'b1,
      read_lock:  1'b0,
      ecc_fatal:  1'b0
    },
    // CREATOR_SW_CFG
    '{
      variant:    Unbuffered,
      offset:     11'd64,
      size:       800,
      key_sel:    key_sel_e'('0),
      secret:     1'b0,
      hw_digest:  1'b0,
      write_lock: 1'b1,
      read_lock:  1'b0,
      ecc_fatal:  1'b1
    },
    // OWNER_SW_CFG
    '{
      variant:    Unbuffered,
      offset:     11'd864,
      size:       800,
      key_sel:    key_sel_e'('0),
      secret:     1'b0,
      hw_digest:  1'b0,
      write_lock: 1'b1,
      read_lock:  1'b0,
      ecc_fatal:  1'b1
    },
    // HW_CFG
    '{
      variant:    Buffered,
      offset:     11'd1664,
      size:       80,
      key_sel:    key_sel_e'('0),
      secret:     1'b0,
      hw_digest:  1'b1,
      write_lock: 1'b1,
      read_lock:  1'b0,
      ecc_fatal:  1'b1
    },
    // SECRET0
    '{
      variant:    Buffered,
      offset:     11'd1744,
      size:       40,
      key_sel:    Secret0Key,
      secret:     1'b1,
      hw_digest:  1'b1,
      write_lock: 1'b1,
      read_lock:  1'b1,
      ecc_fatal:  1'b1
    },
    // SECRET1
    '{
      variant:    Buffered,
      offset:     11'd1784,
      size:       88,
      key_sel:    Secret1Key,
      secret:     1'b1,
      hw_digest:  1'b1,
      write_lock: 1'b1,
      read_lock:  1'b1,
      ecc_fatal:  1'b1
    },
    // SECRET2
    '{
      variant:    Buffered,
      offset:     11'd1872,
      size:       88,
      key_sel:    Secret2Key,
      secret:     1'b1,
      hw_digest:  1'b1,
      write_lock: 1'b1,
      read_lock:  1'b1,
      ecc_fatal:  1'b1
    },
    // LIFE_CYCLE
    '{
      variant:    LifeCycle,
      offset:     11'd1960,
      size:       88,
      key_sel:    key_sel_e'('0),
      secret:     1'b0,
      hw_digest:  1'b0,
      write_lock: 1'b0,
      read_lock:  1'b0,
      ecc_fatal:  1'b1
    }
  };
  // OTP invalid partition default for buffered partitions.
  parameter logic [16383:0] PartInvDefault = 16384'({
    704'({
      320'hDAAF8720F255C5C84D1D9C10648A878DB1D5ABE9610E8395490EC23C0A1EDCCE280E8ECA88CEA2E9,
      384'h9470329E17324EDB1E2960279AB8F882A991BEA2CF16541724A52D80A891BCD52BE973D4C5752E3A6912899150240B3A // verilog_lint: waive line-length
    }),
    704'({
      64'h39C052C50C63C3FB,
      256'hD53651B6259AF2A4FB9DCA186AE168595B637FF7F7BF2E7C26917DDC15EB6827,
      256'hA1AFEC939D240482026740905E57CA6C1D96CF9CAB089A9CF80423F61EC116FD,
      128'h7CB3D374E7DF05B66C61869C02BC1100
    }),
    704'({
      64'hDC793769D983D0,
      128'h8561BFB99BAFAFC47DED6F942A7014DD,
      256'h9A0656978D66A3C419617EDF0BD69B2320EA378AE9812F1F53911418BCBBCCCA,
      256'h9F4C41511001F6AD24DEEF385A7B3CA65869574E09B5710738066DCD7EF4BB9B
    }),
    320'({
      64'h577127F60790BB5D,
      128'hC48FDBD8A0031C11FA602470308055C4,
      128'hABFF25A58087D34A37E5AE39A58FACEE
    }),
    640'({
      64'h2CD09F705F291B7A,
      32'h0, // unallocated space
      8'h69,
      8'h69,
      8'h69,
      8'h69,
      256'h41389646B3968A3B128F4AF0AFFC1AAC77ADEFF42376E09D523D5C06786AAC34,
      256'hFA53B8058E157CB69F1F413E87242971B6B52A656A1CAB7FEBF21E5BF1F45EDD
    }),
    6400'({
      64'h39EB436F1D5AF2D7,
      2144'h0, // unallocated space
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      512'h0,
      128'h0,
      128'h0,
      512'h0,
      2560'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0
    }),
    6400'({
      64'h7D7EA64D850E128D,
      4064'h0, // unallocated space
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      32'h0,
      64'h0,
      32'h0,
      64'h0,
      32'h0,
      32'h0,
      32'h0,
      1248'h0
    }),
    512'({
      64'h1D00E175E3739EC1,
      448'h0
    })});
endpackage
module otp_ctrl_part_buf
  import otp_ctrl_part_pkg::*;
#(
  // Partition information.
  parameter part_info_t             Info = PartInfoDefault,
  parameter logic [Info.size*8-1:0] DataDefault = '0
) ( );
endmodule;

module top();
import otp_ctrl_part_pkg::*;
for (genvar k = 0; k < NumPart; k ++) begin : gen_block
  otp_ctrl_part_buf #(
    .Info(PartInfo[k]),
    .DataDefault(PartInvDefault[PartInfo[k].offset*8 +: PartInfo[k].size*8])
  ) u_part_buf ();
end
endmodule
