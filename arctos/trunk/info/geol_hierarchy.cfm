<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfset title="Geology Attribute Hierarchy">
<cfquery name="cData" datasource="#application.web_user#">
	 SELECT  
	 	level,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
	 	usable_value_fg,
   		attribute_value || ' (' || attribute || ')' attribute
	FROM
		geology_attribute_hierarchy
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
<cfquery name="terms"  datasource="#application.web_user#">
	select geology_attribute_hierarchy_id,
	attribute_value || ' (' || attribute || ')' attribute
	 from geology_attribute_hierarchy  order by attribute
</cfquery>

<cfoutput>
New Term:
<form name="ins" method="post" action="geol_hierarchy.cfm">
	<input type="hidden" name="action" value="newTerm">
	<label for="newTerm">Attribute ("formation")</label>
	<input type="text" name="attribute">
	<label for="newTerm">Value ("Prince Creek")</label>
	<input type="text" name="attribute_value">
	<label for="newTerm">Attribute Valid for Data Entry></label>
	<select name="usable_value_fg" id="usable_value_fg">
		<option value="0">no</option>
		<option value="1">yes</option>
	</select>
	<br>
	<input type="submit" value="Insert Term">
</form>
<br>
Create Hierarchies:
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
<br>Current Data (values in red are NOT code table values but may still be used in searches):
<cfset levelList = "">
<cfloop query="cData">
	

   <!--- Is the last value in the list this level? --->
   <cfif listLast(levelList,",") IS NOT cData.level>
      <!--- Is this level in the levelList?
          If so, we need to close previous level down to this one now. --->
      <cfset levelListIndex = listFind(levelList,cData.level,",")>
      <cfif levelListIndex IS NOT 0>
         <cfset numberOfLevelsToRemove = listLen(levelList,",") - levelListIndex>
         <cfloop from="1" to="#numberOfLevelsToRemove#" index="i">
            <!--- Shorten the list to the appropriate level --->
            <cfset levelList = listDeleteAt(levelList,listLen(levelList,","))>
         </cfloop>
         #repeatString("</ul>",numberOfLevelsToRemove)#
      <cfelse>
         <!--- Not in list, so start a new list level --->
         <cfset levelList = listAppend(levelList,cData.level)>
         <ul>
      </cfif>
   </cfif>

  <li><span
	<cfif not listfindnocase(valuelist(ctgeology_attribute.geology_attribute),attribute)>
		  style="color:red"
	</cfif>
	>#attribute#</span></li>

   <!--- If this is the last row, then we need to close all unordered lists --->
   <cfif cData.currentRow IS cData.recordCount>
      #repeatString("</ul>",listLen(levelList,","))#
   </cfif>


	
	
	
	
	
	
	
	
</cfloop>
</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #action# is "newTerm">
	<cfoutput>

	<cfquery name="changeGeog" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		insert into geology_attribute_hierarchy (attribute,attribute_value,usable_value_fg) 
		values
		 ('#attribute#','#attribute_value#',#usable_value_fg#)
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