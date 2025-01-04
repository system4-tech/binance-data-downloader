#!/usr/bin/env bash

. ./../lib/binance.sh

usage() {
  cat <<EOF
Usage: $0 -p <product> -i <interval> -s <start_time> [-e <end_time>] [-f <format>] [-o <output_dir>]

Options:
  -p    Product: spot, um, cm [required]
  -i    Interval (e.g., 1d, 1h, 15m) [required]
  -s    Start time [required]
  -e    End time (default: current time)
  -f    Output format: csv, tsv, ndjson (default: csv)
  -o    Output directory (default: current directory)
  -P    Maximum parallel jobs (default: 4)
  -h    Show this help message
EOF
}

main() {
  local product interval start_time end_time symbols klines
  local format="csv"
  local output_dir="."
  local max_parallel=4 num_jobs=0
  local start_date
  
  # todo: adjust default end_time based on interval
  end_time=$(now)

  while getopts ":p:i:s:e:f:o:P:h" opt; do
    case "$opt" in
      p) product="$OPTARG" ;;
      i) interval="$OPTARG" ;;
      s) start_time="$OPTARG" ;;
      e) end_time="$OPTARG" ;;
      f) format="$OPTARG" ;;
      o) output_dir="$OPTARG" ;;
      P) max_parallel="$OPTARG" ;;
      h) usage; exit 0 ;;
      *) usage; exit 1 ;;
    esac
  done

  : "${product:?Missing required <product> argument}"
  : "${interval:?Missing required <interval> argument}"
  : "${start_time:?Missing required <start_time> argument}"

  start_date=$(format_date "$start_time" "%Y-%m-%d")
  output_dir="${output_dir%/}"

  case "$format" in
    tsv|csv|ndjson) ;;
    *) fail "Error: Invalid format '$format'. Valid formats are: tsv, csv, ndjson." ;;
  esac

  if ! dir_exists "$output_dir"; then
    fail "Directory does not exist: ${output_dir}"
  fi

  symbols=$(symbols "$product")

  process_symbol() {
    local symbol=$1
    local filename="${output_dir}/${symbol}-${interval}-${start_date}.${format}"
    local temp_file

    temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT

    # shellcheck disable=SC2086
    klines "$product" "$symbol" "$interval" "$start_time" "$end_time" | \
      json_to_$format > "$temp_file"

    if [ -s "$temp_file" ]; then
      mv "$temp_file" "$filename"
      echo "$filename"
    fi
  }

  for symbol in $symbols; do
    process_symbol "$symbol" &
    ((num_jobs++))

    if (( num_jobs >= max_parallel )); then
      wait -n
      ((num_jobs--))
    fi
  done

  wait
}

main "$@"
