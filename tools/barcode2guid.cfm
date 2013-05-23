<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif not isdefined("bc")><cfset bc =""></cfif>
	<cfif not isdefined("delim")><cfset delim =","></cfif>
	<form name="a" method="post" action="barcode2guid.cfm">
		<label for="bc">
			Enter barcodes here
		</label>
		<textarea name="bc" id="bc" rows="20" cols="80">#bc#</textarea>
		<label for="delim">Barcodes delimited by....</label>
		<select name="delim" id="delim">
			<option <cfif delim is ","> selected="selected" </cfif>value=",">,</option>
			<option <cfif delim is "#chr(9)#"> selected="selected" </cfif>value="#chr(9)#">{tab}</option>
		</select>
		<br><input type="submit" value="get guids">
	</form>
	<cfif len(bc) gt 0>
		#bc#
	</cfif>
<!----
<cffunction name="getGuidByPartBarcode" access="remote">
	<cfargument name="barcode" type="any" required="yes">
	<cfquery name="d" datasource="uam_god">
		select 
			c.barcode,
			guid 
		from 
			flat,
			specimen_part,
			coll_obj_cont_hist,
			container p,
			container c 
		where 
			flat.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=p.container_id and
			p.parent_container_id=c.container_id and
			c.barcode in (#ListQualify(barcode, "'")#)
	</cfquery>
	<cfreturn d>
</cffunction>

----->
</cfoutput>
<cfinclude template="/includes/_footer.cfm">