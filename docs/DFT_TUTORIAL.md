# Complete DFT & ATPG Practical Tutorial
## From RTL to Manufacturing Test with Tiny ALU and the Fault Toolchain

---

## 1. Introduction: What is DFT?

**DFT (Design for Testability)** is a specialized discipline in VLSI design that adds dedicated hardware structures and test features into an integrated circuit (IC) before manufacturing, ensuring that physical manufacturing defects can be efficiently detected after fabrication.

In modern silicon manufacturing:
- Billions of transistors are fabricated across nanometer-scale layers.
- Even in ultra-clean semiconductor fabrication facilities ("fabs"), microscopic physical defects occur: dust particles, chemical contamination, mask misalignment, oxide breakdown, metal voids, or bridges between adjacent metal wires.
- These physical defects cause chips to fail functionally.
- **DFT is NOT functional verification**:
  - *Verification* asks: *"Did the designer write the RTL according to the specification?"*
  - *DFT / Manufacturing Testing* asks: *"Did the fab manufacture this specific piece of silicon without physical defects?"*

---

## 2. Why is DFT Required?

### 2.1 The Problem: Internal Controllability and Observability
As chips grow in complexity to millions of gates, accessing internal nodes becomes virtually impossible from the chip's external pins:
1. **Controllability**: The ability to establish a specific logic state (0 or 1) at an internal circuit node using only the primary chip inputs.
2. **Observability**: The ability to observe the logic state of an internal circuit node at the primary chip outputs.

Without DFT, testing an internal gate might require millions of clock cycles just to set the gate inputs and observe its output. With DFT, dedicated test modes (such as Scan Chains) provide direct controllability and observability of every internal flip-flop in just a few clock cycles.

### 2.2 The "Rule of Ten" (Cost of Defects)
The economic cost of finding and replacing a defective chip increases by approximately $10\times$ at each subsequent stage:
- **Wafer Probe (Die Sort)**: ~$0.10 - $0.50
- **Packaged IC Test**: ~$1.00 - $5.00
- **Printed Circuit Board (PCB) Assembly**: ~$50.00
- **System Integration**: ~$500.00
- **Field / Customer Failure (Automotive, Medical, Aerospace)**: ~$5,000+ (plus reputational damage and recalls)

DFT ensures that defective chips are caught at the **earliest possible stage** before packaging or shipping.

---

## 3. Physical Defects vs. Logical Fault Models

| Concept | Definition | Example |
|---|---|---|
| **Defect** | An unintended physical imperfection in the silicon or metal layers. | A speck of dust causing an open via, or a metal bridge between two interconnect wires. |
| **Fault** | A mathematical/logical abstraction of the defect's electrical effect on circuit operation. | A wire behaving as if it is permanently tied to Ground (0) or VDD (1). |
| **Error** | An incorrect logic state produced at an internal node or output due to an activated fault. | Node produces `0` when the correct logical value should have been `1`. |
| **Failure** | A functional deviation observed at the chip pins during system operation. | The ALU produces `8'h00` instead of `8'hFF`. |

Physical defects are infinite in variety (different resistances, sizes, shapes, capacitive couplings). It is computationally impossible for software to simulate every physical particle. Therefore, we use **abstract Fault Models**.

---

## 4. The Classical Stuck-At Fault Model (SA0 and SA1)

The **Single Stuck-At Fault (SSAF)** model is the industry standard baseline fault model. It assumes that a defect causes exactly one circuit line to remain permanently fixed at a logic state:
1. **Stuck-at-0 (SA0)**: The line acts as if it is shorted to Ground (`VSS`). It remains logic `0` regardless of what upstream gates drive it.
2. **Stuck-at-1 (SA1)**: The line acts as if it is shorted to Power (`VDD`). It remains logic `1` regardless of what upstream gates drive it.

### Why the Single Stuck-At Model Works:
Although real silicon may suffer multiple defects or bridging faults, comprehensive test patterns generated for 100% stuck-at coverage have been empirically shown to detect the vast majority of physical manufacturing defects.

