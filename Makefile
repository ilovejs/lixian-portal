all: public node_modules

public: components
	mkdir -p $@/css
	cp components/jquery/jquery.min.js $@
	cp components/bootswatch/js/bootstrap.min.js $@
	cp components/bootswatch/js/bootswatch.js $@

	cp components/bootswatch/simplex/bootstrap.min.css $@/css
	cp components/bootswatch/default/bootstrap-responsive.min.css $@/css

	cp -R components/bootswatch/img $@

	touch $@

components: node_modules component.json
	node_modules/bower/bin/bower install
	touch $@
node_modules: package.json
	npm install
	npm install bower
	touch $@

clean:
	rm -Rf components node_modules public