//Livegrid by Chris van de Steeg (http://blog.ilikeu2.nl)
//LiveGrid is a direct port of Rico.LiveGrid 
// (http://openrico.org)

// version 1.6:
//  Changes sinces 1.5:
//    fixed getMaxFetchSize issues (thanks to Duane Fields)

// version 1.5 was originally based on RicoLiveGrid 1.1rev36

//changes since 1.2:
// - mucho bugfixes

//changes in use since 1.0:
// - additionalParams is now an array
// - ooooh, look that thingie scroll
// - xslt support

//extra comparing to RicoLiveGrid:
// * any html ouput instead of tablerows only
// * no need to specify initial (empty) rowset 
// * automatic height setting if not set on forehand
// * xslt support for any xml-datasource!!
// * the mousewheel support ofcourse! (hey, that's why I started the fork :))

//things to know for using the grid in your site:
// * the element containing the livegrid should always be surrounded by a div (the viewport). This viewport will 
//   be the actually 'frame' that holds the grid
// * xpath: if the rootnode of the xml source contains several root-nodes that are not of importance for the grid
//   (like a rss feed), you should specify the xpath that gets the nodes that _ARE_ of importance
//   Using xpath selector will modify your xml structure: it will create 
//    <livegrid-source>
//       ...elements returned by xpath...
//    </livegrid-source>
// * the livegrid element body should be empty if you want it to auto-size

simpleXslProcessor = function(sXsl) 
{
	if (sXsl)
		this.importStylesheet(sXsl);
}

simpleXslProcessor.prototype._proc = null;

simpleXslProcessor.prototype.importStylesheet = function(sXsl) {
	if(document.implementation && document.implementation.createDocument) {
		this._proc = new XSLTProcessor();
    if (typeof(sXsl) == "string")
    {
  		var parser = new DOMParser();
  		sXsl = parser.parseFromString(sXsl, "text/xml");
    }
		this._proc.importStylesheet(sXsl);

	} else {
		var xslTemplate = new ActiveXObject("Msxml2.XSLTemplate");
    var xslDoc = new ActiveXObject("Msxml2.FreeThreadedDOMDocument");
    xslDoc.async = false;
    xslDoc.loadXML((typeof(sXsl) == "string") ? sXsl : sXsl.xml);
    xslTemplate.stylesheet = xslDoc;
		this._proc = xslTemplate.createProcessor();
	}
}

simpleXslProcessor.prototype.transformAndAdd = function(xmlSource, addToElement, domDocument) {
   if(xmlSource == null) return;
   if (typeof(xmlSource) == "string") {
      if(document.implementation && document.implementation.createDocument) {
         var parser = new DOMParser();
         xmlSource = parser.parseFromString(xmlSource, "text/xml");
      } else {
         var _doc = new ActiveXObject("Msxml2.FreeThreadedDOMDocument");
         _doc.async = false;
         _doc.loadXML(xmlSource);
         xmlSource = _doc;
      }
   }
	if(document.implementation && document.implementation.createDocument) {
      addToElement.innerHTML = '';
      addToElement.appendChild(this._proc.transformToFragment(xmlSource, domDocument));
	} else {
      this._proc.input = xmlSource;
      this._proc.transform();
      addToElement.innerHTML = this._proc.output;
	}
}

simpleXslProcessor.prototype.transform = function(xmlSource, domDocument, returnAsString) {
   if(xmlSource == null) return "";
   if (typeof(returnAsString) == 'undefined') {
      returnAsString = (typeof(xmlSource) == "string");
   }
   if (typeof(xmlSource) == "string") {
      if(document.implementation && document.implementation.createDocument) {
         var parser = new DOMParser();
         xmlSource = parser.parseFromString(xmlSource, "text/xml");
      } else {
         var _doc = new ActiveXObject("Msxml2.FreeThreadedDOMDocument");
         _doc.async = false;
         _doc.loadXML(xmlSource);
         xmlSource = _doc;
      }
   }
	if(document.implementation && document.implementation.createDocument) {
      if (returnAsString){
         var result = this._proc.transformToFragment(xmlSource, domDocument);
         var _tmp = domDocument.createElement('div');
         _tmp.appendChild(result);
         result = _tmp.innerHTML;
         _tmp = null;
         return result;
       }
       else
         return this._proc.transformToDocument (xmlSource, domDocument);
	} else {
      this._proc.input = xmlSource;
      if (!returnAsString){
         var _doc = new ActiveXObject("MSXML2.DOMDocument");
         this._proc.output = _doc;
      }
      this._proc.transform();
      return this._proc.output;
	}
}

