verdiWindowResize -win $_Verdi_1 "65" "24" "1855" "1056"
debImport "-f" "filelist.f"
debLoadSimResult /home/zzy/DIY_CPU/tb.fsdb
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
srcSelect -signal "wb_wd_i" -win $_nTrace1
srcSelect -signal "wb_wreg_i" -win $_nTrace1
srcSelect -signal "wb_wdata_i" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -inst "regfile1" -win $_nTrace1
srcAction -pos 89 2 2 -win $_nTrace1 -name "regfile1" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "regs" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 311788.579198 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 324916.519375 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 372505.302515 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 421735.078178 -snap {("G1" 4)}
                                                        