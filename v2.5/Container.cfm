 <cfoutput>
<!--- check all the variables we got from FindContainer and pass them to a frame via the URL ---> 
<cfif not isdefined("treeURL") OR len(#treeURL#) is 0>
	<cfset treeURL = "location_tree.cfm?">
</cfif>
<cfif not isdefined("srch") OR len(#srch#) is 0>
	<cfset srch = "part">
</cfif>


 <cfif isdefined("af_num")>
 	<cfif len(#af_num#) gt 0>
		<cfset treeURL = "#treeURL#&af_num=#af_num#">
	</cfif>
 </cfif>
  <cfif isdefined("container_type")>
 	<cfif len(#container_type#) gt 0>
		<cfset treeURL = "#treeURL#&container_type=#container_type#">
	</cfif>
 </cfif>
 <cfif isdefined("cat_num")>
 	<cfif len(#cat_num#) gt 0>
		<cfset treeURL = "#treeURL#&cat_num=#cat_num#">
	</cfif>
 </cfif>
 <cfif isdefined("collection_cde")>
 	<cfif len(#collection_cde#) gt 0>
		<cfset treeURL = "#treeURL#&collection_cde=#collection_cde#">
	</cfif>
 </cfif>
 <cfif isdefined("label")>
 	<cfif len(#label#) gt 0>
		<cfset treeURL = "#treeURL#&label=#label#">
	</cfif>
 </cfif>
 <cfif isdefined("collection_object_id")>
 	<cfif len(#collection_object_id#) gt 0>
		<cfset treeURL = "#treeURL#&collection_object_id=#collection_object_id#">
	</cfif>
 </cfif>
  <cfif isdefined("Tissue_Type")>
 	<cfif len(#Tissue_Type#) gt 0>
		<cfset treeURL = "#treeURL#&Tissue_Type=#Tissue_Type#">
	</cfif>
 </cfif>
 <cfif isdefined("Scientific_Name")>
 	<cfif len(#Scientific_Name#) gt 0>
		<cfset treeURL = "#treeURL#&Scientific_Name=#Scientific_Name#">
	</cfif>
 </cfif>
 <cfif isdefined("part_name")>
 	<cfif len(#part_name#) gt 0>
		<cfset treeURL = "#treeURL#&part_name=#part_name#">
	</cfif>
 </cfif>
 <cfif isdefined("container_label")>
 	<cfif len(#container_label#) gt 0>
		<cfset treeURL = "#treeURL#&container_label=#container_label#">
	</cfif>
 </cfif>
 <cfif isdefined("description")>
 	<cfif len(#description#) gt 0>
		<cfset treeURL = "#treeURL#&description=#description#">
	</cfif>
 </cfif>
 <cfif isdefined("barcode")>
 	<cfif len(#barcode#) gt 0>
		<cfset treeURL = "#treeURL#&barcode=#barcode#">
	</cfif>
 </cfif>
 <cfif isdefined("container_remarks")>
 	<cfif len(#container_remarks#) gt 0>
		<cfset treeURL = "#treeURL#&container_remarks=#container_remarks#">
	</cfif>
 </cfif>
<cfif isdefined("wildLbl")>
 	<cfif len(#wildLbl#) gt 0>
		<cfset treeURL = "#treeURL#&wildLbl=#wildLbl#">
	</cfif>
 </cfif>
<cfif isdefined("loan_trans_id")>
 	<cfif len(#loan_trans_id#) gt 0>
		<cfset treeURL = "#treeURL#&loan_trans_id=#loan_trans_id#">
	</cfif>
 </cfif>
 <cfset treeURL = "#treeURL#&srch=#srch#">

<frameset rows="18%,82%">
	<frame src="/includes/_header.cfm" name="_header">
	<frameset cols="50%,50%">
<frame src="#treeURL#" name="_tree">
<cfif #treeURL# contains "location_tree.cfm?">
	<frame name="_detail" src="/ContDet.cfm">
	<cfelseif #treeURL# contains "ContainerGrid.cfm?">
	<frame name="_detail" src="/location_tree.cfm">
</cfif>

</frameset>
	</frameset>
</frameset>



<frameset cols="70%,30%">
<frame src="#treeURL#" name="_tree">
<cfif #treeURL# contains "location_tree.cfm?">
	<frame name="_detail" src="/ContDet.cfm">
	<cfelseif #treeURL# contains "ContainerGrid.cfm?">
	<frame name="_detail" src="/location_tree.cfm">
</cfif>

</frameset><noframes>Ya gotta use frames. Get a real browser.</noframes>

</cfoutput>