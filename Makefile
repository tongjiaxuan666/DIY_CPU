RTL := ./plus_change.v
TB := ./tb.v
SEED ?= $(shell date +%s)

all:compile simulate verdi

compile:
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed -sverilog +v2k -R -nc -debug_pp -LDFLAGS -rdynamic -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a -f filelist.f -l com.log

simulate:
	#./simv +ntb_random_seed=$(SEED) -l sim.log

verdi:
	verdi -f filelist.f -ssf tb.fsdb

run_dve:
	dve -vpd vcdplus.vpd &

clean:
	rm -rf *.log csrc simv* *.fsdb *.key *.vpd DVEfiles coverage *.vdb
