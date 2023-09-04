module top #(
  parameter int N   = 8,
  parameter int DW  = 32
) (
  output [DW-1:0] data_i [N]
);
  localparam int Instances = 2;

  logic [DW-1:0] mem [N];
  logic [DW-1:0] data_buf_b [N];
  logic [DW-1:0] data_buf_c [N];
  logic [DW-1:0] data_buf_e [N];

  $readmemh("mem_file.txt", mem);

  for (genvar i = 0; i < Instances; i++) begin : gen_test_a
    for (genvar j = 0; j < Instances; j++) begin : gen_input_bufs
      for (genvar k = 0; k < Instances; k++) begin : gen_data_bufs
        logic [N-1:0] req_buf_a;
        logic [DW-1:0] data_buf_a [N];
        if (i == 0 && j == 0 && k ==0) begin : gen_buf
          assign data_buf_c = data_buf_a;
        end
      end
    end
  end

  for (genvar i = 0; i < Instances; i++) begin : gen_test_b
    logic [DW-1:0] data_buf_da [N];
    for (genvar j = 0; j < Instances; j++) begin : gen_input_bufs
      logic [DW-1:0] data_buf_db [N];
      for (genvar k = 0; k < Instances; k++) begin : gen_data_bufs
        logic [DW-1:0] data_buf_dc [N];
            $readmemh("mem_file.txt", data_buf_da);
            $readmemh("mem_file.txt", data_buf_db);
            $readmemh("mem_file.txt", data_buf_dc);
            $readmemh("mem_file.txt", data_buf_e);
            assign data_buf_b = mem;
      end
    end
  end

endmodule