---

## 5. The Three Fundamental Principles of Fault Detection

To detect any stuck-at fault at an internal node $N$ and observe it at a primary output $Y$, three conditions **must** be simultaneously met:

```
[ Primary Inputs ]
        │
        ▼ (Step 1: Justification)
[ Internal Node N ] ──── (Step 2: Activation) ────► Fault Site: Good ≠ Faulty
        │
        ▼ (Step 3: Propagation)
[ Sensitized Path through downstream gates ]
        │
        ▼ (Step 4: Observation)
[ Primary Output Y ] ────► Compare: Y_good ≠ Y_faulty (Detected!)
```

### 5.1 Principle 1: Fault Activation
- To test if a node is **Stuck-at-0 (SA0)**, the good circuit must attempt to drive that node to **`1`**.
  - If the node is healthy: it becomes `1`.
  - If the node is defective (SA0): it remains `0`.
  - *Result*: A difference $(1 \ne 0)$ is created at the fault site.
- To test if a node is **Stuck-at-1 (SA1)**, the good circuit must attempt to drive that node to **`0`**.
  - If the node is healthy: it becomes `0`.
  - If the node is defective (SA1): it remains `1`.
  - *Result*: A difference $(0 \ne 1)$ is created at the fault site.

> **Rule**: You cannot test a fault by applying the same value it is stuck at. Testing SA0 requires driving a `1`; testing SA1 requires driving a `0`.

### 5.2 Principle 2: Fault Propagation (Sensitization)
Once the difference (denoted as $D = 1/0$ or $\overline{D} = 0/1$) is created at the fault site, it must travel through downstream gates to reach a primary output.

Downstream gates have multiple inputs. The inputs not on the fault path are called **side inputs** or **off-path inputs**.
To let the fault signal pass through, every side input must be set to the **non-controlling value** of that gate:

| Gate Type | Controlling Value (Forces output, blocks fault) | Non-Controlling Value (Allows fault propagation) | Gate Output when Fault $D$ passes through |
|---|:---:|:---:|:---:|
| **AND** | `0` (output forced to 0) | **`1`** | $D \land 1 = D$ (fault passes through) |
| **NAND** | `0` (output forced to 1) | **`1`** | $\overline{D \land 1} = \overline{D}$ (fault inverted) |
| **OR** | `1` (output forced to 1) | **`0`** | $D \lor 0 = D$ (fault passes through) |
| **NOR** | `1` (output forced to 0) | **`0`** | $\overline{D \lor 0} = \overline{D}$ (fault inverted) |
| **XOR** | None (parity change) | **`0`** (non-inverting) / **`1`** (inverting) | $D \oplus 0 = D$ |

### 5.3 Principle 3: Fault Observation & Detection
The fault effect reaches an accessible chip output $Y$.
The tester compares the measured output $Y_{measured}$ against the golden simulation output $Y_{golden}$:
$$\text{If } Y_{measured} \ne Y_{golden} \implies \text{Fault is DETECTED!}$$

If any side input along the path has a controlling value, the fault is **masked / blocked**, and the defect goes unnoticed by that test pattern.

---

## 6. Detailed Walkthrough: The Tiny ALU Design

### 6.1 RTL Architecture (`alu/tiny_alu.sv`)
```verilog
module tiny_alu (
    input  A,
    input  B,
    input  SEL,
    output Y
);

wire and_out;
wire or_out;

assign and_out = A & B;
assign or_out  = A | B;

assign Y = SEL ? or_out : and_out;

endmodule
```

### 6.2 Truth Table of the ALU
| A | B | SEL | Operation Selected | Equation | Output Y |
|:---:|:---:|:---:|:---|:---|:---:|
| 0 | 0 | 0 | AND Mode (`SEL=0`) | $0 \land 0$ | **0** |
| 0 | 1 | 0 | AND Mode (`SEL=0`) | $0 \land 1$ | **0** |
| 1 | 0 | 0 | AND Mode (`SEL=0`) | $1 \land 0$ | **0** |
| 1 | 1 | 0 | AND Mode (`SEL=0`) | $1 \land 1$ | **1** |
| 0 | 0 | 1 | OR Mode (`SEL=1`) | $0 \lor 0$ | **0** |
| 0 | 1 | 1 | OR Mode (`SEL=1`) | $0 \lor 1$ | **1** |
| 1 | 0 | 1 | OR Mode (`SEL=1`) | $1 \lor 0$ | **1** |
| 1 | 1 | 1 | OR Mode (`SEL=1`) | $1 \lor 1$ | **1** |

