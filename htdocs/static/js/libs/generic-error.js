(function() {

	// Self-contained generic error message with link to reload the current page.
	window.PB_generic_error = function() {
		var body = document.getElementsByTagName('body')[0],
			msgDiv = document.createElement('div');

		msgDiv.setAttribute('style', 'margin:200px auto 0 auto;width:300px;border:3px solid #ddd;padding:20px;');
		msgDiv.innerHTML = 'There was an error loading the application. <a href="javascript:window.location.reload(true);">Please try again.</a>';

		body.innerHTML = '';
		body.appendChild(msgDiv);
	};

	// Default catch-all error. Overridden in main.js once the app loads.
	window.onerror = function() {
		return window.PB_generic_error.apply(this, arguments);
	};

})();
