/**
 * An extension of jQuery UI's `tabs` widget to allow for a special `add new`
 * tab on the right hand side. 
 *
 * Selecting this tab will create a new tab, so we have to be careful about selecting it automatically.
 *
 */
$.widget( "ui.newtabs", $.ui.tabs, {

	/** 
	 * Add a tab heading and panel at the specified index, using the
	 * supplied HTML elements.
	 */
	addTabAndPanel: function( tabEl, panelEl, index ) {
		if ( index === undefined ) {
			index = this.anchors.length;
		}

		var self = this,
			o = this.options,
			$li = $(tabEl),
			$panel = $(panelEl),
			$panelSub = $('div.tab-panel', $panel).eq(0);

		$li.addClass( "ui-state-default ui-corner-top" ).data( "destroy.tabs", true );
		$panelSub.addClass( "ui-tabs-panel ui-widget-content ui-corner-bottom ui-tabs-hide" );

		if ( index >= this.lis.length ) {
			$li.appendTo( this.list );
			$panel.appendTo( this.list[ 0 ].parentNode.parentNode );
		} else {
			$li.insertBefore( this.lis[ index ] );
			$panel.insertBefore( this.panels[ index ].parentNode );
		}

		o.disabled = $.map( o.disabled, function( n, i ) {
			return n >= index ? ++n : n;
		});

		this._tabify();

		if ( this.anchors.length == 1 ) {
			o.selected = 0;
			$li.addClass( "ui-tabs-selected ui-state-active" );
			$panelSub.removeClass( "ui-tabs-hide" );
			this.element.queue( "tabs", function() {
				self._trigger( "show", null, self._ui( self.anchors[ 0 ], self.panels[ 0 ] ) );
			});

			this.load( 0 );
		}

		this._trigger( "add", null, this._ui( this.anchors[ index ], this.panels[ index ] ) );
		return this;
	},

	remove: function( index ) {
		index = this._getIndex( index );
		var o = this.options,
			z = $(this.anchors).eq(index + 1).is('[data-newtab]'),
			$li = this.lis.eq( index ).remove(),
			$panel = this.panels.eq( index ).remove();

		// If selected tab was removed focus tab to the right (unless that tab is the input tab) or
		// in case the last tab was removed the tab to the left.
		if ( $li.hasClass( "ui-tabs-selected" ) && this.anchors.length > 1) {
			this.select( index + ( (index + 1 < this.anchors.length && !z) ? 1 : -1 ) );
		}

		o.disabled = $.map(
			$.grep( o.disabled, function(n, i) {
				return n != index;
			}),
			function( n, i ) {
				return n >= index ? --n : n;
			});

		this._tabify();

		this._trigger( "remove", null, this._ui( $li.find( "a" )[ 0 ], $panel[ 0 ] ) );
		return this;
	}

});