Notice that algebraically:
$$Y = \overline{\text{SEL}}\cdot (A\cdot B) + \text{SEL}\cdot (A + B) = (\text{SEL}\cdot B) + (\text{SEL}\cdot A) + (A\cdot B) = \text{MAJ}(A, B, \text{SEL})$$
The circuit is functionally identical to a 3-input **Majority function**!

---

## 7. Synthesis & Gate-Level Netlist Analysis

When synthesized with Yosys and the SCL 1.2um standard-cell library (`c1d_core_typ.lib`), the logic is mapped into 3 standard cells (`alu/tiny_alu_netlist.v`):

```
       SEL ────────┬────────────────┐
                   │                │
         B ────┬───┼───────────┐    │
               │   │           │    │
               ▼   ▼           ▼    ▼
           ┌───────────┐   ┌─────────────┐
           │ NOR200 _2_│   │  ADNR01 _3_ │  (ADNR01: Out = ~((A & B) | C))
           └─────┬─────┘   └──────┬──────┘
                 │ net _0_        │ net _1_
                 ▼                ▼
           ┌─────────────────────────────┐
           │          NOR200 _4_         │  (NOR200: Out = ~(IN1 | IN2))
           └──────────────┬──────────────┘
                          │
                          ▼
                       Output Y
```

### Standard Cell Equations in Netlist:
1. **Gate `_2_` (`NOR200`)**:
   $$\_0\_ = \overline{\text{SEL} \lor B}$$
   - Produces `1` only when $\text{SEL}=0$ and $B=0$.
   - Produces `0` when $\text{SEL}=1$ or $B=1$.

2. **Gate `_3_` (`ADNR01`)**:
   $$\_1\_ = \overline{(\text{SEL} \land B) \lor A}$$
   - Produces `1` only when $A=0$ AND $(\text{SEL} \land B) = 0$.

3. **Gate `_4_` (`NOR200`)**:
   $$Y = \overline{\_0\_ \lor \_1\_} = \overline{\_0\_} \land \overline{\_1\_}$$
   - Produces `1` only when both inputs are `0` ($\_0\_ = 0$ AND $\_1\_ = 0$).

---

## 8. Manual Derivation of ATPG Vectors (Step-by-Step)

Let us manually derive test vectors for internal faults using the sensitized path method (D-Algorithm / PODEM concepts) and compare with the ATPG output.

---

### Manual Example 1: Net `_0_` Stuck-at-1 (`_0_ SA1`)
- **Fault Location**: Net `_0_` (output of Gate `_2_`, input `IN1` of Gate `_4_`).
- **Goal**: Detect if Net `_0_` is permanently stuck at `1`.

#### Step 1: Activation
- Target fault is SA1 $\implies$ good circuit must produce **`_0_ = 0`**.
- Formula for `_0_`: $\_0\_ = \overline{\text{SEL} \lor B} = 0 \implies \text{SEL} \lor B = 1$.
- Therefore, we need at least one of $\{\text{SEL}, B\}$ to be `1`.

#### Step 2: Propagation through Gate `_4_`
- Gate `_4_` is a NOR gate: $Y = \overline{\_0\_ \lor \_1\_}$.
- Net `_0_` carries the fault. The side input is Net `_1_`.
- Non-controlling input of NOR is **`0`**.
- Therefore, we **must** set **`_1_ = 0`**!
- What makes `_1_ = 0`?
  $$\_1\_ = \overline{(\text{SEL} \land B) \lor A} = 0 \implies (\text{SEL} \land B) \lor A = 1$$
  This requires $A=1$, or $(\text{SEL}=1 \land B=1)$.

