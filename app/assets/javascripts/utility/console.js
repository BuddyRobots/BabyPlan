// fix the bug when console is not defined for some browsers
window.console = window.console || {
	log: function() {},
	warn: function() {},
	debug: function() {},
	info: function() {},
	error: function() {}
};