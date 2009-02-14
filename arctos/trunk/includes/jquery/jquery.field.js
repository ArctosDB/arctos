/*
 * jQuery Field Plug-in
 *
 * Copyright (c) 2007 Dan G. Switzer, II
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Revision: 13
 * Version: 0.9.1
 *
 * NOTES: The getValue() and setValue() methods are designed to be
 * executed on single field (i.e. any field that would share the same
 * "name" attribute--a single text box, a group of checkboxes or radio
 * elements, etc.)
 *
 * Revision History
 * v0.9.1
 * - Optimized the createCheckboxRange to reduced complexity and code size.
 *   Functionality has not changed.
 * 
 * v0.9
 * - Removed createCheckboxRange custom event, this fixes problems with
 *   older jQuery versions that have problems with the trigger
 * - Changed the limitSelection() function to use an options argument, 
 *   instead of all the individual arguments
 * 
 * v0.8.1
 * - createCheckboxRange() no longer breaks the chain
 * - Added callback to createCheckboxRange() (the trigger() method 
 *   does not execute correctly in jQuery v1.1.2, so this functionality 
 *   doesn't work in that version.)
 * - Added configurable setting for the [SHIFT] key bind to the 
 *   createCheckboxRange().
 * - Added the $.Field.setProperty() and getProperty() methods
 * 
 * v0.8
 * - Fixed "bug in checkbox range" (http://plugins.jquery.com/node/1642)
 * - Fixed "Bug when setting value on a select element and the select is empty"
 *   (http://plugins.jquery.com/node/1281)
 *
 * v0.7.1
 * - Changed a comma in code to a semi-colon in a variable definition line
 * - Fixed code to work in min mode
 * - Fixed bug in hashForm() that would not see struct keys with empty values
 *
 * v0.7
 * - Added tabIndex related function (getTabIndex, moveNext, movePrev, moveIndex)
 *
 * v0.6
 * - Fixed bug in the $.formHash() where the arrayed form elements would
 *   not correctly report their values.
 * - Added the $.createCheckboxRange() which allow you to select multiple
 *   checkbox elements by doing a [SHIFT] + click.
 *
 * v0.5
 * - Added $.limitSelection() method for limiting the number of
 *   selection in a select-multiple of checkbox array.
 *
 * v0.4.1
 * - Moved $.type and $.isType into private functions
 * - Rewrote $type() function to use instanceof operator
 *
 * v0.4
 * - Added the formHash() method
 *
 * v0.3
 * - First public release
 *
*/
(function($){

	// set the defaults
	var defaults = {
		// use a comma as the string delimiter
		delimiter: ",",
		// the default key binding to check for when using the createCheckboxRange()
		checkboxRangeKeyBinding: "shiftKey",
		// for methods that could return either a string or array, decide default behavior
		useArray: false
	};

	// set default options
	$.Field = {
		version: "0.9.1",
		setDefaults: function(options){
			$.extend(defaults, options);
		},
		setProperty: function(prop, value){
			defaults[prop] = value;
		},
		getProperty: function(prop){
			return defaults[prop];
		}
	};


	/*
	 * jQuery.fn.fieldArray()
	 *
	 * returns either an array of values or a jQuery object
	 *
	 * NOTE: This *MAY* break the jQuery chain
	 *
	 * Examples:
	 * $("input[@name='name']").fieldArray();
	 * > Gets the current value of the name text element
	 *
	 * $("input[@name='name']").fieldArray(["Dan G. Switzer, II"]);
	 * > Sets the value of the name text element to "Dan G. Switzer, II"
	 *
	 * $("select[@name='state']").fieldArray();
	 * > Gets the current value of the state text element
	 *
	 * $("select[@name='state']").setValue(["OH","NY","CA"]);
	 * > Sets the selected value of the "state" select element to OH, NY and CA
	 *
	 */
	// this will set/get the values for a field based upon and array
	$.fn.fieldArray = function(v){
		var t = $type(v);

		// if no value supplied, return an array of values
		if( t == "undefined" ) return getValue(this);

		// convert the number/string into an array
		if( t == "string" ||  t == "number" ){
			v = v.toString().split(defaults.delimiter);
			t = "array";
		}

		// set the value -- doesn't break the chaing
		if( t == "array" ) return setValue(this, v);

		// if we don't know what do to, don't break the chain
		return this;
	};

	/*
	 * jQuery.fn.getValue()
	 *
	 * returns String - a comma delimited list of values for the field
	 *
	 * NOTE: Breaks the jQuery chain, since it returns a string.
	 *
	 * Examples:
	 * $("input[@name='name']").getValue();
	 * > This would return the value of the name text element
	 *
	 * $("select[@name='state']").getValue();
	 * > This would return the currently selected value of the "state" select element
	 *
	 */
	// the getValue() method -- break the chain
	$.fn.getValue = function(){
		// return the values as a comma-delimited string
		return getValue(this).join(defaults.delimiter);
	};

	/*
	 * getValue()
	 *
	 * returns Array - an array of values for the field
	 *
	 */
	// the getValue() method -- break the chain
	var getValue = function(jq){
		var v = [];

		jq.each(
			function (lc){
				// get the current type
				var t = getType(this);

				switch( t ){
					case "checkbox": case "radio":
						// if the checkbox or radio element is checked
						if( this.checked ) v.push(this.value);
					break;

					case "select":
						if( this.type == "select-one" ){
							v.push( (this.selectedIndex == -1) ? "" : getOptionVal(this[this.selectedIndex]) );
						} else {
							// loop through all element in the array for this field
							for( var i=0; i < this.length; i++ ){
								// if the element is selected, get the selected values
								if( this[i].selected ){
									// append the selected value, if the value property doesn't exist, use the text
									v.push(getOptionVal(this[i]));
								}
							}
						}
					break;

					case "text":
						v.push(this.value);
					break;
				}
			}
		);

		// return the values as an array
		return v;
	};

	/*
	 * setValue()
	 *
	 * returns jQuery object
	 *
	 * NOTE: This does *NOT* break the jQuery chain
	 *
	 * Examples:
	 * $("input[@name='name']").setValue("Dan G. Switzer, II");
	 * > Sets the value of the name text element to "Dan G. Switzer, II"
	 *
	 * $("select[@name='state']").setValue("OH");
	 * > Sets the selected value of the "state" select element to "OH"
	 *
	 */
	// the setValue() method -- does *not* break the chain
	$.fn.setValue = function(v){
		// f no value, set to empty string
		return setValue(this, (!v ? [""] : v.toString().split(defaults.delimiter)));
	};

	/*
	 * setValue()
	 *
	 * returns jQuery object
	 *
	 */
	// the setValue() method -- does *not* break the chain
	var setValue = function(jq, v){

		jq.each(
			function (lc){
				var t = getType(this), x;

				switch( t ){
					case "checkbox": case "radio":
						if( valueExists(v, this.value) ) this.checked = true;
						else this.checked = false;
					break;

					case "select":
						var bSelectOne = (this.type == "select-one");
						var bKeepLooking = true; // if select-one type, then only select the first value found
						// loop through all element in the array for this field
						for( var i=0; i < this.length; i++ ){
							x = getOptionVal(this[i]);
							bSelectItem = valueExists(v, x);
							if( bSelectItem ){
								this[i].selected = true;
								// if a select-one element
								if( bSelectOne ){
									// no need to look farther
									bKeepLooking = false;
									// stop the loop
									break;
								}
							} else if( !bSelectOne ) this[i].selected = false;
						}
						// if a select-one box and nothing selected, then try to select the default value
						if( bSelectOne && bKeepLooking && !!this[0] ){
							this[0].selected = true;
						}
					break;

					case "text":
						this.value = v.join(defaults.delimiter);
					break;
				}

			}
		);

		return jq;
	};

	/*
	 * jQuery.fn.formHash()
	 *
	 * returns either an hash table of form fields or a jQuery object
	 *
	 * NOTE: This *MAY* break the jQuery chain
	 *
	 * Examples:
	 * $("#formName").formHash();
	 * > Returns a hash map of all the form fields and their values
	 *
	 * $("#formName").formHash({"name": "Dan G. Switzer, II", "state": "OH"});
	 * > Returns the jQuery chain and sets the fields "name" and "state" with
	 * > the values "Dan G. Switzer, II" and "OH" respectively.
	 *
	 */
	// the formHash() method -- break the chain
	$.fn.formHash = function(inHash){
		var bGetHash = (arguments.length == 0);
		// create a hash to return
		var stHash = {};

		// run the code for each form
		this.filter("form").each(
			function (){
				// get all the form elements
				var els = this.elements, el, n, stProcessed = {}, jel;

				// loop through the elements and process
				for( var i=0, elsMax = els.length; i < elsMax; i++ ){
					el = els[i]; 
					n = el.name;

					// if the element doesn't have a name, then skip it
					if( !n || stProcessed[n] ) continue;

					// create a jquery object to the current named form elements
					var jel = $(el.tagName.toLowerCase() + "[@name='"+n+"']", this);

					// if we're getting the values, get them now
					if( bGetHash ){
						stHash[n] = jel[defaults.useArray ? "fieldArray" : "getValue"]();
					// if we're setting values, set them now
					} else if( typeof inHash[n] != "undefined" ){
						jel[defaults.useArray ? "fieldArray" : "setValue"](inHash[n]);
					}

					stProcessed[n] = true;
				}
			}
		);

		// if getting a hash map return it, otherwise return the jQuery object
		return (bGetHash) ? stHash : this;
	};

	/*
	 * jQuery.fn.autoAdvance()
	 *
	 * Finds all text-based input fields and makes them autoadvance to the next
	 * fields when they've met their maxlength property.
	 *
	 *
	 * Examples:
	 * $("#form").autoAdvance();
	 * > When a field reaches it's maxlength attribute value, it'll advance to the
	 * > next field in the form's tabindex.
	 *
	 * $("#form").autoAdvance(callback);
	 * > Automatic advances to next field and triggers the callback function on the
	 * > field the user left.
	 *
	 */
	// the autoAdvance() method
	$.fn.autoAdvance = function(callback){
		return this.find(":text,:password,textarea").bind(
			"keyup",
			function (e){
				var
					// get the field
					$field = $(this),
					// get the maxlength for the field
					iMaxLength = parseInt($field.attr("maxlength"), 10);

				// if the user tabs to the field, exit event handler
				// this will prevent movement if the field is already
				// field in with the max number of characters
				if( isNaN(iMaxLength) || ("|9|16|37|38|39|40|".indexOf("|" + e.keyCode + "|") > -1) ) return true;

				// if the value of the field is greater than maxlength attribute,
				// then move the focus to the next field
				if( $field.getValue().length >= $field.attr("maxlength") ){
					// move to the next field and select the existing value
					var $next = $field.moveNext().select();
					if( $.isFunction(callback) ) callback.apply($field, [$next]);
				}
			}
		);
	};

	/*
	 * jQuery.fn.moveNext()
	 *
	 * places the focus in the next form field. if the field element is
	 * the last in the form array, it'll return to the top.
	 *
	 * returns a jQuery object pointing to the next field element
	 *
	 * NOTE: if the selector returns multiple items, the first item is used.
	 *
	 *
	 * Examples:
	 * $("#firstName").moveNext();
	 * > Moves the focus to the next form field found after firstName
	 *
	 */
	// the moveNext() method
	$.fn.moveNext = function(){
		return this.moveIndex("next");
	};

	/*
	 * jQuery.fn.movePrev()
	 *
	 * places the focus in the previous form field. if the field element is
	 * the first in the form array, it'll return to the last element.
	 *
	 * returns a jQuery object pointing to the previos field element
	 *
	 * NOTE: if the selector returns multiple items, the first item is used
	 *
	 * Examples:
	 * $("#firstName").movePrev();
	 * > Moves the focus to the next form field found after firstName
	 *
	 */
	// the movePrev() method
	$.fn.movePrev = function(){
		return this.moveIndex("prev");
	};

	/*
	 * jQuery.fn.moveIndex()
	 *
	 * Places the tab index into the specified index position
	 *
	 * returns a jQuery object pointing to the previos field element
	 *
	 * NOTE: if the selector returns multiple items, the first item is used
	 *
	 * Examples:
	 * $("#firstName").movePrev();
	 * > Moves the focus to the next form field found after firstName
	 *
	 */
	// the moveIndex() method
	$.fn.moveIndex = function(i){
		// get the current position and elements
		var aPos = getFieldPosition(this);

		// if a string option has been specified, calculate the position
		if( i == "next" ) i = aPos[0] + 1; // get the next item
		else if( i == "prev" ) i = aPos[0] - 1; // get the previous item

		// make sure the index position is within the bounds of the elements array
		if( i < 0 ) i = aPos[1].length - 1;
		else if( i >= aPos[1].length ) i = 0;

		return $(aPos[1][i]).trigger("focus");
	};

	/*
	 * jQuery.fn.getTabIndex()
	 *
	 * gets the current tab index of the first element found in the selector
	 *
	 * NOTE: if the selector returns multiple items, the first item is used
	 *
	 * Examples:
	 * $("#firstName").getTabIndex();
	 * > Gets the tabIndex for the firstName field
	 *
	 */
	// the getTabIndex() method
	$.fn.getTabIndex = function(){
		// return the position of the form field
		return getFieldPosition(this)[0];
	};

	var getFieldPosition = function (jq){
		var
			// get the first matching field
			$field = jq.filter("input select textarea").get(0),
			// store items with a tabindex
			aTabIndex = [],
			// store items with no tabindex
			aPosIndex = [];

		// if there is no match, return 0
		if( !$field ) return [-1, []];

		// make a single pass thru all form elements
		$.each(
			$field.form.elements,
			function (i, o){
				if( o.tagName != "FIELDSET" && !o.disabled ){
					if( o.tabIndex > 0 ){
						aTabIndex.push(o);
					} else {
						aPosIndex.push(o);
					}
				}
			}
		);

		// sort the fields that had tab indexes
		aTabIndex.sort(
			function (a, b){
				return a.tabIndex - b.tabIndex;
			}
		);

		// merge the elements to create the correct tab position
		aTabIndex = $.merge(aTabIndex, aPosIndex);

		for( var i=0; i < aTabIndex.length; i++ ){
			if( aTabIndex[i] == $field ) return [i, aTabIndex];
		}

		return [-1, aTabIndex];
	};

	/*
	 * jQuery.fn.limitSelection()
	 *
	 * limits the number of items that can be selected
	 *
	 * Examples:
	 * $("input:checkbox").limitSelection(3);
	 * > No more than 3 items can be selected
	 *
	 * $("input:checkbox").limitSelection(2, {onsuccess: function (), onfailure: function ()});
	 * > Limits the selection to 2 items and runs the callback function when
	 * > more than 2 items have been selected.
	 *
	 * NOTE: Current when a "select-multiple" option undoes the selection,
	 * it selects the first 3 options in the array--which isn't necessarily
	 * the first 3 options the user selected. This is not the most desired
	 * behavior.
	 *
	 */
	$.fn.limitSelection = function(limit, options){
		// get the options to use
		var opt = jQuery.extend(
			(limit && limit.constructor == Object ? limit : {
					limit: limit
				, onsuccess: function (limit){ return true; }
				, onfailure: function (limit){ alert("You can only select a maximum a of " + limit + " items."); return false; }
			})
			, options);
		
		var self = this;

		var getCount = function (el){
			if( el.type == "select-multiple" ) return $("option:selected", self).length;
			else if( el.type == "checkbox" ) return self.filter(":checked").length;
			return 0;
		};

		var undoSelect = function (){
			// reduce selection to n items
			setValue(self, getValue(self).slice(0, opt.limit));
			// do callback
			return opt.onfailure.apply(self, [opt.limit]);
		};

		return this.bind(
			(!!self[0] && self[0].type == "select-multiple") ? "change" : "click",
			function (){
				if( getCount(this) > opt.limit ){
					// run callback, it must return false to prevent action
					return (this.type == "select-multiple") ? undoSelect() : opt.onfailure.apply(self, [opt.limit]);
				}
				opt.onsuccess.apply(self, [opt.limit]);
				return true;
			}
		);
	};

	/*
	 * jQuery.fn.createCheckboxRange()
	 *
	 * limits the number of items that can be selected
	 *
	 * Examples:
	 * $("input:checkbox").createCheckboxRange();
	 * > Allows a [SHIFT] + mouseclick to select all the items from the last
	 * > checked checkmark to the current checkbox.
	 *
	 * $("input:checkbox").createCheckboxRange(callback);
	 * > Runs the callback method for each item who's checked status changes.
	 * > This allows you to build hooks to highlight rows.
	 *
	 */
	$.fn.createCheckboxRange = function(callback){
		var iLastSelection = 0, self = this, bCallback = $.isFunction(callback);

		// if there's a call back, bind it now and run it
		if( bCallback ) 
			this.each(function (){callback.apply(this, [$(this).is(":checked")])});
		
		// loop through each checkbox and return the jQuery object
		return this.each(
			function (){
				// only perform this action on checkboxes
				if( this.type != "checkbox" ) return false;
				var el = this;

				var updateLastCheckbox = function (e){
					iLastSelection = self.index(e.target);
				};

				var checkboxClicked = function (e){
					var bSetChecked = this.checked, current = self.index(e.target), low = Math.min(iLastSelection, current), high = Math.max(iLastSelection, current);
					// run the callback for the clicked item
					if( bCallback ) $(this).each(function (){callback.apply(this, [bSetChecked])});
					// if we don't detect the keypress, exit function
					if( !e[defaults.checkboxRangeKeyBinding] ) return;

					// loop through the items in the selected range
					for( var i=low; i < high; i++ ){
						// make sure to correctly set the checked status
						var item = self.eq(i).attr("checked", bSetChecked ? "checked" : "");
						// run the callback
						if( bCallback ) callback.apply(item[0], [bSetChecked]);
					}
					
					return true;
				};
				
				$(this)
					// unbind the events so we can re-run the createCheckboxRange() plug-in for dynamically created elements
					.unbind("blur", updateLastCheckbox)
					.unbind("click", checkboxClicked)

					// bind the functions, we bind on blur for keyboard selected items
					.bind("blur", updateLastCheckbox)
					.bind("click", checkboxClicked)
					;

				return true;
			}
		);
	};

	// determines how to process a field
	var getType = function (el){
		var t = el.type;

		switch( t ){
			case "select": case "select-one": case "select-multiple":
				t = "select";
				break;
			case "text": case "hidden": case "textarea": case "password": case "button": case "submit": case "submit":
				t = "text";
				break;
			case "checkbox": case "radio":
				t = t;
				break;
		}
		return t;
	};

	// gets the value of a select element
	var getOptionVal = function (el){
		 return jQuery.browser.msie && !(el.attributes['value'].specified) ? el.text : el.value;
	};

	// checks to see if a value exists in an array
	var valueExists = function (a, v){
		return ($.inArray(v, a) > -1);
	};

	// correctly gets the type of an object (including array/dates)
	var $type = function (o){
		var t = (typeof o).toLowerCase();

		if( t == "object" ){
			if( o instanceof Array ) t = "array";
	 		else if( o instanceof Date ) t = "date";
	 	}
	 	return t;
	};

	// checks to see if an object is the specified type
	var $isType = function (o, v){
		return ($type(o) == String(v).toLowerCase());
	};

})(jQuery);