#### Step 3: Vector Selection
Let us pick: $A = 1, B = 0, \text{SEL} = 1$.
- **Activation check**:
  $\text{SEL} \lor B = 1 \lor 0 = 1 \implies \_0\_ = \overline{1} = \mathbf{0}$.
  - Good circuit: $\_0\_ = 0$.
  - Faulty circuit: $\_0\_ = 1$.
  - Activation achieved!
- **Propagation check**:
  $(\text{SEL} \land B) \lor A = (1 \land 0) \lor 1 = 1 \implies \_1\_ = \overline{1} = \mathbf{0}$.
  - Side input `_1_` is `0` (non-controlling for NOR200).
  - Propagation path is clear!
- **Good Circuit Response**:
  $$Y_{good} = \overline{\_0\_ \lor \_1\_} = \overline{0 \lor 0} = \mathbf{1}$$
- **Faulty Circuit Response**:
  $$Y_{faulty} = \overline{1 \lor 0} = \mathbf{0}$$
- **Verdict**:
  $$Y_{good} (1) \ne Y_{faulty} (0) \implies \mathbf{DETECTED!}$$
- **Required Test Vector**: `A = 1, B = 0, SEL = 1` (Vector `101`).

---

### Manual Example 2: Net `_0_` Stuck-at-0 (`_0_ SA0`)
- **Fault Location**: Net `_0_`.
- **Target**: SA0 $\implies$ Good circuit must produce **`_0_ = 1`**.

#### Step 1: Activation
- $\_0\_ = \overline{\text{SEL} \lor B} = 1 \implies \text{SEL} = 0 \text{ and } B = 0$.

#### Step 2: Propagation through Gate `_4_`
- Side input `_1_` must be non-controlling (`0`).
- With $\text{SEL}=0$ and $B=0$:
  $$\_1\_ = \overline{(0 \land 0) \lor A} = \overline{A}$$
- To make `_1_ = 0`, we must choose **$A = 1$**.

#### Step 3: Evaluate Test Vector `A = 1, B = 0, SEL = 0` (Vector `100`):
- Good circuit:
  - $\_0\_ = \overline{0 \lor 0} = \mathbf{1}$.
  - $\_1\_ = \overline{0 \lor 1} = \mathbf{0}$.
  - $Y_{good} = \overline{1 \lor 0} = \mathbf{0}$.
- Faulty circuit (`_0_` stuck at `0`):
  - $\_0\_ = \mathbf{0}$.
  - $\_1\_ = \mathbf{0}$.
  - $Y_{faulty} = \overline{0 \lor 0} = \mathbf{1}$.
- **Verdict**:
  $$Y_{good} (0) \ne Y_{faulty} (1) \implies \mathbf{DETECTED!}$$

---

### Manual Example 3: Fault Masking / Blocking
What happens if we test `Net _1_ SA0` using input vector `A = 0, B = 0, SEL = 0`?
1. **Activation**:
   $\_1\_ = \overline{(0 \land 0) \lor 0} = \mathbf{1}$.
   The good circuit drives `1`. The faulty circuit has `_1_ = 0`.
   $\implies$ The fault is **ACTIVATED**.
2. **Propagation through Gate `_4_`**:
   Side input $\_0\_ = \overline{0 \lor 0} = \mathbf{1}$.
   Gate `_4_` is a NOR gate: $Y = \overline{\_0\_ \lor \_1\_}$.
   Because $\_0\_ = 1$ is the **controlling value** of a NOR gate:
   - In Good circuit: $Y_{good} = \overline{1 \lor 1} = \mathbf{0}$.
   - In Faulty circuit: $Y_{faulty} = \overline{1 \lor 0} = \mathbf{0}$.
   - $Y_{good} = Y_{faulty} = 0$.
   - **Result**: The fault effect cannot reach output $Y$. It is **MASKED** by the controlling `1` on `_0_`!

