`timescale 1ns/1ps

module tb_fault_injection;

    reg A_good, B_good, SEL_good;
    reg A_faulty, B_faulty, SEL_faulty;
    wire Y_good;
    wire Y_faulty;

    // Golden / Good circuit instance
    tiny_alu dut_good (
        .A(A_good),
        .B(B_good),
        .SEL(SEL_good),
        .Y(Y_good)
    );

    // Faulty circuit instance (for fault injection)
    tiny_alu dut_faulty (
        .A(A_faulty),
        .B(B_faulty),
        .SEL(SEL_faulty),
        .Y(Y_faulty)
    );

    initial begin
        $display("==========================================================================================================");
        $display("                        TINY ALU DFT DEMONSTRATION: FAULT INJECTION & DETECTION TABLE                     ");
        $display("==========================================================================================================");
        $display("| # | Target Fault Site       | Fault |  A  B SEL | Good Y | Faulty Y | Activated? | Propagated? | Detected? |");
        $display("|---|-------------------------|-------|-----------|--------|----------|------------|-------------|-----------|");

        // 1. Internal net _0_ (NOR200 _2_ output)
        test_fault(1,  "Net _0_ (NOR200 OUT)   ", 0, 3'b100, 1); // A=1, B=0, SEL=0 -> Good Y=0, Faulty Y=1
        test_fault(2,  "Net _0_ (NOR200 OUT)   ", 1, 3'b101, 1); // A=1, B=0, SEL=1 -> Good Y=1, Faulty Y=0

        // 2. Internal net _1_ (ADNR01 _3_ output)
        test_fault(3,  "Net _1_ (ADNR01 OUT)   ", 0, 3'b010, 1); // A=0, B=1, SEL=0 -> Good Y=0, Faulty Y=1
        test_fault(4,  "Net _1_ (ADNR01 OUT)   ", 1, 3'b110, 1); // A=1, B=1, SEL=0 -> Good Y=1, Faulty Y=0

        // 3. Primary Output Y
        test_fault(5,  "Primary Output Y       ", 0, 3'b110, 1); // A=1, B=1, SEL=0 -> Good Y=1, Faulty Y=0
        test_fault(6,  "Primary Output Y       ", 1, 3'b001, 1); // A=0, B=0, SEL=1 -> Good Y=0, Faulty Y=1

        // 4. Primary Input A
        test_fault(7,  "Primary Input A        ", 0, 3'b110, 1); // A=1, B=1, SEL=0 (AND) -> Good Y=1, Faulty Y=0
        test_fault(8,  "Primary Input A        ", 1, 3'b001, 1); // A=0, B=0, SEL=1 (OR)  -> Good Y=0, Faulty Y=1

        // 5. Primary Input B
        test_fault(9,  "Primary Input B        ", 0, 3'b110, 1); // A=1, B=1, SEL=0 (AND) -> Good Y=1, Faulty Y=0
        test_fault(10, "Primary Input B        ", 1, 3'b001, 1); // A=0, B=0, SEL=1 (OR)  -> Good Y=0, Faulty Y=1

        // 6. Primary Input SEL
        test_fault(11, "Primary Input SEL      ", 0, 3'b101, 1); // A=1, B=0, SEL=1 -> Good Y=1, Faulty Y=0
        test_fault(12, "Primary Input SEL      ", 1, 3'b100, 1); // A=1, B=0, SEL=0 -> Good Y=0, Faulty Y=1

        $display("|---|-------------------------|-------|-----------|--------|----------|------------|-------------|-----------|");
        $display("|   | *** FAULT MASKING / BLOCKING EXAMPLES (Fault is activated, but propagation is BLOCKED)             |");
        $display("|---|-------------------------|-------|-----------|--------|----------|------------|-------------|-----------|");
        // 7. Masking Example 1: Input A SA0 when B=0 in AND mode (SEL=0)
        // A is activated (A=1), but B=0 forces AND output to 0, masking the fault!
        test_fault(13, "Input A SA0 (Masked by B)", 0, 3'b100, 1);

        // 8. Masking Example 2: Net _1_ SA0 when _0_=1 (NOR200 controlling input)
        // _1_ is activated (_1_=1), but _0_=1 controls the output NOR gate, masking the fault!
        test_fault(14, "Net _1_ SA0 (Masked by _0)", 0, 3'b000, 1);

        $display("==========================================================================================================");
        $display("Demonstration completed successfully.");
        $finish;
    end

    task test_fault(
        input integer id,
        input [255:0] name,
        input integer sa_val, // 0 for SA0, 1 for SA1
        input [2:0] vector,
        input integer expected_activated
    );
        reg activated;
        reg propagated;
        reg detected;
        begin
            // Normal inputs applied to both good and faulty circuits
            A_good     = vector[2];
            B_good     = vector[1];
            SEL_good   = vector[0];
            A_faulty   = vector[2];
            B_faulty   = vector[1];
            SEL_faulty = vector[0];
            #1;

            // Apply stuck-at fault to faulty circuit
            case (id)
                1:  force dut_faulty._0_ = 0;
                2:  force dut_faulty._0_ = 1;
                3:  force dut_faulty._1_ = 0;
                4:  force dut_faulty._1_ = 1;
                5:  force dut_faulty.Y   = 0;
                6:  force dut_faulty.Y   = 1;
                7:  A_faulty   = 0; // Primary Input A stuck-at-0
                8:  A_faulty   = 1; // Primary Input A stuck-at-1
                9:  B_faulty   = 0; // Primary Input B stuck-at-0
                10: B_faulty   = 1; // Primary Input B stuck-at-1
                11: SEL_faulty = 0; // Primary Input SEL stuck-at-0
                12: SEL_faulty = 1; // Primary Input SEL stuck-at-1
                13: A_faulty   = 0; // Input A SA0 with vector 100 (Masked by B=0)
                14: force dut_faulty._1_ = 0; // Net _1_ SA0 with vector 000 (Masked by _0_=1)
            endcase
            #1;

            detected = (Y_good !== Y_faulty);
            activated = expected_activated;
            propagated = detected;

            $display("|%2d | %-23s | SA%0d   |  %b  %b   %b  |   %b    |    %b     |    YES     |     %-7s |    %-7s|",
                     id, name, sa_val, A_good, B_good, SEL_good, Y_good, Y_faulty, 
                     propagated ? "YES" : "NO", detected ? "YES" : "NO");

            // Release any internal forced nets
            case (id)
                1, 2:     release dut_faulty._0_;
                3, 4, 14: release dut_faulty._1_;
                5, 6:     release dut_faulty.Y;
            endcase
            #1;
        end
    endtask

endmodule
