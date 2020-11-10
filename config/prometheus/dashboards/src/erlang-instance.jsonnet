local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local row = grafana.row;
local textPanel = grafana.text;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;

local datasource = 'Prometheus';

local beamMemoryPanel = graphPanel.new(
  title='BEAM Memory',
  datasource=datasource,
  bars=true,
  lines=false,
  stack=true,
  format='bytes',
  min=0,
)
                        .addTargets([
  prometheus.target(
    expr='erlang_vm_memory_bytes_total{namespace="$namespace", pod="$pod", kind="processes"}',
    legendFormat='Processes Memory'
  ),
  prometheus.target(
    expr='erlang_vm_memory_system_bytes_total{namespace="$namespace", pod="$pod", usage="atom"}',
    legendFormat='Atoms'
  ),
  prometheus.target(
    expr='erlang_vm_memory_system_bytes_total{namespace="$namespace", pod="$pod", usage="binary"}',
    legendFormat='Binary'
  ),
  prometheus.target(
    expr='erlang_vm_memory_system_bytes_total{namespace="$namespace", pod="$pod", usage="code"}',
    legendFormat='Code'
  ),
  prometheus.target(
    expr='erlang_vm_memory_system_bytes_total{namespace="$namespace", pod="$pod", usage="ets"}',
    legendFormat='ETS'
  ),
]);

local cpuPanel = graphPanel.new(
  title='CPU',
  datasource=datasource,
  bars=true,
  lines=false,
  formatY1='percentunit',
  formatY2='percentunit',
  min=0,
)
                 .addTargets([
  prometheus.target(
    expr='kube_pod_container_resource_limits_cpu_cores{namespace="$namespace", pod="$pod"}',
    legendFormat='CPU Limit'
  ),
  prometheus.target(
    expr='kube_pod_container_resource_requests_cpu_cores{namespace="$namespace", pod="$pod"}',
    legendFormat='CPU Requests'
  ),
  prometheus.target(
    expr='irate(erlang_vm_statistics_runtime_milliseconds{namespace="$namespace", pod="$pod"}[$interval]) / on (namespace, pod) irate(erlang_vm_statistics_wallclock_time_milliseconds[$interval])',
    legendFormat='BEAM CPU Time'
  ),
  prometheus.target(
    expr='irate(container_cpu_usage_seconds_total{namespace="$namespace", pod="$pod", container=""}[$interval]) * 1000 / on (namespace, pod) irate(erlang_vm_statistics_wallclock_time_milliseconds[$interval])',
    legendFormat='Pod CPU Time'
  ),
  prometheus.target(
    expr='irate(container_cpu_cfs_throttled_periods_total{namespace="$namespace", pod="$pod", container=""}[$interval]) / on (namespace, pod, container) irate(container_cpu_cfs_periods_total[$interval])',
    legendFormat='CPU Throttling'
  ),
])
                 .addSeriesOverride({
  alias: 'CPU Limit',
  bars: false,
  fill: 0,
  lines: true,
  color: '#890f02',
})
                 .addSeriesOverride({
  alias: 'CPU Requests',
  bars: false,
  fill: 0,
  lines: true,
  color: '#f2495c',
})
                 .addSeriesOverride({
  alias: 'BEAM CPU Time',
  zindex: 1,
  color: '#3f6833',
})
                 .addSeriesOverride({
  alias: 'Pod CPU Time',
  zindex: 2,
  color: '#ef843c',
})
                 .addSeriesOverride({
  alias: 'CPU Throttling',
  zindex: 3,
  yaxis: 2,
  bars: false,
  fill: 0,
  lines: true,
  color: '#b877d9',
});

local memoryPanel = graphPanel.new(
  title='Pod Memory',
  datasource=datasource,
  bars=true,
  lines=false,
  format='bytes',
  stack=true,
  min=0,
)
                    .addTargets([
  prometheus.target(
    expr='kube_pod_container_resource_limits_memory_bytes{namespace="$namespace", pod="$pod"}',
    legendFormat='Memory Limit'
  ),
  prometheus.target(
    expr='kube_pod_container_resource_requests_memory_bytes{namespace="$namespace", pod="$pod"}',
    legendFormat='Memory Requests'
  ),
  prometheus.target(
    expr='sum(erlang_vm_memory_system_bytes_total{namespace="$namespace", pod="$pod"})',
    legendFormat='BEAM Total'
  ),
  prometheus.target(
    expr='container_memory_rss{namespace="$namespace", pod="$pod", container=""}',
    legendFormat='Pod RSS'
  ),
  prometheus.target(
    expr='container_memory_cache{namespace="$namespace", pod="$pod", container=""}',
    legendFormat='Pod Cache'
  ),
  prometheus.target(
    expr='container_memory_usage_bytes{namespace="$namespace", pod="$pod", container=""}',
    legendFormat='Pod Usage'
  ),
])
                    .addSeriesOverride({
  alias: 'Memory Limit',
  bars: false,
  fill: 0,
  lines: true,
  stack: false,
  color: '#890f02',
})
                    .addSeriesOverride({
  alias: 'Memory Requests',
  bars: false,
  fill: 0,
  lines: true,
  stack: false,
  color: '#f2495c',
})
                    .addSeriesOverride({
  alias: 'BEAM Total',
  zindex: 1,
  color: '#ef843c',
  stack: false,
})
                    .addSeriesOverride({
  alias: 'Pod Usage',
  zindex: -1,
  color: '#3f6833',
  stack: false,
})
                    .addSeriesOverride({
  alias: 'Pod RSS',
  stack: 'A',
});

