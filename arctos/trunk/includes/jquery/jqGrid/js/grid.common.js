/**
 * jqGrid common function
 * Tony Tomov tony@trirand.com
 * http://trirand.com/blog/ 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/ 
// Modal functions
var showModal = function(h) {
	h.w.show();
};
var closeModal = function(h) {
	h.w.hide();
	if(h.o) { h.o.remove(); }
};
function createModal(aIDs, content, p, insertSelector, posSelector, appendsel) {
	var clicon = p.imgpath ? p.imgpath+p.closeicon : p.closeicon;
	var mw  = document.createElement('div');
	jQuery(mw).addClass("modalwin").attr("id",aIDs.themodal);
	var mh = jQuery('<div id="'+aIDs.modalhead+'"><table width="100%"><tbody><tr><td class="modaltext">'+p.caption+'</td> <td style="text-align:right" ><a href="javascript:void(0);" class="jqmClose">'+(clicon!=''?'<img src="' + clicon + '" border="0"/>':'X') + '</a></td></tr></tbody></table> </div>').addClass("modalhead");
	var mc = document.createElement('div');
	jQuery(mc).addClass("modalcontent").attr("id",aIDs.modalcontent);
	jQuery(mc).append(content);
	mw.appendChild(mc);
	var loading = document.createElement("div");
	jQuery(loading).addClass("loading").html(p.processData||"");
	jQuery(mw).prepend(loading);
	jQuery(mw).prepend(mh);
	jQuery(mw).addClass("jqmWindow");
	if (p.drag) {
		jQuery(mw).append("<img  class='jqResize' src='"+p.imgpath+"resize.gif'/>");
	}
	if(appendsel===true) { jQuery('body').append(mw); } //append as first child in body -for alert dialog
	else { jQuery(mw).insertBefore(insertSelector);	}
	if(p.left ==0 && p.top==0) {
		var pos = [];
		pos = findPos(posSelector) ;
		p.left = pos[0] + 4;
		p.top = pos[1] + 4;
	}
	if (p.width == 0 || !p.width) {p.width = 300;}
	if(p.height==0 || !p.width) {p.height =200;}
	if(!p.zIndex) {p.zIndex = 950;}
	jQuery(mw).css({top: p.top+"px",left: p.left+"px",width: p.width+"px",height: p.height+"px", zIndex:p.zIndex});
	return false;
};

function viewModal(selector,o){
	o = jQuery.extend({
		toTop: true,
		overlay: 10,
		modal: false,
		onShow: showModal,
		onHide: closeModal
	}, o || {});
	jQuery(selector).jqm(o).jqmShow();
	return false;
};
function hideModal(selector) {
	jQuery(selector).jqmHide();
}

function DnRModal(modwin,handler){
	jQuery(handler).css('cursor','move');
	jQuery(modwin).jqDrag(handler).jqResize(".jqResize");
	return false;
};

function info_dialog(caption, content,c_b, pathimg) {
	var cnt = "<div id='info_id'>";
	cnt += "<div align='center'><br />"+content+"<br /><br />";
	cnt += "<input type='button' size='10' id='closedialog' class='jqmClose EditButton' value='"+c_b+"' />";
	cnt += "</div></div>";
	createModal({
		themodal:'info_dialog',
		modalhead:'info_head',
		modalcontent:'info_content'},
		cnt,
		{ width:290,
		height:120,drag: false,
		caption:"<b>"+caption+"</b>",
		imgpath: pathimg,
		closeicon: 'ico-close.gif',
		left:250,
		top:170 },
		'','',true
	);
	viewModal("#info_dialog",{
		onShow: function(h) {
			h.w.show();
		},
		onHide: function(h) {
			h.w.hide().remove();
			if(h.o) { h.o.remove(); }
		},
		modal :true
	});
};
//Helper functions
function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		do {
			curleft += obj.offsetLeft;
			curtop += obj.offsetTop; 
		} while (obj = obj.offsetParent);
		//do not change obj == obj.offsetParent 
	}
	return [curleft,curtop];
};
function isArray(obj) {
	if (obj.constructor.toString().indexOf("Array") == -1) {
		return false;
	} else {
		return true;
	}
};
// Form Functions
function createEl(eltype,options,vl,elm) {
	var elem = "";
	switch (eltype)
	{
		case "textarea" :
				elem = document.createElement("textarea");
				if(!options.cols && elm) {jQuery(elem).css("width","99%");}
				jQuery(elem).attr(options);
				if(vl == "&nbsp;" || vl == "&#160;") {vl='';} // comes from grid if empty
				jQuery(elem).val(vl);
				break;
		case "checkbox" : //what code for simple checkbox
			elem = document.createElement("input");
			elem.type = "checkbox";
			jQuery(elem).attr({id:options.id,name:options.name});
			if( !options.value) {
				vl=vl.toLowerCase();
				if(vl.search(/(false|0|no|off|undefined)/i)<0 && vl!=="") {
					elem.checked=true;
					elem.defaultChecked=true;
					elem.value = vl;
				} else {
					elem.value = "on";
				}
				jQuery(elem).attr("offval","off");
			} else {
				var cbval = options.value.split(":");
				if(vl == cbval[0]) {
					elem.checked=true;
					elem.defaultChecked=true;
				}
				elem.value = cbval[0];
				jQuery(elem).attr("offval",cbval[1]);
			}
			break;
		case "select" :
			elem = document.createElement("select");
			var msl = options.multiple==true ? true : false;
			if(options.value) {
				var ovm = [];
				if(msl) {jQuery(elem).attr({multiple:"multiple"}); ovm = vl.split(","); ovm = jQuery.map(ovm,function(n){return jQuery.trim(n)});}
				if(typeof options.size === 'undefined') {options.size =1;}
				if(typeof options.value == 'string') {
					var so = options.value.split(";"),sv, ov;
					jQuery(elem).attr({id:options.id,name:options.name,size:Math.min(options.size,so.length)});
					for(var i=0; i<so.length;i++){
						sv = so[i].split(":");
						ov = document.createElement("option");
						ov.value = sv[0]; ov.innerHTML = jQuery.htmlDecode(sv[1]);
						if (!msl &&  sv[1]==vl) ov.selected ="selected";
						if (msl && jQuery.inArray(jQuery.trim(sv[1]), ovm)>-1) {ov.selected ="selected";}
						elem.appendChild(ov);
					}
				} else if (typeof options.value == 'object') {
					var oSv = options.value;
					var i=0;
					for ( var key in oSv) {
						i++;
						ov = document.createElement("option");
						ov.value = key; ov.innerHTML = jQuery.htmlDecode(oSv[key]);
						if (!msl &&  oSv[key]==vl) {ov.selected ="selected";}
						if (msl && jQuery.inArray(jQuery.trim(oSv[key]),ovm)>-1) {ov.selected ="selected";}
						elem.appendChild(ov);
					}
					jQuery(elem).attr({id:options.id,name:options.name,size:Math.min(options.size,i) });
				}
			}
			break;
		case "text" :
			elem = document.createElement("input");
			elem.type = "text";
			vl = jQuery.htmlDecode(vl);
			elem.value = vl;
			if(!options.size && elm) {
				jQuery(elem).css({width:"98%"});
			}
			jQuery(elem).attr(options);
			break;
		case "password" :
			elem = document.createElement("input");
			elem.type = "password";
			vl = jQuery.htmlDecode(vl);
			elem.value = vl;
			if(!options.size && elm) { jQuery(elem).css("width","99%"); }
			jQuery(elem).attr(options);
			break;
		case "image" :
			elem = document.createElement("input");
			elem.type = "image";
			jQuery(elem).attr(options);
			break;
	}
	return elem;
};
function checkValues(val, valref,g) {
	if(valref >=0) {
		var edtrul = g.p.colModel[valref].editrules;
	}
	if(edtrul) {
		if(edtrul.required === true) {
			if( val.match(/^s+$/) || val == "" )  return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.required,""];
		}
		// force required
		var rqfield = edtrul.required === false ? false : true;
		if(edtrul.number === true) {
			if( !(rqfield === false && isEmpty(val)) ) {
				if(isNaN(val)) return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.number,""];
			}
		}
		if(edtrul.minValue && !isNaN(edtrul.minValue)) {
			if (parseFloat(val) < parseFloat(edtrul.minValue) ) return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.minValue+" "+edtrul.minValue,""];
		}
		if(edtrul.maxValue && !isNaN(edtrul.maxValue)) {
			if (parseFloat(val) > parseFloat(edtrul.maxValue) ) return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.maxValue+" "+edtrul.maxValue,""];
		}
		if(edtrul.email === true) {
			if( !(rqfield === false && isEmpty(val)) ) {
			// taken from jquery Validate plugin
				var filter = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;
				if(!filter.test(val)) {return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.email,""];}
			}
		}
		if(edtrul.integer === true) {
			if( !(rqfield === false && isEmpty(val)) ) {
				if(isNaN(val)) return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.integer,""];
				if ((val % 1 != 0) || (val.indexOf('.') != -1)) return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.integer,""];
			}
		}
		if(edtrul.date === true) {
			if( !(rqfield === false && isEmpty(val)) ) {
				var dft = g.p.colModel[valref].datefmt || "Y-m-d";
				if(!checkDate (dft, val)) return [false,g.p.colNames[valref]+": "+jQuery.jgrid.edit.msg.date+" - "+dft,""];
			}
		}
	}
	return [true,"",""];
};
// Date Validation Javascript
function checkDate (format, date) {
	var tsp = {};
	var result =  false;
	var sep;
	format = format.toLowerCase();
	//we search for /,-,. for the date separator
	if(format.indexOf("/") != -1) {
		sep = "/";
	} else if(format.indexOf("-") != -1) {
		sep = "-";
	} else if(format.indexOf(".") != -1) {
		sep = ".";
	} else {
		sep = "/";
	}
	format = format.split(sep);
	date = date.split(sep);
	if (date.length != 3) return false;
	var j=-1,yln, dln=-1, mln=-1;
	for(var i=0;i<format.length;i++){
		var dv =  isNaN(date[i]) ? 0 : parseInt(date[i],10); 
		tsp[format[i]] = dv;
		yln = format[i];
		if(yln.indexOf("y") != -1) { j=i; }
		if(yln.indexOf("m") != -1) {mln=i}
		if(yln.indexOf("d") != -1) {dln=i}
	}
	if (format[j] == "y" || format[j] == "yyyy") {
		yln=4;
	} else if(format[j] =="yy"){
		yln = 2;
	} else {
		yln = -1;
	}
	var daysInMonth = DaysArray(12);
	var strDate;
	if (j === -1) {
		return false;
	} else {
		strDate = tsp[format[j]].toString();
		if(yln == 2 && strDate.length == 1) {yln = 1;}
		if (strDate.length != yln || tsp[format[j]]==0 ){
			return false;
		}
	}
	if(mln === -1) {
		return false;
	} else {
		strDate = tsp[format[mln]].toString();
		if (strDate.length<1 || tsp[format[mln]]<1 || tsp[format[mln]]>12){
			return false;
		}
	}
	if(dln === -1) {
		return false;
	} else {
		strDate = tsp[format[dln]].toString();
		if (strDate.length<1 || tsp[format[dln]]<1 || tsp[format[dln]]>31 || (tsp[format[mln]]==2 && tsp[format[dln]]>daysInFebruary(tsp[format[j]])) || tsp[format[dln]] > daysInMonth[tsp[format[mln]]]){
			return false;
		}
	}
	return true;
}
function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}
function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31;
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30;}
		if (i==2) {this[i] = 29;}
	} 
	return this;
}

function isEmpty(val)
{
	if (val.match(/^s+$/) || val == "")	{
		return true;
	} else {
		return false;
	} 
}
function htmlEncode (value){
    return !value ? value : String(value).replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;").replace(/"/g, "&quot;");
}
