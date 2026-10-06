# Practical DFT & ATPG Demonstration (Tiny ALU & Sequential Scan Flow)

An end-to-end practical demonstration of Design for Testability (DFT), Automatic Test Pattern Generation (ATPG), Fault Modeling, and Scan Chain Insertion using open-source VLSI tools (**Fault 0.6.1**, **Atalanta 2.0**, **Yosys**, and **Icarus Verilog**).

Designed with the **SCL 1.2µm Standard-Cell Library** (`pdk_scl_1p2um`) and **OSU 0.35µm Standard-Cell Library**.

---

## 🌟 Key Results & Highlights

- **Combinational Tiny ALU**:
  - Synthesized into 3 SCL 1.2µm cells (`2x NOR200`, `1x ADNR01`).
  - Evaluated 14 physical fault sites (28 uncollapsed stuck-at faults, 18 collapsed).
  - ATPG achieved **100.000% Fault Coverage** with only **6 compacted test vectors** (down from 8 exhaustive truth table vectors).
  - 100% bit-for-bit logical equivalence between RTL and gate netlist verified across all input combinations.
  - Demonstrated fault activation, propagation through sensitized paths, and fault masking by controlling values.
- **Sequential Scan ALU**:
  - 2-bit registered ALU with asynchronous reset.
  - Performed automated scan insertion (`fault chain`) yielding a **9-bit Scan Chain** (2 internal scan flip-flops + 7 boundary scan flip-flops).
  - Verified 100% scan chain integrity.
  - Demonstrated full Scan Protocol: **Shift-In ➔ Functional Capture ➔ Shift-Out ➔ Signature Comparison**.

---

## 📂 Repository Structure

```
fault_demo/
├── alu/                                # Combinational Tiny ALU files
│   ├── tiny_alu.sv                    # Original RTL
│   ├── tb.v                           # Functional testbench
│   ├── tiny_alu_netlist.v             # Synthesized SCL 1.2um netlist
│   ├── tiny_alu_fault_netlist.v       # Netlist formatted for Fault tool
│   ├── c1d_cells.v                    # SCL 1.2um cell models for Fault/Icarus
│   ├── tiny_alu.bench                 # ISCAS bench format netlist
│   └── tb_fault_injection.v           # Verilog testbench for manual fault injection
│
├── scan_demo/                          # Sequential Scan DFT files
│   ├── seq_alu.sv                     # 2-bit registered ALU RTL
│   ├── tb_seq_alu.v                   # Functional testbench
│   ├── seq_alu_netlist.v              # Synthesized sequential netlist
│   ├── seq_alu_cut.v                  # Cut netlist for combinational ATPG
│   ├── seq_alu_chained.v              # Netlist with 9-bit scan chain inserted
│   └── tb_scan_demo.v                 # Shift -> Capture -> Shift-Out testbench
│
├── scripts/                            # Automated flow scripts
│   ├── 01_rtl_sim.sh                  # Behavioral RTL simulation
│   ├── 02_synthesis.sh                # Yosys synthesis with SCL 1.2um PDK
│   ├── 03_gls_sim.sh                  # Gate-Level Simulation (GLS)
│   ├── 04_bench_export.sh             # Export to ISCAS bench & generate fault list
│   ├── 05_atpg_atalanta.sh            # Atalanta ATPG (100% coverage)
│   ├── 06_fault_tool_atpg.sh          # Fault tool simulation engine
│   ├── 07_manual_fault_injection.sh   # Manual fault injection & masking demo
│   ├── 08_scan_dft_flow.sh            # Complete Scan DFT flow
│   └── run_all.sh                     # Master one-click execution script
│
├── patterns/                           # Generated test vectors
│   ├── atalanta_patterns.test         # 6 compacted patterns from Atalanta
│   ├── fault_patterns.tv.json         # Patterns & coverage list from Fault tool
│   ├── scan_patterns.vec.bin          # Assembled scan input binary vectors
│   └── scan_golden.out.bin            # Assembled scan golden output binary vectors
│
├── reports/                            # Comprehensive execution reports
│   ├── 01_synthesis_report.txt        # Cell counts, area, and mapped logic
│   ├── 02_equivalence_report.txt      # 100% RTL vs GLS truth table match
│   ├── 03_fault_list.txt              # Complete 28 stuck-at fault list
│   ├── 04_atpg_report.txt             # Atalanta ATPG performance report
│   ├── 05_fault_simulation_report.txt # Fault tool simulation output
│   ├── 06_coverage_report.txt         # 100.0% coverage formula and verification
│   ├── 07_manual_fault_detection_matrix.txt # Pin-by-pin activation and masking table
│   └── 08_scan_dft_report.txt         # Scan chain architecture and protocol
│
├── pdk_scl_1p2um/                      # SCL 1.2µm Standard Cell Library & PDK
└── docs/
    └── DFT_TUTORIAL.md                # Comprehensive beginner DFT & ATPG tutorial
```

