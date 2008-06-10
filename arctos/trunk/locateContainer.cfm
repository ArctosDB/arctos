
<cfinclude template="includes/_header.cfm">


<cfoutput>
   <cfform name="myform">
      <cftree name="treeTest" height="400" width="200" format="html">
         <cftreeitem bind="cfc:getNodes({cftreeitempath},{cftreeitemvalue})">
      </cftree>
   </cfform>
</cfoutput>

 <cfinclude template="includes/_footer.cfm">