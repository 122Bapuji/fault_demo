#!/usr/bin/env bash
# ==============================================================================
# Script 07: Manual Fault Injection & Masking Verification
# Project: Tiny ALU DFT & ATPG Demonstration
# Description: Demonstrates fault activation, propagation, detection, and masking
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [STEP 7] Running Manual Fault Injection & Masking Simulation ==="
cd "$PROJ_ROOT"

mkdir -p logs reports

iverilog -o logs/alu_fault_injection \
    alu/tb_fault_injection.v \
    alu/tiny_alu_netlist.v \
    alu/c1d_cells.v

vvp logs/alu_fault_injection | tee reports/07_manual_fault_detection_matrix.txt logs/07_manual_fault_injection.log

echo "=== Manual Fault Injection Simulation COMPLETED ==="
