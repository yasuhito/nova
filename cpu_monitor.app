{application, cpu_monitor,
[{description, "CPU Monitor"},
 {vsn, "1.0"},
 {modules, [cpu_monitor_app, cpu_monitor_supervisor, cpu_monitor_server, cpu_alarm_handler]},
 {registered, [cpu_monitor_supervisor, cpu_monitor_server, cpu_alarm_handler]},
 {applications, [kernel,stdlib]},
 {mod, {cpu_monitor_app,[]}},
 {start_phases, []}
]}.

