/**
 * backbone.fetch.js
 * Peter Pham: I wrote this plugin to emit the 'beforeFetch', 'errorFetch', 'successFetch' events on Backbone Model and Collection
 */

(function(window) {
	"use strict";

	var Backbone = window.Backbone;

	var _emitFetch = function(name){
		var obj = Backbone[name],
			old_fetch = obj.prototype.fetch;
		obj.prototype.fetch = function(){
			var self = this;
			this.trigger('beforeFetch', this);
			return old_fetch.apply(this, arguments).error(function(xhr, error, exception){
				self.trigger('errorFetch', self, xhr, error, exception);
			}).success(function(object, evt, xhr){
				self.fetched = true;
				self.trigger('successFetch', object, xhr);
			});
		};
	};

	_emitFetch('Model');
	_emitFetch('Collection');

	/**
	 * overwrite Backbone sync and force ajax busted
	 */
	var old_sync = Backbone.sync;
	Backbone.sync = function(method, model, options, error) {
		options.cache = false;
		return old_sync.apply(this, arguments);
	};


})(this);