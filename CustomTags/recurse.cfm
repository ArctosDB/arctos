<!--- check to see if a ParentItemID was passed in.  If so, this is a recursive
      call to this tag, so we set the ParentItemID to the value passed in.  If
      ParentItemID does not exist, this is a request for a top level tree item,
      so we set the ParentItemID to 0. --->
<CFIF ISDEFINED("Attributes.parent_container_id")>
  <CFSET parent_container_id = Attributes.parent_container_id>
</CFIF>

<!--- get the info for each parent item for the current level.  Items directly
     under the root have a ParentItemID of 0.  This info is passed in with each
     iteration of this tag.  By default, the ParentItemID is set to 0. --->


<!--- loop through the GetParents query and create a tree item for each 
      parent --->
	  <CFQUERY NAME="GetParents" DATASOURCE="MCAT_WU">
         SELECT container_id, parent_container_id, label
         FROM container WHERE container_id = #parent_container_id#
</CFQUERY>
<CFLOOP condition="forever is true">

<!--- if the parent is a category, set image to folder.  If it is a link, set the
      image to document
<CFIF #label# IS "">
  <CFSET IMAGE="folder">
<CFELSE>
  <CFSET IMAGE="Document">
</CFIF>
 --->
<!--- create the tree item --->
<CFTREEITEM VALUE="#container_id#" PARENT="#parent_container_id#" DISPLAY="#label#"
           EXPAND="yes"> 

<!--- find parents of the current parent --->
<CFQUERY NAME="GetChildren" DATASOURCE="MCAT_WU">
         SELECT container_id, parent_container_id, label
         FROM container WHERE container_id = #GetParents.parent_container_id#
</CFQUERY>



<!--- find children of the current parent 
<CFQUERY NAME="GetChildren" DATASOURCE="MCAT_WU">
         SELECT container_id, parent_container_id, label
         FROM container WHERE container_id = #GetParents.parent_container_id#
</CFQUERY>
--->

<!---  If there is a child for the parent, call the recurse tag again, but this
       time make the parentitemid equal to the itemid of the current child item.  
       This is what recursion is all about. --->
<CFIF GETCHILDREN.RECORDCOUNT GT 0 >
  <CF_RECURSE
      parent_container_id="#GetParents.container_id#">
</CFIF>
</CFLOOP>
