all: clean deps shellcheck test build
deps:
	@wget https://raw.githubusercontent.com/system4-tech/binance-sh/refs/heads/main/lib/binance.sh -qP lib/
build:
	@awk -f inline.awk src/main.sh > dist/binance-data-downloader.sh
	@chmod +x dist/binance-data-downloader.sh
clean:
	@rm -f lib/*.sh dist/*.sh
test:
	@bats tests/*.bats
shellcheck:
	@shellcheck src/*.sh
