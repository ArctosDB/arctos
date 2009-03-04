/*
	This is the clear version of _overlib.js, Arctos' main JS include file. _overlib.js is an obfuscated version of this
	file. To create _overlib.js, just paste the contents of this file into
	
	http://www.brainjar.com/js/crunch/demo.html
	
	and paste the results of that into _overlib.js
	
	DO NOT OVERWRITE THIS FILE WITH OBFUSCATED CODE!

*/
 function get_cookie ( cookie_name ) {
  var results = document.cookie.match ( '(^|;) ?' + cookie_name + '=([^;]*)(;|$)' );
  if ( results )
    return ( unescape ( results[2] ) );
  else
    return null;
}
function orapwCheck(p,u) {
	var regExp = /^[A-Za-z0-9!$%&_?(\-)<>=/:;*\.]$/;
	var minLen=6;
	var msg='Password is acceptable';
	if (p.indexOf(u) > -1) {
		msg='Password may not contain your username.';
	}
	if (p.length<minLen || p.length>30) {
		msg='Password must be between ' + minLen + ' and 30 characters.';
	}
	if (!p.match(/[a-zA-Z]/)) {
		msg='Password must contain at least one letter.'
	}
	if (!p.match(/\d+/)) {
		msg='Password must contain at least one number.'
	}
	if (!p.match(/[!,$,%,&,*,?,_,-,(,),<,>,=,/,:,;,.]/) ) {
		msg='Password must contain at least one of: !,$,%,&,*,?,_,-,(,),<,>,=,/,:,;.';
	}
	for(var i = 0; i < p.length; i++) {
		if (!p.charAt(i).match(regExp)) {
			msg='Password may contain only A-Z, a-z, 0-9, and !$%&()`*+,-/:;<=>?_.';
		}
	}
	return msg;
}
function isdefined(variable)
{
return (!(!(document.getElementById(variable))))
}
function ahah(url, target, delay) {
  //alert('ahah');

  var req;
  document.getElementById(target).innerHTML = 'Fetching Data...';

  if (window.XMLHttpRequest) {
    req = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
  	//alert('ms');
    req = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (req != undefined) {
    req.onreadystatechange = function() {ahahDone(req, url, target, delay);};
    req.open("GET", url, true);
    req.send("");
  }

}  

function ahahDone(req, url, target, delay) {
//alert('ahahdone');
  if (req.readyState == 4) { // only if req is "loaded"
    if (req.status == 200) { // only if "OK"
      document.getElementById(target).innerHTML = req.responseText;
    } else {
      document.getElementById(target).innerHTML="ahah error:\n"+req.statusText;
    }
    if (delay != undefined) {
       setTimeout("ahah(url,target,delay)", delay); // resubmit after delay
	    //server should ALSO delay before responding
    }
  }
}
function is_number(a_string) {
tc = a_string.charAt(0);
if (tc == "0" || tc == "1" || tc == "2" || tc == "3" ||	tc == "4" || tc == "5" || tc == "6" || tc == "7" || tc == "8" || tc == "9") {
return true;
} 
else {
return false;
   }
}
// IF in a frame, remove header
function checkFrame() {
	alert('top' + top.location + ';d: ' + document.location);
	if (top.location!=document.location) {
		document.getElementById('header_color').style.display='none';
	}
}
// get documentation embedded in code tables
function getCtDoc(table,field) {
	var table;
	var field;
	var fullURL = "/info/ctDocumentation.cfm?table=" + table + "&field=" + field;
	ctDocWin=windowOpener(fullURL,"ctDocWin","width=700,height=400, resizable,scrollbars");
}
/*******************************************
	Manage popup windows
	Stolen from 
	http://www.codestore.net/store.nsf/unid/DOMM-4PYJ3S?OpenDocument
********************************************/
popupWins = new Array();
function windowOpener(url, name, args) {
/*******************************
the popupWins array stores an object reference for
each separate window that is called, based upon
the name attribute that is supplied as an argument
*******************************/
if ( typeof( popupWins[name] ) != "object" ){
popupWins[name] = window.open(url,name,args);
} else {
if (!popupWins[name].closed){
popupWins[name].location.href = url;
} else {
popupWins[name] = window.open(url, name,args);
}
}
popupWins[name].focus();
}
/**************************** End Manage popup windows *******************************/

/* function to call site-specific documentation ******************************************/
/*function getInstDocs(inst,url,anc) {
	var inst;
	var url;
	var anc;
	var baseUrl = "http://curator.museum.uaf.edu/" + inst + "/";
	var extension = ".shtml";
	var fullURL = baseUrl + url + extension;
		if (anc != null) {
			fullURL += "#" + anc;
		}
	siteHelpWin=windowOpener(fullURL,"siteHelpWin","width=700,height=400, resizable,scrollbars");
}
*/
function getInstDocs(inst,url,anc) {
	getDocs(url,anc);
}
/* function to call site-wide documentation ******************************************/
/*
function getDocs(url,anc) {
	var url;
	var anc;
	var baseUrl = "http://curator.museum.uaf.edu/arctosdoc/";
	var extension = ".shtml";
	var fullURL = baseUrl + url + extension;
		if (anc != null) {
			fullURL += "#" + anc;
		}
	siteHelpWin=windowOpener(fullURL,"siteHelpWin","width=700,height=400, resizable,scrollbars");
}
*/
function getDocs(url,anc) {
	var url;
	var anc;
	var baseUrl = "http://g-arctos.appspot.com/arctosdoc/";
	var extension = ".html";
	var fullURL = baseUrl + url + extension;
		if (anc != null) {
			fullURL += "#" + anc;
		}
	siteHelpWin=windowOpener(fullURL,"HelpWin","width=700,height=400, resizable,scrollbars,location,toolbar");
}
/* Function to call page-specific documentation ***********************************************/
/*function pageHelp(url,anc) {
	var url;
	var anc;
	var baseUrl = "http://curator.museum.uaf.edu/pageHelp/";
	var extension = ".shtml";
	var fullURL = baseUrl + url + extension;
		if (anc != null) {
			fullURL += "#" + anc;
		}
	pageHelpWin=windowOpener(fullURL,"pageHelpWin","width=700,height=400, resizable,scrollbars");
}
*/
function pageHelp(url,anc) {
	var url;
	var anc;
	var baseUrl = "/arctosdoc/pageHelp/";
	var extension = ".cfm";
	var fullURL = baseUrl + url + extension;
		if (anc != null) {
			fullURL += "#" + anc;
		}
	pageHelpWin=windowOpener(fullURL,"HelpWin","width=700,height=400, resizable,scrollbars,location,toolbar");
}
/*
	Function to see if there is a parent window with a non-default style sheet, 
	and get it for dependant frames if there is one
*/	
function getAllSheets() {
  //if you want ICEbrowser's limited support, do it this way
  if( !window.ScriptEngine && navigator.__ice_version ) {
  	//IE errors if it sees navigator.__ice_version when a window is closing
  	//window.ScriptEngine hides it from that
    return document.styleSheets; }
  if( document.getElementsByTagName ) {
    //DOM browsers - get link and style tags
    var Lt = document.getElementsByTagName('LINK');
    var St = document.getElementsByTagName('STYLE');
  } else if( document.styleSheets && document.all ) {
    //not all browsers that supply document.all supply document.all.tags
    //but those that do and can switch stylesheets will also provide
    //document.styleSheets (checking for document.all.tags produces errors [WHY?!])
    var Lt = document.all.tags('LINK'), St = document.all.tags('STYLE');
  } else { return []; } //lesser browser - return a blank array
  //for all link tags ...
  for( var x = 0, os = []; Lt[x]; x++ ) {
    //check for the rel attribute to see if it contains 'style'
    if( Lt[x].rel ) { var rel = Lt[x].rel;
    } else if( Lt[x].getAttribute ) { var rel = Lt[x].getAttribute('rel');
    } else { var rel = ''; }
    if( typeof( rel ) == 'string' &&
        rel.toLowerCase().indexOf('style') + 1 ) {
      //fill os with linked stylesheets
      os[os.length] = Lt[x];
    }
  }
  //include all style tags too and return the array
  for( var x = 0; St[x]; x++ ) { os[os.length] = St[x]; } return os;
}
function changeStyle() {
  for( var x = 0, ss = getAllSheets(); ss[x]; x++ ) {
    //for each stylesheet ...
    if( ss[x].title ) {
      //disable the stylesheet if it is switchable
      ss[x].disabled = true;
    }
    for( var y = 0; y < arguments.length; y++ ) {
      //check each title ...
      if( ss[x].title == arguments[y] ) {
        //and re-enable the stylesheet if it has a chosen title
        ss[x].disabled = false;
      }
    }
  }
  if( !ss.length ) { alert( 'Your browser cannot change stylesheets' ); }
}
if (self != top) 
	{
			if (parent.frames[0].thisStyle) 
				{
					changeStyle(parent.frames[0].thisStyle);
				}
	}
// end get parent stylesheet		

// function noenter prevents form submission when a user presses enter from a specific field.
// example:
//<input type="text" name="idBy" class="reqdClr" size="50" 
//	  onchange="getAgent('newIdById','idBy','newID',this.value); return false;"
//	  onKeyPress="return noenter(event);"> 
// note the '(event)' bit - that's required for FireFox to process this correctly
function noenter (e) 
	{
	var key;
	var keychar;
	var reg;
	
	if(window.event) {
		// for IE, e.keyCode or window.event.keyCode can be used
		key = e.keyCode; 
	}
	else if(e.which) {
		// netscape
		key = e.which; 
	}
	if (key == 13) {
			// enter
			return false;
	}
}
 // just fire off a warning and abort submit if they manage to get around a PICK doing it's thing
function gotAgentId (id)	{
					var id;
					var len = id.length;
					if (len == 0) {
					   	alert('Oops! A select box malfunctioned! Try changing the value and leaving with TAB. The background should change to green when you\'ve successfullly run the check routine.');
						return false;
					}
				}
				
 function checkUncheck(formName,CollObjValue)
 {
 	var newStr;
	 {
         //if ( document.remove.exclCollObjId.checked )
		 // this works if ( document.forms['remove'].exclCollObjId.checked )
		 if ( document.forms[formName].exclCollObjId.checked )
		  //if ( document["formName"].exclCollObjId.checked )
		 //orms[\\''\''+tid+\''\\''].eleme  [\''''+tid+''\''
		 	{
              newStr = document.reloadThis.exclCollObjId.value + "," + CollObjValue + ",";
			  document.reloadThis.exclCollObjId.value=newStr;
			  //alert(newStr);
			 }
         else
		 	{
              newStr=replaceSubstring(document.reloadThis.exclCollObjId.value, "," + CollObjValue + ",", "");
			  document.reloadThis.exclCollObjId.value=newStr;
			  //alert(newStr);
			 }
     }
 }


function movepic(img_name,img_src) {
document[img_name].src=img_src;
}

function chgCondition(collection_object_id) {
	var collection_object_id;
	helpWin=windowOpener("/picks/condition.cfm?collection_object_id="+collection_object_id,"conditionWin","width=800,height=338, resizable,scrollbars");
	}
	
	
function openpopup(agentIdFld,agentNameFld,formName){
var url="/picks/AgentPick.cfm";
var agentIdFld;
var agentNameFld;
var formName;
var popurl=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName;
agentpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function getAgent(agentIdFld,agentNameFld,formName,agentNameString,allowCreation){
var url="/picks/findAgent.cfm";
var agentIdFld;
var agentNameFld;
var formName;
var agentNameString;
var allowCreation;
var oawin=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName+"&agent_name="+agentNameString+"&allowCreation="+allowCreation;
agentpickwin=window.open(oawin,"","width=400,height=338, resizable,scrollbars");
}
function getProject(projIdFld,projNameFld,formName,projNameString){
var url="/picks/findProject.cfm";
var projIdFld;
var projNameFld;
var formName;
var projNameString;
var prwin=url+"?projIdFld="+projIdFld+"&projNameFld="+projNameFld+"&formName="+formName+"&project_name="+projNameString;
projpickwin=window.open(prwin,"","width=400,height=338, resizable,scrollbars");
}
function getCatalogedItem(collIdFld,CatCollFld,formName,oidType,oidNum,collCde){
var url="/picks/getCatalogedItem.cfm";
var collIdFld;
var CatCollFld;
var formName;
var oidType;
var oidNum;
var collCde;
var ciWin=url+"?collIdFld="+collIdFld+"&CatCollFld="+CatCollFld+"&formName="+formName+"&oidType="+oidType+"&oidNum="+oidNum+"&collCde="+collCde;
catItemWin=window.open(ciWin,"","width=400,height=338, resizable,scrollbars");
}
function findCatalogedItem(collIdFld,CatNumStrFld,formName,oidType,oidNum,collID){
var url="/picks/findCatalogedItem.cfm";
var collIdFld;
var CatCollFld;
var formName;
var oidType;
var oidNum;
var collCde;
var ciWin=url+"?collIdFld="+collIdFld+"&CatNumStrFld="+CatNumStrFld+"&formName="+formName+"&oidType="+oidType+"&oidNum="+oidNum+"&collID="+collID;
catItemWin=window.open(ciWin,"","width=400,height=338, resizable,scrollbars");
}
function findCollEvent(collIdFld,formName,dispField){
var url="/picks/findCollEvent.cfm";
var collIdFld;
var dispField;
var formName;
var covwin=url+"?collIdFld="+collIdFld+"&dispField="+dispField+"&formName="+formName;
ColPickwin=window.open(covwin,"","width=800,height=600, resizable,scrollbars");
}

function pickCollEvent(collIdFld,formName,collObjId){
var url="/picks/pickCollEvent.cfm";
var collIdFld;
var collObjId;
var formName;

var covwin=url+"?collIdFld="+collIdFld+"&collection_object_id="+collObjId+"&formName="+formName;
ColPickwin=window.open(covwin,"","width=800,height=600, resizable,scrollbars");
}

function getGeog(geogIdFld,geogStringFld,formName,geogString){
var url="/picks/findHigherGeog.cfm";
var geogIdFld;
var geogStringFld;
var formName;
var geogString;
var geogwin=url+"?geogIdFld="+geogIdFld+"&geogStringFld="+geogStringFld+"&formName="+formName+"&geogString="+geogString;
geogpickwin=window.open(geogwin,"","width=400,height=338, resizable,scrollbars");
}

function getHelp(help) {
	var help;
	helpWin=windowOpener("/info/help.cfm?content="+help,"helpWin","width=400,height=338, resizable,scrollbars");
	}

function confirmDelete(formName,msg) {
	var formName;
	var msg = msg || "this record";
	confirmWin=windowOpener("/includes/abort.cfm?formName="+formName+"&msg="+msg,"confirmWin","width=200,height=150,resizable");
	}
	
function getHistory(contID) {
	var idcontID;
	historyWin=windowOpener("/info/ContHistory.cfm?container_id="+contID,"historyWin","width=800,height=338, resizable,scrollbars");
	}


function getQuadHelp() {
	helpWin=windowOpener("/info/quad.cfm","quadHelpWin","width=800,height=600, resizable,scrollbars,status");
	}
	
	function getLegal(blurb) {
	var blurb;
	helpWin=windowOpener("/info/legal.cfm?content="+blurb,"legalWin","width=400,height=338, resizable,scrollbars");
	}
	
function getInfo(subject,id) {
	var subject;
	var id;
	//alert(id);
	
	infoWin=windowOpener("/info/SpecInfo.cfm?subject=" + subject + "&thisId="+id,"infoWin","width=800,height=500, resizable,scrollbars");
	}

	
function addLoanItem(coll_obj_id) {
	var coll_obj_id;
	loanItemWin=windowOpener("/user/loanItem.cfm?collection_object_id="+coll_obj_id,"loanItemWin","width=800,height=500, resizable,scrollbars,toolbar,menubar");
	}

function taxaPick(taxonIdFld,taxonNameFld,formName,scientificName){
var url="/picks/TaxaPick.cfm";
var taxonIdFld;
var taxonNameFld;
var formName;
var scientificName;
var popurl=url+"?taxonIdFld="+taxonIdFld+"&taxonNameFld="+taxonNameFld+"&formName="+formName+"&scientific_name="+scientificName;
taxapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function pubPick(pubIdFld,PubTxtFld,formName){
var url="/picks/PubPick.cfm";
var pubIdFld;
var PubTxtFld;
var formName;
var popurl=url+"?pubIdFld="+pubIdFld+"&PubTxtFld="+PubTxtFld+"&formName="+formName;
pubpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function CatItemPick(collIdFld,catNumFld,formName,sciNameFld){
var url="/picks/CatalogedItemPick.cfm";
var collIdFld;
var catNumFld;
var formName;
var sciNameFld;
var popurl=url+"?collIdFld="+collIdFld+"&catNumFld="+catNumFld+"&formName="+formName+"&sciNameFld="+sciNameFld;
taxapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function agentNamePick(agentIdFld,agentNameFld,formName){
var url="/picks/AgentNamePick.cfm";
var agentIdFld;
var agentNameFld;
var formName;
var popurl=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName;
agentpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function findAgentName(agentIdFld,agentNameFld,formName,agentNameString){
var url="/picks/findAgentName.cfm";
var agentIdFld;
var agentNameFld;
var formName;
var agentNameString;
var popurl=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName+"&agentName="+agentNameString;
agentpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function addrPick(addrIdFld,addrFld,formName){
var url="/picks/AddrPick.cfm";
var addrIdFld;
var addrFld;
var formName;
var popurl=url+"?addrIdFld="+addrIdFld+"&addrFld="+addrFld+"&formName="+formName;
addrpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}

function GeogPick(geogIdFld,highGeogFld,formName){
var url="/picks/GeogPick.cfm";
var geogIdFld;
var highGeogFld;
var formName;
var popurl=url+"?geogIdFld="+geogIdFld+"&highGeogFld="+highGeogFld+"&formName="+formName;
geogpick=window.open(popurl,"","width=600,height=600, toolbar,resizable,scrollbars,");
}

function LocalityPick(localityIdFld,speclocFld,formName,fireEvent){
var url="/picks/LocalityPick.cfm";
var localityIdFld;
var speclocFld;
var formName;
var fireEvent;
var popurl=url+"?localityIdFld="+localityIdFld+"&speclocFld="+speclocFld+"&formName="+formName+"&fireEvent="+fireEvent;
localitypick=window.open(popurl,"","width=800,height=600,resizable,scrollbars,");
}

// outdated button journal pick
function JournalPick(agentIdFld,agentNameFld,formName){
var url="/picks/JournalPick.cfm";
var journalIdFld;
var journalNameFld;
var formName;
var popurl=url+"?journalIdFld="+agentIdFld+"&journalNameFld="+agentNameFld+"&formName="+formName;
journalpick=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}
// new buttonless journal pick
function findJournal(journalIdFld,journalNameFld,formName,journalNameString){
var url="/picks/findJournal.cfm";
var journalIdFld;
var journalNameFld;
var formName;
var journalNameString;
var popurl=url+"?journalIdFld="+journalIdFld+"&journalNameFld="+journalNameFld+"&formName="+formName+"&journalName="+journalNameString;;
journalpick=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}
function deleteEncumbrance(encumbranceId,collectionObjectId){
var url="/picks/DeleteEncumbrance.cfm";
var encumbranceId;
var collectionObjectId;
var popurl=url+"?encumbrance_id="+encumbranceId+"&collection_object_id="+collectionObjectId;
deleteEncumbrance=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}


function pickpart(){
var popurl='CollObjPick.cfm';
collobjpick=window.open(popurl,"","width=400,height=338");
}

<!----- stylesheet switch ---->
function getAllSheets() {
  //if you want ICEbrowser's limited support, do it this way
  if( !window.ScriptEngine && navigator.__ice_version ) {
  	//IE errors if it sees navigator.__ice_version when a window is closing
  	//window.ScriptEngine hides it from that
    return document.styleSheets; }
  if( document.getElementsByTagName ) {
    //DOM browsers - get link and style tags
    var Lt = document.getElementsByTagName('LINK');
    var St = document.getElementsByTagName('STYLE');
  } else if( document.styleSheets && document.all ) {
    //not all browsers that supply document.all supply document.all.tags
    //but those that do and can switch stylesheets will also provide
    //document.styleSheets (checking for document.all.tags produces errors [WHY?!])
    var Lt = document.all.tags('LINK'), St = document.all.tags('STYLE');
  } else { return []; } //lesser browser - return a blank array
  //for all link tags ...
  for( var x = 0, os = []; Lt[x]; x++ ) {
    //check for the rel attribute to see if it contains 'style'
    if( Lt[x].rel ) { var rel = Lt[x].rel;
    } else if( Lt[x].getAttribute ) { var rel = Lt[x].getAttribute('rel');
    } else { var rel = ''; }
    if( typeof( rel ) == 'string' &&
        rel.toLowerCase().indexOf('style') + 1 ) {
      //fill os with linked stylesheets
      os[os.length] = Lt[x];
    }
  }
  //include all style tags too and return the array
  for( var x = 0; St[x]; x++ ) { os[os.length] = St[x]; } return os;
}
function changeStyle() {
  for( var x = 0, ss = getAllSheets(); ss[x]; x++ ) {
    //for each stylesheet ...
    if( ss[x].title ) {
      //disable the stylesheet if it is switchable
      ss[x].disabled = true;
    }
    for( var y = 0; y < arguments.length; y++ ) {
      //check each title ...
      if( ss[x].title == arguments[y] ) {
        //and re-enable the stylesheet if it has a chosen title
        ss[x].disabled = false;
      }
    }
  }
  if( !ss.length ) { alert( 'Your browser cannot change stylesheets' ); }
}
<!----- end stylesheet switch ------>

/***********************************************************************************************
 IsDate functionality
************************************************************************************************/

function isDate(DateToCheck){
if(DateToCheck==""){return true;}
var m_strDate = FormatDate(DateToCheck);
if(m_strDate==""){
return false;
}
var m_arrDate = m_strDate.split("/");
var m_DAY = m_arrDate[0];
var m_MONTH = m_arrDate[1];
var m_YEAR = m_arrDate[2];
if(m_YEAR.length > 4){return false;}
m_strDate = m_MONTH + "/" + m_DAY + "/" + m_YEAR;
var testDate=new Date(m_strDate);
if(testDate.getMonth()+1==m_MONTH){
return true;
} 
else{
return false;
}
}//end function

function fDateDmY(date){
	var format = 'dd-MMM-yyyy'
	format=format+"";
	var result="";
	var i_format=0;
	var c="";
	var token="";
	var y=date.getYear()+"";
	var M=date.getMonth()+1;
	var d=date.getDate();
	var E=date.getDay();
	var H=date.getHours();
	var m=date.getMinutes();
	var s=date.getSeconds();
	var yyyy,yy,MMM,MM,dd,hh,h,mm,ss,ampm,HH,H,KK,K,kk,k;
	var value=new Object();
	if(y.length < 4){
		y=""+(y-0+1900);
		}
		value["y"]=""+y;value["yyyy"]=y;
		value["yy"]=y.substring(2,4);
		value["M"]=M;
		value["MM"]=LZ(M);
		value["MMM"]=MONTH_NAMES[M-1];
		value["NNN"]=MONTH_NAMES[M+11];
		value["d"]=d;
		value["dd"]=LZ(d);
		value["E"]=DAY_NAMES[E+7];
		value["EE"]=DAY_NAMES[E];
		value["H"]=H;
		value["HH"]=LZ(H);if(H==0){
			value["h"]=12;
			}else if(H>12){
				value["h"]=H-12;
				}else{
					value["h"]=H;
					}
					value["hh"]=LZ(value["h"]);
					if(H>11){
						value["K"]=H-12;
						}else{
							value["K"]=H;}
							value["k"]=H+1;
							value["KK"]=LZ(value["K"]);
							value["kk"]=LZ(value["k"]);
							if(H > 11){
								value["a"]="PM";
								}else{
									value["a"]="AM";
									}
									value["m"]=m;
									value["mm"]=LZ(m);
									value["s"]=s;
									value["ss"]=LZ(s);
									while(i_format < format.length){
										c=format.charAt(i_format);
										token="";
										while((format.charAt(i_format)==c) &&(i_format < format.length)){
											token += format.charAt(i_format++);
											}
											if(value[token] != null){
												result=result + value[token];}
												else{
													result=result + token;}
													}return result;
													}


function FormatDate(DateToFormat,FormatAs){
if(DateToFormat==""){return"";}
if(!FormatAs){FormatAs="dd/mm/yyyy";}

var strReturnDate;
FormatAs = FormatAs.toLowerCase();
DateToFormat = DateToFormat.toLowerCase();
var arrDate
var arrMonths = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
var strMONTH;
var Separator;

while(DateToFormat.indexOf("st")>-1){
DateToFormat = DateToFormat.replace("st","");
}

while(DateToFormat.indexOf("nd")>-1){
DateToFormat = DateToFormat.replace("nd","");
}

while(DateToFormat.indexOf("rd")>-1){
DateToFormat = DateToFormat.replace("rd","");
}

while(DateToFormat.indexOf("th")>-1){
DateToFormat = DateToFormat.replace("th","");
}

if(DateToFormat.indexOf(".")>-1){
Separator = ".";
}

if(DateToFormat.indexOf("-")>-1){
Separator = "-";
}


if(DateToFormat.indexOf("/")>-1){
Separator = "/";
}

if(DateToFormat.indexOf(" ")>-1){
Separator = " ";
}

arrDate = DateToFormat.split(Separator);
DateToFormat = "";
	for(var iSD = 0;iSD < arrDate.length;iSD++){
		if(arrDate[iSD]!=""){
		DateToFormat += arrDate[iSD] + Separator;
		}
	}
DateToFormat = DateToFormat.substring(0,DateToFormat.length-1);
arrDate = DateToFormat.split(Separator);

if(arrDate.length < 3){
return "";
}

var DAY = arrDate[0];
var MONTH = arrDate[1];
var YEAR = arrDate[2];




if(parseFloat(arrDate[1]) > 12){
DAY = arrDate[1];
MONTH = arrDate[0];
}

if(parseFloat(DAY) && DAY.toString().length==4){
YEAR = arrDate[0];
DAY = arrDate[2];
MONTH = arrDate[1];
}


for(var iSD = 0;iSD < arrMonths.length;iSD++){
var ShortMonth = arrMonths[iSD].substring(0,3).toLowerCase();
var MonthPosition = DateToFormat.indexOf(ShortMonth);
	if(MonthPosition > -1){
	MONTH = iSD + 1;
		if(MonthPosition == 0){
		DAY = arrDate[1];
		YEAR = arrDate[2];
		}
	break;
	}
}

var strTemp = YEAR.toString();
if(strTemp.length==2){

	if(parseFloat(YEAR)>40){
	YEAR = "19" + YEAR;
	}
	else{
	YEAR = "20" + YEAR;
	}

}


	if(parseInt(MONTH)< 10 && MONTH.toString().length < 2){
	MONTH = "0" + MONTH;
	}
	if(parseInt(DAY)< 10 && DAY.toString().length < 2){
	DAY = "0" + DAY;
	}
	switch (FormatAs){
	case "dd/mm/yyyy":
	return DAY + "/" + MONTH + "/" + YEAR;
	case "mm/dd/yyyy":
	return MONTH + "/" + DAY + "/" + YEAR;
	case "dd/mmm/yyyy":
	return DAY + " " + arrMonths[MONTH -1].substring(0,3) + " " + YEAR;
	case "mmm/dd/yyyy":
	return arrMonths[MONTH -1].substring(0,3) + " " + DAY + " " + YEAR;
	case "dd/mmmm/yyyy":
	return DAY + " " + arrMonths[MONTH -1] + " " + YEAR;	
	case "mmmm/dd/yyyy":
	return arrMonths[MONTH -1] + " " + DAY + " " + YEAR;
	}

return DAY + "/" + strMONTH + "/" + YEAR;;

} //End Function
/***********************************************************************************************/
