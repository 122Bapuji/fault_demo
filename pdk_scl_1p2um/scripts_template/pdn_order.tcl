# ----------------------------------------------------------------------------
# OpenROAD Routing Script for SCL 1200nm for PAD PLACEMENT
# ----------------------------------------------------------------------------

# Read design files
# Update these paths to your actual SCL120 .lib and .lef locations

read_liberty /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lib/c1d_core_typ.lib

read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/tech_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/core_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/io_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/corner_c1d.lef


read_def /././OpenLane/designs/<project directory name>/runs/RUN/results/floorplan/test_fp.def

make_io_sites \
-horizontal_site IO \
-vertical_site IO \
-corner_site corner \
-offset 0
# ── 6. Place Corner Cells (always before pads) ────────────
place_corners  PadLessCorner_New 
# ── 7. Place IO Pads ──────────────────────────────────────
# SOUTH — Inputs
place_pad  U_PAD1 -row IO_SOUTH -location 1200 
place_pad  U_PAD2 -row IO_SOUTH -location 1800 
#place_pad -master PVDD01 -row IO_SOUTH -location 2500 pad_vdd_s 
#place_pad -master PVSS01 -row IO_SOUTH -location 3000 pad_vss_s 
# NORTH — Outputs
#place_pad pad_out_0 -row IO_NORTH -location 1000 
#place_pad pad_out_1 -row IO_NORTH -location 2000  
#place_pad pad_out_2 -row IO_NORTH -location 2500 
#place_pad pad_out_3 -row IO_NORTH -location 1500
#place_pad -master PVDD01 -row IO_NORTH -location 3500 pad_vdd_n 
#place_pad -master PVSS01 -row IO_NORTH -location 3000 pad_vss_n 
# WEST — Power/Ground
#place_pad -master PVDD01 -row IO_WEST -location 1800 pad_vdd_w 
#place_pad -master PVSS01 -row IO_WEST -location 2800 pad_vss_w 
#place_pad -master PVDD01 -row IO_EAST -location 900 pad_vdd_e 
#place_pad -master PVSS01 -row IO_EAST -location 1500 pad_vss_e 


# ── 9. Connect Pad Ring ───────────────────────────────────
connect_by_abutment


write_def /././OpenLane/designs/<project directory name>/runs/RUN/results/floorplan/test_io.def
