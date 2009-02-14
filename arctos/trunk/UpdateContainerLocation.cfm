<cfinclude template = "includes/_header.cfm">
<!---- this is an internal use page and needs a security wrapper --->
 <!--- no security --->

<CFSCRIPT>
/**
* compares one list against another to find the elements in the first list that don't exist in the second list.
*
* @param List1 Full list of delimited values.
* @param List2 Delimited list of values you want to compare to List1.
* @param Delim1 Delimiter used for List1. Default is the comma.
* @param Delim2 Delimiter used for List2. Default is the comma.
* @param Delim3 Delimiter to use for the list returned by the function. Default is the comma.
* @return Returns a delimited list of values.
* @author Rob Brooks-Bilson (rbils@amkor.com)
* @version 1.0, November 14, 2001
*/
function ListCompare(List1, List2)
{
var TempList = "";
var Delim1 = ",";
var Delim2 = ",";
var Delim3 = ",";
var i = 0;
// Handle optional arguments
switch(ArrayLen(arguments)) {
case 3:
{
Delim1 = Arguments[3];
break;
}
case 4:
{
Delim1 = Arguments[3];
Delim2 = Arguments[4];
break;
}
case 5:
{
Delim1 = Arguments[3];
Delim2 = Arguments[4];
Delim3 = Arguments[5];
break;
}
}
/* Loop through the full list, checking for the values from the partial list.
* Add any elements from the full list not found in the partial list to the
* temporary list
*/
for (i=1; i LTE ListLen(List1, "#Delim1#"); i=i+1) {
if (NOT ListFindNoCase(List2, ListGetAt(List1, i, Delim1), Delim2)){
TempList = ListAppend(TempList, ListGetAt(List1, i, Delim1), Delim3);
}
}
Return TempList;
}
</CFSCRIPT>



  <cfset filename = "#application.webDirectory#/temp/newbars.txt">
  
  <cfif #Action# is "nothing">
  <cfoutput> 
    <div align="center"><font size="+2"><strong>Add container scans</strong></font> 
    </div>
    <br>
    This form loads container scans from #filename#. To use this application, you MUST have already loaded a text 
    file to #filename#. If you have not, the application will fail. <br>
    Duplicate scans will be ignored. 
    <cfset fieldlist = "parent, child, sdate, stime">
    <cffile action="READ" file="#filename#" variable="fileContent">
    <!--- The file name should be an absolute path --->
    <!--- Creates a query from the data that was read --->
    <cfset getDump=QueryNew("#fieldlist#")>
    <!--- The field list should be a (comma-delimited string), such as "Name, Address, Phone" --->
    <cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
      <!--- chr(10) is the line feed character, so this loops over the list of lines in the file --->
      <!--- Adds a row to the query for each line of the file --->
      <cfset QueryAddRow(getDump)>
      <cfset fieldcount=0>
      <!--- Loops over each line of the file, treating it as a list and adding each element to the query --->
      <cfloop index="field" list="#line#" delimiters=",">
        <!--- Increments the field counter --->
        <cfset fieldcount = fieldcount + 1>
        <!--- Inserts the field into the query --->
        <cfset QuerySetCell(getDump,listGetAt(fieldlist,fieldcount),field)>
      </cfloop>
    </cfloop>
    <form action="UpdateContainerLocation.cfm?action=update" method="post">
      <input name="submit" type="submit" value="Yep, that's the right stuff. Let's do this.">
    </form>
    <form action="start.cfm" method="get">
      <input type="submit" name="Submit" value="I'm like so lost. Take me somewhere safe">
    </form>
    Upload a new file: <br>
    This file MUST be named "newbars.txt". 
    <cfform action="UpdateContainerLocation.cfm?action=newScans" method="post" enctype="multipart/form-data">
      <input type="file"
   name="FiletoUpload"
   size="45">
      <input type="submit" value="Upload this file">
    </cfform>
    <p>The file located at #filename# containes the following data. Continue only 
      if this is correct and you have searched these data for strangeness (ie, 
      scans placing the museum building into a nunc tube are probably erroneous, 
      unless it is a really big nunc tube). 
    <p>#filename#: 
    <p>&nbsp;</p>
  </cfoutput> <cfoutput query="getDump"> 
    <br>
    #parent#, #child#, #sdate#, #stime# </cfoutput> 
	</cfif>  
	
	
  <cfif #action# is "newScans">
    <cffile action="upload"
      destination="#application.webDirectory#/temp/"
      nameConflict="overwrite"
      fileField="Form.FiletoUpload">
    <!--- reload this form --->
    <cflocation url="UpdateContainerLocation.cfm?action=set">
  </cfif>
  
  <cfif #action# is "update">
    Checking container scans.... 
    <cfflush>
    <!--- get scan dump into query--->
    <cfset fieldlist = "parent, child, sdate, stime">
    <cffile action="READ" file="#filename#" variable="fileContent">
    <!--- The file name should be an absolute path --->
    <!--- Creates a query from the data that was read --->
    <cfset getDump=QueryNew("#fieldlist#")>
    <!--- The field list should be a (comma-delimited string), such as "Name, Address, Phone" --->
    <cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
      <!--- chr(10) is the line feed character, so this loops over the list of lines in the file --->
      <!--- Adds a row to the query for each line of the file --->
      <cfset QueryAddRow(getDump)>
      <cfset fieldcount=0>
      <!--- Loops over each line of the file, treating it as a list and adding each element to the query --->
      <cfloop index="field" list="#line#" delimiters=",">
        <!--- Increments the field counter --->
        <cfset fieldcount = fieldcount + 1>
        <!--- Inserts the field into the query --->
        <cfset QuerySetCell(getDump,listGetAt(fieldlist,fieldcount),field)>
      </cfloop>
    </cfloop>
    <!--- got scan dump 
	make date and time into something more useful--->
    <cfoutput query="getDump"> 
      <cfset timestamp = "#dateformat(sdate,'dd-MMM-YYYY')# #timeformat(stime,'HH:mm:ss')#">
      <!--- case-sensitive--->
      <cfset childCode = quotedvaluelist(getDump.child)>
      <!--- list of child barcodes that we'll use later --->
      <cfset parentCode = quotedvaluelist(getDump.parent)>
      <!--- list of parent barcodes that we'll use later --->
    
	  <cfquery name="dumps" dbtype="query">
      SELECT parent as parent, child as child, '#dateformat(sdate,'dd-MMM-YYYY')# 
      #timeformat(stime,'HH:mm:ss')#' as timestmp from getDump 
      </cfquery>
	 
	  <!----
	   SELECT parent as parent, child as child, '#dateformat(sdate,'dd-MMM-YYYY')# 
      #timeformat(stime,'HH:mm:ss')#' as timestmp from getDump 
	  ---->
    </cfoutput> 
    <!--- 
		get barcodes pulled over so we can use them ( this is ugly--there has to be a better way )
		put all this goo into lists and compare the lists to find parents which do not exits. If nonexistant 
		parents are in the scan dump, show a table of them and do nothing else. Otherwise, run some SQL to 
		load scans into the DB 
	--->
    <cfquery name="getBarcodes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    select distinct(barcode) as barcode from container 
    </cfquery>
    <cfset OldCodes = ValueList(getbarcodes.barcode)>
    <cfset NewCodes = ValueList(getDump.parent)>
    <cfset DumpChild = valuelist(getDump.child)>
    <CFSET BadCodes = ListCompare(NewCodes,OldCodes)>
    <cfset BadCount = "0">
    <CFLOOP INDEX="i" LIST="#BadCodes#">
      <cfset BadCount = #BadCount# + 1>
    </cfloop>
    <!--- Find any existing child containers --->
    <cfoutput> 
      <cfset getChildSql = "select container_id, barcode from container where barcode IN ( #childcode# )">
      <cfquery name="getChildId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
      #preservesinglequotes(getChildSql)# 
      </cfquery>
    </cfoutput> 
    <cfset ExistChild = valuelist(getChildId.barcode)>
    <CFSET MissingChildren = ListCompare(DumpChild,ExistChild)>
    <cfset badChildren = "0">
    <CFLOOP INDEX="i" LIST="#MissingChildren#">
      <cfset badChildren = #badChildren# + 1>
    </cfloop>
    <!--- Find scans that have already been loaded 
	<!--- get everything from container_history --->
    <cfquery name="conthist" datasource="#arctos.web_user#">
    select container_id || parent_container_id || install_date as pkey from container_history 
    </cfquery>
    <cfquery name="dumpcat" dbtype="query">
    select child+parent+timestmp as pkey2 from dumps 
    </cfquery>
    <!--- compare that to the query dump that was made earlier from scans --->
    <cfset conthistlist = valuelist(conthist.pkey)>
    <cfset dumplist = valuelist(dumpcat.pkey2)>
    <CFSET alreadythere = ListCompare(conthistlist,dumplist)>
    <br>
    made it here.... 
    <cfflush>
    <table border="1">
      <tr> 
        <td valign="top"><cfoutput query="conthist"> 
            <br>
            -
            <CFLOOP INDEX="i" LIST="#alreadythere#">
              <br>
              #i#
            </CFLOOP>
          </cfoutput></td>
        <td valign="top"><cfoutput query="dumpcat"> 
            <br>
            =#pkey2# </cfoutput></td>
      </tr>
    </table>
    ---> 
    <cfif badCount gt 0>
      <!---there are new parents or children in the dump file--->
      <CFOUTPUT> 
        <table border="1">
          <tr> 
            <td>The following #badChildren# child barcodes were not found</td>
            <td>The following #BadCount# parent barcodes were not found</td>
          </tr>
          <tr> 
            <td valign="top"><CFLOOP INDEX="i" LIST="#MissingChildren#">
                <br>
                #i#</CFLOOP></td>
            <td valign="top"><CFLOOP INDEX="i" LIST="#BadCodes#">
                <br>
                #i#</CFLOOP></td>
          </tr>
        </table>
      </cfoutput> 
      <cfelse>
      <!--- There are no bad parents, do the update--->
      <br>
      There are no missing records, the update is running.... 
      <P>&nbsp;</P>
      <cfflush>
      <!--- alter the session to get minutes in--->
      <cfquery name="timeFormat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
      ALTER SESSION SET nls_date_format = 'DD-Mon-YYYY hh24:mi:ss' 
      </cfquery>
      <!--- find stuff that already exists in container_history --->
      <br>
      Looking for existing containers... 
      <cfquery name="exists" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
      SELECT container_id||'-'||parent_container_id||'-'||install_date as pkey 
      from container_history 
      </cfquery>
      <cfset AlreadyThere = quotedvaluelist(exists.pkey)>
      <br>
      Running updates.... 
      <cfflush>
      <!--- 
			Now find container_id for existing parents
			That should be all of them if we made it this far.
		--->
      <cfoutput> 
        <cfset getParentSql = "select container_id, barcode from container where barcode IN ( #parentcode# )">
        <cfquery name="getParentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        #preservesinglequotes(getParentSql)# 
        </cfquery>
      </cfoutput> 
	  <cfoutput> 
        <!--- put all this crap into a single query that we can send to Oracle --->
        <cfquery name="cids" dbtype="query">
        SELECT 
			getChildId.container_id as container_id, 
			dumps.timestmp as timestmp,
			dumps.parent as Pbarcode 
		from 
			getChildId, 
			dumps 
		WHERE 
			dumps.child = getChildId.barcode 
        </cfquery>
        <!--- get container_ids for existing children (all children should exist) --->
        <cfquery name="allData" dbtype="query">
        SELECT getParentId.container_id as parent_container_id, cids.container_id, 
        cids.timestmp from getParentId, cids WHERE cids.pbarcode = getParentId.barcode 
        </cfquery>
      </cfoutput> <br>
      Running SQL: 
      <cfloop query="allData">
        <cftransaction>
          <cfoutput> 
            <!--- set parent_container_id and parent_install_date --->
            <cfquery name="setParents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
            UPDATE container SET parent_container_id = #parent_container_id#, 
            parent_install_date = '#timestmp#' WHERE container_id = #container_id# 
            </cfquery>
            <!--- update labels to unknown scans --->
            <cfquery name=setType datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
            UPDATE container SET container_type = 'unknown scan' WHERE container_id 
            = #container_id# AND container_type = 'cryovial label' 
            </cfquery>
            <!--- update history table --->
            <!--- See if the value we want is already there --->
            <cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
            SELECT * FROM container_history WHERE container_id = #container_id# 
            AND parent_container_id = #parent_container_id# AND install_date='#timestmp#' 
            </cfquery>
            <cfif #isThere.recordcount# is 0>
              <cfquery name="setHistory" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
              INSERT INTO container_history ( container_id, parent_container_id, 
              install_date ) VALUES ( #container_id#, #parent_container_id#, '#timestmp#') 
              </cfquery>
            </cfif>
          </cfoutput> 
        </cftransaction>
      </cfloop>
      <br>
      <font color="#00FF00" size="+1">The update has completed. <a href="index.html">Go 
      away</a>.</font> 
    </cfif>
    <!---end of checking for bad parents and end of updates--->
    <!--- end of update action--->
  </cfif>
 
<cfinclude template = "includes/_footer.cfm">