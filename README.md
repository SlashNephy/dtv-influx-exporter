# dtv-influx-exporter
A tiny tool to export statistics of DTV applications (mirakc, EPGStation)

Demo -> [dashboard.starry.blue](https://dashboard.starry.blue/d/RqWiLyfGk/dtv?orgId=1&refresh=10s)

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/slashnephy/dtv-influx-exporter/latest)](https://hub.docker.com/r/slashnephy/dtv-influx-exporter)

`docker-compose.yml`

```yaml
version: '3.8'

services:
  mirakc:
    # ...
  epgstation:
    # ...

  influxdb:
    container_name: InfluxDB
    image: influxdb
    restart: always
    volumes:
      - influxdb:/var/lib/influxdb

  dtv-influx-exporter:
    container_name: dtv-influx-exporter
    image: slashnephy/dtv-influx-exporter:latest
    restart: always
    environment:
      # メトリックの取得間隔 (秒)
      INTERVAL: 10
      # mirakc アドレス
      MIRAKC_ADDR: http://mirakc:40772
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
