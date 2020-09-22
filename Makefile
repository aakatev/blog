serve:
	hugo serve -b /

build-gh: clean
	hugo -b https://aakatev.github.io/blog/

clean:
	rm -rf docs