This proves why test vector selection requires satisfying **both** activation AND propagation constraints across all paths.

---

## 9. Comprehensive Fault Detection Table

The table below summarizes results from our automated Verilog fault simulation testbench (`alu/tb_fault_injection.v`):

| # | Target Fault Site | Fault Type | Applied Pattern (A B SEL) | Good Y | Faulty Y | Activated? | Propagated? | Detected? | Notes |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | Net `_0_` (Gate `_2_` OUT) | SA0 | 1 0 0 | 0 | 1 | YES | YES | **YES** | Good `_0_` is 1; faulty is 0 |
| 2 | Net `_0_` (Gate `_2_` OUT) | SA1 | 1 0 1 | 1 | 0 | YES | YES | **YES** | Good `_0_` is 0; faulty is 1 |
| 3 | Net `_1_` (Gate `_3_` OUT) | SA0 | 0 1 0 | 0 | 1 | YES | YES | **YES** | Good `_1_` is 1; faulty is 0 |
| 4 | Net `_1_` (Gate `_3_` OUT) | SA1 | 1 1 0 | 1 | 0 | YES | YES | **YES** | Good `_1_` is 0; faulty is 1 |
| 5 | Primary Output `Y` | SA0 | 1 1 0 | 1 | 0 | YES | YES | **YES** | Direct observation |
| 6 | Primary Output `Y` | SA1 | 0 0 1 | 0 | 1 | YES | YES | **YES** | Direct observation |
| 7 | Primary Input `A` | SA0 | 1 1 0 | 1 | 0 | YES | YES | **YES** | Tested via AND mode |
| 8 | Primary Input `A` | SA1 | 0 0 1 | 0 | 1 | YES | YES | **YES** | Tested via OR mode |
| 9 | Primary Input `B` | SA0 | 1 1 0 | 1 | 0 | YES | YES | **YES** | Tested via AND mode |
| 10 | Primary Input `B` | SA1 | 0 0 1 | 0 | 1 | YES | YES | **YES** | Tested via OR mode |
| 11 | Primary Input `SEL` | SA0 | 1 0 1 | 1 | 0 | YES | YES | **YES** | Differentiates OR from AND |
| 12 | Primary Input `SEL` | SA1 | 1 0 0 | 0 | 1 | YES | YES | **YES** | Differentiates AND from OR |
| 13 | Primary Input `A` | SA0 | 1 0 0 | 0 | 0 | YES | NO | **NO (MASKED)** | Masked: in AND mode with $B=0$, output remains 0 |
| 14 | Net `_1_` | SA0 | 0 0 0 | 0 | 0 | YES | NO | **NO (MASKED)** | Masked: Gate `_4_` input `_0_ = 1` forces $Y=0$ |

---

## 10. Automated ATPG Results (Atalanta & Fault Tool)

### 10.1 Atalanta Test Vector Generation
Running `atalanta alu/tiny_alu.bench` yielded **6 test patterns** with **100.000% fault coverage**:

```
* Test patterns and fault free responses:
   1: 011  => 1
   2: 001  => 0
   3: 010  => 0
   4: 110  => 1
   5: 100  => 0
   6: 101  => 1
```

### 10.2 Why Only 6 Vectors are Needed (Test Compaction)
For 3 inputs ($A, B, \text{SEL}$), the exhaustive truth table contains $2^3 = 8$ vectors.
The 2 vectors omitted by Atalanta are:
- `A=0, B=0, SEL=0` ($Y=0$)
- `A=1, B=1, SEL=1` ($Y=1$)

Every single fault that `000` or `111` could detect is **already detected** by one of the other 6 vectors.
Atalanta performed **Reverse-Order and Shuffling Compaction** to eliminate redundant test vectors, saving tester memory and reducing test time on the production floor.

---

## 11. Fault Simulation & Coverage Calculation

### 11.1 The Fault Coverage Formula
$$\text{Fault Coverage (\%)} = \frac{\text{Detected Faults}}{\text{Total Testable Faults}} \times 100\%$$

