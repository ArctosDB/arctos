<cfinclude template="/includes/_header.cfm">
<cfset title='disposition vs remarks'>
<cfoutput>
<cfif action is "nothing">
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select collection,collection_id from collection order by collection	
	</cfquery>
	<cfquery name="disp" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select coll_obj_disposition from CTCOLL_OBJ_DISP order by coll_obj_disposition	
	</cfquery>
<form name="f" method="post" action="CatItemDispFix.cfm">
	<input type="hidden" name="action" value="go">
	<label for="collection_id">select collections</label>
	<select name="collection_id" multiple="multiple" size="10">
		<cfloop query="c">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<label for="disposition">catitem disposition</label>
	<select name="disposition" multiple="multiple" size="10">
		<cfloop query="disp">
			<option value="#coll_obj_disposition#">#coll_obj_disposition#</option>
		</cfloop>
	</select>
	<br><input type="submit">
</form>

</cfif>
<cfif action is "go">
		<script src="/includes/sorttable.js"></script>
<cfset sql="
			select
		    count(*) c,
		    collection.collection_id,
		   	collection.collection,
		    cco.coll_obj_disposition catitemdisp,
		    spo.coll_obj_disposition spdisp
		from
		    cataloged_item,
		    collection,
		    coll_object cco,
		    specimen_part,
		    coll_object spo
		where
		    cataloged_item.collection_id in (#collection_id#) and
		    cataloged_item.collection_id=collection.collection_id and
		    cataloged_item.collection_object_id=cco.collection_object_id and
		    cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
		    specimen_part.collection_object_id=spo.collection_object_id and
		    (
		        cco.coll_obj_disposition in (">
	<cfset sql=sql & listqualify(disposition,"'")>
	<cfset sql=sql & "
		       )) 
			group by
		    collection.collection_id,
		   	collection.collection,
		    cco.coll_obj_disposition,
		    spo.coll_obj_disposition">
	
	<div style="border:1px solid green;padding:1em;font-size:smaller">
		#sql#
	</div>
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<td>##Items</td>
			<td>catItemDispn</td>
			<td>PartDispn</td>
		</tr>
	<cfloop query="d">
		<tr>
			<td><a href="/SpecimenResults.cfm?collection_id=#collection_id#&coll_obj_disposition=#catitemdisp#&part_disposition=#spdisp#&debug=true">#c# #collection#</a></td>
			<td>#catitemdisp#</td>
			<td>#spdisp#</td>
		</tr>
	</cfloop>	
	</table>
</cfif>
	</cfoutput>

<cfinclude template="/includes/_footer.cfm">