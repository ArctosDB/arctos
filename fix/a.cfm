<cfinclude template="/includes/_header.cfm">
<cfoutput>
	
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
	
<script src="/includes/jquery/jqGrid/js/jquery.ui.all.js" type="text/javascript"></script>


<link rel="stylesheet" type="text/css" media="screen" href="/includes/jquery/jqGrid/themes/basic/grid.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="/includes/jquery/jqGrid/themes/jqModal.css" /> 
<script src="/includes/jquery/jquery.js" type="text/javascript"></script> 
<script src="/includes/jquery/jqGrid/jquery.jqGrid.js" type="text/javascript"></script> 
<script src="/includes/jquery/jqGrid/js/jqModal.js" type="text/javascript"></script> 
<script src="/includes/jquery/jqGrid/js/jqDnR.js" type="text/javascript"></script> 
<script type="text/javascript"> 
jQuery(document).ready(function(){  
  jQuery("##list").jqGrid({ 
    url:'example.php', 
    datatype: 'xml', 
    mtype: 'GET', 
    colNames:['Inv No','Date', 'Amount','Tax','Total','Notes'], 
    colModel :[  
      {name:'invid', index:'invid', width:55},  
      {name:'invdate', index:'invdate', width:90},  
      {name:'amount', index:'amount', width:80, align:'right'},  
      {name:'tax', index:'tax', width:80, align:'right'},  
      {name:'total', index:'total', width:80, align:'right'},  
      {name:'note', index:'note', width:150, sortable:false} ], 
    pager: jQuery('#pager'), 
    rowNum:10, 
    rowList:[10,20,30], 
    sortname: 'id', 
    sortorder: "desc", 
    viewrecords: true, 
    imgpath: 'themes/basic/images', 
    caption: 'My first grid' 
  });  
});  
</script> 

<table id="list" class="scroll"></table>  
<div id="pager" class="scroll" style="text-align:center;"></div>  

</cfoutput>