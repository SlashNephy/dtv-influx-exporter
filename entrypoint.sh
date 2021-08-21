#!/bin/ash

set -eu

curl -i -X POST "${INFLUX_ADDR}/query" --data-urlencode "q=CREATE DATABASE ${INFLUX_DB}"

while true
do
    tuners=`curl -s "${MIRAKURUN_ADDR}/api/tuners"`
    tuners_using=`echo $tuners | jq "[.[] | select(.isUsing == true)] | length"`
    tuners_fault=`echo $tuners | jq "[.[] | select(.isFault == true)] | length"`
    tuners_users=`echo $tuners | jq "[.[].users | length] | add"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "mirakc,type=tuners using=${tuners_using},fault=${tuners_fault},users=${tuners_users}"

    programs=`curl -s ${MIRAKURUN_ADDR}/api/programs`
    programs_total=`echo $programs | jq "length"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "mirakc,type=programs total=${programs_total}"

    streams=`curl -s ${EPGSTATION_ADDR}/api/streams?isHalfWidth=true`
    streams_live_stream=`echo $streams | jq "[.items[].type | select(. == \"LiveStream\")] | length"`
    streams_live_hls=`echo $streams | jq "[.items[].type | select(. == \"LiveHLS\")] | length"`
    streams_recorded_stream=`echo $streams | jq "[.items[].type | select(. == \"RecordedStream\")] | length"`
    streams_recorded_hls=`echo $streams | jq "[.items[].type | select(. == \"RecordedHLS\")] | length"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "epgstation,type=streams live_stream=${streams_live_stream},live_hls=${streams_live_hls},recorded_stream=${streams_recorded_stream},recorded_hls=${streams_recorded_hls}"

    reserves=`curl -s ${EPGSTATION_ADDR}/api/reserves/cnts`
    reserves_normal=`echo $reserves | jq ".normal"`
    reserves_conflicts=`echo $reserves | jq ".conflicts"`
    reserves_skips=`echo $reserves | jq ".skips"`
    reserves_overlaps=`echo $reserves | jq ".overlaps"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "epgstation,type=reserves normal=${reserves_normal},conflicts=${reserves_conflicts},skips=${reserves_skips},overlaps=${reserves_overlaps}"

    recording=`curl -s ${EPGSTATION_ADDR}/api/recording?isHalfWidth=true`
    recording_total=`echo $recording | jq ".records | length"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "epgstation,type=recording total=${recording_total}"

    encode=`curl -s ${EPGSTATION_ADDR}/api/encode?isHalfWidth=true`
    encode_running=`echo $encode | jq ".runningItems | length"`
    encode_waiting=`echo $encode | jq ".waitItems | length"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "epgstation,type=encode running=${encode_running},waiting=${encode_waiting}"

    storages=`curl -s ${EPGSTATION_ADDR}/api/storages`
    storages_available=`echo $storages | jq "[.items[].available] | add"`
    storages_used=`echo $storages | jq "[.items[].used] | add"`
    curl -s -X POST "${INFLUX_ADDR}/write?db=${INFLUX_DB}&precision=s" --data-binary "epgstation,type=storages available=${storages_available},used=${storages_used}"

    sleep ${INTERVAL}
done
