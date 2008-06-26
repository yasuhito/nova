.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

.yrl.erl:
	erlc -W $<

ERL = erl -boot start_clean

# コンパイルしたい Erlang モジュールのリストをここに書く

MODS = cpu_monitor_supervisor

all: compile

compile: ${MODS:%=%.beam} subdirs

# アプリの実行
application1: compile
	${ERL} -pa Dir1 -s application1 start Arg1 Arg2

subdirs:

clean:
	rm -rf *.beam erl_crash.dump
