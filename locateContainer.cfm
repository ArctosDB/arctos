
<cfinclude template="includes/_header.cfm">


<cfoutput>
   <cfform name="myform">
      <cftree name="treeTest" height="400" width="200" format="html">
         <cftreeitem bind="cfc:component.test.getNodes({cftreeitempath},{cftreeitemvalue})">
      </cftree>
   </cfform>
		<cfquery name="test" datasource="#Application.web_user#" timeout="60">
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
	start with container_id=1021
	connect by prior parent_container_id = container_id 
	</cfquery>
 <cfform name="myform2">
      <cftree name="treeTest2" height="400" width="200" format="html">
			<cftreeitem display="boogity: #label#" query="test">
      </cftree>
   </cfform>
</cfoutput>

 <cfinclude template="includes/_footer.cfm">