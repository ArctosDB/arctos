<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
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
<cfoutput >
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
			<option value="#geology_attribute_hierarchy_id#">#attribute#</option>
		</cfloop>
	</select>
	<label for="newTerm">Child Term</label>
	<select name="child">
		<cfloop query="terms">
			<option value="#geology_attribute_hierarchy_id#">#attribute#</option>
		</cfloop>
	</select>
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
	start with parent_id is null
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
<cfloop query="cData">
	<cfset p=#level# * 50>
	<div style="margin-left:#p#;border:1px dotted red;">
		#attribute# (#level#)
	</div>
</cfloop>
</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #action# is "newTerm">
	<cfoutput>
	<cfquery name="changeGeog" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		insert into geology_attribute_hierarchy (attribute) values ('#attribute#')
	</cfquery>
	<cflocation url="geol_hierarchy.cfm" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #action# is "newReln">
	<cfoutput>
	<cfquery name="changeGeog" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		update geology_attribute_hierarchy set parent_id=#parent# where geology_attribute_hierarchy_id=#child#
	</cfquery>
	<cflocation url="geol_hierarchy.cfm" addtoken="false">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">