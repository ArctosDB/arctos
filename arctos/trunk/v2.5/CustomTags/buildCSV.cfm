     <cfscript>
  
         outputFile = getDirectoryFromPath(GetCurrentTemplatePath()) & "bulk.csv";
   
         oFileWriter = CreateObject("java","java.io.FileWriter").init(outputFile,JavaCast("boolean","true"));
   
         oBufferedWriter = CreateObject("java","java.io.BufferedWriter").init(oFileWriter);
   
      </cfscript>
   
       
   
      <cfquery datasource="#Application.web_user#" name="qData">
   			select * from bulkloader
     </cfquery>
  
       <cfoutput>
  
      <cftimer type="inline" label="Generate CSV">
  
         <cfset oBufferedWriter.write("#qData.columnList#" & chr(13) & chr(10))>
  		<cfset numCols = listlen(qData.columnList)>
       <cfset lastColumnName = listgetat(qData.columnList,numCols)>
  
         <cfloop query="qData">
  
       <cfloop list="#qData.columnList#" index="colName">
	   		 <cfif #colName# is #lastColumnName#>
			 	<cfset oBufferedWriter.write(chr(34) & #evaluate("qData." & colName)# & chr(34) & chr(13) & chr(10))>
			 <cfelse>
			 	<cfset oBufferedWriter.write(chr(34) & #evaluate("qData." & colName)# & chr(34) & ",")>
			 </cfif>
	   		
	   </cfloop>
  
            
  
       
  
         </cfloop>
  
         <cfset oBufferedWriter.close()>
  
      </cftimer>
</cfoutput>