local ioPanel = graphPanel.new(
  title='IO',
  datasource=datasource,
  bars=true,
  lines=false,
  format='bytes',
)
                .addTargets([
  prometheus.target(
    expr='irate(erlang_vm_statistics_bytes_received_total{namespace="$namespace", pod="$pod"}[$interval])',
    legendFormat='Input'
  ),
  prometheus.target(
    expr='-irate(erlang_vm_statistics_bytes_output_total{namespace="$namespace", pod="$pod"}[$interval])',
    legendFormat='Output'
  ),
])
                .addSeriesOverride({
  alias: 'Input',
  color: '#73bf69',
})
                .addSeriesOverride({
  alias: 'Output',
  color: '#1f60c4',
});

local loadPanel = graphPanel.new(
  title='Load',
  datasource=datasource,
  min=0,
)
                  .addTargets([
  prometheus.target(
    expr='irate(erlang_vm_statistics_context_switches{namespace="$namespace", pod="$pod"}[$interval])',
    legendFormat='Context Switches'
  ),
  prometheus.target(
    expr='irate(erlang_vm_statistics_reductions_total{namespace="$namespace", pod="$pod"}[$interval])',
    legendFormat='Reductions'
  ),
])
                  .addSeriesOverride({
  alias: 'Context Switches',
  yaxis: 2,
});

local processesPanel = graphPanel.new(
  title='Processes',
  datasource=datasource,
  bars=true,
  lines=false,
  min=0,
)
                       .addTargets([
  prometheus.target(
    expr='erlang_vm_process_count{namespace="$namespace", pod="$pod"}',
    legendFormat='Processes'
  ),
  prometheus.target(
    expr='erlang_vm_statistics_run_queues_length_total{namespace="$namespace", pod="$pod"}',
    legendFormat='Run Queues Length'
  ),
])
                       .addSeriesOverride({
  alias: 'Run Queues Length',
  yaxis: 2,
  zindex: 1,
});

local gcPanel = graphPanel.new(
  title='GC',
  datasource=datasource,
  formatY2='bytes',
  bars=true,
  lines=false,
  min=0,
)
                .addTargets([
  prometheus.target(
    expr='irate(erlang_vm_statistics_garbage_collection_number_of_gcs{namespace="$namespace", pod="$pod"}[$interval])',
    legendFormat='Number of GCs'
  ),
  prometheus.target(
    expr='irate(erlang_vm_statistics_garbage_collection_bytes_reclaimed{namespace="$namespace", pod="$pod"}[$interval])',
    legendFormat='Bytes Reclaimed'
  ),
])
                .addSeriesOverride({
  alias: 'Bytes Reclaimed',
  yaxis: 2,
  zindex: 1,
  fill: 0,
  bars: false,
  lines: true,
});

dashboard.new(
  title='Erlang Instance Overview',
  time_from='now-3h',
  time_to='now',
  refresh='30s',
  graphTooltip='shared_crosshair',
)
.addTemplate(
  template.interval(
    name='interval',
    label='Interval',
    query='1m,5m,10m,30m,1h,6h,12h,1d,7d,14d,30d',
    current='1m',
  )
)
.addTemplate(
  template.new(
    name='namespace',
    label='Namespace',
    datasource=datasource,
    query='label_values(erlang_vm_process_count, namespace)',
    refresh='load',
  )
)
.addTemplate(
  template.new(
    name='service',
    label='Service',
    datasource=datasource,
    query='label_values(erlang_vm_process_count{namespace="$namespace"}, service)',
    refresh='load',
  )
)
.addTemplate(
  template.new(
    name='pod',
    label='Pod',
    datasource=datasource,
    query='label_values(erlang_vm_process_count{namespace="$namespace", service="$service"}, pod)',
    refresh='time',
  )
)
.addPanels([
  // left column
  beamMemoryPanel { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  cpuPanel { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  loadPanel { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  gcPanel { gridPos: { h: 5, w: 12, x: 0, y: 0 } },
  // right column
  memoryPanel { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  ioPanel { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
  processesPanel { gridPos: { h: 5, w: 12, x: 12, y: 0 } },
])
