/*
**
 * formatter for values but most of the values if for jqGrid
 * Some of this was inspired and based on how YUI does the table datagrid but in jQuery fashion
 * we are trying to keep it as light as possible
 * Joshua Burnett josh@9ci.com	
 * http://www.greenbill.com
 *
 * Changes from Tony Tomov tony@trirand.com
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 * 
**/

;(function($) {
	$.fmatter = {};
	//opts can be id:row id for the row, rowdata:the data for the row, colmodel:the column model for this column
	//example {id:1234,}
	$.fn.fmatter = function(formatType, cellval, opts, act) {
		//debug(this);
		//debug(cellval);
		// build main options before element iteration
		opts = $.extend({}, $.jgrid.formatter, opts);
		return this.each(function() {
			//debug("in the each");
			$this = $(this);
			//for the metaplugin if it exists
			var o = $.meta ? $.extend({}, opts, $this.data()) : opts;
			//debug("firing formatter");
			fireFormatter($this,formatType,cellval, opts, act); 
		});
	};
	$.fmatter.util = {
		// Taken from YAHOO utils
		NumberFormat : function(nData,opts) {
			if(!isNumber(nData)) {
				nData *= 1;
			}
			if(isNumber(nData)) {
		        var bNegative = (nData < 0);
				var sOutput = nData + "";
				var sDecimalSeparator = (opts.decimalSeparator) ? opts.decimalSeparator : ".";
				var nDotIndex;
				if(isNumber(opts.decimalPlaces)) {
					// Round to the correct decimal place
					var nDecimalPlaces = opts.decimalPlaces;
					var nDecimal = Math.pow(10, nDecimalPlaces);
					sOutput = Math.round(nData*nDecimal)/nDecimal + "";
					nDotIndex = sOutput.lastIndexOf(".");
					if(nDecimalPlaces > 0) {
                    // Add the decimal separator
						if(nDotIndex < 0) {
							sOutput += sDecimalSeparator;
							nDotIndex = sOutput.length-1;
						}
						// Replace the "."
						else if(sDecimalSeparator !== "."){
							sOutput = sOutput.replace(".",sDecimalSeparator);
						}
                    // Add missing zeros
						while((sOutput.length - 1 - nDotIndex) < nDecimalPlaces) {
						    sOutput += "0";
						}
	                }
	            }
	            if(opts.thousandsSeparator) {
	                var sThousandsSeparator = opts.thousandsSeparator;
	                nDotIndex = sOutput.lastIndexOf(sDecimalSeparator);
	                nDotIndex = (nDotIndex > -1) ? nDotIndex : sOutput.length;
	                var sNewOutput = sOutput.substring(nDotIndex);
	                var nCount = -1;
	                for (var i=nDotIndex; i>0; i--) {
	                    nCount++;
	                    if ((nCount%3 === 0) && (i !== nDotIndex) && (!bNegative || (i > 1))) {
	                        sNewOutput = sThousandsSeparator + sNewOutput;
	                    }
	                    sNewOutput = sOutput.charAt(i-1) + sNewOutput;
	                }
	                sOutput = sNewOutput;
	            }
	            // Prepend prefix
	            sOutput = (opts.prefix) ? opts.prefix + sOutput : sOutput;
	            // Append suffix
	            sOutput = (opts.suffix) ? sOutput + opts.suffix : sOutput;
	            return sOutput;
				
			} else {
				return nData;
			}
		},
		// Tony Tomov
		// PHP implementation. Sorry not all options are supported.
		// Feel free to add them if you want
		DateFormat : function (format, date, newformat, opts)  {
			var	token = /\\.|[dDjlNSwzWFmMntLoYyaABgGhHisueIOPTZcrU]/g,
			timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
			timezoneClip = timezoneClip = /[^-+\dA-Z]/g,
			pad = function (value, length) {
				value = String(value);
				length = parseInt(length) || 2;
				while (value.length < length) value = '0' + value;
				return value;
			},
		    ts = {m : 1, d : 1, y : 1970, h : 0, i : 0, s : 0},
		    timestamp=0,
		    dateFormat=["i18n"];
			// Internationalization strings
		    dateFormat["i18n"] = {
				dayNames:   opts.dayNames,
		    	monthNames: opts.monthNames
			};
			format = format.toLowerCase();
			date = date.split(/[\\\/:_;.tT\s-]/);
			format = format.split(/[\\\/:_;.tT\s-]/);
			// !!!!!!!!!!!!!!!!!!!!!!
			// Here additional code to parse for month names
			// !!!!!!!!!!!!!!!!!!!!!!
		    for(var i=0;i<format.length;i++){
		        ts[format[i]] = parseInt(date[i],10);
		    }
		    ts.m = parseInt(ts.m)-1;
		    var ty = ts.y;
		    if (ty >= 70 && ty <= 99) ts.y = 1900+ts.y;
		    else if (ty >=0 && ty <=69) ts.y= 2000+ts.y;
		    timestamp = new Date(ts.y, ts.m, ts.d, ts.h, ts.i, ts.s,0);
			if( opts.masks.newformat )  {
				newformat = opts.masks.newformat;
			} else if ( !newformat ) {
				newformat = 'Y-m-d';
			}
		    var 
		        G = timestamp.getHours(),
		        i = timestamp.getMinutes(),
		        j = timestamp.getDate(),
				n = timestamp.getMonth() + 1,
				o = timestamp.getTimezoneOffset(),
				s = timestamp.getSeconds(),
				u = timestamp.getMilliseconds(),
				w = timestamp.getDay(),
				Y = timestamp.getFullYear(),
				N = (w + 6) % 7 + 1,
				z = (new Date(Y, n - 1, j) - new Date(Y, 0, 1)) / 86400000,
				flags = {
					// Day
					d: pad(j),
					D: dateFormat.i18n.dayNames[w],
					j: j,
					l: dateFormat.i18n.dayNames[w + 7],
					N: N,
					S: opts.S(j),
					//j < 11 || j > 13 ? ['st', 'nd', 'rd', 'th'][Math.min((j - 1) % 10, 3)] : 'th',
					w: w,
					z: z,
					// Week
					W: N < 5 ? Math.floor((z + N - 1) / 7) + 1 : Math.floor((z + N - 1) / 7) || ((new Date(Y - 1, 0, 1).getDay() + 6) % 7 < 4 ? 53 : 52),
					// Month
					F: dateFormat.i18n.monthNames[n - 1 + 12],
					m: pad(n),
					M: dateFormat.i18n.monthNames[n - 1],
					n: n,
					t: '?',
					// Year
					L: '?',
					o: '?',
					Y: Y,
					y: String(Y).substring(2),
					// Time
					a: G < 12 ? opts.AmPm[0] : opts.AmPm[1],
					A: G < 12 ? opts.AmPm[2] : opts.AmPm[3],
					B: '?',
					g: G % 12 || 12,
					G: G,
					h: pad(G % 12 || 12),
					H: pad(G),
					i: pad(i),
					s: pad(s),
					u: u,
					// Timezone
					e: '?',
					I: '?',
					O: (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
					P: '?',
					T: (String(timestamp).match(timezone) || [""]).pop().replace(timezoneClip, ""),
					Z: '?',
					// Full Date/Time
					c: '?',
					r: '?',
					U: Math.floor(timestamp / 1000)
				};	
			return newformat.replace(token, function ($0) {
				return $0 in flags ? flags[$0] : $0.substring(1);
			});			
		}
	};
	$.fn.fmatter.defaultFormat = function(el, cellval, opts) {
		$(el).html((isValue(cellval) && cellval!=="" ) ?  cellval : "&#160;");
	};
	$.fn.fmatter.email = function(el, cellval, opts) {
		if(!isEmpty(cellval)) {
            $(el).html("<a href=\"mailto:" + cellval + "\">" + cellval + "</a>");
        }else {
           $.fn.fmatter.defaultFormat(el, cellval);
        }
	};
	$.fn.fmatter.checkbox =function(el,cval,opts) {
		cval=cval+""; cval=cval.toLowerCase();
		var bchk = cval.search(/(false|0|no|off)/i)<0 ? " checked=\"checked\"" : "";
        $(el).html("<input type=\"checkbox\"" + bchk  + " value=\""+ cval+"\" offval=\"no\" disabled/>");
    },
	$.fn.fmatter.link = function(el,cellval,opts) {
        if(!isEmpty(cellval)) {
           $(el).html("<a href=\"" + cellval + "\">" + cellval + "</a>");
        }else {
            $(el).html(isValue(cellval) ? cellval : "");
        }
    };
	$.fn.fmatter.showlink = function(el,cellval,opts) {
		var op = {baseLinkUrl: opts.baseLinkUrl,showAction:opts.showAction, addParam: opts.addParam };
		if(!isUndefined(opts.colModel.formatoptions)) {
			op = $.extend({},op,opts.colModel.formatoptions);
		}
		idUrl = op.baseLinkUrl+op.showAction + '?id='+opts.rowId+op.addParam;
        if(isString(cellval)) {	//add this one even if its blank string
			$(el).html("<a href=\"" + idUrl + "\">" + cellval + "</a>");
        }else {
			$.fn.fmatter.defaultFormat(el, cellval);
	    }
    };
	$.fn.fmatter.integer = function(el,cellval,opts) {
		var op = $.extend({},opts.integer);
		if(!isUndefined(opts.colModel.formatoptions)) {
			op = $.extend({},op,opts.colModel.formatoptions);
		}
		if(isEmpty(cellval)) {
			cellval = op.defaultValue || 0;
		}
		$(el).html($.fmatter.util.NumberFormat(cellval,op));
	};
	$.fn.fmatter.number = function (el,cellval, opts) {
		var op = $.extend({},opts.number);
		if(!isUndefined(opts.colModel.formatoptions)) {
			op = $.extend({},op,opts.colModel.formatoptions);
		}
		if(isEmpty(cellval)) {
			cellval = op.defaultValue || 0;
		}
		$(el).html($.fmatter.util.NumberFormat(cellval,op));
	};
	$.fn.fmatter.currency = function (el,cellval, opts) {
		var op = $.extend({},opts.currency);
		if(!isUndefined(opts.colModel.formatoptions)) {
			op = $.extend({},op,opts.colModel.formatoptions);
		}
		if(isEmpty(cellval)) {
			cellval = op.defaultValue || 0;
		}
		$(el).html($.fmatter.util.NumberFormat(cellval,op));
	};
	$.fn.fmatter.date = function (el, cellval, opts, act) {
		var op = $.extend({},opts.date);
		if(!isUndefined(opts.colModel.formatoptions)) {
			op = $.extend({},op,opts.colModel.formatoptions);
		}
		if(!op.reformatAfterEdit && act=='edit'){
			$.fn.fmatter.defaultFormat(el,cellval);
		} else if(!isEmpty(cellval)) {
			var ndf = $.fmatter.util.DateFormat(op.srcformat,cellval,op.newformat,op);
			$(el).html(ndf);
		} else {
			$.fn.fmatter.defaultFormat(el,cellval);
		}
	};
	$.fn.fmatter.select = function (el, cellval,opts, act) {
		// jqGrid specific
		if(act=='edit') {
			$.fn.fmatter.defaultFormat(el,cellval);
		} else if (!isEmpty(cellval)) {
			var oSelect = false;
			if(!isUndefined(opts.colModel.editoptions)){
				oSelect= opts.colModel.editoptions.value;
			}
			if (oSelect) {
				var ret = [];
				var msl =  opts.colModel.editoptions.multiple === true ? true : false;
				var scell = [];
				if(msl) { scell = cellval.split(","); scell = $.map(scell,function(n){return $.trim(n);})}
				if (isString(oSelect)) {
					// mybe here we can use some caching with care ????
					var so = oSelect.split(";"), j=0;
					for(var i=0; i<so.length;i++){
						sv = so[i].split(":");
						if(msl) {
							if(jQuery.inArray(sv[0],scell)>-1) {
								ret[j] = sv[1];
								j++;
							}
						} else if($.trim(sv[0])==$.trim(cellval)) {
							ret[0] = sv[1];
							break;
						}
					}
				} else if(isObject(oSelect)) {
					// this is quicker
					if(msl) {
						ret = jQuery.map(scel, function(n, i){
							return oSelect[n];
						});
					}
					ret[0] = oSelect[cellval] || "";
				}
				$(el).html(ret.join(", "));
			} else {
				$.fn.fmatter.defaultFormat(el,cellval);
			}
		}
	};
	$.unformat = function (cellval,options,pos,cnt) {
		// specific for jqGrid only
		var ret, formatType = options.colModel.formatter, op =options.colModel.formatoptions || {};
		if(formatType !== 'undefined' && isString(formatType) ) {
			var opts = $.jgrid.formatter || {}, stripTag;
			switch(formatType) {
				case 'link' :
				case 'showlink' :
				case 'email' :
					ret= $(cellval).text();
					break;
				case 'integer' :
					op = $.extend({},opts.integer,op);
					stripTag = eval("/"+op.thousandsSeparator+"/g");
					ret = $(cellval).text().replace(stripTag,'');
					break;
				case 'number' :
					op = $.extend({},opts.number,op);
					stripTag = eval("/"+op.thousandsSeparator+"/g");
					ret = $(cellval).text().replace(op.decimalSeparator,'.').replace(stripTag,"");
					break;
				case 'currency':
					op = $.extend({},opts.currency,op);
					stripTag = eval("/"+op.thousandsSeparator+"/g");
					ret = $(cellval).text().replace(op.decimalSeparator,'.').replace(op.prefix,'').replace(op.suffix,'').replace(stripTag,'');
					break;
				case 'checkbox' :
					var cbv = (options.colModel.editoptions) ? options.colModel.editoptions.value.split(":") : ["Yes","No"];
					ret = $('input',cellval).attr("checked") ? cbv[0] : cbv[1];
					break;
			}
		}
		//else {
			// Here aditional code to run custom unformater
		//}
		return ret ? ret : cnt===true ? $(cellval).text() : $.htmlDecode($(cellval).html());
	};
	function fireFormatter(el,formatType,cellval, opts, act) {
		//debug("in formatter with " +formatType);
	    formatType = formatType.toLowerCase();
	    switch (formatType) {
	        case 'link': $.fn.fmatter.link(el, cellval, opts); break;
			case 'showlink': $.fn.fmatter.showlink(el, cellval, opts); break;
	        case 'email': $.fn.fmatter.email(el, cellval, opts); break;
			case 'currency': $.fn.fmatter.currency(el, cellval, opts); break;
	        case 'date': $.fn.fmatter.date(el, cellval, opts, act); break;
	        case 'number': $.fn.fmatter.number(el, cellval, opts) ; break;
	        case 'integer': $.fn.fmatter.integer(el, cellval, opts) ; break;
	        case 'checkbox': $.fn.fmatter.checkbox(el, cellval, opts); break;
	        case 'select': $.fn.fmatter.select(el, cellval, opts,act); break;
	        //case 'textbox': s.transparent = false; break;
	    }
	};
	//private methods and data
	function debug($obj) {
		if (window.console && window.console.log) window.console.log($obj);
	};
	/**
     * A convenience method for detecting a legitimate non-null value.
     * Returns false for null/undefined/NaN, true for other values, 
     * including 0/false/''
	 *  --taken from the yui.lang
     */
    isValue= function(o) {
		return (isObject(o) || isString(o) || isNumber(o) || isBoolean(o));
    };
	isBoolean= function(o) {
        return typeof o === 'boolean';
    };
    isNull= function(o) {
        return o === null;
    };
    isNumber= function(o) {
        return typeof o === 'number' && isFinite(o);
    };
    isString= function(o) {
        return typeof o === 'string';
    };
	/**
	* check if its empty trim it and replace \&nbsp and \&#160 with '' and check if its empty ===""
	* if its is not a string but has a value then it returns false, Returns true for null/undefined/NaN
	essentailly this provdes a way to see if it has any value to format for things like links
	*/
 	isEmpty= function(o) {
		if(!isString(o) && isValue(o)) {
			return false;
		}else if (!isValue(o)){
			return true;
		}
		o = $.trim(o).replace(/\&nbsp\;/ig,'').replace(/\&#160\;/ig,'');
        return o==="";
		
    };
    isUndefined= function(o) {
        return typeof o === 'undefined';
    };
	isObject= function(o) {
		return (o && (typeof o === 'object' || isFunction(o))) || false;
    };
	isFunction= function(o) {
        return typeof o === 'function';
    };

})(jQuery);