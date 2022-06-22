# dtv-influx-exporter
A tiny tool to export statistics of DTV applications (Mirakurun, EPGStation).

Supports InfluxDB 2.x.

`docker-compose.yml`

```yaml
version: '3.8'

services:
  mirakurun:
    # ...
  epgstation:
    # ...

  influxdb:
    container_name: InfluxDB
    image: influxdb:2.3
    restart: always
    volumes:
      - influxdb:/var/lib/influxdb

  dtv-influx-exporter:
    container_name: dtv-influx-exporter
    image: ghcr.io/slashnephy/dtv-influx-exporter:master
    restart: always
    environment:
      # メトリックの取得間隔 (秒)
      INTERVAL: 10
      # Mirakurun アドレス
      MIRAKURUN_ADDR: http://mirakurun:40772
      # EPGStation アドレス
      EPGSTATION_ADDR: http://epgstation:8888
      # InfluxDB アドレス
      INFLUX_ADDR: http://influxdb:8086
      # InfluxDB データベース名
      INFLUX_DB: dtv

volumes:
  influxdb:
    local: driver
```
