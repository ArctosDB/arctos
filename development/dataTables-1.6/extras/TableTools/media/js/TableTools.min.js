/*
 * File:        TableTools.min.js
 * Version:     1.1.4
 * Author:      Allan Jardine (www.sprymedia.co.uk)
 * 
 * Copyright 2009-2010 Allan Jardine, all rights reserved.
 *
 * This source file is free software, under either the GPL v2 license or a
 * BSD (3 point) style license, as supplied with this software.
 * 
 * This source file is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the license files for details.
 */
var TableToolsInit={oFeatures:{bCsv:true,bXls:true,bCopy:true,bPrint:true},oBom:{bCsv:true,bXls:true},bIncFooter:true,bIncHiddenColumns:false,sPrintMessage:"",sPrintInfo:"<h6>Print view</h6><p>Please use your browser's print function to print this table. Press escape when finished.",sTitle:"",sSwfPath:"media/swf/ZeroClipboard.swf",iButtonHeight:30,iButtonWidth:30,sCsvBoundary:"'",_iNextId:1};
(function(a){function b(i){var n;var m=null;var r;var u=[];var c=0;var e=null;var x;
var f;var z;function q(C){_nTools=document.createElement("div");_nTools.className="TableTools";
z=TableToolsInit._iNextId++;n=a.extend(true,{},TableToolsInit);x=C.oDTSettings;r=k(x.nTable,"dataTables_wrapper");
ZeroClipboard.moviePath=n.sSwfPath;if(n.oFeatures.bCopy){B()}if(n.oFeatures.bCsv){j()
}if(n.oFeatures.bXls){s()}if(n.oFeatures.bPrint){d()}return _nTools}function j(){var E="TableTools_button TableTools_csv";
var C=document.createElement("div");C.id="ToolTables_CSV_"+z;C.style.height=n.iButtonHeight+"px";
C.style.width=n.iButtonWidth+"px";C.className=E;_nTools.appendChild(C);var D=new ZeroClipboard.Client();
D.setHandCursor(true);D.setAction("save");D.setCharSet("UTF8");D.setBomInc(n.oBom.bCsv);
D.setFileName(l()+".csv");D.addEventListener("mouseOver",function(F){C.className=E+"_hover"
});D.addEventListener("mouseOut",function(F){C.className=E});D.addEventListener("mouseDown",function(F){v(D,h(",",TableToolsInit.sCsvBoundary))
});g(D,C,"ToolTables_CSV_"+z,"Save as CSV")}function s(){var E="TableTools_button TableTools_xls";
var C=document.createElement("div");C.id="ToolTables_XLS_"+z;C.style.height=n.iButtonHeight+"px";
C.style.width=n.iButtonWidth+"px";C.className=E;_nTools.appendChild(C);var D=new ZeroClipboard.Client();
D.setHandCursor(true);D.setAction("save");D.setCharSet("UTF16LE");D.setBomInc(n.oBom.bXls);
D.setFileName(l()+".xls");D.addEventListener("mouseOver",function(F){C.className=E+"_hover"
});D.addEventListener("mouseOut",function(F){C.className=E});D.addEventListener("mouseDown",function(F){v(D,h("\t"))
});g(D,C,"ToolTables_XLS_"+z,"Save for Excel")}function B(){var E="TableTools_button TableTools_clipboard";
var C=document.createElement("div");C.id="ToolTables_Copy_"+z;C.style.height=n.iButtonHeight+"px";
C.style.width=n.iButtonWidth+"px";C.className=E;_nTools.appendChild(C);var D=new ZeroClipboard.Client();
D.setHandCursor(true);D.setAction("copy");D.addEventListener("mouseOver",function(F){C.className=E+"_hover"
});D.addEventListener("mouseOut",function(F){C.className=E});D.addEventListener("mouseDown",function(F){v(D,h("\t"))
});D.addEventListener("complete",function(F,H){var G=f.split("\n");alert("Copied "+(G.length-1)+" rows to the clipboard")
});g(D,C,"ToolTables_Copy_"+z,"Copy to clipboard")}function d(){var D="TableTools_button TableTools_print";
var C=document.createElement("div");C.style.height=n.iButtonHeight+"px";C.style.width=n.iButtonWidth+"px";
C.className=D;C.title="Print table";_nTools.appendChild(C);a(C).hover(function(E){C.className=D+"_hover"
},function(E){C.className=D});a(C).click(function(){y(x.nTable);_iPrintSaveStart=x._iDisplayStart;
_iPrintSaveLength=x._iDisplayLength;x._iDisplayStart=0;x._iDisplayLength=-1;x.oApi._fnCalculateEnd(x);
x.oApi._fnDraw(x);var E=x.anFeatures;for(var G in E){if(G!="i"&&G!="t"){u.push({node:E[G],display:"block"});
E[G].style.display="none"}}var F=document.createElement("div");F.className="TableTools_PrintInfo";
F.innerHTML=n.sPrintInfo;document.body.appendChild(F);if(n.sPrintMessage!==""){e=document.createElement("p");
e.className="TableTools_PrintMessage";e.innerHTML=n.sPrintMessage;document.body.insertBefore(e,document.body.childNodes[0])
}c=a(window).scrollTop();window.scrollTo(0,0);a(document).bind("keydown",null,p);
setTimeout(function(){a(F).fadeOut("normal",function(){document.body.removeChild(F)
})},2000)})}function p(C){if(C.keyCode==27){t();window.scrollTo(0,c);if(e){document.body.removeChild(e);
e=null}x._iDisplayStart=_iPrintSaveStart;x._iDisplayLength=_iPrintSaveLength;x.oApi._fnCalculateEnd(x);
x.oApi._fnDraw(x);a(document).unbind("keydown",p)}}function t(){for(var D=0,C=u.length;
D<C;D++){u[D].node.style.display=u[D].display}u.splice(0,u.length)}function y(D){var G=D.parentNode;
var H=G.childNodes;for(var E=0,C=H.length;E<C;E++){if(H[E]!=D&&H[E].nodeType==1){var F=a(H[E]).css("display");
if(F!="none"){u.push({node:H[E],display:F});H[E].style.display="none"}}}if(G.nodeName!="BODY"){y(G)
}}function g(D,C,F,E){if(document.getElementById(F)){D.glue(C,E)}else{setTimeout(function(){g(D,C,F,E)
},100)}}function l(){var C;if(n.sTitle!==""){C=n.sTitle}else{C=document.getElementsByTagName("title")[0].innerHTML
}if("\u00A1".toString().length<4){return C.replace(/[^a-zA-Z0-9_\u00A1-\uFFFF\.,\-_ !\(\)]/g,"")
}else{return C.replace(/[^a-zA-Z0-9_\.,\-_ !\(\)]/g,"")}}function k(D,C){if(D.className.match(C)||D.nodeName=="BODY"){return D
}else{return k(D.parentNode,C)}}function o(C,E,D){if(E===""){return C}else{return E+C.replace(D,"\\"+E)+E
}}function w(D){var E=A(D,2048),J=document.createElement("div"),F,C,H,I="",G;for(F=0,C=E.length;
F<C;F++){H=E[F].lastIndexOf("&");if(H!=-1&&E[F].length>=8&&H>E[F].length-8){G=E[F].substr(H);
E[F]=E[F].substr(0,H)}J.innerHTML=E[F];I+=J.childNodes[0].nodeValue}return I}function A(C,E){var F=[];
var G=C.length;for(var D=0;D<G;D+=E){if(D+E<G){F.push(C.substring(D,D+E))}else{F.push(C.substring(D,G))
}}return F}function v(G,D){var F=A(D,8192);G.clearText();for(var E=0,C=F.length;E<C;
E++){G.appendText(F[E])}}function h(E,I){var G,D;var F,M;var K="";var H="";var C=navigator.userAgent.match(/Windows/)?"\r\n":"\n";
if(typeof I=="undefined"){I=""}var J=new RegExp(I,"g");for(G=0,D=x.aoColumns.length;
G<D;G++){if(n.bIncHiddenColumns===true||x.aoColumns[G].bVisible){H=x.aoColumns[G].sTitle.replace(/\n/g," ").replace(/<.*?>/g,"");
if(H.indexOf("&")!=-1){H=w(H)}K+=o(H,I,J)+E}}K=K.slice(0,E.length*-1);K+=C;for(F=0,M=x.aiDisplay.length;
F<M;F++){for(G=0,D=x.aoColumns.length;G<D;G++){if(n.bIncHiddenColumns===true||x.aoColumns[G].bVisible){var L=x.aoData[x.aiDisplay[F]]._aData[G];
if(typeof L=="string"){H=L.replace(/\n/g," ");H=H.replace(/<img.*?\s+alt\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>]+)).*?>/gi,"$1$2$3");
H=H.replace(/<.*?>/g,"")}else{H=L+""}H=H.replace(/^\s+/,"").replace(/\s+$/,"");if(H.indexOf("&")!=-1){H=w(H)
}K+=o(H,I,J)+E}}K=K.slice(0,E.length*-1);K+=C}K.slice(0,-1);if(n.bIncFooter){for(G=0,D=x.aoColumns.length;
G<D;G++){if(x.aoColumns[G].nTf!==null&&(n.bIncHiddenColumns===true||x.aoColumns[G].bVisible)){H=x.aoColumns[G].nTf.innerHTML.replace(/\n/g," ").replace(/<.*?>/g,"");
if(H.indexOf("&")!=-1){H=w(H)}K+=o(H,I,J)+E}}K=K.slice(0,E.length*-1)}f=K;return K
}return q(i)}if(typeof a.fn.dataTable=="function"&&typeof a.fn.dataTableExt.sVersion!="undefined"){a.fn.dataTableExt.aoFeatures.push({fnInit:function(c){return new b({oDTSettings:c})
},cFeature:"T",sFeature:"TableTools"})}else{alert("Warning: TableTools requires DataTables 1.5 or greater - www.datatables.net/download")
}})(jQuery);