simpleXslProcessor.prototype.getParameter = function(paramName, paramValue) {
	this._proc.getParameter(paramName, paramValue);

}

simpleXslProcessor.prototype.setParameter = function(namespace, paramName, paramValue) {
	if(document.implementation && document.implementation.createDocument) {
		this._proc.setParameter(namespace, paramName, paramValue);
	} else {
		this._proc.addParameter(paramName, paramValue);
	}

}

var defaultXslt = 
'<?xml version="1.0" encoding="ISO-8859-1"?>'+
'<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">'+
'<xsl:param name="start" />'+
'<xsl:param name="end" />'+
'<xsl:param name="emptyrows">0</xsl:param>'+
'<xsl:template match="@*|node()"><xsl:copy-of select="." /></xsl:template>'+
'<xsl:template match="/"><xsl:element name="{name(/*[1])}">'+
'<xsl:apply-templates select="/*[1]/*[position() &gt; $start and position() &lt;= $end]" />'+
'</xsl:element></xsl:template>'+
'</xsl:stylesheet>';

// LiveGridMetaData -----------------------------------------------------

LiveGridMetaData = Class.create();

LiveGridMetaData.prototype = {

   initialize: function( pageSize, totalRows, options ) {
      this.pageSize  = pageSize;
      this.setOptions(options);
      this.setTotalRows(totalRows);
      this.scrollArrowHeight = 16;
   },

   setOptions: function(options) {
      this.options = {
         largeBufferSize    : 7.0,   // 7 pages
         nearLimitFactor    : 0.2,    // 20% of buffer
         maxRecordsetCount  : 500000 //
      };
      Object.extend(this.options, options || {});
   },

   getPageSize: function() {
      return this.pageSize;
   },

   setPageSize: function(newVal) {
        this.pageSize = newVal;
   },

   getTotalRows: function() {
      return this.totalRows;
   },

   setTotalRows: function(n) {
      if (n > this.options.maxRecordsetCount) {
        this.totalRows = this.options.maxRecordsetCount;
        this.realTotalRows = n;
      } else {
        this.totalRows = this.realTotalRows = n;
      }
      
   },
   
   getRealTotalRows: function() {
    return this.realTotalRows;
   },

   getLargeBufferSize: function() {
      return parseInt(this.options.largeBufferSize * this.pageSize);
   },

   getLimitTolerance: function() {
      return parseInt(this.getLargeBufferSize() * this.options.nearLimitFactor);
   }
};

// LiveGridScroller -----------------------------------------------------

LiveGridScroller = Class.create();

