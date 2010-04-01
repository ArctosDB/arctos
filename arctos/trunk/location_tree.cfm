<cfinclude template="/includes/alwaysInclude.cfm">
<div style="float:right; position:absolute; right:0; top:0;">
	<cfinclude template="container_nav.cfm">
</div>
<!----<cfset sql="SELECT container.container_id, container.parent_container_id, container_type, label FROM container,coll_obj_cont_hist,specimen_part,cataloged_item,identification WHERE container.container_id = coll_obj_cont_hist.container_id AND coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND cataloged_item.collection_object_id = identification.collection_object_id AND identification.accepted_id_fg = 1 AND upper(scientific_name)='SOREX YUKONICUS' ORDER BY container.container_id">

<cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
#preservesinglequotes(sql)#
</cfquery>
---->
<cfif #action# is "nothing">
<cfif not isdefined ("srch")>
	<cfset srch="part">
</cfif>
<cfset sel = "
SELECT 
	 container.container_id,
	 container.parent_container_id,
	 container_type,
	 label">
<cfset frm = "
	 FROM
	 container">
<cfset whr = " WHERE ">
	 <cfif #srch# is "Part">
	 <cfset frm = "#frm#,coll_obj_cont_hist,specimen_part,cataloged_item">
	 <cfset whr = "#whr# container.container_id = coll_obj_cont_hist.container_id 
	 				AND coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id
					AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id">
	 </cfif>
	 <cfif #srch# is "Container">
		 <cfset frm = "#frm#,fluid_container_history">	
		<cfset whr = "#whr# container.container_id = fluid_container_history.container_id (+)">
	 	<!--- don't need to add anything --->
	 </cfif>
 <!----

	  <cfset frm = "#frm#,coll_obj_cont_hist,specimen_part,cataloged_item,fluid_container_history">
	   <cfset whr = "#whr# container.container_id = coll_obj_cont_hist.container_id (+)
	 				AND coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id (+)
					AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id (+)
					AND container.container_id = fluid_container_history.container_id (+)">

	---->
	
