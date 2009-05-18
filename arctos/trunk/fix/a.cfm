<cfinclude template="/includes/_header.cfm">
<cfoutput>
	

<link rel="stylesheet" type="text/css" media="screen" href="/includes/jquery/jqGrid/themes/basic/grid.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="/includes/jquery/jqGrid/themes/jqModal.css" /> 

<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script src="/includes/jquery/jqGrid/jquery.jqGrid.js" type="text/javascript"></script> 

<script src="/includes/jquery/jqGrid/js/jqModal.js" type="text/javascript"></script> 
<script src="/includes/jquery/jqGrid/js/jqDnR.js" type="text/javascript"></script> 
<script type="text/javascript"> 
jQuery(document).ready(function(){  
  jQuery("##list").jqGrid({ 
    url:'/fix/data.cfm', 
    datatype: 'json', 
    mtype: 'GET', 
   colModel:[ 
   {name:'name',label:'Name', width:150,editable: true}, 
   {name:'id',width:50, sorttype:"int", editable: true}, 
   {name:'email',label:'Email', width:150,editable: true,formatter:'email'}, 
   {name:'stock',label:'Stock', width:60, align:"center", editable: true,formatter:'checkbox',edittype:"checkbox"}, 
   {name:'item.price',label:'Price', width:100, align:"right", editable: true,formatter:'currency'}, 
   {name:'item.weight',label:'Weight',width:60, align:"right", editable: true,formatter:'number'}, 
   {name:'ship',label:'Ship Via',width:90, editable: true,formatter:'select', edittype:"select",            
editoptions:{value:"2:FedEx;1:InTime;3:TNT;4:ARK;5:ARAMEX"}},       
   {name:'note',label:'Notes', width:100, sortable:false,editable: true,edittype:"textarea", 
editoptions:{rows:"2",cols:"20"}} 
],
   
    colNames:['name','id', 'email','stock','Total','item.price','item.weight','ship'], 
   
    pager: jQuery('##pager'), 
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