LiveGridScroller.prototype = {

   initialize: function(liveGrid, viewPort) {
      this.isIE = navigator.userAgent.toLowerCase().indexOf("msie") >= 0;
      this.liveGrid = liveGrid;
      this.metaData = liveGrid.metaData;
      this.viewPort = viewPort;
      this.createScrollBar();
      this.scrollTimeout = null;
      this.lastScrollPos = 0;
      this.rows = null;
   },

   isUnPlugged: function() {
      return this.scrollerDiv.onscroll == null;
   },

   plugin: function() {
      this.scrollerDiv.onscroll = this.handleScroll.bindAsEventListener(this);
   },

   unplug: function() {
      this.scrollerDiv.onscroll = null;
   },

   createScrollBar: function() {
      var visibleHeight = this.liveGrid.viewPort.visibleHeight();
      // create the outer div...
      this.scrollerDiv  = document.createElement("div");
      var scrollerStyle = this.scrollerDiv.style;
      scrollerStyle.position    = "absolute";
      
      var offsets = Position.cumulativeOffset(this.viewPort.div);
      this.scrollerDiv.style.top = offsets[1] + 'px';
      this.scrollerDiv.style.left = (offsets[0] + this.viewPort.div.offsetWidth -19) + 'px';

      scrollerStyle.width       = "19px";
      scrollerStyle.height      = this.viewPort.div.offsetHeight + "px";
      scrollerStyle.overflowY    = "scroll"; // always show disabled scroll
      
      scrollerStyle.zIndex = 999;
      var table = this.liveGrid.table;
      this.scrollerDiv.className = 'scrollerdiv';
      
      // create the inner div...
      this.heightDiv = document.createElement("div");
      this.heightDiv.style.width  = "1px";
      this.heightDiv.style.height = parseInt(visibleHeight * this.metaData.getTotalRows()/this.metaData.getPageSize()) + "px" ;
      this.scrollerDiv.appendChild(this.heightDiv);
      this.scrollerDiv.onscroll = this.handleScroll.bindAsEventListener(this);
      
      var table = this.liveGrid.table;
      //table.parentNode.appendChild(this.scrollerDiv);
      document.body.insertBefore(this.scrollerDiv, document.body.firstChild);      
 
      var eventName = this.isIE ? "mousewheel" : "DOMMouseScroll";
      Event.observe(table, eventName, 
            function(evt) {
				if (!this.isUnPlugged() && !this.viewPort.isBlank && (this.metaData.getTotalRows() > this.metaData.getPageSize())) {
					if (evt.wheelDelta>=0 || evt.detail < 0) //wheel-up
						this.scrollerDiv.scrollTop -= (2*this.viewPort.rowHeight);
					else
						this.scrollerDiv.scrollTop += (2*this.viewPort.rowHeight);
					this.handleScroll(false);
				}
            }.bindAsEventListener(this), 
            false);
   },

   updateSize: function() {
      var table = this.liveGrid.table;
      var visibleHeight = this.viewPort.visibleHeight();
      this.scrollerDiv.style.height = this.viewPort.div.offsetHeight + "px";
      if (visibleHeight<0)
        visibleHeight = 0;
	  
	  this.heightDiv.style.height = visibleHeight *
									(this.metaData.getTotalRows()/this.metaData.getPageSize()) + "px";
   },

   rowToPixel: function(rowOffset) {
      return (rowOffset / this.metaData.getTotalRows()) * this.heightDiv.offsetHeight
   },
   
   moveScroll: function(rowOffset) {
      this.scrollerDiv.scrollTop = this.rowToPixel(rowOffset);
      if ( this.metaData.options.onscroll )
         this.metaData.options.onscroll( this.liveGrid, rowOffset );    
   },

   handleScroll: function() {
	if ( this.scrollTimeout )
		clearTimeout( this.scrollTimeout );
	if ( this.preventDoubleScrollEventTimeout )
		clearTimeout( this.preventDoubleScrollEventTimeout );

	var scrollDiff = this.lastScrollPos-this.scrollerDiv.scrollTop;
	/*
	if (scrollDiff != 0.00) {
  		var r = this.scrollerDiv.scrollTop % this.viewPort.rowHeight;
  		if (r != 0) {
  			this.unplug();
  			if ( scrollDiff < 0 ) {
  				this.scrollerDiv.scrollTop += (this.viewPort.rowHeight-r);
  			} else {
  				this.scrollerDiv.scrollTop -= r;
  			}
  			this.plugin();
  		}
	}*/
		    
	var contentOffset = parseInt(this.scrollerDiv.scrollTop / this.viewPort.rowHeight);
	if ( this.metaData.options.onscroll )
		this.metaData.options.onscroll( this.liveGrid, contentOffset );
	this.preventDoubleScrollEventTimeout = setTimeout(
		function() {
			var contentOffset = parseInt(this.scrollerDiv.scrollTop / this.viewPort.rowHeight);
			this.liveGrid.requestContentRefresh(contentOffset);
			this.viewPort.scrollTo(this.scrollerDiv.scrollTop);

			this.scrollTimeout = setTimeout( this.scrollIdle.bind(this), 1200 );
			this.lastScrollPos = this.scrollerDiv.scrollTop;

		}.bind(this), 1);
			
   },

   scrollIdle: function() {
      if ( this.metaData.options.onscrollidle )
         this.metaData.options.onscrollidle();
   }
};

// LiveGridBuffer -----------------------------------------------------

LiveGridBuffer = Class.create();

