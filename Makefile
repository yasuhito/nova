.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

.yrl.erl:
	erlc -W $<

ERL = erl -boot start_sasl -config nova_test

MODS = cpu_monitor_app cpu_monitor_supervisor cpu_monitor_server cpu_alarm_handler \
	plain_server hostname_server \
	lib_nova heartbeat_server

all: compile

compile: ${MODS:%=%.beam} subdirs

application1: compile
	${ERL} -pa Dir1 -s application1 start Arg1 Arg2

subdirs:

clean:
	rm -rf *.beam erl_crash.dump