---

## 🚀 Quick Start: How to Run

Clone and run the complete flow in a single command:

```bash
git clone https://github.com/122Bapuji/fault_demo.git
cd fault_demo
chmod +x scripts/*.sh
./scripts/run_all.sh
```

Or run any stage independently:
```bash
./scripts/01_rtl_sim.sh                 # Verify behavioral RTL
./scripts/02_synthesis.sh               # Synthesize netlist with SCL 1.2um PDK
./scripts/03_gls_sim.sh                 # Verify gate-level equivalence
./scripts/04_bench_export.sh            # Generate ISCAS bench netlist
./scripts/05_atpg_atalanta.sh           # Run Atalanta ATPG (100% coverage)
./scripts/06_fault_tool_atpg.sh         # Run Fault tool simulation engine
./scripts/07_manual_fault_injection.sh  # Run fault activation & masking demo
./scripts/08_scan_dft_flow.sh           # Run complete Scan DFT flow
```

---

## 📊 Summary of Test Patterns (Atalanta & Fault Tool)

| Pattern # | Primary Inputs (A B SEL) | Golden Output (Y) | Target Mode | Detected Faults |
|:---:|:---:|:---:|:---:|:---|
| **1** | `0 1 1` | `1` | OR Mode | `_2_.IN1/0`, `_3_.B/0`, `Y/0`, `_3_.A/0`, `_2_.IN2/0`, `_4_.OUT1/0`, `B/0`, `SEL/0`, `_4_.IN1/1`, `_3_.OUT1/1`, `_2_.OUT1/1`, `_4_.IN2/1` |
| **2** | `0 0 1` | `0` | OR Mode Zero | `A/1`, `_3_.B/1`, `Y/1`, `_2_.IN2/1`, `_4_.OUT1/1`, `_3_.C/1`, `B/1`, `_3_.OUT1/0`, `_4_.IN2/0` |
| **3** | `0 1 0` | `0` | AND Mode Zero | `A/1`, `_2_.IN1/1`, `Y/1`, `_3_.A/1`, `_4_.OUT1/1`, `_3_.C/1`, `SEL/1`, `_3_.OUT1/0`, `_4_.IN2/0` |
| **4** | `1 1 0` | `1` | AND Mode One | `_4_.IN1/1`, `_3_.OUT1/1`, `_2_.OUT1/1`, `_4_.IN2/1`, `A/0`, `_3_.B/0`, `Y/0`, `_2_.IN2/0`, `_4_.OUT1/0`, `_3_.C/0`, `B/0` |
| **5** | `1 0 0` | `0` | AND Mode Zero | `_4_.IN1/0`, `_2_.OUT1/0`, `_2_.IN1/1`, `_3_.B/1`, `Y/1`, `_3_.A/1`, `_2_.IN2/1`, `_4_.OUT1/1`, `B/1`, `SEL/1` |
| **6** | `1 0 1` | `1` | OR Mode One | `A/0`, `_2_.IN1/0`, `Y/0`, `_3_.A/0`, `_4_.OUT1/0`, `_3_.C/0`, `SEL/0`, `_4_.IN1/1`, `_3_.OUT1/1`, `_2_.OUT1/1`, `_4_.IN2/1` |

**Fault Coverage**: $\frac{28}{28} \times 100\% = \mathbf{100.000\%}$.

---

## 📖 Comprehensive Tutorial

Read [`docs/DFT_TUTORIAL.md`](docs/DFT_TUTORIAL.md) for a complete explanation of:
- DFT motivation and physical defects vs. logical fault models
- Stuck-at fault modeling (SA0 / SA1)
- The 3 principles: Fault Activation, Sensitization/Propagation, and Observation
- Controlling vs. non-controlling gate values and fault masking
- ATPG algorithms (D-Algorithm, PODEM, FAN) and test vector compaction
- Full-scan chain DFT architecture and testing protocol

---

## 👤 Author
**122Bapuji**  
Email: 24b81d5703@gmail.com