$$\text{Fault Efficiency (\%)} = \frac{\text{Detected Faults}}{\text{Total Faults} - \text{Identified Redundant Faults}} \times 100\%$$

### 11.2 Actual Project Metrics
- **Total Fault Sites**: 14 sites
- **Total Stuck-At Faults (Uncollapsed)**: 28 faults
- **Collapsed Faults (Atalanta)**: 18 representative faults
- **Detected Faults**: 28 / 28 (100.0%)
- **Undetected Faults**: 0
- **Redundant / Untestable Faults**: 0
- **Actual Coverage**:
  $$\text{Coverage} = \frac{28}{28} \times 100\% = \mathbf{100.000\%}$$

---

## 12. Sequential Scan DFT Demonstration (`scan_demo/`)

### 12.1 Why Combinational ATPG Fails for Sequential Circuits
In pure combinational circuits, every gate input can be controlled directly from primary inputs, and every gate output reaches a primary output in 1 cycle.
In **sequential circuits**, states are stored in internal flip-flops:
- You cannot arbitrarily load a state into flip-flops from external pins in 1 cycle.
- You cannot directly see the flip-flop contents at external pins in 1 cycle.
- Sequential ATPG is computationally complex and often fails to achieve high coverage.

### 12.2 The Solution: Full Scan Design
Scan design modifies ordinary flip-flops into **Scan Flip-Flops (SFFs)** equipped with a 2-to-1 multiplexer on the D input:
- When **`shift = 0` (Functional Mode)**: D input comes from combinational logic ($D_{func}$).
- When **`shift = 1` (Scan Mode)**: D input comes from the preceding flip-flop ($ScanIn$).

All flip-flops are connected into a serial **Scan Chain**:
$$\text{sin} \longrightarrow \text{FF}_0 \longrightarrow \text{FF}_1 \longrightarrow \dots \longrightarrow \text{FF}_{N-1} \longrightarrow \text{sout}$$

```
                ┌──────────────────────────────────────────────┐
                │             Combinational Logic              │
                │                                              │
                └───▲───────────────▲──────────────────────┬───┘
                    │               │                      │
       Scan In (sin)│               │                      │
         │          │               │                      │
         ▼          │               │                      ▼
      ┌─────┐       │            ┌─────┐                ┌─────┐
      │ MUX ├───────┤            │ MUX ├────────────────┤ MUX │
      └▲─┬──┘       │            └▲─┬──┘                └▲─┬──┘
       │ │          │             │ │                    │ │
 shift ┤ ▼          │       shift ┤ ▼              shift ┤ ▼
       │┌─────────┐ │             │┌─────────┐           │┌─────────┐
       ─┤ DFF 0   ├─┴──────────────┤ DFF 1   ├────────────┤ DFF N-1 ├──► Scan Out (sout)
        │         │                │         │            │         │
    clk─┤>        │            clk─┤>        │        clk─┤>        │
        └─────────┘                └─────────┘            └─────────┘
```

### 12.3 The 4-Step Scan Testing Protocol
1. **Scan Shift-In**:
   - Set `test = 1` and `shift = 1`.
   - Apply $N$ clock cycles to shift the desired test vector serially into the chain via `sin`.
2. **Functional Launch & Capture**:
   - Set `shift = 0`.
   - Apply **1 clock cycle** on `clk`.
   - The combinational logic evaluates the loaded state and captures the response into the flip-flops.
3. **Scan Shift-Out**:
   - Set `shift = 1`.
   - Apply $N$ clock cycles on `clk`.
   - The captured response bits are shifted out via `sout` (simultaneously shifting in the next test pattern!).
4. **Response Compare**:
   - Compare the bitstream from `sout` with the golden expected simulation vector.

### 12.4 Project Scan Results (`scan_demo/`)
In our project:
- We designed a 2-bit registered sequential ALU (`scan_demo/seq_alu.sv`).
- Used Fault's automated scan insertion engine:
  ```bash
  fault chain --cellModel osu035_stdcells.v --liberty osu035_stdcells.lib \
      --output scan_demo/seq_alu_chained.v --clock clk --reset rst \
      scan_demo/seq_alu_netlist.v
  ```
