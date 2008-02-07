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
<cfparam name="Variables.ParentItemID" default="0">
<cfif IsDefined("Attributes.ParentItemID")>
    <cfset Variables.ParentItemID = Attributes.ParentItemID >
</cfif>

<cfparam name="Variables.OrderBy" default="Item">
<cfif IsDefined("Attributes.OrderBy")>
    <cfset Variables.OrderBy = Attributes.OrderBy >
</cfif>

<!------------------------------------------------------------------------------
    Query all items with ParentItemID equal to the current ParentItemID.  All
    top level items should have a ParentItemID of zero (0).
------------------------------------------------------------------------------->
<cfquery name="GetCurrentItems" datasource="TestDB">
    SELECT      *
    FROM        Items
    WHERE       ParentItemID = #Variables.ParentItemID#
    ORDER BY    #Variables.OrderBy#;
</cfquery>

<!------------------------------------------------------------------------------
    Loop through the query and display the item information.
------------------------------------------------------------------------------->
<ul>
<cfloop query="GetCurrentItems">
    <cfoutput>
        <li>#GetCurrentItems.Item#
    </cfoutput>
    <!--------------------------------------------------------------------------
        Query items with ParentItemID equal to the current ItemID.  
    --------------------------------------------------------------------------->
    <cfquery name="CheckForChild" datasource="TestDB">
        SELECT  *
        FROM    Items
        WHERE   ParentItemID = #GetCurrentItems.ItemID#;
    </cfquery>
    <!--------------------------------------------------------------------------
        If CheckForChild returned records, then recurse sending the current
        ItemID as the ParentItemID.
    --------------------------------------------------------------------------->
    <cfif CheckForChild.RecordCount gt 0 >
        <cf_MyMakeTree
            ParentItemID="#GetCurrentItems.ItemID#"
            OrderBy="#Variables.OrderBy#">
    </cfif>
</cfloop>
</ul>

<!------------------------------------------------------------------------------
    End MyMakeTree.cfm
------------------------------------------------------------------------------->