<!--- check to see if a ParentItemID was passed in.  If so, this is a recursive
      call to this tag, so we set the ParentItemID to the value passed in.  If
      ParentItemID does not exist, this is a request for a top level tree item,
      so we set the ParentItemID to 0. --->
<CFIF ISDEFINED("Attributes.Parent_Container_Id")>
  <CFSET Parent_Container_Id = Attributes.Parent_Container_Id>
<CFELSE>
  <CFSET Parent_Container_Id = 0>
</CFIF>

<!--- get the info for each parent item for the current level.  Items directly
     under the root have a ParentItemID of 0.  This info is passed in with each
     iteration of this tag.  By default, the ParentItemID is set to 0. --->
<CFQUERY NAME="GetParents" DATASOURCE="ArctosTest">
         SELECT container_id, Parent_Container_Id, description, barcode
         FROM container WHERE Parent_Container_Id = #Parent_Container_Id# ORDER BY description
</CFQUERY>

<!--- loop through the GetParents query and create a tree item for each 
      parent --->
<CFLOOP QUERY="GetParents">
<!--- if the parent is a category, set image to folder.  If it is a link, set the
      image to document --->
<CFIF LINKURL IS "">
  <CFSET IMAGE="folder">
<CFELSE>
  <CFSET IMAGE="Document">
</CFIF>

<!--- create the tree item --->
<CFTREEITEM VALUE="#Container_id#" PARENT="#Parent_Container_Id#" DISPLAY="#description#"
            HREF="#LinkURL#" IMG="#Image#" EXPAND="No"> 

<!--- find children of the current parent --->
<CFQUERY NAME="GetChildren" DATASOURCE="arctostest">
         SELECT container_id, Parent_Container_Id, description, barcode
         FROM container WHERE Parent_Container_Id = #GetParents.container_id#
</CFQUERY>

<!---  If there is a child for the parent, call the recurse tag again, but this
       time make the parentitemid equal to the itemid of the current child item.  
       This is what recursion is all about. --->
<CFIF GETCHILDREN.RECORDCOUNT GT 0 >
  <CF_RECURSE
      PARENTITEMID="#GetParents.container_id#">
</CFIF>
</CFLOOP>
