<cfinclude template="/includes/_header.cfm">
<cfquery name="cData" datasource="#application.web_user#">
	 SELECT  
	 	level,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
		attribute
	FROM
		geology_attribute_hierarchy
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
<cfquery name="terms"  datasource="#application.web_user#">
	select geology_attribute_hierarchy_id,
	attribute from geology_attribute_hierarchy  order by attribute
</cfquery>
<form name="ins" method="post" action="geol_hierarchy.cfm">
	<input type="hidden" name="action" value="newTerm">
	<label for="newTerm">Insert Term</label>
	<input type="text" name="attribute">
	<input type="submit">
</form>
<form name="rel" method="post" action="geol_hierarchy.cfm">
	<input type="hidden" name="action" value="newReln">
	<label for="newTerm">Parent Term</label>
	<select name="parent">
		<cfloop query="terms">
			<option value="#attribute#">#attribute#</option>
		</cfloop>
	</select>
	<label for="newTerm">Child Term</label>
	<select name="child">
		<cfloop query="terms">
			<option value="#attribute#">#attribute#</option>
		</cfloop>
	</select>
	<input type="text" name="parent">
	<input type="submit">
</form>


<cfquery name="cData" datasource="#application.web_user#">
	 SELECT  
	 	level,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
		attribute
	FROM
		geology_attribute_hierarchy
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
<cfdump var="#cData#">
<cfinclude template="/includes/_footer.cfm">