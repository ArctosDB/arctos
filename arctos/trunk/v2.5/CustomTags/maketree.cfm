<!------------------------------------------------------------------------------
    Custom Tag : MyMakeTree.cfm 
    Author     : Steve Majewski
    Date       : 08/10/1999
    
    Attributes:
        ParentItemID (default="0") -     
            Defines the ParentItemID with which to start.  Defaults to zero (0),
            which means top level.  Use this to display sub-items only.
        OrderBy (default="Item") -
            Defines the field by which to order the records.  May also include 
            the order preference [ASC|DESC].  Use this to alter the direction
            or order, or to sort by another field.
------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------
    Assign attributes passed to local variables.  Use the CFPARAM statements
    to set default values if attributes are not passed.
------------------------------------------------------------------------------->

<cfparam name="Variables.parent_container_id" default="0">
<cfset parent_container_id = 100000>
<cfif IsDefined("Attributes.parent_container_id")>
    <cfset Variables.parent_container_id = Attributes.parent_container_id >
</cfif>

<cfparam name="Variables.OrderBy" default="container_id">
<cfif IsDefined("Attributes.OrderBy")>
    <cfset Variables.OrderBy = Attributes.OrderBy >
</cfif>

<!------------------------------------------------------------------------------
    Query all items with ParentItemID equal to the current ParentItemID.  All
    top level items should have a ParentItemID of zero (0).
------------------------------------------------------------------------------->
<cfquery name="GetCurrentItems" datasource="arctostest">
    SELECT      *
    FROM        container
    WHERE       parent_container_id = #Variables.parent_container_id#
    ORDER BY    #Variables.OrderBy#
</cfquery>

<!------------------------------------------------------------------------------
    Loop through the query and display the item information.
------------------------------------------------------------------------------->
<ul>
<cfloop query="GetCurrentItems">
    <cfoutput>
        <li>#GetCurrentItems.container_id#
    </cfoutput>
    <!--------------------------------------------------------------------------
        Query items with ParentItemID equal to the current ItemID.  
    --------------------------------------------------------------------------->
    <cfquery name="CheckForChild" datasource="arctostest">
        SELECT  *
        FROM    container
        WHERE   parent_container_id = #GetCurrentItems.container_id#
    </cfquery>
    <!--------------------------------------------------------------------------
        If CheckForChild returned records, then recurse sending the current
        ItemID as the ParentItemID.
    --------------------------------------------------------------------------->
    <cfif CheckForChild.RecordCount gt 0 >
        <cf_MakeTree
            parent_container_id="#GetCurrentItems.container_id#"
            OrderBy="#Variables.OrderBy#">
    </cfif>
</cfloop>
</ul>

<!------------------------------------------------------------------------------
    End MyMakeTree.cfm
------------------------------------------------------------------------------->