<script type='text/javascript' language="javascript" src='jquery.jqGrid-3.6.5/js/jquery-1.4.2.min.js'></script>


<link rel="stylesheet" type="text/css" media="screen" href="jquery-ui-1.8.1.custom/css/smoothness/jquery-ui-1.8.1.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" href="ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" href="ui.multiselect.css" />

<script src="jquery.jqGrid-3.6.5/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="jquery.jqGrid-3.6.5/js/jquery.jqGrid.min.js" type="text/javascript"></script>


<div class="h">Search By:</div> <div>  
	<input type="checkbox" id="autosearch" onclick="enableAutosubmit(this.checked)"> Enable Autosearch <br/>  Code<br />  
	<input type="text" id="search_cd" onkeydown="doSearch(arguments[0]||event)" /> </div> <div>  Name<br>  
	<input type="text" id="item" onkeydown="doSearch(arguments[0]||event)" />  
	<button onclick="gridReload()" id="submitButton" style="margin-left:30px;">Search</button> </div> 

<br /> <table id="bigset"></table> <div id="pagerb"></div> 



<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {
		jQuery("#bigset").jqGrid({ 
			url:'gData.cfm', 
			datatype: "json", 
			height: 255, 
			colNames:['Index','Name', 'Code'], 
			colModel:[ 
				{name:'item_id',index:'item_id', width:65}, 
				{name:'item',index:'item', width:150}, 
				{name:'item_cd',index:'item_cd', width:100} 
			], 
			rowNum:12,
			// rowList:[10,20,30], 
			mtype: "POST", 
			pager: jQuery('#pagerb'), 
			pgbuttons: false, 
			pgtext: false, 
			pginput:false, 
			sortname: 'item_id', 
			viewrecords: true, 
			sortorder: "asc" 
		}); 
		
		
	});
	
	
	var timeoutHnd; 
		var flAuto = false; 
		
		function doSearch(ev){ 
			if(!flAuto) 
				return; 
			// var elem = ev.target||ev.srcElement; 
			if(timeoutHnd) 
				clearTimeout(timeoutHnd) 
			timeoutHnd = setTimeout(gridReload,500) 
		} 
		function gridReload(){ 
			var nm_mask = jQuery("#item_nm").val(); 
			var cd_mask = jQuery("#search_cd").val(); 
			jQuery("#bigset").jqGrid('setGridParam',{url:"gData.cfm?nm_mask="+nm_mask+"&cd_mask="+cd_mask,page:1}).trigger("reloadGrid"); 
		} 
		function enableAutosubmit(state){ 
				flAuto = state; 
				jQuery("#submitButton").attr("disabled",state); 
		} 
</script>

<!-------
<script>

	jQuery("#bigset").jqGrid({        
   	url:'gData.cfm',
	datatype: "json",
	height: 255,
   	colNames:['Index','Name', 'Code'],
   	colModel:[
   		{name:'item_id',index:'item_id', width:65},
   		{name:'item',index:'item', width:150},
   		{name:'item_cd',index:'item_cd', width:100}
   	],
   	rowNum:12,
//   	rowList:[10,20,30],
   	mtype: "POST",
   	pager: jQuery('#pagerb'),
   	pgbuttons: false,
   	pgtext: false,
   	pginput:false,
   	sortname: 'item_id',
    viewrecords: true,
    sortorder: "asc"
});
var timeoutHnd;
var flAuto = false;

function doSearch(ev){
	if(!flAuto)
		return;
//	var elem = ev.target||ev.srcElement;
	if(timeoutHnd)
		clearTimeout(timeoutHnd)
	timeoutHnd = setTimeout(gridReload,500)
}

function gridReload(){
	var nm_mask = jQuery("#item_nm").val();
	var cd_mask = jQuery("#search_cd").val();
	jQuery("#bigset").jqGrid('setGridParam',{url:"gData.cfm?nm_mask="+nm_mask+"&cd_mask="+cd_mask,page:1}).trigger("reloadGrid");
}
function enableAutosubmit(state){
	flAuto = state;
	jQuery("#submitButton").attr("disabled",state);
}
	
</script>

<div class="h">Search By:</div> 
<div>  
	<input type="checkbox" id="autosearch" onclick="enableAutosubmit(this.checked)"> 
	Enable Autosearch <br/>  
	Code<br />  
	<input type="text" id="search_cd" onkeydown="doSearch(arguments[0]||event)" /> 
</div> 
<div>  
	Name<br>  
	<input type="text" id="item" onkeydown="doSearch(arguments[0]||event)" />  
	<button onclick="gridReload()" id="submitButton" style="margin-left:30px;">Search</button> 
</div> 
<br /> 
<table id="bigset"></table> 
<div id="pagerb"></div> 



<table id="list2"></table> <div id="pager2"></div> 

<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {
		jQuery("#list2").jqGrid({ 
			url:'gData.cfm', 
			datatype: "json", 
			colNames:['Inv No','Date', 'Client', 'Amount','Tax','Total','Notes'], 
			colModel:[ {name:'id',index:'id', width:55}, 
				{name:'invdate',index:'invdate', width:90}, 
				{name:'name',index:'name asc, invdate', width:100}, 
				{name:'amount',index:'amount', width:80, align:"right"}, 
				{name:'tax',index:'tax', width:80, align:"right"}, 
				{name:'total',index:'total', width:80,align:"right"}, 
				{name:'note',index:'note', width:150, sortable:false} 
			], 
			rowNum:10, 
			rowList:[10,20,30], 
			pager: '#pager2', 
			sortname: 'id', 
			viewrecords: true, 
			sortorder: "desc", 
			caption:"JSON Example" 
		}); 
		jQuery("#list2").jqGrid('navGrid','#pager2',{edit:false,add:false,del:false});  
		
	});
</script>


--->
