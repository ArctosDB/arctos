<cfinclude template="includes/_header.cfm">
<cfset title = "Edit Code Tables">
<br>This is a dynamically-generated form. Buttons are ordered alphabetically and labeled with
the name of the table who's values they control. For the most part, tables names are intuitive. 
However, some tables have not followed normal naming conventions and are cryptically-named at best. 




<cfquery name="getCTName" datasource="uam_god">
	select distinct(table_name) from sys.user_tables where table_name like 'CT%' order by table_name
</cfquery>
<cfoutput>
<cfset i=1>
<table>
<cfloop query="getCTName">

<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_columns where table_name='#table_name#'
</cfquery>
<cfloop query="getCols">
	<cfif not #getCols.column_name# contains "DISPLAY">
		<cfset dispValFg = "no">
	<cfelse>
		<cfset dispValFg = "yes">
	</cfif>
</cfloop>
<tr><td>
<cfif #dispValFg# is "yes">
	--Table #getCTName.table_name# contains stored and display values. You can't change it yet.--
</cfif>
<cfif #dispValFg# is "no">

<cfif #getCTName.table_name# is "ctattribute_code_tables">
	<form name="#getCTName.table_name#" method="post" action="CodeTableEditor.cfm">
		<input type="hidden" name="tbl" value="#getCTName.table_name#">
		<input type="hidden" name="fld" value="special">
		<cfset collcde="n">
	<input type="hidden" name="collcde" value="#collcde#">
	<input type="submit" value="Edit #getCTName.table_name#" class="lnkBtn"
   						onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
						
						
	</form>
	</td></tr>
	



<!---------- normal CTs ----------------->
<cfelse>
<form name="btn#i#" method="post" action="CodeTableEditor.cfm">
	<input type="hidden" name="tbl" value="#getCTName.table_name#">
	
<cfset collcde = "">
<cfset descn = "">
<cfloop query="getCols">
	<cfif not #column_name# contains "display" AND not #column_name# contains "description">
		<cfif not #column_name# is "collection_cde">
			<input type="hidden" name="fld" value="#column_name#">
			<cfset collcde="#collcde#n">
		<cfelse>
			<cfset collcde="#collcde#y">
		</cfif>
	</cfif>
	<cfif #column_name# contains "description">
		<cfset descn="y">
	</cfif>
</cfloop>
<cfif #collcde# contains "y">
	<cfset collcde="y">
<cfelse>
	<cfset collcde="n">
</cfif>
<cfif #descn# contains "y">
	<cfset descn="y">
	This table has documentation available.
<cfelse>
	<cfset descn="n">
</cfif>
<cfif #getCTName.table_name# is "CTCOLLECTION_CDE">
	<input type="hidden" name="fld" value="COLLECTION_CDE">
	<CFSET collcde="n">
</cfif>

<input type="hidden" name="collcde" value="#collcde#">
<input type="hidden" name="hasDescn" value="#descn#">
<input type="submit" value="Edit #getCTName.table_name#" class="lnkBtn"
   						onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
</form>
</td></tr>

</cfif>
</cfif>
<cfset i=#i#+1>
</cfloop>
</table>
</cfoutput>
<cfinclude template="includes/_footer.cfm">