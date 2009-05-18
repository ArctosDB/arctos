<cfinclude template="/includes/_header.cfm">

	

<link rel="stylesheet" type="text/css" media="screen" href="/includes/jquery/jqGrid/themes/basic/grid.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="/includes/jquery/jqGrid/themes/jqModal.css" /> 

<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script src="/includes/jquery/jqGrid/jquery.jqGrid.js" type="text/javascript"></script> 

<script src="/includes/jquery/jqGrid/js/jqModal.js" type="text/javascript"></script> 
<script src="/includes/jquery/jqGrid/js/jqDnR.js" type="text/javascript"></script> 
<script type="text/javascript"> 
jQuery("#list2").jqGrid({
   	url:'/fix/data.cfm',
	datatype: "json",
   	colNames:['Inv No','Date', 'Client', 'Amount','Tax','Total','Notes'],
   	colModel:[
   		{name:'id',index:'id', width:55},
   		{name:'invdate',index:'invdate', width:90},
   		{name:'name',index:'name asc, invdate', width:100},
   		{name:'amount',index:'amount', width:80, align:"right"},
   		{name:'tax',index:'tax', width:80, align:"right"},		
   		{name:'total',index:'total', width:80,align:"right"},		
   		{name:'note',index:'note', width:150, sortable:false}		
   	],
   	rowNum:10,
   	rowList:[10,20,30],
   	imgpath: gridimgpath,
   	pager: jQuery('#pager2'),
   	sortname: 'id',
    viewrecords: true,
    sortorder: "desc",
    caption:"JSON Example"
}).navGrid('#pager2',{edit:false,add:false,del:false});
 
</script> 

<table id="list" class="scroll"></table>  
<div id="pager" class="scroll" style="text-align:center;"></div>  

