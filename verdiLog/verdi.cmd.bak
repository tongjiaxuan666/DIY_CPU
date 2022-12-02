verdiWindowResize -win $_Verdi_1 "65" "24" "1653" "902"
debImport "-f" "filelist.f"
debLoadSimResult /home/tjx/DIY_CPU/tb.fsdb
wvCreateWindow
verdiDockWidgetDisplay -dock widgetDock_WelcomePage
verdiDockWidgetHide -dock widgetDock_WelcomePage
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0" -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" \
           -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.pc_reg0" -win \
           $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1" -delim \
           "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "regs\[waddr\]" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvExpandBus -win $_nWave2 {("G1" 1)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvSelectStuckSignals -win $_nWave2
