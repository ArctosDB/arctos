//Orignal Script by : Julian Robichaux, http://www.nsftools.com
//This script has been changed/modified/added to compose it as a javscript a class, such that multiple instances of
//suggest can be used on a single page, with easily user defined properties and css settings.


Suggest = Class.create();

Suggest.prototype = {
	initialize: function() 
	{
		this.name  = "";
		this.queryField = "";
		this.divName = "";
		this.ifName = "";
		this.lastVal = "";
		this.val = ""
		this.xmlHttp = null;
		this.cache = new Object();
		this.searching = false;
		this.globalDiv = "";
		this.divFormatted = false;
	
		this.selectionListener  = this.defaultSelectionListener;
		this.DIV_BG_COLOR = "#FFFFFF";
		this.DIV_HIGHLIGHT_COLOR = "#cccccc";
		this.listStyle = "";
		this.listItemStyle = "";
		this.listItemKey = "";
		this.listItemValue = "";
		this.listWidth = "";
		this.minCharToStartSearch=1;
		this.showKey = true;
		this.queryFieldHolds = 0;  //0 - Key, 1 = Value  , 2 - Both Key and value
	}
	,

	setQueryFieldHolds: function(value)
	{
    	this.queryFieldHolds = value;
	}
	,

	setShowKey: function(value)
	{
    	this.showKey = value;
	}
	,

	setSelectionListener: function(handler)
	{
    	this.selectionListener = handler;
	}
	,

	setMinCharToStartSearch: function(value)
	{
		this.minCharToStartSearch = value;
	}
	,

	setListWidth: function(value)
	{
		this.listWidth = value;
	}
	,

	setListStyle: function(value)
	{
		this.listStyle = value;
	}
	,

	setListItemStyle: function(value)
	{
		this.listItemStyle = value;
	}
	,

	setListItemKey: function(value)
	{
		this.listItemKey = value;
	}
	,

	setListItemValue: function(value)
	{
		this.listItemValue = value;
	}
	,

	setHighlightColor: function(value)
	{
		this.DIV_HIGHLIGHT_COLOR = value;
	}
	,

	setBackgroundColor: function(value)
	{
		this.DIV_BG_COLOR = value;
	}
	,

	/**
	The InitQueryCode function should be called by the <body onload> event, passing
	at least the queryFieldName , where:
	queryFieldName = the name of the form field we're using for lookups
	*/
	InitQueryCode: function(name, queryFieldName)
	{
		this.name = name;
		this.queryField = document.getElementsByName(queryFieldName).item(0);
		this.queryField.onblur = suggestHideDiv;
		this.queryField.onkeydown = suggestKeypressHandler;
		
		// for some reason, Firefox 1.0 doesn't allow us to set autocomplete to off
		// this way, so you should manually set autocomplete="off" in the input tag
		// if you can -- we'll try to set it here in case you forget
		this.queryField.autocomplete = "off";
		this.divName = name + 'div'; //"querydiv";
		this.ifName = "queryiframe";
		
		// add a blank value to the cache (so we don't try to do a lookup when the
		// field is empty) and start checking for changes to the input field
		this.addToCache("", new Array(), new Array());
		setTimeout("suggestMainLoop()", 100);
		
	}
	,
	
	/**
	This is a helper function that just adds results to our cache, to avoid
	repeat lookups.
	*/
	addToCache: function(queryString, resultArray1, resultArray2)
	{
		this.cache[queryString] = new Array(resultArray1, resultArray2);
	}
	,
	
	/**
	Get the <DIV> we're using to display the lookup results, and create the
	<DIV> if it doesn't already exist.
	*/
	getDiv: function(divID)
	{
		if (!this.globalDiv) 
		{
			// if the div doesn't exist on the page already, create it
			if (!document.getElementById(divID)) {
			  	var newNode = document.createElement("div");
			  	if (this.listStyle == "")  
		  			newNode.className = "_listStyle";
				else
					newNode.className = this.listStyle;

				newNode.setAttribute("id", divID);
			  	document.body.appendChild(newNode);
			}
		
			// set the globalDiv reference
			this.globalDiv = document.getElementById(divID);
		
			// figure out where the top corner of the div should be, based on the
			// bottom left corner of the input field
			var x = this.queryField.offsetLeft;
			var y = this.queryField.offsetTop + this.queryField.offsetHeight;
			var parent = this.queryField;
			
			while (parent.offsetParent) {
				parent = parent.offsetParent;
				x += parent.offsetLeft;
				y += parent.offsetTop;
			}
		
			// add some formatting to the div, if we haven't already
			if (!this.divFormatted) 
			{
				this.globalDiv.style.backgroundColor = this.DIV_BG_COLOR;
				
				if (this.listStyle == "")
				{
					this.globalDiv.style.fontFamily = "Verdana, Geneva, Arial, Helvetica, sans-serif";
					this.globalDiv.style.fontSize = "90%";
					this.globalDiv.style.padding = "4px";
					this.globalDiv.style.border = "1px solid black";
				}
				
				this.globalDiv.style.position = "absolute";
				this.globalDiv.style.left = x + "px";
				this.globalDiv.style.top = y + "px";
				this.globalDiv.style.visibility = "hidden";
				this.globalDiv.style.zIndex = 10000;
				if (this.listWidth != "") this.globalDiv.style.width = this.listWidth;

				this.divFormatted = true;
			}
		}
		return this.globalDiv;
	}
	,
	
	/**
	This is the function that should be returned by the XMLHTTP call. It will
	format and display the lookup results.
	*/
	showQueryDiv: function(queryString, resultArray1, resultArray2)
	{
		var div = this.getDiv(this.divName);
	  
		// remove any results that are already there
		while (div.childNodes.length > 0)
			div.removeChild(div.childNodes[0]);
	  
		// add an entry for each of the results in the resultArray
		for (var i = 0; i < resultArray1.length; i++)
		{
			// each result will be contained within its own div
			var result = document.createElement("div");
			if (this.listItemStyle != "") 
			{
				result.className = this.listItemStyle;
			}
			else
			{
				result.style.cursor = "pointer";
				result.style.borderBottom = "2px solid #777777";
				result.style.padding = "3px 0px 3px 0px"
			}
			
			
			this._unhighlightResult(result);
			result.onmousedown = this.selectResult;
			result.onmouseover = this.highlightResult;
			result.onmouseout = this.unhighlightResult;
		
			var result1 = document.createElement("span");
			if (this.listItemKey == "")
				result1.className = "_listItemKey";
			else
				result1.className = this.listItemKey;
				
			if (this.listItemKey == "")
			{
				result1.style.textAlign = "left";
				result1.style.fontWeight = "bold";
			}
			result1.innerHTML = resultArray1[i];
			
			var result2 = document.createElement("span");
			
			if (this.listItemValue == "")
				result2.className = "_listItemValue";
			else
				result2.className = this.listItemValue;
				
			if (this.listItemValue == "")
			{
				result2.style.textAlign = "right";
				result2.style.paddingLeft = "20px";
			}
			result2.innerHTML = resultArray2[i];
			
			var result3 = document.createElement("span");
			result3.className = resultArray1[i] + ";" + resultArray2[i];
			
			
			result.appendChild(result3);
			if (this.showKey) result.appendChild(result1);
			result.appendChild(result2);
			div.appendChild(result);
		}
	  
		// if this resultset isn't already in our cache, add it
		var isCached = this.cache[queryString];
		if (!isCached)
			this.addToCache(queryString, resultArray1, resultArray2);
	  
		// display the div if we had at least one result
		this.showDiv(resultArray1.length > 0);
	}
	,
	
	/**
	This is called whenever the user clicks one of the lookup results.
	It puts the value of the result in the queryField and hides the
	lookup div.
	*/
	selectResult: function()
	{
		selectedSuggestObject._selectResult(this);
	}
	,
	
	/** This actually fills the field with the selected result and hides the div */
	_selectResult: function(item)
	{
		var spans = item.getElementsByTagName("span");
		if (spans) {
			
			var data = spans[0].className.split(";");

			if (this.queryFieldHolds == 0) {
				//key 
				this.queryField.value = data[0];
			} else if (this.queryFieldHolds == 1) {
				//value
				this.queryField.value = data[1];
			} else if (this.queryFieldHolds == 2) {
				//both key and value
				this.queryField.value = data[0] + " - " + data[1];
			}
			
			
			this.lastVal = val = escape(this.queryField.value);
			this.searching = false;
			suggestMainLoop();
			this.queryField.focus();
			this.showDiv(false);
			
			
			var _retData = new Array(); 
			_retData.KEY = data[0]; 
			_retData.VALUE = data[1];					
			this.selectionListener(_retData);
			
			return;
		}
	}
	,


	/**
	This is called when a user mouses over a lookup result
	*/
	highlightResult: function()
	{
		selectedSuggestObject._highlightResult(this);
	}
	,
	
	/** This actually highlights the selected result */
	_highlightResult: function(item)
	{
	  item.style.backgroundColor = selectedSuggestObject.DIV_HIGHLIGHT_COLOR;
	}
	,
	
	/**
	This is called when a user mouses away from a lookup result
	*/
	unhighlightResult: function()
	{
		selectedSuggestObject._unhighlightResult(this);
	}
	,
	
	/** This actually unhighlights the selected result */
	_unhighlightResult: function(item)
	{
	  item.style.backgroundColor = selectedSuggestObject.DIV_BG_COLOR;
	}
	,
	
	/**
	This either shows or hides the lookup div, depending on the value of
	the "show" parameter.
	*/
	showDiv: function(show)
	{
		var div = this.getDiv(this.divName);
		if (show)
			div.style.visibility = "visible";
		else
			div.style.visibility = "hidden";
	
		this.adjustiFrame();
	}
	,
	
	
	/**
	Use an "iFrame shim" to deal with problems where the lookup div shows up behind
	selection list elements, if they're below the queryField. The problem and solution are
	described at:
	
	http://dotnetjunkies.com/WebLog/jking/archive/2003/07/21/488.aspx
	http://dotnetjunkies.com/WebLog/jking/archive/2003/10/30/2975.aspx
	*/
	adjustiFrame: function()
	{
		if (!document.getElementById(this.ifName)) 
		{
			var newNode = document.createElement("iFrame");
			newNode.setAttribute("id", this.ifName);
			newNode.setAttribute("src", "javascript:false;");
			newNode.setAttribute("scrolling", "no");
			newNode.setAttribute("frameborder", "0");
			newNode.setAttribute("width", "0");
			document.body.appendChild(newNode);
		}
	  
		iFrameDiv = document.getElementById(this.ifName);
		var div = this.getDiv(this.divName);
	  
		try {
			iFrameDiv.style.position = "absolute";
			if (this.listWidth != "") 
				this.globalDiv.style.width = this.listWidth;
			else
				iFrameDiv.style.width = div.offsetWidth;
			//alert(div.offsetWidth);
			iFrameDiv.style.height = div.offsetHeight;
			iFrameDiv.style.top = div.style.top;
			iFrameDiv.style.left = div.style.left;
			iFrameDiv.style.zIndex = div.style.zIndex - 1;
			iFrameDiv.style.visibility = div.style.visibility;
		} catch(e) {
		}
	}
	,
	
	/**
	Get the number of the result that's currently selected/highlighted
	(the first result is 0, the second is 1, etc.)
	*/
	getSelectedSpanNum: function(div)
	{
		var count = -1;
		var spans = div.getElementsByTagName("div");
		if (spans) 
		{
			for (var i = 0; i < spans.length; i++) 
			{
				count++;
				if (spans[i].style.backgroundColor != div.style.backgroundColor)
					return count;
			}
		}
		return -1;
	}
	,
	
	/**
	Select/highlight the result at the given position
	*/
	setSelectedSpan: function(div, spanNum)
	{
		var count = -1;
		var thisSpan;
		var spans = div.getElementsByTagName("div");
		if (spans) 
		{
			for (var i = 0; i < spans.length; i++) 
			{
				if (++count == spanNum) 
				{
					this._highlightResult(spans[i]);
					thisSpan = spans[i];
				} else {
					this._unhighlightResult(spans[i]);
				}
			}
		}
		return thisSpan;
	}
	,
	
	defaultSelectionListener: function(result)
	{
		//do nothing -- customer listener required
	}
}


