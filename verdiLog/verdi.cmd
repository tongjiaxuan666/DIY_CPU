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
srcHBSelect "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "openmips_min_sopc_tb.openmips_min_sopc0.openmips0.ex0" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "HI" -win $_nTrace1
srcSelect -signal "LO" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomIn -win $_nWave2
