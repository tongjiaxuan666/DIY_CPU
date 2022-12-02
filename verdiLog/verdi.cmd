verdiWindowResize -win $_Verdi_1 "65" "24" "1653" "864"
debImport "-f" "filelist.f"
debLoadSimResult /home/zzy/DIY_CPU/tb.fsdb
wvCreateWindow
verdiDockWidgetDisplay -dock widgetDock_WelcomePage
verdiDockWidgetHide -dock widgetDock_WelcomePage
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0" -win $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0" -win $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0" -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" \
           -delim "."
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" \
           -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "timer_int_o" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.cp0_reg0" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.cp0_reg0" -delim \
           "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "compare_o" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "count_o" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "status_o" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "compare_o" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvSetCursor -win $_nWave2 507138.987392 -snap {("G1" 36)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