LiveGridBuffer.prototype = {

   initialize: function(liveGrid) {
      this.startPos = 0;
      this.size     = 0;
      this.rows     = null;
      this.updateInProgress = false;
      this.liveGrid = liveGrid;
      this.lastOffset = 0;
      this.isIE = navigator.userAgent.toLowerCase().indexOf("msie") >= 0;
   },
   
   getMaxFetchSize: function(){
      return this.liveGrid.metaData.getLargeBufferSize();
   },

   getMaxBufferSize: function(){
      return this.liveGrid.metaData.getLargeBufferSize() * 2;
   },

   loadRows: function(ajaxResponse) {
     if (this.isIE && !this.liveGrid.preXslProcessor)
       return ajaxResponse.responseXML;
     if (this.liveGrid.preXslProcessor)
     {
       return this.liveGrid.preXslProcessor.transform(ajaxResponse.responseXML, document, false);
     }
     else
     {
       var _rows = ajaxResponse.responseXML;
       for (var i=_rows.documentElement.childNodes.length-1;i>=0;i--) {
         var tp = _rows.documentElement.childNodes[i].nodeType;
         if (tp == 3 || tp == 3) {
           _rows.documentElement.removeChild(_rows.documentElement.childNodes[i]);
         }
       }
     
       return _rows;
     }
   },
   
   update: function(ajaxResponse, start) {
      var newRows = this.loadRows(ajaxResponse);
      var total = ajaxResponse.responseXML.documentElement.getAttribute(this.liveGrid.options.rs_totalrows);
      if (total != null)
      {
         this.liveGrid.setTotalRows(parseInt(total));
	  }

      if (this.rows == null) { // initial load
         this.rows = newRows;
         this.size = this.rows.documentElement.childNodes.length;
         this.startPos = start;
         return;
      }
      if(start == this.startPos) { //not moving just refreshing..
		this.rows = newRows;
      }
      else if (start > this.startPos) { //appending
         var fullSize = this.rows.documentElement.childNodes.length;            
         if (this.startPos + fullSize < start) {
            this.rows = newRows;
            this.startPos = start;//
         } else {
            while (newRows.documentElement.childNodes.length > 0) {
              this.rows.documentElement.appendChild(newRows.documentElement.childNodes[0]);
            }
            fullSize = this.rows.documentElement.childNodes.length;    
            if (fullSize > this.getMaxBufferSize()) {
               for (var i=(fullSize - this.getMaxBufferSize()-1);i>=0;i--) {
                 this.rows.documentElement.removeChild(this.rows.documentElement.childNodes[0]);
               }
               this.startPos = this.startPos +  (fullSize - this.rows.documentElement.childNodes.length);
            }
         }
      } else { //prepending
         var newRowsSize = newRows.documentElement.childNodes.length;
         if (start + newRowsSize < this.startPos) {
            this.rows = newRows;
         } else {
            //this.rows = newRows.slice(0, this.startPos).concat(this.rows);
            var firstRow = this.rows.documentElement.childNodes[0];
            while (newRows.documentElement.childNodes.length > 0) {
               this.rows.documentElement.insertBefore(newRows.documentElement.childNodes[0], firstRow)
            } 
            var rowsize = this.rows.documentElement.childNodes.length;
            for (var i=rowsize-1;i>this.getMaxBufferSize();i--)
               this.rows.documentElement.removeChild(this.rows.documentElement.childNodes[i]);
         }
         this.startPos =  start;
      }
      this.size = this.rows.documentElement.childNodes.length;
   },
   
   clear: function() {
      this.rows = null;
      this.startPos = 0;
      this.size = 0;
   },

   isOverlapping: function(start, size) {
      return ((start < this.endPos()) && (this.startPos < start + size)) || (this.endPos() == 0)
   },

   isInRange: function(position) {
      return (position >= this.startPos) && (position + this.liveGrid.metaData.getPageSize() <= this.endPos()); 
             //&& this.size()  != 0;
   },

   isNearingTopLimit: function(position) {
      return position - this.startPos < this.liveGrid.metaData.getLimitTolerance();
   },

   endPos: function() {
      return this.startPos + this.size;
   },
   
   isNearingBottomLimit: function(position) {
      return this.endPos() - (position + this.liveGrid.metaData.getPageSize()) < this.liveGrid.metaData.getLimitTolerance();
   },

   isAtTop: function() {
      return this.startPos == 0;
   },

   isAtBottom: function() {
      return this.endPos() == this.liveGrid.metaData.getTotalRows();
   },

   isNearingLimit: function(position) {
      return ( !this.isAtTop()    && this.isNearingTopLimit(position)) ||
             ( !this.isAtBottom() && this.isNearingBottomLimit(position) )
   },

   getFetchSize: function(offset) {
      var adjustedOffset = this.getFetchOffset(offset);
      var adjustedSize = 0;
      if (adjustedOffset >= this.startPos) { //appending
         var endFetchOffset = this.getMaxFetchSize()  + adjustedOffset;
         if (endFetchOffset > this.liveGrid.metaData.getTotalRows())
            endFetchOffset = this.liveGrid.metaData.getTotalRows();
         adjustedSize = endFetchOffset - adjustedOffset;
		 if(adjustedOffset == 0 && adjustedSize < this.getMaxFetchSize()){ 
			adjustedSize = this.getMaxFetchSize(); 
         } 
         
      } else {//prepending
         var adjustedSize = this.startPos - adjustedOffset;
         if (adjustedSize > this.getMaxFetchSize())
            adjustedSize = this.getMaxFetchSize();
      }
      return adjustedSize;
   }, 

   getFetchOffset: function(offset) {
      var adjustedOffset = offset;
      if (offset > this.startPos)  //apending
         adjustedOffset = (offset > this.endPos()) ? offset :  this.endPos(); 
      else { //prepending
         if (offset + this.getMaxFetchSize() >= this.startPos) {
            var adjustedOffset = this.startPos - this.getMaxFetchSize();
            if (adjustedOffset < 0)
               adjustedOffset = 0;
         }
      }
      this.lastOffset = adjustedOffset;
      return adjustedOffset;
   },

   convertSpaces: function(s) {
      return s.split(" ").join("&nbsp;");
   }

};