- **Result**:
  - Internal scan flip-flops chained: 2
  - Boundary scan flip-flops chained: 7
  - Total scan chain length: **9 flip-flops**
  - Dedicated scan signals added: `sin`, `sout`, `shift`, `test`, `tck`.
  - Scan integrity verified: **PASSED (100% integrity)**.

---

## 13. Project Structure & File Guide

```
fault_demo/
├── alu/                                # Combinational Tiny ALU directory
│   ├── tiny_alu.sv                    # Original behavioral RTL
│   ├── tb.v                           # Original functional testbench
│   ├── tiny_alu_netlist.v             # Synthesized SCL 1.2um netlist
│   ├── tiny_alu_fault_netlist.v       # Netlist formatted with clock port for Fault
│   ├── c1d_cells.v                    # Standard cell Verilog models for Fault/Icarus
│   ├── tiny_alu.bench                 # ISCAS bench netlist for Atalanta
│   └── tb_fault_injection.v           # Verilog testbench demonstrating fault injection
│
├── scan_demo/                          # Sequential Scan DFT directory
│   ├── seq_alu.sv                     # 2-bit registered ALU RTL
│   ├── tb_seq_alu.v                   # Functional testbench
│   ├── seq_alu_netlist.v              # Synthesized sequential netlist
│   ├── seq_alu_cut.v                  # Cut netlist for combinational ATPG
│   ├── seq_alu_chained.v              # Netlist with 9-bit scan chain inserted
│   └── tb_scan_demo.v                 # Testbench demonstrating Shift -> Capture -> Shift-Out
│
├── scripts/                            # Automated flow scripts
│   ├── 01_rtl_sim.sh                  # Runs RTL simulation
│   ├── 02_synthesis.sh                # Synthesizes ALU with SCL 1.2um library
│   ├── 03_gls_sim.sh                  # Runs Gate-Level Simulation & equivalence check
│   ├── 04_bench_export.sh             # Converts netlist to ISCAS bench & extracts fault list
│   ├── 05_atpg_atalanta.sh            # Generates test patterns using Atalanta
│   ├── 06_fault_tool_atpg.sh          # Runs Fault tool ATPG & fault simulation
│   ├── 07_manual_fault_injection.sh   # Runs manual fault injection testbench
│   ├── 08_scan_dft_flow.sh            # Complete Scan DFT flow (synth, cut, chain, asm, sim)
│   └── run_all.sh                     # Master script: executes entire flow end-to-end
│
├── patterns/                           # Generated test patterns
│   ├── atalanta_patterns.test         # 6 compacted patterns from Atalanta
│   ├── fault_patterns.tv.json         # Patterns & per-fault coverage list from Fault tool
│   ├── scan_patterns.vec.bin          # Assembled scan input binary vectors
│   └── scan_golden.out.bin            # Assembled scan golden output binary vectors
│
├── reports/                            # Comprehensive execution reports
│   ├── 01_synthesis_report.txt        # Cell counts, area, and logic function
│   ├── 02_equivalence_report.txt      # 100% RTL vs GLS truth table match
│   ├── 03_fault_list.txt              # Complete 28 stuck-at fault list
│   ├── 04_atpg_report.txt             # Atalanta ATPG performance and patterns
│   ├── 05_fault_simulation_report.txt # Fault tool simulation output
│   ├── 06_coverage_report.txt         # 100.0% coverage formula and verification
│   ├── 07_manual_fault_detection_matrix.txt # Pin-by-pin activation and masking table
│   └── 08_scan_dft_report.txt         # Scan chain architecture and protocol
│
└── docs/
    └── DFT_TUTORIAL.md                # This comprehensive beginner tutorial
```

---

## 14. How to Reproduce All Results

To execute the entire flow and regenerate all patterns, logs, and reports in a single command:

```bash
cd /mnt/g/VLSI_Projects/capstone/fault_demo
./scripts/run_all.sh
```

Or run any individual stage as needed:
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
