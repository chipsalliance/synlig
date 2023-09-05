module top();
  parameter int InfoTypesWidth  = 5;
  parameter int AllPagesW       = 10;
  parameter int BankW           = 3;
  parameter int InfoPageW       = 3;
  typedef struct packed {
    logic [InfoTypesWidth-1:0] sel;
    logic [AllPagesW-1:0] addr;
  } page_addr_t;
  parameter int InfoTypes                = 3;
  function automatic integer max_info_pages(int infos[InfoTypes]);
    int current_max = 0;
    for (int i = 0; i < InfoTypes; i++) begin
      if (infos[i] > current_max) begin
        current_max = infos[i];
      end
    end
    return current_max;
  endfunction // max_info_banks
  parameter int InfosPerBank    = max_info_pages('{
    10,
    1,
    2
  });
  parameter logic [InfoTypesWidth-1:0] InfoSel = 0;
  parameter logic [BankW-1:0] Bank = 0;

  for (genvar i = 0; i < InfosPerBank; i++) begin : gen_info_priv
    localparam logic [InfoPageW-1:0] CurPage = 0;
    localparam page_addr_t CurAddr = '{sel: InfoSel, addr: {Bank, PageW'(CurPage)}};
  end
endmodule
