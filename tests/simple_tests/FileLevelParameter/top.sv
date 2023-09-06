parameter int FILE_PARAMETER = 10;
module top();
  initial begin
    if (FILE_PARAMETER != 10) begin
      $stop("Wrong FILE_PARAMETER value!");
    end
  end
endmodule
