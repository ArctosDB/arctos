;(function ($) {
/*
 * jqGrid  3.4.3 - jQuery Grid
 * Copyright (c) 2008, Tony Tomov, tony@trirand.com
 * Dual licensed under the MIT and GPL licenses
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 * Date: 2009-03-12 rev 84
 */
$.fn.jqGrid = function( p ) {
	p = $.extend(true,{
	url: "",
	height: 150,
	page: 1,
	rowNum: 20,
	records: 0,
	pager: "",
	pgbuttons: true,
	pginput: true,
	colModel: [],
	rowList: [],
	colNames: [],
	sortorder: "asc",
	sortname: "",
	datatype: "xml",
	mtype: "GET",
	imgpath: "",
	sortascimg: "sort_asc.gif",
	sortdescimg: "sort_desc.gif",
	firstimg: "first.gif",
	previmg: "prev.gif",
	nextimg: "next.gif",
	lastimg: "last.gif",
	altRows: true,
	selarrrow: [],
	savedRow: [],
	shrinkToFit: true,
	xmlReader: {},
	jsonReader: {},
	subGrid: false,
	subGridModel :[],
	lastpage: 0,
	lastsort: 0,
	selrow: null,
	beforeSelectRow: null,
	onSelectRow: null,
	onSortCol: null,
	ondblClickRow: null,
	onRightClickRow: null,
	onPaging: null,
	onSelectAll: null,
	loadComplete: null,
	gridComplete: null,
	loadError: null,
	loadBeforeSend: null,
	afterInsertRow: null,
	beforeRequest: null,
	onHeaderClick: null,
	viewrecords: false,
	loadonce: false,
	multiselect: false,
	multikey: false,
	editurl: null,
	search: false,
	searchdata: {},
	caption: "",
	hidegrid: true,
	hiddengrid: false,
	postData: {},
	userData: {},
	treeGrid : false,
	treeGridModel : 'nested',
	treeReader : {},
	treeANode : 0,
	ExpandColumn: null,
	tree_root_level : 0,
	prmNames: {page:"page",rows:"rows", sort: "sidx",order: "sord"},
	sortclass: "grid_sort",
	resizeclass: "grid_resize",
	forceFit : false,
	gridstate : "visible",
	cellEdit: false,
	cellsubmit: "remote",
	nv:0,
	loadui: "enable",
	toolbar: [false,""],
	scroll: false,
	multiboxonly : false,
	scrollrows : false,
	deselectAfterSort: true
	}, $.jgrid.defaults, p || {});
	var grid={         
		headers:[],
		cols:[],
		dragStart: function(i,x) {
			this.resizing = { idx: i, startX: x};
			this.hDiv.style.cursor = "e-resize";
		},
		dragMove: function(x) {
			if(this.resizing) {
				var diff = x-this.resizing.startX,
				h = this.headers[this.resizing.idx],
				newWidth = h.width + diff, hn, nWn;
				if(newWidth > 25) {
					if(p.forceFit===true ){
						hn = this.headers[this.resizing.idx+p.nv];
						nWn = hn.width - diff;
						if(nWn >25) {
							h.el.style.width = newWidth+"px";
							h.newWidth = newWidth;
							this.cols[this.resizing.idx].style.width = newWidth+"px";
							hn.el.style.width = nWn +"px";
							hn.newWidth = nWn;
							this.cols[this.resizing.idx+p.nv].style.width = nWn+"px";
							this.newWidth = this.width;
						}
					} else {
						h.el.style.width = newWidth+"px";
						h.newWidth = newWidth;
						this.cols[this.resizing.idx].style.width = newWidth+"px";
						this.newWidth = this.width+diff;
						$('table:first',this.bDiv).css("width",this.newWidth +"px");
						$('table:first',this.hDiv).css("width",this.newWidth +"px");
						this.hDiv.scrollLeft = this.bDiv.scrollLeft;
					}
				}
			}
		},
		dragEnd: function() {
			this.hDiv.style.cursor = "default";
			if(this.resizing) {
				var idx = this.resizing.idx;
				this.headers[idx].width = this.headers[idx].newWidth || this.headers[idx].width;
				this.cols[idx].style.width = this.headers[idx].newWidth || this.headers[idx].width;
				// here code to set the width in colmodel
				if(p.forceFit===true){
					this.headers[idx+p.nv].width = this.headers[idx+p.nv].newWidth || this.headers[idx+p.nv].width;
					this.cols[idx+p.nv].style.width = this.headers[idx+p.nv].newWidth || this.headers[idx+p.nv].width;
				}
				if(this.newWidth) {this.width = this.newWidth;}
				this.resizing = false;
			}
		},
		scrollGrid: function() {
			if(p.scroll === true) {
				var scrollTop = this.bDiv.scrollTop;
				if (scrollTop != this.scrollTop) {
					this.scrollTop = scrollTop;
					if ((this.bDiv.scrollHeight-scrollTop-$(this.bDiv).height()) <= 0) {
						if(parseInt(p.page,10)+1<=parseInt(p.lastpage,10)) {
							p.page = parseInt(p.page,10)+1;
							this.populate();
						}
					}
				}
			}
			this.hDiv.scrollLeft = this.bDiv.scrollLeft;
		}
	};
	$.fn.getGridParam = function(pName) {
		var $t = this[0];
		if (!$t.grid) {return;}
		if (!pName) { return $t.p; }
		else {return $t.p[pName] ? $t.p[pName] : null;}
	};
	$.fn.setGridParam = function (newParams){
		return this.each(function(){
			if (this.grid && typeof(newParams) === 'object') {$.extend(true,this.p,newParams);}
		});
	};
	$.fn.getDataIDs = function () {
		var ids=[];
		this.each(function(){
			$(this.rows).slice(1).each(function(i){
				ids[i]=this.id;
			});
		});
		return ids;
	};
	$.fn.setSortName = function (newsort) {
		return this.each(function(){
			var $t = this;
			for(var i=0;i< $t.p.colModel.length;i++){
				if($t.p.colModel[i].name===newsort || $t.p.colModel[i].index===newsort){
					$("tr th:eq("+$t.p.lastsort+") div img",$t.grid.hDiv).remove();
					$t.p.lastsort = i;
					$t.p.sortname=newsort;
					break;
				}
			}
		});
	};
	$.fn.setSelection = function(selection,onsr,sd) {
		return this.each(function(){
			var $t = this, stat,pt, ind;
			onsr = onsr === false ? false : true;
			if(selection===false) {pt = sd;}
			else { ind = $($t).getInd($t.rows,selection); pt=$($t.rows[ind]);}
			selection = $(pt).attr("id");
			if (!pt.html()) {return;}
			if($t.p.selrow && $t.p.scrollrows===true) {
				var olr = $($t).getInd($t.rows,$t.p.selrow);
				var ner = $($t).getInd($t.rows,selection);
				if(ner >=0 ){
					if(ner > olr ) {
						scrGrid(ner,'d');
					} else {
						scrGrid(ner,'u');
					}
				}
			}
			if(!$t.p.multiselect) {
				if($(pt).attr("class") !== "subgrid") {
				if( $t.p.selrow ) {$("tr#"+$t.p.selrow.replace(".", "\\."),$t.grid.bDiv).removeClass("selected");}
				$t.p.selrow = selection;
				$(pt).addClass("selected");
				if( $t.p.onSelectRow && onsr) { $t.p.onSelectRow($t.p.selrow, true); }
				}
			} else {
				$t.p.selrow = selection;
				var ia = $.inArray($t.p.selrow,$t.p.selarrrow);
				if (  ia === -1 ){ 
					if($(pt).attr("class") !== "subgrid") { $(pt).addClass("selected");}
					stat = true;
					$("#jqg_"+$t.p.selrow.replace(".", "\\.") ,$t.rows).attr("checked",stat);
					$t.p.selarrrow.push($t.p.selrow);
					if( $t.p.onSelectRow && onsr) { $t.p.onSelectRow($t.p.selrow, stat); }
				} else {
					if($(pt).attr("class") !== "subgrid") { $(pt).removeClass("selected");}
					stat = false;
					$("#jqg_"+$t.p.selrow.replace(".", "\\.") ,$t.rows).attr("checked",stat);
					$t.p.selarrrow.splice(ia,1);
					if( $t.p.onSelectRow && onsr) { $t.p.onSelectRow($t.p.selrow, stat); }
					var tpsr = $t.p.selarrrow[0];
					$t.p.selrow = (tpsr==undefined) ? null : tpsr;
				}
			}
			function scrGrid(iR,tp){
				var ch = $($t.grid.bDiv)[0].clientHeight,
				st = $($t.grid.bDiv)[0].scrollTop,
				nROT = $t.rows[iR].offsetTop+$t.rows[iR].clientHeight,
				pROT = $t.rows[iR].offsetTop;
				if(tp == 'd') {
					if(nROT >= ch) { $($t.grid.bDiv)[0].scrollTop = st + nROT-pROT; }
				}
				if(tp == 'u'){
					if (pROT < st) { $($t.grid.bDiv)[0].scrollTop = st - nROT+pROT; }
				}
			}
		});
	};
	$.fn.resetSelection = function(){
		return this.each(function(){
			var t = this, ind;
			if(!t.p.multiselect) {
				if(t.p.selrow) {
					$("tr#"+t.p.selrow.replace(".", "\\."),t.grid.bDiv).removeClass("selected");
					t.p.selrow = null;
				}
			} else {
				$(t.p.selarrrow).each(function(i,n){
					ind = $(t).getInd(t.rows,n);
					$(t.rows[ind]).removeClass("selected");
					$("#jqg_"+n.replace(".", "\\."),t.rows[ind]).attr("checked",false);
				});
				$("#cb_jqg",t.grid.hDiv).attr("checked",false);
				t.p.selarrrow = [];
			}
		});
	};
	$.fn.getRowData = function( rowid ) {
		var res = {};
		if (rowid){
			this.each(function(){
				var $t = this,nm,ind;
				ind = $($t).getInd($t.rows,rowid);
				if (!ind) {return res;}
				$('td',$t.rows[ind]).each( function(i) {
					nm = $t.p.colModel[i].name; 
					if ( nm !== 'cb' && nm !== 'subgrid') {
						if($t.p.treeGrid===true && nm == $t.p.ExpandColumn) {
							res[nm] = $.htmlDecode($("span:first",this).html());
						} else {
							res[nm] = $.htmlDecode($(this).html());
						}
					}
				});
			});
		}
		return res;
	};
	$.fn.delRowData = function(rowid) {
		var success = false, rowInd, ia;
		if(rowid) {
			this.each(function() {
				var $t = this;
				rowInd = $($t).getInd($t.rows,rowid);
				if(!rowInd) {return false;}
				else {
					$($t.rows[rowInd]).remove();
					$t.p.records--;
					$t.updatepager();
					success=true;
					if(rowid == $t.p.selrow) {$t.p.selrow=null;}
					ia = $.inArray(rowid,$t.p.selarrrow);
					if(ia != -1) {$t.p.selarrrow.splice(ia,1);}
				}
				if(rowInd == 1 && success && ($.browser.opera || $.browser.safari)) {
					$($t.rows[1]).each( function( k ) {
						$(this).css("width",$t.grid.headers[k].width+"px");
						$t.grid.cols[k] = this;
					});
				}
				if( $t.p.altRows === true && success) {
					$($t.rows).slice(1).each(function(i){
						if(i % 2 ==1) {$(this).addClass('alt');}
						else {$(this).removeClass('alt');}
					});
				}
			});
		}
		return success;
	};
	$.fn.setRowData = function(rowid, data) {
		var nm, success=false;
		this.each(function(){
			var t = this, vl, ind, ttd;
			if(!t.grid) {return false;}
			if( data ) {
				ind = $(t).getInd(t.rows,rowid);
				if(!ind) {return false;}
				success=true;
				$(this.p.colModel).each(function(i){
					nm = this.name;
					vl = data[nm];
					if( vl !== undefined ) {
						if(t.p.treeGrid===true && nm == t.p.ExpandColumn) {
							ttd = $("td:eq("+i+") > span:first",t.rows[ind]);
						} else {
							ttd = $("td:eq("+i+")",t.rows[ind]); 
						}
						t.formatter(ttd, t.rows[ind], vl, i, 'edit');
						success = true;
					}
				});
			}
		});
		return success;
	};
	$.fn.addRowData = function(rowid,data,pos,src) {
		if(!pos) {pos = "last";}
		var success = false, nm, row, td, gi=0, si=0,sind, i;
		if(data) {
			this.each(function() {
				var t = this;
				row =  document.createElement("tr");
				row.id = rowid || t.p.records+1;
				$(row).addClass("jqgrow");
				if(t.p.multiselect) {
					td = $('<td></td>');
					$(td[0],t.grid.bDiv).html("<input type='checkbox'"+" id='jqg_"+rowid+"' class='cbox'/>");
					row.appendChild(td[0]);
					gi = 1;
				}
				if(t.p.subGrid ) { try {$(t).addSubGrid(t.grid.bDiv,row,gi);} catch(e){} si=1;}
				for(i = gi+si; i < this.p.colModel.length;i++){
					nm = this.p.colModel[i].name;
					td  = $('<td></td>');
					t.formatter(td, row, data[nm], i, 'add');
					t.formatCol($(td[0],t.grid.bDiv),i);
					row.appendChild(td[0]);
				}
				switch (pos) {
					case 'last':
						$(t.rows[t.rows.length-1]).after(row);
						break;
					case 'first':
						$(t.rows[0]).after(row);
						break;
					case 'after':
						sind = $(t).getInd(t.rows,src);
						sind >= 0 ?	$(t.rows[sind]).after(row): "";
						break;
					case 'before':
						sind = $(t).getInd(t.rows,src);
						sind > 0 ?	$(t.rows[sind-1]).after(row): "";
						break;
				}
				t.p.records++;
				if($.browser.safari || $.browser.opera) {
					t.scrollLeft = t.scrollLeft;
					$("td",t.rows[1]).each( function( k ) {
						$(this).css("width",t.grid.headers[k].width+"px");
						t.grid.cols[k] = this;
					});
				}
				if( t.p.altRows === true ) {
					if (pos == "last") {
						if (t.rows.length % 2 == 1)  {$(row).addClass('alt');}
					} else {
						$(t.rows).slice(1).each(function(i){
							if(i % 2 ==1) {$(this).addClass('alt');}
							else {$(this).removeClass('alt');}
						});
					}
				}
				try {t.p.afterInsertRow(row.id,data); } catch(e){}
				t.updatepager();
				success = true;
			});
		}
		return success;
	};
	$.fn.hideCol = function(colname) {
		return this.each(function() {
			var $t = this,w=0, fndh=false, gtw;
			if (!$t.grid ) {return;}
			if( typeof colname == 'string') {colname=[colname];}
			$(this.p.colModel).each(function(i) {
				if ($.inArray(this.name,colname) != -1 && !this.hidden) {
					w = parseInt($("tr th:eq("+i+")",$t.grid.hDiv).css("width"),10);
 					$("tr th:eq("+i+")",$t.grid.hDiv).css({display:"none"});
					$($t.rows).each(function(j){
						$("td:eq("+i+")",$t.rows[j]).css({display:"none"});
					});
					$t.grid.cols[i].style.width = 0;
					$t.grid.headers[i].width = 0;
					$t.grid.width -= w;
					this.hidden=true;
					fndh=true;
				}
			});
			if(fndh===true) {
				gtw = Math.min($t.p._width,$t.grid.width);
				$("table:first",$t.grid.hDiv).width(gtw);
				$("table:first",$t.grid.bDiv).width(gtw);
				$($t.grid.hDiv).width(gtw);
				$($t.grid.bDiv).width(gtw);
				if($t.p.pager && $($t.p.pager).hasClass("scroll") ) {
					$($t.p.pager).width(gtw);
				}
				if($t.p.caption) {$($t.grid.cDiv).width(gtw);}
				if($t.p.toolbar[0]) {$($t.grid.uDiv).width(gtw);}
				$t.grid.hDiv.scrollLeft = $t.grid.bDiv.scrollLeft;
			}
		});
	};
	$.fn.showCol = function(colname) {
		return this.each(function() {
			var $t = this, w = 0, fdns=false, gtw, ofl;
			if (!$t.grid ) {return;}
			if( typeof colname == 'string') {colname=[colname];}
			$($t.p.colModel).each(function(i) {
				if ($.inArray(this.name,colname) != -1 && this.hidden) {
					w = parseInt($("tr th:eq("+i+")",$t.grid.hDiv).css("width"),10);
					$("tr th:eq("+i+")",$t.grid.hDiv).css("display","");
					$($t.rows).each(function(j){
						$("td:eq("+i+")",$t.rows[j]).css("display","").width(w);
					});
					this.hidden=false;
					$t.grid.cols[i].style.width = w;
					$t.grid.headers[i].width =  w;
					$t.grid.width += w;
					fdns=true;
				}
			});
			if(fdns===true) {
				gtw = Math.min($t.p._width,$t.grid.width);
				ofl = ($t.grid.width <= $t.p._width) ? "hidden" : "auto";
				$("table:first",$t.grid.hDiv).width(gtw);
				$("table:first",$t.grid.bDiv).width(gtw);
				$($t.grid.hDiv).width(gtw);
				$($t.grid.bDiv).width(gtw).css("overflow-x",ofl);
				if($t.p.pager && $($t.p.pager).hasClass("scroll") ) {
					$($t.p.pager).width(gtw);
				}
				if($t.p.caption) {$($t.grid.cDiv).width(gtw);}
				if($t.p.toolbar[0]) {$($t.grid.uDiv).width(gtw);}
				$t.grid.hDiv.scrollLeft = $t.grid.bDiv.scrollLeft;
			}
		});
	};
	$.fn.setGridWidth = function(nwidth, shrink) {
		return this.each(function(){
			var $t = this, chw=0,w,cw,ofl;
			if (!$t.grid ) {return;}
			if(typeof shrink != 'boolean') {shrink=true;}
			var testdata = getScale();
			if(shrink !== true) {testdata[0] = Math.min($t.p._width,$t.grid.width); testdata[2]=0;}
			else {testdata[2]= testdata[1]}
			$.each($t.p.colModel,function(i,v){
				if(!this.hidden && this.name != 'cb' && this.name!='subgrid') {
					cw = shrink !== true ? $("tr:first th:eq("+i+")",$t.grid.hDiv).css("width") : this.width;
					w = Math.floor((IENum(nwidth)-IENum(testdata[2]))/IENum(testdata[0])*IENum(cw));
					chw += w;
					$("table thead tr:first th:eq("+i+")",$t.grid.hDiv).css("width",w+"px");
					$("table:first tbody tr:first td:eq("+i+")",$t.grid.bDiv).css("width",w+"px");
					$t.grid.cols[i].style.width = w;
					$t.grid.headers[i].width =  w;
				}
				if(this.name=='cb' || this.name == 'subgrid'){chw += IENum(this.width);}
			});
			if(chw + testdata[1] <= nwidth || $t.p.forceFit === true){ ofl = "hidden"; tw = nwidth;}
			else { ofl= "auto"; tw = chw + testdata[1];}
			$("table:first",$t.grid.hDiv).width(tw);
			$("table:first",$t.grid.bDiv).width(tw);
			$($t.grid.hDiv).width(nwidth);
			$($t.grid.bDiv).width(nwidth).css("overflow-x",ofl);
			if($t.p.pager && $($t.p.pager).hasClass("scroll") ) {
				$($t.p.pager).width(nwidth);
			}
			if($t.p.caption) {$($t.grid.cDiv).width(nwidth);}
			if($t.p.toolbar[0]) {$($t.grid.uDiv).width(nwidth);}
			$t.p._width = nwidth; $t.grid.width = tw;
			if($.browser.safari || $.browser.opera ) {
				$("table tbody tr:eq(1) td",$t.grid.bDiv).each( function( k ) {
					$(this).css("width",$t.grid.headers[k].width+"px");
					$t.grid.cols[k] = this;
				});
			}
			$t.grid.hDiv.scrollLeft = $t.grid.bDiv.scrollLeft;
			function IENum(val) {
				val = parseInt(val,10);
				return isNaN(val) ? 0 : val;
			}
			function getScale(){
				var testcell = $("table tr:first th:eq(1)", $t.grid.hDiv);
				var addpix = IENum($(testcell).css("padding-left")) +
					IENum($(testcell).css("padding-right"))+
					IENum($(testcell).css("border-left-width"))+
					IENum($(testcell).css("border-right-width"));
				var w =0,ap=0; 
				$.each($t.p.colModel,function(i,v){
					if(!this.hidden) {
						w += parseInt(this.width);
						ap += addpix;
					}
				});
				return [w,ap,0];
			}
		});
	};
	$.fn.setGridHeight = function (nh) {
		return this.each(function (){
			var ovfl, ovfl2, $t = this;
			if(!$t.grid) {return;}
			if($t.p.forceFit === true) { ovfl2='hidden'; } else {ovfl2=$($t.grid.bDiv).css("overflow-x");}
			ovfl = (isNaN(nh) && $.browser.mozilla && (nh.indexOf("%")!=-1 || nh=="auto")) ? "hidden" : "auto";
			$($t.grid.bDiv).css({height: nh+(isNaN(nh)?"":"px"),"overflow-y":ovfl,"overflow-x": ovfl2});
			$t.p.height = nh;
		});
	};
	$.fn.setCaption = function (newcap){
		return this.each(function(){
			this.p.caption=newcap;
			$("table:first th",this.grid.cDiv).html(newcap);
			$(this.grid.cDiv).show();
		});
	};
	$.fn.setLabel = function(colname, nData, prop, attrp ){
		return this.each(function(){
			var $t = this, pos=-1;
			if(!$t.grid) {return;}
			if(isNaN(colname)) {
				$($t.p.colModel).each(function(i){
					if (this.name == colname) {
						pos = i;return false;
					}
				});
			} else {pos = parseInt(colname,10);}
			if(pos>=0) {
				var thecol = $("table:first th:eq("+pos+")",$t.grid.hDiv);
				if (nData){
					$("div",thecol).html(nData);
				}
				if (prop) {
					if(typeof prop == 'string') {$(thecol).addClass(prop);} else {$(thecol).css(prop);}
				}
				if(typeof attrp == 'object') {$(thecol).attr(attrp);}
			}
		});
	};
	$.fn.setCell = function(rowid,colname,nData,cssp,attrp) {
		return this.each(function(){
			var $t = this, pos =-1;
			if(!$t.grid) {return;}
			if(isNaN(colname)) {
				$($t.p.colModel).each(function(i){
					if (this.name == colname) {
						pos = i;return false;
					}
				});
			} else {pos = parseInt(colname,10);}
			if(pos>=0) {
				var ind = $($t).getInd($t.rows,rowid);
				if (ind>=0){
					var tcell = $("td:eq("+pos+")",$t.rows[ind]);
					if(nData != "") {
						$t.formatter(tcell, $t.rows[ind], nData, pos,'edit');
					}
					if (cssp){
						if(typeof cssp == 'string') {$(tcell).addClass(cssp);} else {$(tcell).css(cssp);}
					}
					if(typeof attrp == 'object') {$(tcell).attr(attrp);}
				}
			}
		});
	};
	$.fn.getCell = function(rowid,col) {
		var ret = false;
		this.each(function(){
			var $t=this, pos=-1;
			if(!$t.grid) {return;}
			if(isNaN(col)) {
				$($t.p.colModel).each(function(i){
					if (this.name == col) {
						pos = i;return false;
					}
				});
			} else {pos = parseInt(col,10);}
			if(pos>=0) {
				var ind = $($t).getInd($t.rows,rowid);
				if(ind>=0) {
					ret = $.htmlDecode($("td:eq("+pos+")",$t.rows[ind]).html());
				}
			}
		});
		return ret;
	};
	$.fn.clearGridData = function() {
		return this.each(function(){
			var $t = this;
			if(!$t.grid) {return;}
			$("tbody tr:gt(0)", $t.grid.bDiv).remove();
			$t.p.selrow = null; $t.p.selarrrow= []; $t.p.savedRow = [];
			$t.p.records = '0';$t.p.page='0';$t.p.lastpage='0';
			$t.updatepager();
		});
	};
	$.fn.getInd = function(obj,rowid,rc){
		var ret =false;
		$(obj).each(function(i){
			if(this.id==rowid) {
				ret = rc===true ? this : i;
				return false;
			}
		});
		return ret;
	};
	$.htmlDecode = function(value){
		if(value=='&nbsp;' || value=='&#160;') {value = "";}
		return !value ? value : String(value).replace(/&amp;/g, "&").replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&quot;/g, '"');
	};
	return this.each( function() {
		if(this.grid) {return;}
		this.p = p ;
		if(this.p.colNames.length === 0) {
			for (var i=0;i<this.p.colModel.length;i++){
				this.p.colNames[i] = this.p.colModel[i].label || this.p.colModel[i].name;
			}
		}
		if( this.p.colNames.length !== this.p.colModel.length ) {
			alert($.jgrid.errors.model);
			return;
		}
		if(this.p.imgpath !== "" ) {this.p.imgpath += "/";}
		$("<div class='loadingui' id=lui_"+this.id+"><div class='msgbox'>"+this.p.loadtext+"</div></div>").insertBefore(this);
		$(this).attr({cellSpacing:"0",cellPadding:"0",border:"0"});
		var ts = this,
		bSR = $.isFunction(this.p.beforeSelectRow) ? this.p.beforeSelectRow :false,
		onSelectRow = $.isFunction(this.p.onSelectRow) ? this.p.onSelectRow :false,
		ondblClickRow = $.isFunction(this.p.ondblClickRow) ? this.p.ondblClickRow :false,
		onSortCol = $.isFunction(this.p.onSortCol) ? this.p.onSortCol : false,
		loadComplete = $.isFunction(this.p.loadComplete) ? this.p.loadComplete : false,
		loadError = $.isFunction(this.p.loadError) ? this.p.loadError : false,
		loadBeforeSend = $.isFunction(this.p.loadBeforeSend) ? this.p.loadBeforeSend : false,
		onRightClickRow = $.isFunction(this.p.onRightClickRow) ? this.p.onRightClickRow : false,
		afterInsRow = $.isFunction(this.p.afterInsertRow) ? this.p.afterInsertRow : false,
		onHdCl = $.isFunction(this.p.onHeaderClick) ? this.p.onHeaderClick : false,
		beReq = $.isFunction(this.p.beforeRequest) ? this.p.beforeRequest : false,
		onSC = $.isFunction(this.p.onCellSelect) ? this.p.onCellSelect : false,
		sortkeys = ["shiftKey","altKey","ctrlKey"];
		if ($.inArray(ts.p.multikey,sortkeys) == -1 ) {ts.p.multikey = false;}
		var IntNum = function(val,defval) {
			val = parseInt(val,10);
			if (isNaN(val)) { return (defval) ? defval : 0;}
			else {return val;}
		};
		var formatCol = function (elem, pos){
			var ral = ts.p.colModel[pos].align;
			if(ral) { $(elem).css("text-align",ral);}
			if(ts.p.colModel[pos].hidden) {$(elem).css("display","none");}
		};
		var resizeFirstRow = function (t,er){
			$("tbody tr:eq("+er+") td",t).each( function( k ) {
				$(this).css("width",grid.headers[k].width+"px");
				grid.cols[k] = this;
			});
		};
		var addCell = function(t,row,cell,pos) {
			var td;
			td = document.createElement("td");
			formatter($(td,t),row,cell,pos,'add');			
			row.appendChild(td);
			formatCol($(td,t), pos);
		};
		var formatter = function (elem, row, cellval , colpos, act){
			var cm = ts.p.colModel[colpos]; 
			if(cm.formatter) {
				var opts= {rowId: row.id, colModel:cm,rowData:row};
				if($.isFunction( cm.formatter ) ) {
					cm.formatter(elem,cellval,opts,act);
				} else if($.fmatter){
					$(elem).fmatter(cm.formatter, cellval,opts, act);
				} else {
					$(elem).html(cellval || '&#160;');
				}
			}else {
				$(elem).html(cellval || '&#160;');
			}
			elem[0].title = elem[0].textContent || elem[0].innerText;
		};
		var addMulti = function(t,row){
			var cbid,td;
			td = document.createElement("td");
			cbid = "jqg_"+row.id;
			$(td,t).html("<input type='checkbox'"+" id='"+cbid+"' class='cbox'/>");
			formatCol($(td,t), 0);
			row.appendChild(td);
		};
		var reader = function (datatype) {
			var field, f=[], j=0, i;
			for(i =0; i<ts.p.colModel.length; i++){
				field = ts.p.colModel[i];
				if (field.name !== 'cb' && field.name !=='subgrid') {
					f[j] = (datatype=="xml") ? field.xmlmap || field.name : field.jsonmap || field.name;
					j++;
				}
			}
			return f;
		};
		var addXmlData = function addXmlData (xml,t, rcnt) {
			if(xml) { var fpos = ts.p.treeANode || 0; rcnt=rcnt ||0; if(fpos===0 && rcnt===0) {$("tbody tr:gt(0)", t).remove();} } else { return; }
			var v,row,gi=0,si=0,cbid,idn, getId,f=[],rd =[],cn=(ts.p.altRows === true) ? 'alt':'';
			if(!ts.p.xmlReader.repeatitems) {f = reader("xml");}
			if( ts.p.keyIndex===false) {
				idn = ts.p.xmlReader.id;
				if( idn.indexOf("[") === -1 ) {
					getId = function( trow, k) {return $(idn,trow).text() || k;};
				}
				else {
					getId = function( trow, k) {return trow.getAttribute(idn.replace(/[\[\]]/g,"")) || k;};
				}
			} else {
				getId = function(trow) { return (f.length - 1 >= ts.p.keyIndex) ? $(f[ts.p.keyIndex],trow).text() : $(ts.p.xmlReader.cell+":eq("+ts.p.keyIndex+")",trow).text(); };
			}
			$(ts.p.xmlReader.page,xml).each(function() {ts.p.page = this.textContent  || this.text ; });
			$(ts.p.xmlReader.total,xml).each(function() {ts.p.lastpage = this.textContent  || this.text ; }  );
			$(ts.p.xmlReader.records,xml).each(function() {ts.p.records = this.textContent  || this.text ; }  );
			$(ts.p.xmlReader.userdata,xml).each(function() {ts.p.userData[this.getAttribute("name")]=this.textContent || this.text;});
			$(ts.p.xmlReader.root+" "+ts.p.xmlReader.row,xml).each( function( j ) {
				row = document.createElement("tr");
				row.id = getId(this,j+1);
				if(ts.p.multiselect) {
					addMulti(t,row);
					gi = 1;
				}
				if (ts.p.subGrid) {
					try {$(ts).addSubGrid(t,row,gi,this);} catch (e){}
					si= 1;
				}
				if(ts.p.xmlReader.repeatitems===true){
					$(ts.p.xmlReader.cell,this).each( function (i) {
						v = this.textContent || this.text;
						addCell(t,row,v,i+gi+si);
						rd[ts.p.colModel[i+gi+si].name] = v;
					});
				} else {
					for(var i = 0; i < f.length;i++) {
						v = $(f[i],this).text();
						addCell(t, row, v , i+gi+si);
						rd[ts.p.colModel[i+gi+si].name] = v;
					}
				}
				if(j%2 == 1) {row.className = cn;} $(row).addClass("jqgrow");
				if( ts.p.treeGrid === true) {
					try {$(ts).setTreeNode(rd,row);} catch (e) {}
					ts.p.treeANode = 0;
				}
				$(ts.rows[j+fpos+rcnt]).after(row);
				if(afterInsRow) {ts.p.afterInsertRow(row.id,rd,this);}
				rd=[];
			});
			if(isSafari || isOpera) {resizeFirstRow(t,1);}
		  	if(!ts.p.treeGrid && !ts.p.scroll) {ts.grid.bDiv.scrollTop = 0;}
			endReq();
			updatepager();
		};
		var addJSONData = function(data,t, rcnt) {
			if(data) { var fpos = ts.p.treeANode || 0; rcnt = rcnt || 0; if(fpos===0 && rcnt===0) {$("tbody tr:gt(0)", t).remove();} }  else { return; }
			var v,i,j,row,f=[],cur,gi=0,si=0,drows,idn,rd=[],cn=(ts.p.altRows===true) ? 'alt':'';
			ts.p.page = data[ts.p.jsonReader.page];
			ts.p.lastpage= data[ts.p.jsonReader.total];
			ts.p.records= data[ts.p.jsonReader.records];
			ts.p.userData = data[ts.p.jsonReader.userdata] || {};
			if(!ts.p.jsonReader.repeatitems) {f = reader("json");}
			if( ts.p.keyIndex===false ) {
				idn = ts.p.jsonReader.id;
				if(f.length>0 && !isNaN(idn)) {idn=f[idn];}
			} else {
				idn = f.length>0 ? f[ts.p.keyIndex] : ts.p.keyIndex;
			}
			drows = data[ts.p.jsonReader.root];
			if (drows) {
			for (i=0;i<drows.length;i++) {
				cur = drows[i];
				row = document.createElement("tr");
				row.id = cur[idn] || "";
				if(row.id === "") {
					if(f.length===0){
						if(ts.p.jsonReader.cell){
							var ccur = cur[ts.p.jsonReader.cell];
							row.id = ccur[idn] || i+1;
							ccur=null;
						} else {row.id=i+1;}
					} else {
						row.id=i+1;
					}
				}
				if(ts.p.multiselect){
					addMulti(t,row);
					gi = 1;
				}
				if (ts.p.subGrid) {
					try { $(ts).addSubGrid(t,row,gi,drows[i]);} catch (e){}
					si= 1;
				}
				if (ts.p.jsonReader.repeatitems === true) {
					if(ts.p.jsonReader.cell) {cur = cur[ts.p.jsonReader.cell];}
					for (j=0;j<cur.length;j++) {
						addCell(t,row,cur[j],j+gi+si);
						rd[ts.p.colModel[j+gi+si].name] = cur[j];
					}
				} else {
					for (j=0;j<f.length;j++) {
						v=cur[f[j]];
						if(v === undefined) {
							try { v = eval("cur."+f[j]);}
							catch (e) {}
						}
						addCell(t,row,v,j+gi+si);
						rd[ts.p.colModel[j+gi+si].name] = cur[f[j]];
					}
				}
				if(i%2 == 1) {row.className = cn;} $(row).addClass("jqgrow");
				if( ts.p.treeGrid === true) {
					try {$(ts).setTreeNode(rd,row);} catch (e) {}
					ts.p.treeANode = 0;
				}
				$(ts.rows[i+fpos+rcnt]).after(row);
				if(afterInsRow) {ts.p.afterInsertRow(row.id,rd,drows[i]);}
				rd=[];
			}
			}
			if(isSafari || isOpera) {resizeFirstRow(t,1);}
			if(!ts.p.treeGrid && !ts.p.scroll) {ts.grid.bDiv.scrollTop = 0;}
			endReq();
			updatepager();
		};
		var updatepager = function() {
			if(ts.p.pager) {
				var cp, last,imp = ts.p.imgpath;
				if (ts.p.loadonce) {
					cp = last = 1;
					ts.p.lastpage = ts.page =1;
					$(".selbox",ts.p.pager).attr("disabled",true);
				} else {
					cp = IntNum(ts.p.page);
					last = IntNum(ts.p.lastpage);
					$(".selbox",ts.p.pager).attr("disabled",false);
				}
				if(ts.p.pginput===true) {
					$('input.selbox',ts.p.pager).val(ts.p.page);
				}
				if (ts.p.viewrecords){
					if(ts.p.pgtext) {
						$('#sp_1',ts.p.pager).html(ts.p.pgtext+"&#160;"+ts.p.lastpage );
					}
					$('#sp_2',ts.p.pager).html(ts.p.records+"&#160;"+ts.p.recordtext+"&#160;");
				}
				if(ts.p.pgbuttons===true) {
					if(cp<=0) {cp = last = 1;}
					if(cp==1) {$("#first",ts.p.pager).attr({src:imp+"off-"+ts.p.firstimg,disabled:true});} else {$("#first",ts.p.pager).attr({src:imp+ts.p.firstimg,disabled:false});}
					if(cp==1) {$("#prev",ts.p.pager).attr({src:imp+"off-"+ts.p.previmg,disabled:true});} else {$("#prev",ts.p.pager).attr({src:imp+ts.p.previmg,disabled:false});}
					if(cp==last) {$("#next",ts.p.pager).attr({src:imp+"off-"+ts.p.nextimg,disabled:true});} else {$("#next",ts.p.pager).attr({src:imp+ts.p.nextimg,disabled:false});}
					if(cp==last) {$("#last",ts.p.pager).attr({src:imp+"off-"+ts.p.lastimg,disabled:true});} else {$("#last",ts.p.pager).attr({src:imp+ts.p.lastimg,disabled:false});}
				}
			}
			if($.isFunction(ts.p.gridComplete)) {ts.p.gridComplete();}
		};
		var populate = function () {
			if(!grid.hDiv.loading) {
				beginReq();
				var gdata, prm = {nd: (new Date().getTime()), _search:ts.p.search};
				prm[ts.p.prmNames.rows]= ts.p.rowNum; prm[ts.p.prmNames.page]= ts.p.page;
				prm[ts.p.prmNames.sort]= ts.p.sortname; prm[ts.p.prmNames.order]= ts.p.sortorder;
				gdata = $.extend(ts.p.postData,prm);
				if (ts.p.search ===true) {gdata =$.extend(gdata,ts.p.searchdata);}				
				if ($.isFunction(ts.p.datatype)) {ts.p.datatype(gdata);endReq();}
				var rcnt = ts.p.scroll===false ? 0 : ts.rows.length-1; 
				switch(ts.p.datatype)
				{
				case "json":
					$.ajax({url:ts.p.url,type:ts.p.mtype,dataType:"json",data: gdata, complete:function(JSON,st) { if(st=="success") {addJSONData(eval("("+JSON.responseText+")"),ts.grid.bDiv,rcnt); JSON=null;if(loadComplete) {loadComplete();}}}, error:function(xhr,st,err){if(loadError) {loadError(xhr,st,err);}endReq();}, beforeSend: function(xhr){if(loadBeforeSend) {loadBeforeSend(xhr);}}});
					if( ts.p.loadonce || ts.p.treeGrid) {ts.p.datatype = "local";}
				break;
				case "xml":
					$.ajax({url:ts.p.url,type:ts.p.mtype,dataType:"xml",data: gdata , complete:function(xml,st) {if(st=="success")	{addXmlData(xml.responseXML,ts.grid.bDiv,rcnt); xml=null;if(loadComplete) {loadComplete();}}}, error:function(xhr,st,err){if(loadError) {loadError(xhr,st,err);}endReq();}, beforeSend: function(xhr){if(loadBeforeSend) {loadBeforeSend(xhr);}}});
					if( ts.p.loadonce || ts.p.treeGrid) {ts.p.datatype = "local";}
				break;
				case "xmlstring":
					addXmlData(stringToDoc(ts.p.datastr),ts.grid.bDiv);
					ts.p.datastr = null;
					ts.p.datatype = "local";
					if(loadComplete) {loadComplete();}
				break;
				case "jsonstring":
					if(typeof ts.p.datastr == 'string') { ts.p.datastr = eval("("+ts.p.datastr+")");}
					addJSONData(ts.p.datastr,ts.grid.bDiv);
					ts.p.datastr = null;
					ts.p.datatype = "local";
					if(loadComplete) {loadComplete();}
				break;
				case "local":
				case "clientSide":
					ts.p.datatype = "local";
					sortArrayData();
				break;
				}
			}
		};
		var beginReq = function() {
			if(beReq) {ts.p.beforeRequest();}
			grid.hDiv.loading = true;
			switch(ts.p.loadui) {
				case "disable":
					break;
				case "enable":
					$("div.loading",grid.hDiv).fadeIn("fast");
					break;
				case "block":
					$("#lui_"+ts.id).width($(grid.bDiv).width()).height(IntNum($(grid.bDiv).height())+IntNum(ts.p._height)).fadeIn("fast");
					break;
			}
		};
		var endReq = function() {
			grid.hDiv.loading = false;
			switch(ts.p.loadui) {
				case "disable":
					break;
				case "enable":
					$("div.loading",grid.hDiv).fadeOut("fast");
					break;
				case "block":
					$("#lui_"+ts.id).fadeOut("fast");
					break;
			}
		};
		var stringToDoc =	function (xmlString) {
			var xmlDoc;
			if(typeof xmlString !== 'string') return xmlString;
			try	{
				var parser = new DOMParser();
				xmlDoc = parser.parseFromString(xmlString,"text/xml");
			}
			catch(e) {
				xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
				xmlDoc.async=false;
				xmlDoc["loadXM"+"L"](xmlString);
			}
			return (xmlDoc && xmlDoc.documentElement && xmlDoc.documentElement.tagName != 'parsererror') ? xmlDoc : null;
		};
		var sortArrayData = function() {
			var stripNum = /[\$,%]/g;
			var rows=[], col=0, st, sv, findSortKey,newDir = (ts.p.sortorder == "asc") ? 1 :-1;
			$.each(ts.p.colModel,function(i,v){
				if(this.index == ts.p.sortname || this.name == ts.p.sortname){
					col = ts.p.lastsort= i;
					st = this.sorttype;
					return false;
				}
			});
			if (st == 'float' || st== 'number' || st== 'currency') {
				findSortKey = function($cell) {
					var key = parseFloat($cell.replace(stripNum, ''));
					return isNaN(key) ? 0 : key;
				};
			} else if (st=='int' || st=='integer') {
				findSortKey = function($cell) {
					return IntNum($cell.replace(stripNum, ''));
				};
			} else if(st == 'date') {
				findSortKey = function($cell) {
					var fd = ts.p.colModel[col].datefmt || "Y-m-d";
					return parseDate(fd,$cell).getTime();
				};
			} else {
				findSortKey = function($cell) {
					return $.trim($cell.toUpperCase());
				};
			}
			$.each(ts.rows, function(index, row) {
				if (index > 0) {
					try { sv = $.unformat($(row).children('td').eq(col),{colModel:ts.p.colModel[col]},col,true);}
					catch (_) { sv = $(row).children('td').eq(col).text(); }
					row.sortKey = findSortKey(sv);
					rows[index-1] = this;
				}
			});
			if(ts.p.treeGrid) {
				$(ts).SortTree( newDir);
			} else {
				rows.sort(function(a, b) {
					if (a.sortKey < b.sortKey) {return -newDir;}
					if (a.sortKey > b.sortKey) {return newDir;}
					return 0;
				});
				$.each(rows, function(index, row) {
					$('tbody',ts.grid.bDiv).append(row);
					row.sortKey = null;
				});
			}
			if(isSafari || isOpera) {resizeFirstRow(ts.grid.bDiv,1);}
			if(ts.p.multiselect) {
				$("tbody tr:gt(0)", ts.grid.bDiv).removeClass("selected");
				$("[id^=jqg_]",ts.rows).attr("checked",false);
				$("#cb_jqg",ts.grid.hDiv).attr("checked",false);
				ts.p.selarrrow = [];
			}
			if( ts.p.altRows === true ) {
				$("tbody tr:gt(0)", ts.grid.bDiv).removeClass("alt");
				$("tbody tr:odd", ts.grid.bDiv).addClass("alt");
			}
			ts.grid.bDiv.scrollTop = 0;
			endReq();
		};
		var parseDate = function(format, date) {
			var tsp = {m : 1, d : 1, y : 1970, h : 0, i : 0, s : 0};
			format = format.toLowerCase();
			date = date.split(/[\\\/:_;.\s-]/);
			format = format.split(/[\\\/:_;.\s-]/);
			for(var i=0;i<format.length;i++){
				tsp[format[i]] = IntNum(date[i],tsp[format[i]]);
			}
			tsp.m = parseInt(tsp.m,10)-1;
			var ty = tsp.y;
			if (ty >= 70 && ty <= 99) {tsp.y = 1900+tsp.y;}
			else if (ty >=0 && ty <=69) {tsp.y= 2000+tsp.y;}
			return new Date(tsp.y, tsp.m, tsp.d, tsp.h, tsp.i, tsp.s,0);
		};
		var setPager = function (){
			var inpt = "<img class='pgbuttons' src='"+ts.p.imgpath+"spacer.gif'",
			pginp = (ts.p.pginput===true) ? "<input class='selbox' type='text' size='3' maxlength='5' value='0'/>" : "",
			pgl="", pgr="", str;
			if(ts.p.viewrecords===true) {pginp += "<span id='sp_1'></span>&#160;";}
			if(ts.p.pgbuttons===true) {
				pgl = inpt+" id='first'/>&#160;&#160;"+inpt+" id='prev'/>&#160;";
				pgr = inpt+" id='next' />&#160;&#160;"+inpt+" id='last'/>";
			}
			$(ts.p.pager).append(pgl+pginp+pgr);
			if(ts.p.rowList.length >0){
				str="<SELECT class='selbox'>";
				for(var i=0;i<ts.p.rowList.length;i++){
					str +="<OPTION value="+ts.p.rowList[i]+((ts.p.rowNum == ts.p.rowList[i])?' selected':'')+">"+ts.p.rowList[i];
				}
				str +="</SELECT>";
				$(ts.p.pager).append("&#160;"+str+"&#160;<span id='sp_2'></span>");
				$(ts.p.pager).find("select").bind('change',function() { 
					ts.p.rowNum = this.value; 
					if (typeof ts.p.onPaging =='function') {ts.p.onPaging('records');}
					populate();
					ts.p.selrow = null;
				});
			} else { $(ts.p.pager).append("&#160;<span id='sp_2'></span>");}
			if(ts.p.pgbuttons===true) {
			$(".pgbuttons",ts.p.pager).mouseover(function(e){
				if($(this).attr('disabled') == 'true') { this.style.cursor='auto';}				
				else {this.style.cursor= "pointer";}
				return false;
			}).mouseout(function(e) {
				this.style.cursor= "default";
				return false;
			});
			$("#first, #prev, #next, #last",ts.p.pager).click( function(e) {
				var cp = IntNum(ts.p.page),
				last = IntNum(ts.p.lastpage), selclick = false,
				fp=true, pp=true, np=true,lp=true;
				if(last ===0 || last===1) {fp=false;pp=false;np=false;lp=false; }
				else if( last>1 && cp >=1) {
					if( cp === 1) { fp=false; pp=false; } 
					else if( cp>1 && cp <last){ }
					else if( cp===last){ np=false;lp=false; }
				} else if( last>1 && cp===0 ) { np=false;lp=false; cp=last-1;}
				if( this.id === 'first' && fp ) { ts.p.page=1; selclick=true;} 
				if( this.id === 'prev' && pp) { ts.p.page=(cp-1); selclick=true;} 
				if( this.id === 'next' && np) { ts.p.page=(cp+1); selclick=true;} 
				if( this.id === 'last' && lp) { ts.p.page=last; selclick=true;}
				if(selclick) {
					if (typeof ts.p.onPaging =='function') {ts.p.onPaging(this.id);}
					populate();
					ts.p.selrow = null;
					if(ts.p.multiselect) {ts.p.selarrrow =[];$('#cb_jqg',ts.grid.hDiv).attr("checked",false);}
					ts.p.savedRow = [];
				}
				e.stopPropagation();
				return false;
			});
			}
			if(ts.p.pginput===true) {
			$('input.selbox',ts.p.pager).keypress( function(e) {
				var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
				if(key == 13) {
					ts.p.page = ($(this).val()>0) ? $(this).val():ts.p.page;
					if (typeof ts.p.onPaging =='function') {ts.p.onPaging( 'user');}
					populate();
					ts.p.selrow = null;
					return false;
				}
				return this;
			});
			}
		};
		var sortData = function (index, idxcol,reload){
			var imgs, so, scg, ls, iId;
			if(ts.p.savedRow.length > 0) {return;}
			if(!reload) {
				if( ts.p.lastsort === idxcol ) {
					if( ts.p.sortorder === 'asc') {
						ts.p.sortorder = 'desc';
					} else if(ts.p.sortorder === 'desc') { ts.p.sortorder='asc';}
				} else { ts.p.sortorder='asc';}
				ts.p.page = 1;
			}
			imgs = (ts.p.sortorder==='asc') ? ts.p.sortascimg : ts.p.sortdescimg;
			imgs = "<img src='"+ts.p.imgpath+imgs+"'>";
			var thd= $("thead:first",grid.hDiv).get(0);
			ls = ts.p.colModel[ts.p.lastsort].name.replace('.',"\\.");
			$("tr th div#jqgh_"+ls+" img",thd).remove();
			$("tr th div#jqgh_"+ls,thd).parent().removeClass(ts.p.sortclass);
			iId = index.replace('.',"\\.");
			$("tr th div#"+iId,thd).append(imgs).parent().addClass(ts.p.sortclass);
			ts.p.lastsort = idxcol;
			index = index.substring(5);
			ts.p.sortname = ts.p.colModel[idxcol].index || index;
			so = ts.p.sortorder;
			if(onSortCol) {onSortCol(index,idxcol,so);}
			if(ts.p.datatype == "local") {
				if(ts.p.deselectAfterSort) {$(ts).resetSelection();}
			} else {
				ts.p.selrow = null;
				if(ts.p.multiselect){$("#cb_jqg",ts.grid.hDiv).attr("checked",false);}
				ts.p.selarrrow =[];
				ts.p.savedRow =[];
			}			
			scg = ts.p.scroll; if(ts.p.scroll===true) {ts.p.scroll=false;}
			populate();
			if(ts.p.sortname != index && idxcol) {ts.p.lastsort = idxcol;}
			setTimeout(function() {ts.p.scroll=scg;},500);
		};
		var setColWidth = function () {
			var initwidth = 0; 
			for(var l=0;l<ts.p.colModel.length;l++){
				if(!ts.p.colModel[l].hidden){
					initwidth += IntNum(ts.p.colModel[l].width);
				}
			}
			var tblwidth = ts.p.width ? ts.p.width : initwidth;
			for(l=0;l<ts.p.colModel.length;l++) {
				if(!ts.p.shrinkToFit){
					ts.p.colModel[l].owidth = ts.p.colModel[l].width;
				}
				ts.p.colModel[l].width = Math.round(tblwidth/initwidth*ts.p.colModel[l].width);
			}
		};
		var nextVisible= function(iCol) {
			var ret = iCol, j=iCol, i;
			for (i = iCol+1;i<ts.p.colModel.length;i++){
				if(ts.p.colModel[i].hidden !== true ) {
					j=i; break;
				}
			}
			return j-ret;
		};
		this.p.id = this.id;
		if(this.p.treeGrid === true) {
			this.p.subGrid = false; this.p.altRows =false;
			this.p.pgbuttons = false; this.p.pginput = false;
			this.p.multiselect = false; this.p.rowList = [];
			try {
				$(this).setTreeGrid();
				this.p.treedatatype = this.p.datatype;
				$.each(this.p.treeReader,function(i,n){
					if(n){
						ts.p.colNames.push(n);
						ts.p.colModel.push({name:n,width:1,hidden:true,sortable:false,resizable:false,hidedlg:true,editable:true,search:false});
					}
				});
			} catch (_) {}
		}
		ts.p.keyIndex=false;
		for (var i=0; i<ts.p.colModel.length;i++) {
			if (ts.p.colModel[i].key===true) {
				ts.p.keyIndex = i;
				break;
			}
		}
		if(this.p.subGrid) {
			this.p.colNames.unshift("");
			this.p.colModel.unshift({name:'subgrid',width:25,sortable: false,resizable:false,hidedlg:true,search:false});
		}
		if(this.p.multiselect) {
			this.p.colNames.unshift("<input id='cb_jqg' class='cbox' type='checkbox'/>");
			this.p.colModel.unshift({name:'cb',width:27,sortable:false,resizable:false,hidedlg:true,search:false});
		}
		var	xReader = {
			root: "rows",
			row: "row",
			page: "rows>page",
			total: "rows>total",
			records : "rows>records",
			repeatitems: true,
			cell: "cell",
			id: "[id]",
			userdata: "userdata",
			subgrid: {root:"rows", row: "row", repeatitems: true, cell:"cell"}
		};
		var jReader = {
			root: "rows",
			page: "page",
			total: "total",
			records: "records",
			repeatitems: true,
			cell: "cell",
			id: "id",
			userdata: "userdata",
			subgrid: {root:"rows", repeatitems: true, cell:"cell"}
		};
		if(ts.p.scroll===true){
			ts.p.pgbuttons = false; ts.p.pginput=false; ts.p.pgtext = false; ts.p.rowList=[];
		}
		ts.p.xmlReader = $.extend(xReader, ts.p.xmlReader);
		ts.p.jsonReader = $.extend(jReader, ts.p.jsonReader);
		$.each(ts.p.colModel, function(i){this.width= IntNum(this.width,150);});
		if (ts.p.width) {setColWidth();}
		var thead = document.createElement("thead");
		var trow = document.createElement("tr");
		thead.appendChild(trow); 
		var i=0, th, idn, thdiv;
		if(ts.p.shrinkToFit===true && ts.p.forceFit===true) {
			for (i=ts.p.colModel.length-1;i>=0;i--){
				if(!ts.p.colModel[i].hidden) {
					ts.p.colModel[i].resizable=false;
					break;
				}
			}
		}
		for(i=0;i<this.p.colNames.length;i++){
			th = document.createElement("th");
			idn = ts.p.colModel[i].name;
			thdiv = document.createElement("div");
			$(thdiv).html(ts.p.colNames[i]+"&#160;");
			if (idn == ts.p.sortname) {
				var imgs = (ts.p.sortorder==='asc') ? ts.p.sortascimg : ts.p.sortdescimg;
				imgs = "<img src='"+ts.p.imgpath+imgs+"'>";
				$(thdiv).append(imgs);
				ts.p.lastsort = i;
				$(th).addClass(ts.p.sortclass);
			}
			thdiv.id = "jqgh_"+idn;
			th.appendChild(thdiv);
			trow.appendChild(th);
		}
		if(this.p.multiselect) {
			var onSA = true;
			if(typeof ts.p.onSelectAll !== 'function') {onSA=false;}
			$('#cb_jqg',trow).click(function(){
				var chk;
				if (this.checked) {
					$("[id^=jqg_]",ts.rows).attr("checked",true);
					$(ts.rows).slice(1).each(function(i) {
						if(!$(this).hasClass("subgrid")){
						$(this).addClass("selected");
						ts.p.selarrrow[i]= ts.p.selrow = this.id; 
						}
					});
					chk=true;
				}
				else {
					$("[id^=jqg_]",ts.rows).attr("checked",false);
					$(ts.rows).slice(1).each(function(i) {
						if(!$(this).hasClass("subgrid")){
							$(this).removeClass("selected");
						}
					});
					ts.p.selarrrow = []; ts.p.selrow = null;
					chk=false;
				}
				if(onSA) {ts.p.onSelectAll(ts.p.selarrrow,chk);}
			});
		}
		this.appendChild(thead);
		thead = $("thead:first",ts).get(0);
		var w, res, sort;
		$("tr:first th",thead).each(function ( j ) {
			w = ts.p.colModel[j].width;
			if(typeof ts.p.colModel[j].resizable === 'undefined') {ts.p.colModel[j].resizable = true;}
			res = document.createElement("span");
			$(res).html("&#160;");
			if(ts.p.colModel[j].resizable){
				$(this).addClass(ts.p.resizeclass);
				$(res).mousedown(function (e) {
					if(ts.p.forceFit===true) {ts.p.nv= nextVisible(j);}
					grid.dragStart(j, e.clientX);
					e.preventDefault();
					return false;
				});
			} else {res="";}
			$(this).css("width",w+"px").prepend(res);
			if( ts.p.colModel[j].hidden) {$(this).css("display","none");}
			grid.headers[j] = { width: w, el: this };
			sort = ts.p.colModel[j].sortable;
			if( typeof sort !== 'boolean') {sort =  true;}
			if(sort) { 
				$("div",this).css("cursor","pointer")
				.click(function(){sortData(this.id,j);return false;});
			}
		});
		var isMSIE = $.browser.msie ? true:false,
		isMoz = $.browser.mozilla ? true:false,
		isOpera = $.browser.opera ? true:false,
		isSafari = $.browser.safari ? true : false,
		td, ptr, gw=0,hdc=0, tbody = document.createElement("tbody");
		trow = document.createElement("tr");
		trow.id = "_empty";
		tbody.appendChild(trow);
		for(i=0;i<ts.p.colNames.length;i++){
			td = document.createElement("td");
			trow.appendChild(td);
		}
		this.appendChild(tbody);
		$("tbody tr:first td",ts).each(function(ii) {
			w = ts.p.colModel[ii].width;
			$(this).css({width:w+"px",height:"0px"});
			w +=  IntNum($(this).css("padding-left")) +
			IntNum($(this).css("padding-right"))+
			IntNum($(this).css("border-left-width"))+
			IntNum($(this).css("border-right-width"));
			if( ts.p.colModel[ii].hidden===true) {
				$(this).css("display","none");
				hdc += w;
			}
			grid.cols[ii] = this;
			gw += w;
		});
		if(isMoz) {$(trow).css({visibility:"collapse"});}
		else if( isSafari || isOpera ) {$(trow).css({display:"none"});}
		grid.width = IntNum(gw)-IntNum(hdc);
		ts.p._width = grid.width;
		grid.hTable = document.createElement("table");
		$(grid.hTable).append(thead)
		.css({width:grid.width+"px"})
		.attr({cellSpacing:"0",cellPadding:"0",border:"0"})
		.addClass("scroll grid_htable");
		grid.hDiv = document.createElement("div");
		var hg = (ts.p.caption && ts.p.hiddengrid===true) ? true : false;
		$(grid.hDiv)
			.css({ width: grid.width+"px", overflow: "hidden"})
			.prepend('<div class="loading">'+ts.p.loadtext+'</div>')
			.addClass("grid_hdiv")
			.append(grid.hTable)
			.bind("selectstart", function () { return false; });
		if(hg) {$(grid.hDiv).hide(); ts.p.gridstate = 'hidden'}
		if(ts.p.pager){
			if(typeof ts.p.pager == "string") {if(ts.p.pager.substr(0,1) !="#") ts.p.pager = "#"+ts.p.pager;}
			if( $(ts.p.pager).hasClass("scroll")) { $(ts.p.pager).css({ width: grid.width+"px", overflow: "hidden"}).show(); ts.p._height= parseInt($(ts.p.pager).height(),10); if(hg) {$(ts.p.pager).hide();}}
			setPager();
		}
		if( ts.p.cellEdit === false) {
		$(ts).mouseover(function(e) {
			td = (e.target || e.srcElement);
			ptr = $(td,ts.rows).parents("tr:first");
			if($(ptr).hasClass("jqgrow")) {
				$(ptr).addClass("over");
			}
			return false;
		}).mouseout(function(e) {
			td = (e.target || e.srcElement);
			ptr = $(td,ts.rows).parents("tr:first");
			$(ptr).removeClass("over");
			return false;
		});
		}
		var ri,ci;
		
		$(ts).before(grid.hDiv).css("width", grid.width+"px").click(function(e) {
			td = (e.target || e.srcElement);
			if (td.href) { return true; }
			var scb = $(td).hasClass("cbox");
			ptr = $(td,ts.rows).parent("tr");
			if($(ptr).length === 0 ){
				ptr = $(td,ts.rows).parents("tr:first");
				td = $(td).parents("td:first")[0];
			}
			var cSel = true;
			if(bSR) { cSel = bSR(ptr.attr("id"));}
			if(cSel === true) {
				if(ts.p.cellEdit === true) {
					if(ts.p.multiselect && scb){
						$(ts).setSelection(false,true,ptr);
					} else {
						ri = ptr[0].rowIndex;
						ci = td.cellIndex;
						try {$(ts).editCell(ri,ci,true,true);} catch (e) {}
					}
				} else if ( !ts.p.multikey ) {
					if(ts.p.multiselect && ts.p.multiboxonly) {
						if(scb){$(ts).setSelection(false,true,ptr);}
					} else {
						$(ts).setSelection(false,true,ptr);
					}
				} else {
					if(e[ts.p.multikey]) {
						$(ts).setSelection(false,true,ptr);
					} else if(ts.p.multiselect && scb) {
						scb = $("[id^=jqg_]",ptr).attr("checked");
						$("[id^=jqg_]",ptr).attr("checked",!scb);
					}
				}
				if(onSC) {
					ri = ptr[0].id;
					ci = td.cellIndex;
					onSC(ri,ci,$(td).html());
				}
			}
			e.stopPropagation();
		}).bind('reloadGrid', function(e) {
			if(ts.p.treeGrid ===true) {	ts.p.datatype = ts.p.treedatatype;}
			if(ts.p.datatype=="local"){ $(ts).resetSelection();}
			else if(!ts.p.treeGrid){
				ts.p.selrow=null;
				if(ts.p.multiselect) {ts.p.selarrrow =[];$('#cb_jqg',ts.grid.hDiv).attr("checked",false);}
				if(ts.p.cellEdit) {ts.p.savedRow = []; }
			}
			populate();
		});		
		if( ondblClickRow ) {
			$(this).dblclick(function(e) {
				td = (e.target || e.srcElement);
				ptr = $(td,ts.rows).parent("tr");
				if($(ptr).length === 0 ){
					ptr = $(td,ts.rows).parents("tr:first");
				}
				ts.p.ondblClickRow($(ptr).attr("id"));
				return false;
			});
		}
		if (onRightClickRow) {
			$(this).bind('contextmenu', function(e) {
				td = (e.target || e.srcElement);
				ptr = $(td,ts).parents("tr:first");
				if($(ptr).length === 0 ){
					ptr = $(td,ts.rows).parents("tr:first");
				}
				if(!ts.p.multiselect) {	$(ts).setSelection(false,true,ptr);	}
				ts.p.onRightClickRow($(ptr).attr("id"));
				return false;
			});
		}
		grid.bDiv = document.createElement("div");
		var ofl2 = (isNaN(ts.p.height) && isMoz && (ts.p.height.indexOf("%")!=-1 || ts.p.height=="auto")) ? "hidden" : "auto";
		$(grid.bDiv)
			.addClass("grid_bdiv")
			.scroll(function (e) {grid.scrollGrid();})
			.css({ height: ts.p.height+(isNaN(ts.p.height)?"":"px"), padding: "0px", margin: "0px", overflow: ofl2,width: (grid.width)+"px"} ).css("overflow-x","hidden")
			.append(this);
		$("table:first",grid.bDiv).css({width:grid.width+"px"});
		if( isMSIE ) {
			if( $("tbody",this).size() === 2 ) { $("tbody:first",this).remove();}
			if( ts.p.multikey) {$(grid.bDiv).bind("selectstart",function(){return false;});}
			if(ts.p.treeGrid) {$(grid.bDiv).css("position","relative");}
		} else {
			if( ts.p.multikey) {$(grid.bDiv).bind("mousedown",function(){return false;});}
		}
		if(hg) {$(grid.bDiv).hide();}
		grid.cDiv = document.createElement("div");
		$(grid.cDiv).append("<table class='Header' cellspacing='0' cellpadding='0' border='0'><tr><td class='HeaderLeft'><img src='"+ts.p.imgpath+"spacer.gif' border='0' /></td><th>"+ts.p.caption+"</th>"+ ((ts.p.hidegrid===true) ? "<td class='HeaderButton'><img src='"+ts.p.imgpath+"up.gif' border='0'/></td>" :"") +"<td class='HeaderRight'><img src='"+ts.p.imgpath+"spacer.gif' border='0' /></td></tr></table>")
		.addClass("GridHeader").width(grid.width);
		$(grid.cDiv).insertBefore(grid.hDiv);
		if( ts.p.toolbar[0] ) {
			grid.uDiv = document.createElement("div");
			if(ts.p.toolbar[1] == "top") {$(grid.uDiv).insertBefore(grid.hDiv);}
			else {$(grid.uDiv).insertAfter(grid.hDiv);}
			$(grid.uDiv).width(grid.width).addClass("userdata").attr("id","t_"+this.id);
			ts.p._height += parseInt($(grid.uDiv).height(),10);
			if(hg) {$(grid.uDiv).hide();}
		}
		if(ts.p.caption) {
			ts.p._height += parseInt($(grid.cDiv,ts).height(),10);
			var tdt = ts.p.datatype;
			if(ts.p.hidegrid===true) {
				$(".HeaderButton",grid.cDiv).toggle( function(){
					if(ts.p.pager) {$(ts.p.pager).slideUp();}
					if(ts.p.toolbar[0]) {$(grid.uDiv,ts).slideUp();}
					$(grid.bDiv).hide();
					$(grid.hDiv).slideUp();
					$("img",this).attr("src",ts.p.imgpath+"down.gif");
					ts.p.gridstate = 'hidden';
					if(onHdCl) {if(!hg) {ts.p.onHeaderClick(ts.p.gridstate);}}
					},
					function() {
					$(grid.hDiv).slideDown();
					$(grid.bDiv).show();
					if(ts.p.pager) {$(ts.p.pager).slideDown();}
					if(ts.p.toolbar[0]) {$(grid.uDiv).slideDown();}
					$("img",this).attr("src",ts.p.imgpath+"up.gif");
					if(hg) {ts.p.datatype = tdt;populate();hg=false;}
					ts.p.gridstate = 'visible';
					if(onHdCl) {ts.p.onHeaderClick(ts.p.gridstate)}
					}
				);
				if(hg) { $(".HeaderButton",grid.cDiv).trigger("click"); ts.p.datatype="local";}
			}
		} else {$(grid.cDiv).hide();}
		ts.p._height += parseInt($(grid.hDiv,ts).height(),10);
		$(grid.hDiv).mousemove(function (e) {grid.dragMove(e.clientX); return false;}).after(grid.bDiv);
		$(document).mouseup(function (e) {
			if(grid.resizing) {
				grid.dragEnd();
				if(grid.newWidth && ts.p.forceFit===false){
					var gwdt = (grid.width <= ts.p._width) ? grid.width: ts.p._width;
					var overfl = (grid.width <= ts.p._width) ? "hidden" : "auto";
					if(ts.p.pager && $(ts.p.pager).hasClass("scroll") ) {
						$(ts.p.pager).width(gwdt);
					}
					if(ts.p.caption) {$(grid.cDiv).width(gwdt);}
					if(ts.p.toolbar[0]) {$(grid.uDiv).width(gwdt);}
					$(grid.bDiv).width(gwdt).css("overflow-x",overfl);
					$(grid.hDiv).width(gwdt);
				}
				return false;
			}
			return true;
		});
		ts.formatCol = function(a,b) {formatCol(a,b);};
		ts.sortData = function(a,b,c){sortData(a,b,c);};
		ts.updatepager = function(){updatepager();};
		ts.formatter = function (elem, row, cellval , colpos, act){formatter(elem, row, cellval , colpos,act);};
		$.extend(grid,{populate : function(){populate();}});
		this.grid = grid;
		ts.addXmlData = function(d) {addXmlData(d,ts.grid.bDiv);};
		ts.addJSONData = function(d) {addJSONData(d,ts.grid.bDiv);};
		populate();
		if (!ts.p.shrinkToFit) {
			ts.p.forceFit = false;
			$("tr:first th", thead).each(function(j){
				var w = ts.p.colModel[j].owidth;
				var diff = w - ts.p.colModel[j].width;
				if (diff > 0 && !ts.p.colModel[j].hidden) {
					grid.headers[j].width = w;
					$(this).add(grid.cols[j]).width(w);
					$('table:first',grid.bDiv).add(grid.hTable).width(ts.grid.width);
					ts.grid.width += diff;
					grid.hDiv.scrollLeft = grid.bDiv.scrollLeft;
				}
			});
			ofl2 = (grid.width <= ts.p._width) ? "hidden" : "auto";
			$(grid.bDiv).css({"overflow-x":ofl2});
		}
		$(window).unload(function () {
			$(this).unbind("*");
			this.grid = null;
			this.p = null;
		});
	});
};
})(jQuery);