<cfif isdefined("af_num")>
	<cfset aflist = "">
	<cfloop list="#af_num#" index="i">
					<cfif len(#aflist#) is 0>
						<cfset aflist = "'#i#'">
					<cfelse>
						<cfset aflist = "#aflist#,'#i#'">
					</cfif>
				</cfloop>
	<cfset frm = "#frm#,af_num">
	<cfset whr = "#whr# AND cataloged_item.collection_object_id = af_num.collection_object_id
		and af_num.af_num IN (#aflist#)">
</cfif>
 <cfif isdefined("cat_num")>
 	<cfset whr = "#whr# AND cataloged_item.cat_num IN (#cat_num#)">
 </cfif>
 <cfif isdefined("collection_cde")>
 	<cfset whr = "#whr# AND cataloged_item.collection_cde='#collection_cde#'">
 </cfif>

 
 <cfif isdefined("Tissue_Type")>
 	<cfset whr = "#whr# AND Tissue_Type='#Tissue_Type#'">
 </cfif>
 <cfif isdefined("Part_Name")>
 	<cfset whr = "#whr# AND part_Name='#part_Name#'">
 </cfif>
 <cfif isdefined("Scientific_Name")>
 	<cfset frm = "#frm#,identification">
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id = identification.collection_object_id
					AND identification.accepted_id_fg = 1 
					AND upper(Scientific_Name) like '%#ucase(Scientific_Name)#%'">
 </cfif>
 <cfif isdefined("container_label")>
 	<cfif isdefined("wildLbl") and #wildLbl# is 1>
			<cfset whr = "#whr# AND upper(label) LIKE '%#ucase(container_label)#%'">
		<cfelse>
			<cfset whr = "#whr# AND label = '#container_label#'">
	</cfif>
 
 </cfif>
 <cfif isdefined("description")>
 	<cfif isdefined("wildLbl") and #wildLbl# is 1>
			<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
		<cfelse>
			<cfset whr = "#whr# AND description='#description#'">
	</cfif>
	
	
 </cfif>
 <cfif isdefined("collection_object_id")>
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
 </cfif>
 <cfif isdefined("barcode")>
 <cfset bclist = "">
	<cfloop list="#barcode#" index="i">
					<cfif len(#bclist#) is 0>
						<cfset bclist = "'#i#'">
					<cfelse>
						<cfset bclist = "#bclist#,'#i#'">
					</cfif>
				</cfloop>
 	<cfset whr = "#whr# AND barcode IN (#bclist#)">
 </cfif>
 <cfif isdefined("container_type")>
 	<cfset whr = "#whr# AND container_type='#container_type#'">
 </cfif>
 <cfif isdefined("container_remarks")>
 <cfset whr = "#whr# AND container_remarks like '%#ucase(container_remarks)#%'">
 </cfif>
  <cfif isdefined("container_id")>
 	<cfset whr = "#whr# AND container.container_id=#container_id#">
 </cfif>
<cfif isdefined("loan_trans_id")>
 	<cfset frm = "#frm#,loan_item">
	<cfset whr = "#whr# AND loan_item.collection_object_id = specimen_part.collection_object_id	
		AND loan_item.transaction_id = #loan_trans_id#">
</cfif>
	
 <cfset sql = "#sel# #frm# #whr# ORDER BY label">
 <!----
<cfoutput>
 #preservesinglequotes(sql)#
 </cfoutput>
 <cfflush>
 ---->
 
 <cfif #whr# is " WHERE ">
 	<!--- WAITING FOR SEARCH TERMS --->
	<cfabort>
 </cfif>
 <cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" timeout="60">
 	#preservesinglequotes(sql)#
 </cfquery>
</cfif>
<!---------------- end search by container ---------------->
<!---------------- search by container_id (ie, for all the containers in a container
	from a previous search ---------------------------------->
<cfif #action# is "contentsSearch">
<cfset sql = "SELECT container_id  ,
parent_container_id,
	 container_type,
	 label
	FROM
	container
	WHERE
	parent_container_id=#container_id#
	order by label">
<cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" timeout="60">
 	#preservesinglequotes(sql)#
 </cfquery>
</cfif>
<!-------------------------- end contents search ----------------------->

<cfif #queriedFor.recordcount# is 0>
	Your search returned no records. Use your browser's back button to try again.
	<cfabort>
</cfif>
	<link rel="StyleSheet" href="/includes/dtree.css" type="text/css" />
	<script type="text/javascript" src="/includes/dtree.js"></script>
	<a href="/findContainer.cfm">New container search</a>
<div class="dtree">

	<p><a href="javascript: d.openAll();">open all</a> | <a href="javascript: d.closeAll();">close all</a></p>
	<cfset a="d.add(0,-1,'Part Locations');">
	<cfset placedContainers = ""> 
	<cfoutput>
	<cfloop query="queriedFor">
		<cfif not listfind(placedContainers,#container_id#)>
			<cfif #CONTAINER_TYPE# is "collection object">
				<cfset expand = "">
			<cfelse>
				<cfset expand = " <a href=""location_tree.cfm?container_id=#container_id#&action=contentsSearch""><img src=""/images/plus.gif""></a>">
			</cfif>
			<cfset a = "#a#
				d.add(#container_id#,#parent_container_id#,'#label# (#container_type#) #expand#','ContDet.cfm?container_id=#container_id#&objType=CollObj','','_detail');">
			<cfset placedContainers = listappend(placedContainers,#container_id#)> 
		</cfif>
		
		<cfquery name="thisRecord" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" timeout="60">
	select 
	CONTAINER_ID,
	PARENT_CONTAINER_ID,
	CONTAINER_TYPE,
	DESCRIPTION,
	PARENT_INSTALL_DATE,
	CONTAINER_REMARKS,
	barcode,
	label
	 from container
	start with container_id=#container_id#
	connect by prior parent_container_id = container_id 
	</cfquery>
		<cfloop query="thisRecord">
		<cfif not listfind(placedContainers,#container_id#)>
			<cfif #CONTAINER_TYPE# is "collection object">
				<cfset expand = "">
			<cfelse>
				<cfset expand = " <a href=""location_tree.cfm?container_id=#container_id#&action=contentsSearch""><img src=""/images/plus.gif""></a>">
			</cfif>
			<cfset a = "#a#
			d.add(#container_id#,#parent_container_id#,'#label# (#container_type#) [#barcode#] #expand#','ContDet.cfm?container_id=#container_id#&objType=CollObj','','_detail');">
		</cfif>
		<cfset placedContainers = listappend(placedContainers,#container_id#)> 
	</cfloop>
	
	</cfloop>
	<script type="text/javascript">
		d = new dTree('d');
		#a#
		document.write(d);
		d.openAll();
	</script>
	</cfoutput>
	</div>
<!----
	<script type="text/javascript">
		<!--

		d = new dTree('d');

		d.add(0,-1,'Part Locations');
		d.add(1,0,'Freezer','example01.html');
		d.add(2,1,'Stuff','example01.html');
		d.add(3,1,'Node 1.1','example01.html');
		d.add(4,0,'Node 3','example01.html');
		d.add(5,3,'Node 1.1.1','example01.html');
		d.add(6,5,'Node 1.1.1.1','example01.html');
		d.add(7,0,'Node 4','example01.html');
		d.add(8,1,'Node 1.2','example01.html');
		d.add(9,0,'My Pictures','example01.html','Pictures I\'ve taken over the years','','','img/imgfolder.gif');
		d.add(10,9,'The trip to Iceland','example01.html','Pictures of Gullfoss and Geysir');
		d.add(11,9,'Mom\'s birthday','example01.html');
		d.add(12,0,'Recycle Bin','example01.html','','','img/trash.gif');
		d.add(12,2,'More Stuff','example01.html','','','img/trash.gif');

		document.write(d);

		//-->
	</script>



<p><a href="mailto&#58;drop&#64;destroydrop&#46;com">&copy;2002-2003 Geir Landr&ouml;</a></p>

</body>

</html>
---->
 <cfif isdefined("sql") and len(#sql#) gt 0>
	 <form method="post" action="locDownload.cfm" target="_blank">
		<cfoutput>
			<input type="hidden" name="sql" value="#preservesinglequotes(sql)#">
			<input type="submit" 
				value="Download Summary" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
		</cfoutput>
	 </form>
	 <form method="post" action="locDownload2.cfm" target="_blank">
		<cfoutput>
			<input type="hidden" name="sql" value="#preservesinglequotes(sql)#">
			<input type="submit" 
				value="DLM" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
		</cfoutput>
	 </form>
 </cfif>
<cfinclude template="/includes/_pickFooter.cfm">
<script>
	var thePar = parent.location.href;
		var isFrame = thePar.indexOf('SpecimenDetail.cfm');
		if (isFrame != -1) {
			// we are a frame in SpecimenDetail
			// change style, resize holder
			changeStyle('#getItems.institution_acronym#');
			parent.dyniframesize();
			//alert('in specdetail');
		}
</script>