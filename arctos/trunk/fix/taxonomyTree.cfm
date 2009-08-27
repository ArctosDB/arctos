<cfinclude template="/includes/_header.cfm">

<cfoutput>
    <cfform name="myform">
        <cftree name="TaxTree" height="400" width="200" format="html">
            <cftreeitem bind="cfc:components.taxTree.getNodes({cftreeitempath},{cftreeitemvalue})">
        </cftree>
    </cfform>
</cfoutput>