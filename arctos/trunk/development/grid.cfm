<script type='text/javascript' language="javascript" src='jquery.jqGrid-3.6.5/js/jquery-1.4.2.min.js'></script>
<script src="jquery.jqGrid-3.6.5/js/jquery.jqGrid.min.js" type="text/javascript"></script>


<script>

	jQuery("#bigset").jqGrid({        
   	url:'bigset.php',
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
	jQuery("#bigset").jqGrid('setGridParam',{url:"bigset.php?nm_mask="+nm_mask+"&cd_mask="+cd_mask,page:1}).trigger("reloadGrid");
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
<script src="bigset.js" type="text/javascript"> </script> 