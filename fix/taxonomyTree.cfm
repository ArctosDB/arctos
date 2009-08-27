<cfinclude template="/includes/_header.cfm">

<cfoutput>
	<hr>
    <cfform name="myform">
        <hr>
		<cftree name="TaxTree" height="400" width="200" format="html">
            <cftreeitem bind="cfc:/component.taxTree.getNodes({cftreeitempath},{cftreeitemvalue})">
        </cftree>
		<hr>
    </cfform>
	<hr>
</cfoutput>