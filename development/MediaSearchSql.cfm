<cfif not isdefined("mapurl")>
	<cfset mapurl = "">
</cfif>
<cfif not isdefined("basQual")>
	<cfset basQual = "">
</cfif>


<cfif isdefined("srchType") and srchType is "key">
	<cfset mapurl="#mapurl#&srchType=#srchType#">

	<cfif isdefined("keyword") and len(keyword) gt 0>

		<cfif not isdefined("kwType")>
			<cfset kwType="all">
		</cfif>
		<cfif kwType is "any">
			<cfset kwsql="">
			<cfloop list="#keyword#" index="i" delimiters=",;: ">
				<cfset kwsql=listappend(kwsql,"upper(#mediaFlatTableName#.keywords) like '%#ucase(trim(i))#%'","|")>
			</cfloop>
			<cfset kwsql=replace(kwsql,"|"," OR ","all")>
			<cfset srch="#srch# AND ( #kwsql# ) ">
		<cfelseif kwType is "all">
			<cfset kwsql="">
			<cfloop list="#keyword#" index="i" delimiters=",;: ">
				<cfset kwsql=listappend(kwsql,"upper(#mediaFlatTableName#.keywords) like '%#ucase(trim(i))#%'","|")>
			</cfloop>
			<cfset kwsql=replace(kwsql,"|"," AND ","all")>
			<cfset srch="#srch# AND ( #kwsql# ) ">
		<cfelse>
			<cfset srch="#srch# AND upper(#mediaFlatTableName#.keywords) like '%#ucase(keyword)#%'">
		</cfif>
		<cfset terms="#keyword#">
		
		<cfset mapurl="#mapurl#&kwType=#kwType#&keyword=#keyword#">		
	</cfif>
	
	<cfif isdefined("media_uri") and len(media_uri) gt 0>
		<cfset srch="#srch# AND upper(#mediaFlatTableName#.media_uri) like '%#ucase(media_uri)#%'">
		<cfset mapurl="#mapurl#&media_uri=#media_uri#">
	</cfif>
	<cfif isdefined("tag") and len(tag) gt 0>
		<cfset whr="#whr# AND #mediaFlatTableName#.media_id IN (select media_id from tag)">
		<cfset mapurl="#mapurl#&tag=#tag#">
	</cfif>
	<cfif isdefined("media_type") and len(media_type) gt 0>
		<cfset srch="#srch# AND #mediaFlatTableName#.media_type IN (#listQualify(media_type,"'")#)">
		<cfset mapurl="#mapurl#&media_type=#media_type#">
	</cfif>
	
	<cfif isdefined("media_id") and len(#media_id#) gt 0>
		<cfset whr="#whr# AND #mediaFlatTableName#.media_id in (#media_id#)">
		<cfset mapurl="#mapurl#&media_id=#media_id#">
	</cfif>
	<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
		<cfset srch="#srch# AND #mediaFlatTableName#.mime_type in (#listQualify(mime_type,"'")#)">
		<cfset mapurl="#mapurl#&mime_type=#mime_type#">
	</cfif>
here is is: #mapurl#
<cfelse>

	<cfif isdefined("media_uri") and len(media_uri) gt 0>
		<cfset srch="#srch# AND upper(#mediaFlatTableName#.media_uri) like '%#ucase(media_uri)#%'">
		<cfset mapurl="#mapurl#&media_uri=#media_uri#">
	</cfif>
	<cfif isdefined("media_type") and len(media_type) gt 0>
		<cfset srch="#srch# AND upper(#mediaFlatTableName#.media_type) like '%#ucase(media_type)#%'">
		<cfset mapurl="#mapurl#&media_type=#media_type#">
	</cfif>
	<cfif isdefined("tag") and len(tag) gt 0>
		<cfset whr="#whr# AND #mediaFlatTableName#.media_id in (select media_id from tag)">
		<cfset mapurl="#mapurl#&tag=#tag#">
	</cfif>
	<cfif isdefined("media_id") and len(#media_id#) gt 0>
		<cfset whr="#whr# AND #mediaFlatTableName#.media_id in (#media_id#)">
		<cfset mapurl="#mapurl#&media_id=#media_id#">
	</cfif>
	<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
		<cfset srch="#srch# AND #mediaFlatTableName#.mime_type = '#mime_type#'">
		<cfset mapurl="#mapurl#&mime_type=#mime_type#">
	</cfif>
	
	<cfif not isdefined("number_of_relations")>
	    <cfif (isdefined("relationship") and len(relationship) gt 0) or (isdefined("related_to") and len(related_to) gt 0)>
			<cfset number_of_relations=1>
			<cfif isdefined("relationship") and len(relationship) gt 0>
				<cfset relationship__1=relationship>
			</cfif>
			 <cfif isdefined("related_to") and len(related_to) gt 0>
				<cfset related_value__1=related_to>
			</cfif>
		<cfelse>
			<cfset number_of_relations=1>
		</cfif>
	</cfif>
	<cfset mapurl="#mapurl#&number_of_relations=#number_of_relations#">
	
	<cfif not isdefined("number_of_labels")>
	    <cfif (isdefined("label") and len(label) gt 0) or (isdefined("label__1") and len(label__1) gt 0)>
			<cfset number_of_labels=1>
			<cfif isdefined("label") and len(label) gt 0>
				<cfset label__1=label>
			</cfif>
			<cfif isdefined("label_value") and len(label_value) gt 0>
				<cfset label_value__1=label_value>
			</cfif>
		<cfelse>
			<cfset number_of_labels=0>
		</cfif>
	</cfif>
	<cfset mapurl="#mapurl#&number_of_labels=#number_of_labels#">
	
	<cfloop from="1" to="#number_of_relations#" index="n">
		<cftry>
	        <cfset thisRelationship = #evaluate("relationship__" & n)#>
		    <cfcatch>
		        <cfset thisRelationship = "">
		    </cfcatch>
	    </cftry>
	    <cftry>
	        <cfset thisRelatedItem = #evaluate("related_value__" & n)#>
		    <cfcatch>
	            <cfset thisRelatedItem = "">
		    </cfcatch>
	    
	    </cftry>
	    <cftry>
	         <cfset thisRelatedKey = #evaluate("related_primary_key__" & n)#>
		    <cfcatch>
	            <cfset thisRelatedKey = "">
		    </cfcatch>
	    </cftry>
		<cfif len(#thisRelationship#) gt 0>
			<cfset srch="#srch# AND upper(#mediaFlatTableName#.media_relationships) like '%#ucase(thisRelationship)#%'">
			<cfset mapurl="#mapurl#&relationship__#n#=#thisRelationship#">
		</cfif>
		<cfif len(#thisRelatedItem#) gt 0>
			<cfset srch="#srch# AND upper(#mediaFlatTableName#.media_rel_values) like '%#ucase(thisRelatedItem)#%'">
			<cfset mapurl="#mapurl#&related_value__#n#=#thisRelatedItem#">
			<cfif len(terms) gt 0>
				<cfset terms=terms & ";" & thisRelatedItem>
			<cfelse>
				<cfset terms=thisRelatedItem>
			</cfif>
		</cfif>
	    <cfif len(#thisRelatedKey#) gt 0>
			<cfset srch="#srch# AND #mediaFlatTableName#.related_primary_keys like '%#thisRelatedKey#%'">
			<cfset mapurl="#mapurl#&related_primary_key__#n#=#thisRelatedKey#">
	    	<cfif len(terms) gt 0>
				<cfset terms=terms & ";" & thisRelatedKey>
			<cfelse>
				<cfset terms=thisRelatedKey>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfloop from="1" to="#number_of_labels#" index="n">
		<cftry>
	        <cfset thisLabel = #evaluate("label__" & n)#>
		    <cfcatch>
	            <cfset thisLabel = "">
		    </cfcatch>
        </cftry>
        <cftry>
	        <cfset thisLabelValue = #evaluate("label_value__" & n)#>
		    <cfcatch>
	            <cfset thisLabelValue = "">
		    </cfcatch>
        </cftry>		
        <cfif len(#thisLabel#) gt 0>
			<cfset srch="#srch# AND upper(#mediaFlatTableName#.media_labels) like '#ucase(thisLabel)#'">
			<cfset mapurl="#mapurl#&label__#n#=#thisLabel#">
		</cfif>
		<cfif len(#thisLabelValue#) gt 0>
			<cfset srch="#srch# AND upper(#mediaFlatTableName#.label_values) like '%#ucase(thisLabelValue)#%'">
			<cfset mapurl="#mapurl#&label_value__#n#=#thisLabelValue#">
			<cfif len(terms) gt 0>
				<cfset terms=terms & ";" & thisLabelValue>
			<cfelse>
				<cfset terms=thisLabelValue>
			</cfif>
		</cfif>
	</cfloop>
	<cfif len(srch) is 0>
		<div class="error">You must enter search criteria.</div>
		<cfabort> 
	</cfif>


</cfif><!--- end srchType --->

<!-- Limit results to 500 rows -->
<cfset srch = "#srch# AND rownum <= 500">

<!-- Allows bnhmMapData.cfm to see that this search is different from SpecimenSearch-->
<cfset mapurl="#mapurl#&search=MediaSearch">