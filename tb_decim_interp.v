`timescale 1ns / 1ps

module tb_decim_interp;

    localparam real CLK_PERIOD   = 8.333;        // ns
    localparam integer NUM_SAMPLES = 2400;        
    reg          clk;
    reg          rst_n;
    reg  [15:0]  s_data;
    reg          s_valid;
    wire         s_ready;
    wire [15:0]  decim_data;
    wire         decim_valid;
    wire [191:0] interp_data;
    wire         interp_valid;
    integer      fd_in;
    integer      fd_decim;
    integer      fd_interp;
    integer      scan_ret;
    reg  [15:0]  mem_in [0:NUM_SAMPLES-1];
    integer      idx_in;
    integer      cnt_decim;
    integer      cnt_interp;
    integer      k;
    initial  clk = 1'b0;// clk generated
    always #(CLK_PERIOD / 2.0) clk = ~clk;
    decim_interp_top dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .s_data      (s_data),
        .s_valid     (s_valid),
        .s_ready     (s_ready),
        .decim_data  (decim_data),
        .decim_valid (decim_valid),
        .interp_data (interp_data),
        .interp_valid(interp_valid)
    );
    initial begin
        fd_in = $fopen("C:/Users/vegneshrraj/Downloads/input_signal.txt", "r");
        if (fd_in == 0) begin
            $display("[ERROR] Cannot open input_signal.txt");
            $finish;
        end

        for (idx_in = 0; idx_in < NUM_SAMPLES; idx_in = idx_in + 1) begin
            scan_ret = $fscanf(fd_in, "%d\n", mem_in[idx_in]);
            if (scan_ret != 1) begin
                $display("[WARNING] EOF at sample %0d", idx_in);
                 while (idx_in < NUM_SAMPLES) begin
                    mem_in[idx_in] = 16'h0000;
                    idx_in = idx_in + 1;
                end
                idx_in = NUM_SAMPLES;   
            end
        end
        $fclose(fd_in);
        $display("[INFO] Loaded %0d input samples from input_signal.txt", NUM_SAMPLES);
    end

       initial begin
        rst_n   = 1'b0;
        s_data  = 16'h0000;
        s_valid = 1'b0;
        idx_in  = 0;
        cnt_decim  = 0;
        cnt_interp = 0;
        fd_decim  = $fopen("C:/Users/vegneshrraj/Downloads/decimated_output.txt",    "w");
        fd_interp = $fopen("C:/Users/vegneshrraj/Downloads/interpolated_output.txt", "w");
        if (fd_decim == 0 || fd_interp == 0) begin
            $display("[ERROR] Cannot open output files");
            $finish;
        end
        repeat(15) @(posedge clk);
        @(negedge clk);   
        rst_n = 1'b1;

        $display("[INFO] Reset released. Starting stimulus at t=%0t", $time);
        @(posedge clk);

        s_valid = 1'b1;
        for (idx_in = 0; idx_in < NUM_SAMPLES; idx_in = idx_in + 1) begin
             while (!s_ready) begin
                @(posedge clk);
            end
            s_data = mem_in[idx_in];
            @(posedge clk);
        end

         s_valid = 1'b0;
        s_data  = 16'h0000;

       
        repeat(300) @(posedge clk);

        $fclose(fd_decim);
        $fclose(fd_interp);

        $display("[INFO] Simulation complete at t=%0t", $time);
        $display("[INFO] Decimated  samples written : %0d", cnt_decim);
        $display("[INFO] Interpolated samples written: %0d  (= %0d valid pulses × 12)",
                 cnt_interp, cnt_interp / 12);
               $finish;
    end

    
    always @(posedge clk) begin
        if (rst_n && decim_valid) begin
            $fdisplay(fd_decim, "%0d", $signed(decim_data));
            $fflush(fd_decim);
            cnt_decim = cnt_decim + 1;
        end
    end

   
    always @(posedge clk) begin
        if (rst_n && interp_valid) begin
            for (k = 0; k < 12; k = k + 1) begin
                
                $fdisplay(fd_interp, "%0d",
                          $signed(interp_data[k*16 +: 16]));
                $fflush(fd_interp);
                cnt_interp = cnt_interp + 1;
            end
        end
    end

   
    initial begin
        $dumpfile("decim_interp_sim.vcd");
        $dumpvars(0, tb_decim_interp);
    end

    
    initial begin
        #120_000;   // 120 µs
        $display("[TIMEOUT] Simulation exceeded 120 µs — check DUT ready signal.");
        
        $fclose(fd_decim);
        $fclose(fd_interp);
        $finish;
    end

endmodule
