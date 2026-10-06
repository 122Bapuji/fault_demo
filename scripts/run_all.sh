#!/usr/bin/env bash
# ==============================================================================
# Master Script: Complete DFT & ATPG Demonstration Flow
# Project: Tiny ALU DFT & ATPG Demonstration
# Description: Executes all flow scripts end-to-end and validates all outputs
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJ_ROOT"

echo "=============================================================================="
echo "          STARTING COMPLETE DFT & ATPG FLOW (TINY ALU + SCAN DEMO)             "
echo "=============================================================================="

chmod +x scripts/*.sh

echo -e "\n--> Stage 1: RTL Functional Simulation"
bash scripts/01_rtl_sim.sh

echo -e "\n--> Stage 2: Gate-Level Synthesis (SCL 1.2um)"
bash scripts/02_synthesis.sh

echo -e "\n--> Stage 3: Gate-Level Simulation & Logical Equivalence"
bash scripts/03_gls_sim.sh

echo -e "\n--> Stage 4: ISCAS Bench Conversion & Fault Modeling"
bash scripts/04_bench_export.sh

echo -e "\n--> Stage 5: Atalanta ATPG Pattern Generation (FAN/PODEM)"
bash scripts/05_atpg_atalanta.sh

echo -e "\n--> Stage 6: Fault Tool Integration & Fault Simulation"
bash scripts/06_fault_tool_atpg.sh

echo -e "\n--> Stage 7: Manual Fault Injection & Masking Verification"
bash scripts/07_manual_fault_injection.sh

echo -e "\n--> Stage 8: Sequential Scan DFT Flow (Insertion, Cut, Asm, Sim)"
bash scripts/08_scan_dft_flow.sh

echo "=============================================================================="
echo "                   ALL DFT FLOW STEPS COMPLETED SUCCESSFULLY                  "
echo "=============================================================================="
echo "Artifacts generated:"
echo "  - Patterns:  patterns/atalanta_patterns.test, patterns/fault_patterns.tv.json"
echo "  - Reports:   reports/ (8 comprehensive reports generated)"
echo "  - Tutorial:  docs/DFT_TUTORIAL.md"
echo "=============================================================================="