var selectedSuggestObject = null;
function onSuggestFieldFocus(object)
{
	selectedSuggestObject = object;
}

/**
We originally used showDiv as the function that was called by the onBlur
event of the field, but it turns out that Firefox will pass an event as the first
parameter of the function, which would cause the div to always be visible.
So onBlur now calls suggestHideDiv instead.
*/
function suggestHideDiv()
{
	selectedSuggestObject.searching = false;
	selectedSuggestObject.showDiv(false);
}

/**
This is the key handler function, for when a user presses the up arrow,
down arrow, tab key, or enter key from the input field.
*/
function suggestKeypressHandler(evt)
{
	// don't do anything if the div is hidden
	var div = selectedSuggestObject.getDiv(selectedSuggestObject.divName);
	if (div.style.visibility == "hidden")
		return true;
  
	// make sure we have a valid event variable
	if(!evt && window.event) 
	{
		evt = window.event;
	}
	
	var key = evt.keyCode;
  
	// if this key isn't one of the ones we care about, just return
	var KEYUP = 38;
	var KEYDOWN = 40;
	var KEYENTER = 13;
	var KEYTAB = 9;
  
	if ((key != KEYUP) && (key != KEYDOWN) && (key != KEYENTER) && (key != KEYTAB))
		return true;
  
	// get the span that's currently selected, and perform an appropriate action
	var selNum = selectedSuggestObject.getSelectedSpanNum(div);
	var selSpan = selectedSuggestObject.setSelectedSpan(div, selNum);
  
	if ((key == KEYENTER) || (key == KEYTAB)) 
	{
		if (selSpan)
		{
			selectedSuggestObject._selectResult(selSpan);
		}
		evt.cancelBubble=true;
		return false;
	} else {
	if (key == KEYUP)
		selSpan = selectedSuggestObject.setSelectedSpan(div, selNum - 1);
	if (key == KEYDOWN)
		selSpan = selectedSuggestObject.setSelectedSpan(div, selNum + 1);
	if (selSpan)
		selectedSuggestObject._highlightResult(selSpan);
	}
  
	selectedSuggestObject.showDiv(true);
	return true;
}

/**
This is the function that monitors the queryField, and calls the lookup
functions when the queryField value changes.
*/
function suggestMainLoop() 
{
	val = escape(selectedSuggestObject.queryField.value);
 
 	if (val.length >= selectedSuggestObject.minCharToStartSearch)
	{
		// if the field value has changed and we're not currently waiting for
		// a lookup result to be returned, do a lookup (or use the cache, if
		// we can)
		if (selectedSuggestObject.lastVal != val && selectedSuggestObject.searching == false)
		{
			var cacheResult = selectedSuggestObject.cache[val];
			if (cacheResult)
			  selectedSuggestObject.showQueryDiv(val, cacheResult[0], cacheResult[1]);
			else
			  getData(val);
			selectedSuggestObject.lastVal = val;
		}
	}
	setTimeout("suggestMainLoop()", 100);
	return true;
}