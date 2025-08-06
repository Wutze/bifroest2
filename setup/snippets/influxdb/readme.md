# InfluxDB2.x nutzen

Das Script funktioniert ausschließlich mit InfluxDB2.x

## InfluxDB

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> aggregateWindow(every: 1m, fn: sum, createEmpty: true)
  |> group(columns: ["action"])
  |> yield(name: "action_per_hour")
````

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> group(columns: ["proto"])
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
  |> yield(name: "blocked_ports")
````

## PieChart Grafana

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> group(columns: ["proto"])
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
  |> yield(name: "blocked_ports")
````

## Time Series Grafana

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> group(columns: ["proto"])
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
  |> yield(name: "blocked_ports")
````
