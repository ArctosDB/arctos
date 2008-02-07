/**
 * HelpBalloon
 * Prototype/Scriptaculous based help balloons
 * @copyright 2006 Beau D. Scott
 */
var HelpBalloon = Class.create();
HelpBalloon.prototype = {

	/**
	 * Instantiates the object
	 * @param {Object} options
	 */
	initialize: function(options)
	{
		/**
		 * Establish default options and apply specified values
		 */
		this.options = Object.extend({
			returnElement: false,								//For use with embedding this object into another. Returns a reference to the object, rather than appending itself to the DOM.
			icon: '/images/icon_info.gif',						//url to the icon to use
			altText: 'Click here for help with this topic',		//Alt text of the help icon
			dataURL: null,										//URL to pull the title/content XML
			title: 'Title',										//Title of the balloon topic
			content: 'Content',									//Static content of the help balloon
			duration: .2,										//Duration of fade/appear affect
			useEvent: ['click'],								//Events to trigger the balloon
			imagePath: '/images/',
			method:	'get'										//Method to retrieve the AJAX content
		}, options||{});

		/**
		 * collection of object elements
		 */
		this._elements = {
			container: null,									//Containing element of the balloon
			inner: null,										//Inner content container
			icon: null,											//Triggering icon
			content: null,										//Body Content container
			button: null,										//Closing 'X' button
			title: null,										//Title Content Container
			bgContainer: null									//For IE, renders the alpha-transparent PNG
		};

		/**
		 * Properties and Attributes
		 */
		this._properties = {
			id: "HelpBalloon_" + Object.genGUID(),				//ID for object and Icon, Requires prototype.improvements.js
			balloons : [										//Path to 4 bubble images
				this.options.imagePath + 'balloon-tl.png',			//Top Left
				this.options.imagePath + 'balloon-tr.png',			//Top Right
				this.options.imagePath + 'balloon-bl.png',			//Bottom Left
				this.options.imagePath + 'balloon-br.png'			//Bottom Right
			],
			balloonStyle: {										//Balloon styling
				position: 'absolute',
				border: 'none',
				background: 'white',
				width: '300px',
				height: '240px',
				display: 'none'
			},
			button: this.options.imagePath + 'button.png',		//Closing 'X' image
			visible: false,										//Status of Balloon's visibility
			balloonCoords: null,								//Stores the balloon coordinates
			innerDims: [230,170],								//Inner dimensions of the balloon, available for content
			outerDims: [300,240],								//Outer dimensions of the balloon
			pointerDims: [20,20],								//Balloon tail dimensions
			innerMargin: 15,									//Inner margin
			buttonHeight: 20,									//Size of 'X' image
			drawn: false,										//Rendering status
			renderXY: [0,0]										//X/Y coordinate of icon at time of render
		};

		/**
		 * Preload the balloon images
		 */
		for(var i = 0; i < this._properties.balloons.length; i++)
		{
			var timg = document.createElement('img');
			timg.src = this._properties.balloons[i];
		}

		/**
		 * Create the anchoring icon
		 */
		this._elements.icon = document.createElement('img');
		this._elements.icon.src = this.options.icon;
		this._elements.icon.id = this._properties.id + "_icon";
		this._elements.icon._HelpBalloon = this;
		if(!this._elements.icon) return false;
		/**
		 * Attach rendering events
		 */

		for(i = 0; i < this.options.useEvent.length; i++)
		{
			Event.observe(this._elements.icon, this.options.useEvent[i], this.toggle.bindAsEventListener(this));
		}
		this._elements.icon.style.cursor = 'pointer';
		this._elements.container = document.createElement('div');
		this._elements.container._HelpBalloon = this;

		/**
		 * If we are not relying on other javascript to attach the anchoring icon
		 * to the DOM, we'll just do where the script is called from. Default behavior.
		 *
		 * If you want to use external JavaScript to attach it to the DOM, attach this._elements.icon
		 */
		if(!this.options.returnElement)
		{
			document.write('<span id="' + this._properties.id + '"></span>');
			var te = $(this._properties.id);
			var p = te.parentNode;
			p.insertBefore(this._elements.icon, te);
			p.removeChild(te);
		}
	},

	/**
	 * Toggles the help balloon
	 * @param {Object} e Event
	 */
	toggle: function(e)
	{
		if(!e) e = window.event || {type: this.options.useEvent, target: this._elements.icon};
		var icon = Event.element(e);

		if(e.type == this.options.useEvent && !this._properties.visible && icon == this._elements.icon)
			this.show();
		else
			this.hide();
	},

	show: function()
	{
		if(!this._properties.drawn) this._draw();
		this._reposition();
		this._hideOtherHelps();
		Effect.Appear(this._elements.container, {duration: this.options.duration});
		setTimeout(this._hideLowerElements.bind(this), (this.options.duration * 1000) / 2);
		setTimeout(function(){this._elements.container.style.display = 'block';}.bind(this), (this.options.duration * 1000));
		this._properties.visible = true;
		Event.observe(window, 'resize', this._reposition.bindAsEventListener(this));
	},

	/**
	 * Hides the balloon
	 */
	hide: function()
	{
		this._showLowerElements();
		Effect.Fade(this._elements.container, {duration: this.options.duration});
		setTimeout(function(){this._elements.container.style.display = 'none';}.bind(this), this.options.duration * 1000);
		this._properties.visible = false;
		Event.stopObserving(window, 'resize', this._reposition.bindAsEventListener(this));
		return;
	},

	/**
	 * Redraws the balloon based on the current coordinates of the icon.
	 */
	_reposition: function()
	{
		this._properties.balloonCoords = this._getXY(this._elements.icon);
		this._properties.balloonCoords.x += Math.round(this._elements.icon.width / 2);
		this._properties.balloonCoords.y += Math.round(this._elements.icon.height / 2);

		var pos = 0;

		var oh = this._properties.balloonCoords.x + parseInt(this._elements.container.style.width);
		var ov = this._properties.balloonCoords.y - parseInt(this._elements.container.style.height);

		if(ov > 0)
			pos += 2;

		var ww = Browser.isMSIE() ? document.body.clientWidth : window.outerWidth;
		if(oh > ww)
			pos += 1;

		// Fix for IE alpha transparencies
		if(Browser.isMSIE() && this._properties.balloons[pos].toLowerCase().indexOf('.png') > -1)
		{
			var doAppend = false;
			if(!this._elements.bgContainer)
			{
				doAppend=true;
				this._elements.bgContainer = document.createElement('div');
			}
			this._elements.bgContainer.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + this._properties.balloons[pos] + "', sizingMethod='crop')";
			this._elements.bgContainer.style.position = 'absolute';
			this._elements.bgContainer.style.left = '0px';
			this._elements.bgContainer.style.top = '0px';
			this._elements.bgContainer.style.width = this._elements.container.style.width;
			this._elements.bgContainer.style.height = this._elements.container.style.width;
			this._elements.bgContainer.style.zIndex = -1;
			doAppend && this._elements.container.appendChild(this._elements.bgContainer);
		}
		else
			this._elements.container.style.backgroundImage = 'url(' + this._properties.balloons[pos] + ')';

		this._elements.container.style.backgroundRepeat = 'no-repeat';
		this._elements.container.style.backgroundColor = 'transparent';
		if(Browser.isMSIE()) this._elements.container.style.backgroundAttachment = 'fixed';
		this._elements.container.style.backgroundPosition = 'top left';

		var cx = 0;
		var cy = 0;
		var zx = 0;
		var zy = 0;
		switch(pos)
		{
			case 1:
				cx = this._properties.pointerDims[0];
				cy = this._properties.pointerDims[1];

				zx = this._properties.balloonCoords.x - parseInt(this._elements.container.style.width);
				zy = this._properties.balloonCoords.y;
			break;

			case 2:
				cx = this._properties.pointerDims[0];
				cy = this._properties.pointerDims[1];

				zx = this._properties.balloonCoords.x;
				zy = this._properties.balloonCoords.y - parseInt(this._elements.container.style.height);
			break;

			case 3:
				cx = this._properties.pointerDims[0];
				cy = this._properties.pointerDims[1];

				zx = this._properties.balloonCoords.x - parseInt(this._elements.container.style.width);
				zy = this._properties.balloonCoords.y - parseInt(this._elements.container.style.height);
			break;

			default:
			case 0:
				cx = this._properties.pointerDims[0];
				cy = this._properties.pointerDims[1];

				zx = this._properties.balloonCoords.x;
				zy = this._properties.balloonCoords.y;
			break;
		}

		this._elements.container.style.left = zx + "px";
		this._elements.container.style.top = zy + "px";
		if(this._elements.inner) this._elements.inner.style.left = (cx + this._properties.innerMargin) + 'px';
		if(this._elements.inner) this._elements.inner.style.top = (cy + this._properties.innerMargin) + 'px';
	},

	/**
	 * Render's the Balloon
	 */
	_draw: function()
	{
		Element.setStyle(this._elements.container, this._properties.balloonStyle);
		if(this.options.dataURL && !this._properties.drawn)
		{
			var cont = new Ajax.Request(this.options.dataURL, {asynchronous: false, method: this.options.method});
			/**
			 * Expects the following XML format:
			 * <HelpBalloon>
			 * 		<title>My Title</title>
			 * 		<content>My content</content>
			 * </HelpBaloon>
			 */
			var doHTML = false;
			if(cont.transport.responseXML)
			{
				var xml = cont.transport.responseXML.getElementsByTagName('HelpBalloon')[0];
				if(xml)
				{
					xmlTitle = xml.getElementsByTagName('title')[0];
					if(xmlTitle) this.options.title = xmlTitle.firstChild.nodeValue;

					xmlContent = xml.getElementsByTagName('content')[0];
					if(xmlContent) this.options.content = xmlContent.firstChild.nodeValue;
				}
				else
					doHTML = true;
			}
			else
				doHTML = true;

			if(doHTML)
			{
				// Attempt to get the title from a <title/> HTML tag
				var htmlTitle = cont.transport.responseText.match(/\<title\>([^\<]+)\<\/title\>/gi);
				if(htmlTitle)
				{
					htmlTitle = htmlTitle.toString().replace(/\<title\>|\<\/title\>/gi, '');
					this.options.title = htmlTitle;
				}
				this.options.content = cont.transport.responseText;
			}
		}


		this._elements.inner = document.createElement('div');
		this._elements.inner.style.position = 'absolute';
		this._elements.inner.style.width = this._properties.innerDims[0] + 'px';
		this._elements.inner.style.height = this._properties.innerDims[1] + 'px';

		var title = document.createElement('div');
		title.appendChild(document.createTextNode(this.options.title));
		title.style.fontFamily = 'verdana';
		title.style.fontSize = '14px';
		title.style.fontWeight = 'bold';
		title.style.color = 'black';
		title.style.width = (this._properties.innerDims[0] - this._properties.buttonHeight) + 'px';
		title.style.height = this._properties.buttonHeight + 'px'
		title.style.position = 'absolute';
		title.style.overflow = 'hidden';
		title.style.top = '0px';
		title.style.left = '0px';
		this._elements.inner.appendChild(title);

		var closer = null;
		if(Browser.isMSIE() && this._properties.button.toLowerCase().indexOf('.png') > -1)
		{
			closer = document.createElement('div');
			closer.style.width = this._properties.buttonHeight + 'px';
			closer.style.height = this._properties.buttonHeight + 'px';
			closer.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + this._properties.button + "', sizingMethod='crop')";
		}
		else
		{
			closer = document.createElement('img');
			closer.width = this._properties.buttonHeight;
			closer.height= this._properties.buttonHeight;
			closer.src = this._properties.button;
		}
		Event.observe(closer, 'click', this.toggle.bindAsEventListener(this));
		closer.style.cursor = 'pointer';
		closer.title = 'Click to close this balloon';
		closer.style.position = 'absolute';
		closer.style.top = '0px';
		closer.style.left = parseInt(title.style.width) + 'px';
		this._elements.inner.appendChild(closer);

		var contents = document.createElement('div');
		contents.style.width = this._properties.innerDims[0] + 'px';
		contents.style.height = (this._properties.innerDims[1] - parseInt(title.style.height)) + 'px';
		contents.style.overflow = 'auto';
		contents.style.position = 'absolute';
		contents.style.top = parseInt(title.style.height) + 'px';
		contents.style.left = "0px";
		contents.style.fontFamily = 'verdana';
		contents.style.fontSize = '11px';
		contents.style.fontWeight = 'normal';
		contents.style.color = 'black';
		contents.innerHTML = this.options.content;
		this._elements.inner.appendChild(contents);
		this._elements.container.appendChild(this._elements.inner);
		document.getElementsByTagName('body')[0].appendChild(this._elements.container);
		this._properties.drawn = true;
	},

	/**
	 * Gets the current position of the obj
	 * @param {Object} obj
	 */
	_getXY: function(obj)
	{
		var pos = Position.cumulativeOffset(obj)
		var y = pos[1];
		var x = pos[0];
		var x2 = x + parseInt(obj.offsetWidth);
		var y2 = y + parseInt(obj.offsetHeight);
		return {'x':x, 'y':y, 'x2':x2, 'y2':y2};

	},

	/**
	 * Determins if the object is a child of the balloon element
	 * @param {Object} obj
	 */
	_isChild: function(obj)
	{
		var i = 15;
		do{
			if(obj == this._elements.container)
				return true;
			obj = obj.parentNode;
		}while(obj && i--);
		return false
	},

	/**
	 * Determines if the balloon is over this_obj object
	 * @param {Object} this_obj
	 */
	_isOver: function(this_obj)
	{
		if(!this._properties.visible) return false;
		if(this_obj == this._elements.container || this._isChild(this_obj)) return false;
		var this_coords = this._getXY(this_obj);
		var that_coords = this._getXY(this._elements.container);
		if(
			(
			 (
			  (this_coords.x >= that_coords.x && this_coords.x <= that_coords.x2)
			   ||
			  (this_coords.x2 >= that_coords.x &&  this_coords.x2 <= that_coords.x2)
			 )
			 &&
			 (
			  (this_coords.y >= that_coords.y && this_coords.y <= that_coords.y2)
			   ||
			  (this_coords.y2 >= that_coords.y && this_coords.y2 <= that_coords.y2)
			 )
			)

		  ){
			return true;
		}
		else
			return false;
	},

	/**
	 * Restores visibility of elements under the balloon
	 * (For IE)
	 */
	_showLowerElements: function()
	{
		var elements = this._getWeirdAPIElements();
		for(var i = 0; i < elements.length; i++)
		{
			if(this._isOver(elements[i]))
			{
				if(elements[i].style.visibility != 'visible' && elements[i].hiddenBy == this)
				{
					elements[i].style.visibility = 'visible';
					elements[i].hiddenBy = null;
				}
			}
		}
	},

	/**
	 * Hides elements below the balloon
	 * (For IE)
	 */
	_hideLowerElements: function()
	{
		var elements = this._getWeirdAPIElements();
		for(var i = 0; i < elements.length; i++)
		{
			if(this._isOver(elements[i]))
			{
				if(elements[i].style.visibility != 'hidden')
				{
					elements[i].style.visibility = 'hidden';
					elements[i].hiddenBy = this;
				}
			}
		}
	},

	/**
	 * Determines which elements need to be hidden
	 * (For IE)
	 */
	_getWeirdAPIElements: function()
	{
		if(!document.all) return [];
		var objs = ['select', 'input', 'object'];
		var elements = [];
		for(var i = 0; i < objs.length; i++)
		{
			var e = document.getElementsByTagName(objs[i]);
			for(var j = 0; j < e.length; j++)
			{
				elements.push(e[j]);
			}
		}
		return elements;
	},

	/**
	 * Hides the other visible help balloons
	 * @param {Object} e
	 */
	_hideOtherHelps: function(e)
	{
		if(!e) e = window.event;
		var divs = document.getElementsByTagName('div');
		for(var i = 0; i < divs.length; i++)
		{
			if(divs[i]._HelpBalloon && divs[i]._HelpBalloon._properties.visible && (divs[i] != this._elements.container))
				divs[i]._HelpBalloon.toggle(e);
		}
	}
};