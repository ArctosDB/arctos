<cfinclude template="/includes/_header.cfm">
<style>
	.good{background-color:#00FF00;}
	.mebbe{background-color:#FFFF00;}
	.bad{background-color:#FF0000;}
</style>
 
<!----
	checks containers in table cf_temp_container_location,
	which must be populated prior to calling this application,
	for validity, availability, etc.
	
	Include it with a cfinclude tag
	
---->
<!---- get the scans we care about ---->
<cfif #action# is "makeParentLabelsUnknown">
<cfquery name="isParentLabel" datasource="#Application.uam_dbo#">
	select container_type,container.container_id
	 from cf_temp_container_location,container
	  where container.container_id = cf_temp_container_location.parent_container_id
	  and upper(container_type) like '%LABEL%' 
</cfquery>
<cfoutput>
	<cfloop query="isParentLabel">
		<cfquery name="upCont" datasource="#Application.uam_dbo#">
			update container set container_type='unknown'
			where container_id=#container_id#
		</cfquery>
	</cfloop>
	<cflocation url="checkContainerMovement.cfm" addtoken="no">
</cfoutput>
</cfif>

<!---------------------------------------------------->
<cfif #action# is "deleteSelected">
	<cfoutput>
		<cfquery name="alterSessoin" datasource="#Application.uam_dbo#">
			ALTER SESSION set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'
		</cfquery>
		#delPair#
		<hr>
		<cfloop list="#delPair#" delimiters="," index="p">
			#p#<br />
			<cfset cid = listgetat(p,1,"|")>
			<cfset pid = listgetat(p,2,"|")>
			<cfset ts = listgetat(p,3,"|")>
			cid:#cid#<br />
			pid:#pid#<br />
			ts:#ts#<br />
			<hr />
			delete from cf_temp_container_location where
				container_id=#cid# and
				parent_container_id=#pid# and
				timestamp='#ts#'
				<cfquery name="DIE" datasource="#Application.uam_dbo#">
				delete from cf_temp_container_location where
				container_id=#cid# and
				parent_container_id=#pid# and
				timestamp='#ts#'
			</cfquery>
				<!---
			
			
			
			--->
		</cfloop>
		<cflocation url="checkContainerMovement.cfm" addtoken="no">
		
	</cfoutput>
</cfif>

<!---------------------------------------------------->
<cfif #action# is "loadEverything">
	<cftry>
		<cftransaction>
			<cfquery name="alterSessoin" datasource="#Application.uam_dbo#">
				ALTER SESSION set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'
			</cfquery>
			<cfquery name="data" datasource="#Application.uam_dbo#">
				select * from cf_temp_container_location
			</cfquery>
			<cfloop query="data">
				<cfquery name="insThis" datasource="#Application.uam_dbo#">
					UPDATE container SET
						parent_container_id = #parent_container_id#,
						parent_install_date='#dateformat(timestamp,"DD-MMM-YYYY")# #timeformat(timestamp,"HH:mm:ss")#'
					WHERE
						container_id=#container_id#
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="checkContainerMovement.cfm" addtoken="no">
	<cfcatch>
		Yikes! Something hinky happened. 
		<cfoutput>
			<p>#cfcatch.Message#
				<br />#cfcatch.Detail#
			</p>
		</cfoutput>
	</cfcatch>
	</cftry>
</cfif>
<!---------------------------------------------------->
<cfif #action# is "deleteEverything">
	<cfquery name="diediedie" datasource="#Application.uam_dbo#">
		delete from cf_temp_container_location
	</cfquery>
	<cflocation url="checkContainerMovement.cfm" addtoken="no">
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #action# is "deleteLoaded">
	<cfquery name="delAlreadyLoaded" datasource="#Application.uam_dbo#">
		delete from cf_temp_container_location where (
			container_id,
			parent_container_id,
			to_char(timestamp,'DD-MON-YYYY HH24:MI:SS'))
		IN (
			select container_id,
			parent_container_id,
			to_char(parent_install_date,'DD-MON-YYYY HH24:MI:SS')
			FROM container
			)			
	</cfquery>
	<cflocation url="checkContainerMovement.cfm">
</cfif>


<!----------------------------------------------------------------------------------->
<cfif #action# is "makeChildLabelsUnknown">

<cfquery name="isChildLabel" datasource="#Application.uam_dbo#">
	select 
		container_type,
		container.container_id,
		label		
	 from cf_temp_container_location,container
	  where container.container_id = cf_temp_container_location.container_id
	  and upper(container_type) like '%LABEL%' 
</cfquery>
<cfoutput>
	<cfloop query="isChildLabel">
		<cfquery name="upCont" datasource="#Application.uam_dbo#">
			update container set container_type='#container_type#'
			where container_id=#container_id#
		</cfquery>
	</cfloop>
	<cflocation url="checkContainerMovement.cfm">
</cfoutput>

</cfif>
<!----------------------------------------------------------------------------------->
<cfif #action# is "nothing">
<cfset thisIsBad = "">

<cfoutput>
<!--- kill true duplicates --->
<cftry>
	<cfquery name="byenow" datasource="#Application.uam_dbo#">
		drop table cf_temp_container_location_two
	</cfquery>
	<cfcatch>bahhh</cfcatch>
</cftry>
	<cftransaction>
		<cfquery name="bethere" datasource="#Application.uam_dbo#">
			create table cf_temp_container_location_two as select * from cf_temp_container_location
		</cfquery>
		<cfquery name="beGone" datasource="#Application.uam_dbo#">
			delete from cf_temp_container_location
		</cfquery>
		<cfquery name="noDups" datasource="#Application.uam_dbo#">
			insert into cf_temp_container_location (
				 CONTAINER_ID,
				 PARENT_CONTAINER_ID,
				 TIMESTAMP) 
				 select   
				 	CONTAINER_ID,
				 PARENT_CONTAINER_ID,
				 TIMESTAMP
				FROM
					cf_temp_container_location_two
					group by   CONTAINER_ID,
				 PARENT_CONTAINER_ID,
				 TIMESTAMP
		</cfquery>
	</cftransaction>
	<cfquery name="ctcontainer_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select container_type from ctcontainer_type
		where container_type <> 'collection object'
	</cfquery>
<cfquery name="isChildLabel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		container_type,
		container.container_id,
		label		
	 from cf_temp_container_location,container
	  where container.container_id = cf_temp_container_location.container_id
	  and upper(container_type) like '%LABEL%' 
</cfquery>
	<cfif #isChildLabel.recordcount# gt 0>
		<cfset thisIsBad = "bad">
		<div class="bad">
		The following child containers are labels:
		<cfloop query="isChildLabel">
			<br />
				<a href="EditContainer.cfm?container_id=#container_id#">#label# (#container_type#)</a>
		</cfloop>
		<p>
		Read the data above. Really! Check a couple of them. If there are only a few and you know what they should be, 
		change them.
	</p>
	</div>
	<div class="mebbe">
	Change all these containers to type:
	<form name="newType" method="post" action="checkContainerMovement.cfm">
		<input type="hidden" name="action" value="makeChildLabelsUnknown" />
		<select name="container_type" size="1">
			<cfloop query="ctcontainer_type">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<input type="submit" value="Change All" class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
		</form>
	</form>
	
	</div>
	<cfelse>
		<div class="good">
		There are no child containers of type label. 
		</div>
	</cfif>
	<hr />
	
	<cfquery name="isParentLabel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select container_type,container.container_id,label
	 from cf_temp_container_location,container
	  where container.container_id = cf_temp_container_location.parent_container_id
	  and upper(container_type) like '%LABEL%' 
</cfquery>
	<cfif #isParentLabel.recordcount# gt 0>
		<cfset thisIsBad = "bad">
		<div class="bad">
		<br />The following parent containers are labels:
		<cfloop query="isParentLabel">
			<br />
				<a href="EditContainer.cfm?container_id=#container_id#">#isParentLabel.label# (#isParentLabel.container_type#)</a>
		</cfloop>
		<p>
		Read the data above. Really! Check a couple of them. If there are only a few and you know what they should be, 
		change them.
		</p>
		</div>
		<div class="mebbe">	
	If you're really really sure you want to, <a href="checkContainerMovement.cfm?action=makeParentLabelsUnknown">click here</a>
	to change them all to containers_type='unknown'.	
		</div>
	<cfelse>
		<div class="good">
		There are no parent containers of type label. 
		</div>
	</cfif>
<hr />	



<cfquery name="dups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		CONTAINER_ID,
		count(CONTAINER_ID)
	from cf_temp_container_location 
	having count(CONTAINER_ID) > 1 
	group by CONTAINER_ID
</cfquery>
<br />There are #dups.recordcount# duplicate child records in cf_temp_container_location. 
<cfset dupId = valuelist(dups.container_id)>
<cfif #dups.recordcount# gt 0>
	You may continue, but there are no guarantees about where they'll end up! Locations are NOT sorted by date.
	<cfquery name="dupDetail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
		CONTAINER_ID,
		get_container_barcode(container_id) child_barcode,
		parent_container_id,
		get_container_barcode(parent_container_id) parent_barcode,
		timestamp
	from cf_temp_container_location 
	where container_id IN (#dupId#)
	order by container_id, timestamp
	</cfquery>
	<table border>
	<tr>
		<td>Parent barcode</td>
		<td>Duplicate Child barcode</td>
		<td>Timestamp</td>
	</tr>
	<cfloop query="dupDetail">
		<tr>
			<td><a href="EditContainer.cfm?container_id=#parent_container_id#">#parent_barcode#</a></td>
			<td><a href="EditContainer.cfm?container_id=#CONTAINER_ID#">#child_barcode#</a></td>
			<td>#dateformat(timestamp,"dd mmm yyyy")# #timeformat(timestamp,"hh:mm:ss")#</td>
		</tr>
	</cfloop>
	</table>
</cfif>
<hr />



<cfquery name="howMany" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT container_id, parent_container_id, timestamp FROM cf_temp_container_location
	group by
	container_id, parent_container_id, timestamp 
</cfquery>
<cfquery name="isMatches" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		cf_temp_container_location.container_id,
		cf_temp_container_location.parent_container_id,
		to_char(cf_temp_container_location.timestamp,'DD-MON-YYYY HH24:MI:SS') timestamp,
		get_container_barcode(cf_temp_container_location.container_id) child_barcode,
		get_container_barcode(cf_temp_container_location.parent_container_id) parent_barcode
	FROM
		cf_temp_container_location,
		container
	WHERE
		cf_temp_container_location.container_id = container.container_id AND
		cf_temp_container_location.parent_container_id = container.parent_container_id AND
		to_char(cf_temp_container_location.timestamp,'DD-MON-YYYY HH24:MI:SS') = to_char(container.parent_install_date,'DD-MON-YYYY HH24:MI:SS')
	GROUP BY
		cf_temp_container_location.container_id,
		cf_temp_container_location.parent_container_id,
		to_char(cf_temp_container_location.timestamp,'DD-MON-YYYY HH24:MI:SS'),
		get_container_barcode(cf_temp_container_location.container_id)	,
		get_container_barcode(cf_temp_container_location.parent_container_id)
</cfquery>
	There are <strong>#howMany.recordcount#</strong> unique values in table cf_temp_container_location.
	<strong>#isMatches.recordcount#</strong> of these are already loaded.
	<cfif #isMatches.recordcount# gt 0>
		<form name="remLoaded" method="post" action="checkContainerMovement.cfm">
			<input type="hidden" name="action" value="deleteLoaded" />
		<input type="submit" value="Delete Loaded Records" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'">
		</form>
	<form name="d" method="post" action="checkContainerMovement.cfm">
		<input type="hidden" name="action" value="deleteSelected" />
	
		<table border>
			<tr>
				<td>Parent</td>
				<td>Child</td>
				<td>Date</td>
				<td>Die Die Die</td>
			</tr>
			<cfloop query="isMatches">
				<tr>
					<td>#parent_barcode#</td>
					<td>#child_barcode#</td>
					<td>#timestamp#</td>
					<td>
						<input type="checkbox" name="delPair" value="#container_id#|#parent_container_id#|#timestamp#" />
					</td>
				</tr>
			</cfloop>
		</table>
		<input type="submit" value="Delete Checked" class="delBtn"
	   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'">
		</form>
	</cfif>
<hr />



</cfoutput>


	
	
	
	
	<br />
	
<p>Potential Errors in Data: (Note: this table does NOT include errors listed above.)</p>
<table border>
	<tr>
		<td>Parent barcode</td>
		<td>Child barcode</td>
		<td>Problem</td>
		<td>Delete</td>
	</tr>
	<cfset globalError = "">
<cfquery name="scans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT container_id, parent_container_id, 
	to_char(timestamp,'DD-MON-YYYY HH24:MI:SS') timestamp	
	 FROM cf_temp_container_location
	group by
	container_id, parent_container_id, timestamp
</cfquery>
<form name="d_tab" method="post" action="checkContainerMovement.cfm">
		<input type="hidden" name="action" value="deleteSelected" />
<cfoutput query="scans">
	<cfset error="">
	<!--- we already have container_ids and a timestamp in date format;
		don't worry about checking that ---->
	<!--- get container info and check standard stoopidity ---->
	<cfquery name="child" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from container where container_id = #container_id#
	</cfquery>
	<cfquery name="parent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from container where container_id = #parent_container_id#
	</cfquery>
	
	<!---- see how the dimensions work.
	Ignore it unless there's a dimension for each container
		----->
		<cfif len(#child.width#) gt 0 and len(#parent.width#) gt 0>
			<cfif #child.width# gte #parent.width#>
				<cfset thisIsBad = "bad">
				<cfset error = "#error#; The child width is greater than the parent">
			</cfif>
		</cfif>
		
		<cfif len(#child.length#) gt 0 and len(#parent.length#) gt 0>
			<cfif #child.length# gte #parent.length#>
				<cfset thisIsBad = "bad">
				<cfset error = "#error#; The child length is greater than the parent">
			</cfif>
		</cfif>
		<!--- is the child position locked? ---->
		<cfif #child.locked_position# gt 0>
			<cfset thisIsBad = "bad">
			<cfset error = "#error#; The child is locked into position and cannot be moved.">
		</cfif>
		<!--- are they trying to put something in a collection object? ---->
		<cfif #parent.container_type# is "collection object">
			<cfset thisIsBad = "bad">
			<cfset error = "#error#; You are trying to put a container in a collection object!">
		</cfif>
		<cfif len(#error#) gt 0>
			<cfset globalError = "#globalError#; #error#">
			<cfset error = replace(error,"; ","","first")>
			<cfif len(#child.barcode#) gt 0>
				<cfset childLink = "<a href=""EditContainer.cfm?container_id=#child.container_id#"" target=""_blank"">#child.barcode#</a>">
			<cfelse>
				<cfset childLink = "<a href=""EditContainer.cfm?container_id=#child.container_id#"" target=""_blank"">#child.container_id#</a>">
			</cfif>
			<cfif len(#parent.barcode#) gt 0>
				<cfset parentLink = "<a href=""EditContainer.cfm?container_id=#parent.container_id#"" target=""_blank"">#parent.barcode#</a>">
			<cfelse>
				<cfset parentLink = "<a href=""EditContainer.cfm?container_id=#parent.container_id#"" target=""_blank"">#child.container_id#</a>">
			</cfif>
			<tr>
				
				<td>#parentLink#</td>
				<td>#childLink#</td>
				<td><font color="##FF0000">#error#</font></td>
				<td>
						<input type="checkbox" name="delPair" value="#container_id#|#parent_container_id#|#timestamp#" />
					</td>
			</tr>
		<cfelse>
			<tr>
				
				<td>#parent.barcode#</td>
				<td>#child.barcode#</td>
				<td>none</td>
				<td>
						<input type="checkbox" name="delPair" value="#container_id#|#parent_container_id#|#timestamp#" />
					</td>
			</tr>
		</cfif>
</cfoutput>
</table>
<input type="submit" value="Delete Checked" class="delBtn"
	   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'">
		</form>
<cfif len(#thisIsBad#) is 0>
	<form name="loadAll" method="post" action="checkContainerMovement.cfm">
		<input type="hidden" name="action" value="loadEverything" />
		<input type="submit" value="LOAD all Records" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
	</form>	
</cfif>
<p>&nbsp;</p>
<form name="remAll" method="post" action="checkContainerMovement.cfm">
		<input type="hidden" name="action" value="deleteEverything" />
		<input type="button" value="Delete ALL Records" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
   onclick="confirmDelete('remAll');">
	</form>
</cfif>
<cfinclude template="/includes/_footer.cfm">
