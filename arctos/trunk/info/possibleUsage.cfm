<cfinclude template="/includes/_header.cfm">
<cfif actoun is "nothing">
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select collection,collection_id from collection order by collection	
	</cfquery>
	<cfquery name="disp" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select coll_obj_disposition from CTCOLL_OBJ_DISP order by coll_obj_disposition	
	</cfquery>

</cfif>
<form name="f" method="post" action="DispositionClash.cfm">
	<input type="hidden" name="action" value="go">
	<label for="collection_id">select collections</label>
	<select name="collection_id" multiple="multiple" size="10">
		<cfloop query="c">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<label for="disposition">disposition one of...</label>
	<select name="disposition" multiple="multiple" size="10">
		<cfloop query="disp">
			<option value="#coll_obj_disposition#">#coll_obj_disposition#</option>
		</cfloop>
	</select>
	<label for="remark">remarks like (comma-list, substring match)</label>
	<textarea name="remark">donat,transfer,loan,exchange</textarea>
	<br><input type="submit">
</form>

<cfif action is "go">
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
		    cat_num,
		    cco.coll_obj_disposition catitemdisp,
		    spo.coll_obj_disposition spdisp,
		    cir.coll_object_remarks cirem,
		    spr.coll_object_remarks sprem
		from
		    cataloged_item,
		    coll_object cco,
		    specimen_part,
		    coll_object spo,
		    coll_object_remark cir,
		    coll_object_remark spr
		where
		    cataloged_item.collection_id in (#collection_id#) and
		    cataloged_item.collection_object_id=cco.collection_object_id and
		    cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
		    specimen_part.collection_object_id=spo.collection_object_id and
		    specimen_part.collection_object_id=spr.collection_object_id (+) and
		    cataloged_item.collection_object_id=cir.collection_object_id (+) and
		    (
		        cco.coll_obj_disposition in (
		            #listqualify(disposition,"'")#
		        ) or
		        spo.coll_obj_disposition not in (
		            #listqualify(disposition,"'")#
		        )
		    ) and
		    (
		        <cfloop list="#remark#" index="i">
					cir.coll_object_remarks like '%#i#%' or
				</cfloop>
		        <cfloop list="#remark#" index="i">
					spr.coll_object_remarks like '%#i#%' or
				</cfloop>
				1=2
		    )
	</cfquery>
	<cfoutput>
	<table border>
		<tr>
			<td>cat_num</td>
			<td>catitemdisp</td>
			<td>spdisp</td>
			<td>cirem</td>
			<td>sprem</td>
		</tr>
	<cfloop query="d">
		<tr>
			<td>#cat_num#</td>
			<td>#catitemdisp#</td>
			<td>#spdisp#</td>
			<td>#cirem#</td>
			<td>#sprem#</td>
		</tr>
	</cfloop>	
	</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">