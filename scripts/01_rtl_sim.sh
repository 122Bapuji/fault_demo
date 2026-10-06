#!/usr/bin/env bash
# ==============================================================================
# Script 01: RTL Functional Simulation
# Project: Tiny ALU DFT & ATPG Demonstration
# Description: Compiles and runs behavioral RTL simulation of tiny_alu
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [STEP 1] Running RTL Functional Simulation ==="
cd "$PROJ_ROOT"

mkdir -p logs reports

iverilog -g2012 -o logs/alu_rtl_sim alu/tb.v alu/tiny_alu.sv
vvp logs/alu_rtl_sim | tee logs/01_rtl_sim.log

echo "=== RTL Functional Simulation PASSED ==="
