verdiWindowResize -win $_Verdi_1 "65" "24" "1649" "840"
debImport "-f" "filelist.f"
debLoadSimResult /home/tjx/DIY_CPU/tb.fsdb
wvCreateWindow
verdiDockWidgetDisplay -dock widgetDock_WelcomePage
verdiDockWidgetHide -dock widgetDock_WelcomePage
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0" -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" -win $_nTrace1
srcSetScope -win $_nTrace1 "openmips_min_sopc_tb.openmips_min_sopc0.openmips0" \
           -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1" -win \
           $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1" -win \
           $_nTrace1
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1" -delim \
           "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "regs" -win $_nTrace1
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
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 319151.825564 -snap {("G1" 2)}
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 621674.844278 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 689761.781343 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 649774.613853 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 669310.329268 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 690168.775414 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 770412.034373 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 990002.450089 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 1009436.416986 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 1048989.854464 -snap {("G1" 4)}
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -delim "."
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "HI" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "LO" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
