debImport "-f" "filelist.f"
debLoadSimResult /home/tjx/DIY_CPU/tb.fsdb
wvCreateWindow
verdiDockWidgetDisplay -dock widgetDock_WelcomePage
verdiDockWidgetHide -dock widgetDock_WelcomePage
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0" -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" \
           -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -inst "regfile1" -win $_nTrace1
srcAction -pos 97 2 1 -win $_nTrace1 -name "regfile1" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "regs" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
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
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 327394.105153 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 430293.605493 -snap {("G1" 4)}
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -win \
           $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -delim "."
        