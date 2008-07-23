<cfinclude template="/includes/_header.cfm">

<cfset fileName = "c:\JRun4\servers\cfusion\cfusion-ear\cfusion-war\temp\GenBankData.txt">


<cfif #Action# is "nothing">
Upload a COMMA-DELIMITED file (cat_num, collection_cde, other_id_num, other_id_type) ....
<cfform name="getData" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="sendFile">
			
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			  <input type="submit" value="Upload this file">
		</cfform>
		
</cfif>

<!-------------------------------------------------------------------------->
<cfif #Action# is "sendFile">
	<cfoutput>
<!--- load the file --->

<cffile action="upload"
      destination="#fileName#"
      nameConflict="overwrite"
      fileField="Form.FiletoUpload">

<cflocation url="UploadIdentifiers.cfm?Action=gotFile">
</cfoutput>
</cfif>

<cfif #Action# is "gotFile">
<cfoutput>
<!---- read it into a query --->
<cfset fieldlist = "cat_num,findOtherIdType,findOtherIdNumber,collection,other_id_num,other_id_type">
    <cffile action="READ" file="#filename#" variable="fileContent">
   
    <cfset getDump=QueryNew("#fieldlist#")>
    <!--- The field list should be a (comma-delimited string), such as "Name, Address, Phone" --->
    <cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
	<hr>	
	<cfset a = #replace(line,#chr(9)#,"-tab-","all")#>
	#a#
      <!--- chr(10) is the line feed character, so this loops over the list of lines in the file --->
      <!--- Adds a row to the query for each line of the file --->
      <cfset QueryAddRow(getDump)>
      <cfset fieldcount=0>
      <!--- Loops over each line of the file, treating it as a list and adding each element to the query --->
      <cfloop index="field" list="#a#" delimiters="#chr(9)#">

        <!--- Increments the field counter --->
        <cfset fieldcount = fieldcount + 1>
        <!--- Inserts the field into the query --->
		
			 (#field#)
			 <cfset QuerySetCell(getDump,listGetAt(fieldlist,fieldcount),field)>
			 
			 <!----
			 <cfset QuerySetCell(getDump,listGetAt(fieldlist,fieldcount),field)>
		--->
        
		
		
      </cfloop>
    </cfloop>
	

</cfoutput>
<ht><hr><hr>
<table border>
<cfoutput query="getDump">
<tr>
	<td>#cat_num#</td>
	<td>#findOtherIdType#</td>
	<td>#findOtherIdNumber#</td>
	<td>#collection#</td>
	<td>#other_id_num#</td>
	<td>#other_id_type#</td>
</tr>
	<br> -  -  -  -  - 
</cfoutput>
</table>
</cfif>
<!-------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">