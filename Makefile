all: components node_modules

components: node_modules component.json
	node_modules/bower/bin/bower install
	find . -type f -name *.css -exec perl -e "s/\@import\surl\(.*//g;" -pi.save {} \;
	touch $@
node_modules: package.json
	npm install
	touch $@

clean:
	rm -Rf components node_modules