//GridViewPort --------------------------------------------------
GridViewPort = Class.create();

GridViewPort.prototype = {

   initialize: function(table, rowHeight, visibleRows, buffer, liveGrid) {
      this.lastDisplayedStartPos = 0;
      this.div = table.parentNode;
      this.table = table
      this.rowHeight = rowHeight;
      if (rowHeight > 0)
        this.div.style.height = (this.rowHeight * visibleRows);
      this.div.style.overflow = "hidden";
      this.buffer = buffer;
      this.liveGrid = liveGrid;
      this.visibleRows = visibleRows + 1;
      this.lastPixelOffset = 0;
      this.startPos = 0;
      //this.clearRows();
      this.heightIsSet = false;
   },

   setPageSize: function(newVal) {
      if (this.visibleRows == newVal+1)
        return;
      
      this.heightIsSet = false;
      var oldVal = this.visibleRows;
      this.visibleRows = newVal+1;
      this.emptyHTML = null;
      if (this.liveGrid.needToCalcHeight) {
        this.rowHeight = -1;
        this.heightIsSet = false;
      }
      this.liveGrid.resetContents();
   },
   
   bufferChanged: function(offset) {
      this.refreshContents( offset ? offset : parseInt(this.lastPixelOffset / this.rowHeight));
   },
   
   clearRows: function() {
      if (!this.isBlank) {
        if (this.emptyHTML == null)
        {
          this.liveGrid.xsltProc.setParameter(null, "offset", 0);
          this.liveGrid.xsltProc.setParameter(null, "start", -1);
          this.liveGrid.xsltProc.setParameter(null, "end", -1);
          this.liveGrid.xsltProc.setParameter(null, "emptyrows", this.visibleRows);
          if (this.buffer.rows == null) {
			this.liveGrid.xsltProc.transformAndAdd('<empty></empty>', this.table, document);
		  } else {
			this.liveGrid.xsltProc.transformAndAdd(this.buffer.rows, this.table, document);
		  }
          this.emptyHTML = this.table.innerHTML;
        } else {
          this.table.innerHTML = this.emptyHTML;
        }
        if (this.table.innerHTML == '' || ((this.table.childNodes.length == 1) && (this.table.childNodes[0].innerHTML == '')))
          this.table.innerHTML = '&nbsp;'; //strange, but if the grid's totally empty, the width gets screwed up :s
        this.isBlank = true;
        //this.checkSize();
      }
   },
   
   clearContents: function() {
      this.isBlank = false;   
      this.emptyHTML = null;
      this.clearRows();
      this.scrollTo(0, true);
      this.startPos = 0;
      this.lastStartPos = -1;   
   },
   
   refreshContents: function(startPos) {
      if (startPos == this.lastRowPos && !this.isPartialBlank && !this.isBlank) {
         return;
      }
      if ((startPos + this.visibleRows < this.buffer.startPos)  
          || (this.buffer.startPos + this.buffer.size < startPos) 
          || (this.buffer.size == 0)) {
         if (this.buffer.rows != null) {
			this.emptyHTML = null;
			this.isBlank = false;//allow to reset the empty content based on the received xml (ie. if the root has attributes)
         }
         this.clearRows();
         return;
      }
      this.isBlank = false;
      var viewPrecedesBuffer = this.buffer.startPos > startPos
      var contentStartPos = viewPrecedesBuffer ? this.buffer.startPos: startPos;
      var contentEndPos = (this.buffer.startPos + this.buffer.size < startPos + this.visibleRows) 
                                 ? this.buffer.startPos + this.buffer.size
                                 : startPos + this.visibleRows;
      
      var offset =  contentStartPos - this.buffer.startPos;
      var rowSize = contentEndPos - contentStartPos;
      var datasourceLength = this.buffer.rows.documentElement.childNodes.length;
      var blankSize = (datasourceLength < this.visibleRows) ? (this.visibleRows-datasourceLength) : 0;
      
      if (viewPrecedesBuffer)
      {
		blankSize = -blankSize;
      }
                   
      var blankOffset = viewPrecedesBuffer ? 0: rowSize;
      var contentOffset = viewPrecedesBuffer ? blankSize: 0;

      this.liveGrid.xsltProc.setParameter(null, "offset", startPos);
      this.liveGrid.xsltProc.setParameter(null, "start", offset);
      this.liveGrid.xsltProc.setParameter(null, "end", offset + rowSize);
      this.liveGrid.xsltProc.setParameter(null, "emptyrows", blankSize);
      this.liveGrid.xsltProc.transformAndAdd(this.buffer.rows, this.table, document);
      if (this.table.innerHTML == '' || this.table.childNodes[0].innerHTML == '')
         this.table.innerHTML = '&nbsp;'; //strange, but if the grid's totally empty, the width gets screwed up :s
      this.isPartialBlank = blankSize > 0;
      this.lastRowPos = startPos;
      
      this.checkSize();
	  
	  var onRefreshComplete = this.liveGrid.options.onRefreshComplete; 
      if (onRefreshComplete != null) 
         onRefreshComplete(); 
      
   },
   
   checkSize: function() {
      if (this.liveGrid.needToCalcHeight && !this.heightIsSet) {
        this.rowHeight = this.table.offsetHeight/this.visibleRows;
        this.heightIsSet = true;
        //this.div.style.height = (this.rowHeight * (this.visibleRows))+ "px";
        if (this.liveGrid.scroller) {
          this.liveGrid.scroller.updateSize();
        }
      }   
   },

   scrollTo: function(pixelOffset, force) {  
      if (!force && (this.lastPixelOffset == pixelOffset))
         return;
      this.refreshContents(parseInt(pixelOffset / this.rowHeight));
      this.div.scrollTop = pixelOffset % this.rowHeight;

      this.lastPixelOffset = pixelOffset;
   },
   
   visibleHeight: function() {
      //return this.div.offsetHeight;
      return (this.rowHeight * (this.visibleRows-1));
   }
   
};


