default: build-gh build-prod

serve:
	hugo serve -b /

build-gh: clean
	hugo -b https://aakatev.github.io/blog/

build-prod: clean
	hugo -b https://artem.lol/ -d www

clean:
	rm -rf docs www