all: public node_modules

public: bower_components
	mkdir -p $@/css
	cp $^/jquery/jquery.min.js $@
	cp $^/bootswatch/js/bootstrap.min.js $@
	cp $^/bootswatch/js/bootswatch.js $@

	cp $^/bootswatch/simplex/bootstrap.min.css $@/css
	cp $^/bootswatch/default/bootstrap-responsive.min.css $@/css

	cp -R $^/bootswatch/img $@

	touch $@

bower_components: node_modules component.json
	node_modules/bower/bin/bower install
	touch $@
node_modules: package.json
	npm install
	touch $@

clean:
	rm -Rf bower_components node_modules public