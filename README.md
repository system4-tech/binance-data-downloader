# [`binance-data-downloader.sh`](dist/binance-data-downloader.sh)

This repository contains shell scripts for downloading Binance public market data in various formats (NDJSON, CSV and TSV).

## Usage

```sh
$ binance-data-downloader -h
Usage: binance-data-downloader -p <product> -i <interval> -s <start_time> [-e <end_time>] [-f <format>] [-o <output_dir> [-P <max_parallel>]

Options:
  -p    Product: spot, um, cm [required]
  -i    Interval (e.g., 1d, 1h, 15m) [required]
  -s    Start time [required]
  -e    End time (default: current time)
  -f    Output format: csv, tsv, ndjson (default: csv)
  -o    Output directory (default: current directory)
  -P    Maximum parallel jobs (default: 4)
  -h    Show this help message

# Download CSV data for all spot symbols since 2019-01-01 (until now)
$ binance-data-downloader.sh -p spot -i 1d -s 2019-01-01 -f csv -o data/spot/
data/spot/BTCUSDT-1d-2019-01-01.csv
data/spot/ETHUSDT-1d-2019-01-01.csv
data/spot/BNBUSDT-1d-2019-01-01.csv
...
```

See [tests](tests/) for more examples.