LiveGridRequest = Class.create();
LiveGridRequest.prototype = {
   initialize: function( requestOffset, options ) {
      this.requestOffset = requestOffset;
   }
};

// LiveGrid -----------------------------------------------------

LiveGrid = Class.create();

LiveGrid.prototype = {

   initialize: function( tableId, visibleRows, totalRows, url, options ) {
      if ( options == null )
         options = {};

      this.setOptions(options);
      
      this.xsltProc = new simpleXslProcessor();
      if (this.options.xslt == null) {
        this.xsltProc.importStylesheet(defaultXslt);
      } else {
        this.xsltProc.importStylesheet(this.options.xslt);
      }
      
      if (this.options.xpath) {
         this.setXpathSelector(this.options.xpath);
      }
      
      this.tableId     = tableId; 
      this.table       = $(tableId);
      if (this.table.clientHeight == 0 || this.options.calcHeight) {
        this.needToCalcHeight = true;
      }
      if (this.table.innerHTML == '')
      {
        this.needToCalcHeight = true;
        this.hasNoContent = true;
        this.table.innerHTML = '&nbsp;';
      }
      this.metaData    = new LiveGridMetaData(visibleRows, totalRows, options);
      this.buffer      = new LiveGridBuffer(this);
      this.url         = url;

      this.additionalParms = options.requestParameters || [];
      
      options.sortHandler = this.sortHandler.bind(this);

      if ( $(tableId + '_header') )
         this.sort = new LiveGridSort(tableId + '_header', options)

      this.processingRequest = null;
      this.unprocessedRequest = null;

      if ( options.prefetchBuffer || options.prefetchOffset > 0) {
        this.requestContentRefresh(options.offset || 0);
      } else {
       
       //remove text'nodes'
       for (var i=this.table.childNodes.length-1;i>=0;i--) {
         var tp = this.table.childNodes[i].nodeType;
         if (tp == 3 || tp == 3) {
           this.table.removeChild(this.table.childNodes[i]);
         }
       }
      
       var rowCount = this.table.childNodes.length;

       this.viewPort =  new GridViewPort(this.table, 
                                              this.table.offsetHeight/rowCount,
                                              visibleRows,
                                              this.buffer, this);
       this.scroller    = new LiveGridScroller(this,this.viewPort);
      }
   },
   
   setOptions: function(options) {
      this.options = {
         xpath:         false,
         qs_offset:     'offset',
         qs_pagesize:   'page_size',
         qs_offset_add: 0,
         requestTimeout: 20000,
         rs_totalrows:  'totalrows'          
      };
      
      Object.extend(this.options, options || {});
   },

   
   setXpathSelector: function(xpath) {
      this.options.xpath = xpath;
      if (this.options.xpath) {
         var preXslt = 
            '<xsl:stylesheet version="1.0" ' + (this.options.xpathNamespace ? this.options.xpathNamespace : '') +  
            ' xmlns:xsl="http://www.w3.org/1999/XSL/Transform">'+
            '<xsl:template match="@*|node()"><xsl:copy-of select="." /></xsl:template>'+
            '<xsl:template match="/"><livegrid-source><xsl:apply-templates select="' + this.options.xpath + '" /></livegrid-source></xsl:template>'+
            '</xsl:stylesheet>';
         this.preXslProcessor = new simpleXslProcessor();
         this.preXslProcessor.importStylesheet(preXslt);
      } else {
         this.preXslProcessor = false;
      }
   },

   setXslt: function(xslt) {
      this.xsltProc.importStylesheet(xslt);
      this.resetContents();
      this.viewPort.clearRows();
      this.requestContentRefresh(0);
   },
   
   setVisibleRows: function(newVal) {
     if (newVal != this.metaData.getPageSize()) {
        this.metaData.setPageSize(newVal);
        this.viewPort.setPageSize(newVal);
        this.resetContents();
        this.viewPort.clearRows();
        this.requestContentRefresh(0);
     }
   },
   
   resetContents: function() {
      if (this.scroller)
        this.scroller.moveScroll(0);
      if (this.buffer)
        this.buffer.clear();
      if (this.viewPort) {
		this.viewPort.clearRows();
          //this.viewPort.rowHeight = -1;
        this.viewPort.heightIsSet = false;
        this.viewPort.clearContents();
      }
      this.processingRequest = null;
      this.unprocessedRequest = null;
      clearTimeout( this.timeoutHandler );
   },
   
   sortHandler: function(column) {
	  if (!column) return;
	  
      this.sortCol = column.name;
      this.sortDir = column.currentSort;

      this.resetContents();
      this.requestContentRefresh(0) 
   },
   
   setRequestParams: function() {
      this.additionalParms = [];
      //check if an array has been passed
      if ((arguments.length > 0) &&
		 (arguments[0].constructor == Array))
	  {	
		this.additionalParms = arguments[0];
      }
      else {
		this.additionalParms = [];
		for ( var i=0 ; i < arguments.length ; i++ )
			this.additionalParms[i] = arguments[i];
	 }
	 
   },

   setTotalRows: function( newTotalRows ) {
      if (newTotalRows != this.metaData.getTotalRows())
      {
        //this.resetContents();
        this.metaData.setTotalRows(newTotalRows);
        if (this.scroller)
         this.scroller.updateSize();
      }
   },

   handleTimedOut: function() {
      //server did not respond in 4 seconds... assume that there could have been
      //an error or something, and allow requests to be processed again...
      this.processingRequest = null;
      this.processQueuedRequest();
      if (this.options.onTimedOut)
        this.options.onTimedOut(this);
   },

   fetchBuffer: function(offset) {
      if ( this.buffer.isInRange(offset) &&
         !this.buffer.isNearingLimit(offset)) {
         return false;
      }
      if (this.processingRequest) {
         this.unprocessedRequest = new LiveGridRequest(offset);
         return false;
      }
      var bufferStartPos = this.buffer.getFetchOffset(offset);
      this.processingRequest = new LiveGridRequest(offset);
      this.processingRequest.bufferOffset = bufferStartPos;   
      var fetchSize = this.buffer.getFetchSize(offset);
      var partialLoaded = false;
      var callParms = []; 
      //callParms.push(this.tableId + '_request');
      //callParms.push('id='        + this.tableId);
      callParms.push(this.options.qs_pagesize + '=' + fetchSize);
      callParms.push(this.options.qs_offset   + '=' + (bufferStartPos + this.options.qs_offset_add));
      if ( this.sortCol) {
         callParms.push('sort_col='    + this.sortCol);
         callParms.push('sort_dir='    + this.sortDir);
      }
      
      for( var i=0 ; i < this.additionalParms.length ; i++ )
         callParms.push(this.additionalParms[i]);
      
      var options = {
          parameters: callParms.join('&'),
          method: 'get'
      };
      Object.extend(options,this.options);
      options.onComplete = this.ajaxUpdate.bind(this); 
      this.timeoutHandler = setTimeout( this.handleTimedOut.bind(this), this.options.requestTimeout );
      new Ajax.Request(this.url, options);
   },

   requestContentRefresh: function(contentOffset) {
      if (contentOffset == null)
      {
		contentOffset = parseInt(this.scroller.scrollerDiv.scrollTop / this.viewPort.rowHeight);
      }
      if (this.viewPort)
		this.viewPort.lastRowPos = -1;
      return this.fetchBuffer(contentOffset);
   },
   dispose: function() {
	this.resetContents();
	if(this.scroller && this.scroller.scrollerDiv)
		this.scroller.scrollerDiv.onscroll = null;
	this.viewPort = null;
   },

   ajaxUpdate: function(ajaxResponse) {
      try {
        clearTimeout( this.timeoutHandler );
        if (!this.processingRequest)
			return;
			
        this.buffer.update(ajaxResponse,this.processingRequest.bufferOffset);
        if (!this.scroller) //firstcontent
        {
          this.viewPort =  new GridViewPort(this.table, 
                                                (this.needToCalcHeight ? -1 : (this.table.offsetHeight/this.metaData.pageSize)),
                                                this.metaData.pageSize,
                                                this.buffer, this);
          this.viewPort.bufferChanged(this.options.offset ? this.options.offset : null);
          this.scroller    = new LiveGridScroller(this,this.viewPort);
          var offset = 0;
          if (this.options.offset ) {
            offset = this.options.offset;            
            this.scroller.moveScroll(offset);
            this.viewPort.scrollTo(this.scroller.rowToPixel(offset), force);            
          } else {
            this.scroller.moveScroll(0);
            this.viewPort.scrollTo(0, true);
          }
          if (this.options.sortCol) {
             this.sortCol = this.options.sortCol;
             this.sortDir = this.options.sortDir;
          }
           if (this.options.onFirstContent)
              this.options.onFirstContent(this, 0);
        } else {
          this.viewPort.bufferChanged();
        }
        
        if (this.options.onComplete)
          this.options.onComplete(this);
      }
      catch(err) {
        if (this.options.onFailure)
          this.options.onFailure(this, err);
        else
			alert("Error occured: \n" + err.message);
      }
      finally {
        this.processingRequest = null; 
      }
      
      this.processQueuedRequest();
   },

   processQueuedRequest: function() {
      if (this.unprocessedRequest != null) {
        this.requestContentRefresh(this.unprocessedRequest.requestOffset);
        this.unprocessedRequest = null
      }  
   }
 
};
