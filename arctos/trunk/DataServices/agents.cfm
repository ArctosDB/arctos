<!----




drop table ds_temp_agent;

create table ds_temp_agent (
	key number not null,
	agent_type varchar2(255),
	preferred_name varchar2(255),
	first_name varchar2(255),
	middle_name varchar2(255),
	last_name varchar2(255),
	birth_date date,
	death_date date,
	prefix varchar2(255),
	suffix varchar2(255),
	other_name_1  varchar2(255),
	other_name_type_1   varchar2(255),
	other_name_2  varchar2(255),
	other_name_type_2   varchar2(255),
	other_name_3  varchar2(255),
	other_name_type_3   varchar2(255),
	agent_remark varchar2(4000),
	new_agent_type varchar2(255),
	new_preferred_name varchar2(255),
	new_first_name varchar2(255),
	new_middle_name varchar2(255),
	new_last_name varchar2(255),
	new_birth_date date,
	new_death_date date,
	new_agent_remark varchar2(255),
	new_prefix varchar2(255),
	new_suffix varchar2(255),
	new_existing_agent_id number
	);
	
create public synonym ds_temp_agent for ds_temp_agent;
grant all on ds_temp_agent to coldfusion_user;
grant select on ds_temp_agent to public;

 CREATE OR REPLACE TRIGGER ds_temp_agent_key                                         
 before insert  ON ds_temp_agent
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err




---->
<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	Step 1: Upload a comma-delimited text file (csv). 
	Include column headings, spelled exactly as below. 
	<div id="template">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">agent_type,preferred_name,first_name,middle_name,last_name,birth_date,death_date,agent_remark</textarea>
	</div> 
	<p></p>
	
	
	
	
	Columns in <span style="color:red">red</span> are required; others are optional:
	<ul>
		<li style="color:red">agent_type</li>
		<li style="color:red">preferred_name</li>
		<li>first_name (agent_type="person" only)</li>
		<li>middle_name (agent_type="person" only)</li>
		<li>last_name (agent_type="person" only)</li>
		<li>birth_date (agent_type="person" only; format 1-Jan-2000)</li>
		<li>death_date (agent_type="person" only; format 1-Jan-2000)</li>
		<li>agent_remark</li>
		<li>prefix (agent_type="person" only)</li>
		<li>suffix (agent_type="person" only)</li>
		<li>other_name_type (second name type)</li>
		<li>other_name (second name)</li>
	    <li>other_name_type_2</li>
		<li>other_name_2</li>
	    <li>other_name_type_3</li>
		<li>other_name_3</li>				 
	</ul>
	
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>

</cfif>
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from ds_temp_agent
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into ds_temp_agent (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="agents.cfm?action=validate" addtoken="false">

<!---
---->
</cfif>
<cfif action is "validate">
<script src="/includes/sorttable.js"></script>
<script type='text/javascript' language='javascript'>
	jQuery(document).ready(function() {
	  	var keyList = document.getElementById('keyList').value;
	  	console.log(keyList);
	  	kAry=keyList.split(",");
	  	for (i=0; i<kAry.length; ++i) {
	  		jQuery.getJSON("/component/DSFunctions.cfc",
				{
					method : "findAgentMatch",
					key : kAry[i],
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if(r.ROWCOUNT > 0) {
						var ns='<select>';
						console.log(ns);
						for (a=0; a<r.ROWCOUNT; ++a) {
							ns+='<option value="' + r.DATA.AGENT_ID[a] + '">' + r.DATA.PREFERRED_AGENT_NAME + '</option>';
						}
						ns+='</select>';
						console.log(ns);
						$('#suggested__' + r.DATA.KEY[a]).html(ns);
					}
				}
			);
	  	}
	});
</script>
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent
	</cfquery>
	<input type="hidden" id="keyList" value="#valuelist(d.key)#">
	<table border id="theTable" class="sortable">
		<tr>
			<th>agent_type</th>
			<th>preferred_name</th>
			<th>first_name</th>
			<th>middle_name</th>
			<th>last_name</th>
			<th>birth_date</th>
			<th>death_date</th>
			<th>prefix</th>
			<th>suffix</th>
			<th>aka_1</th>
			<th>aka_2</th>
			<th>aka_3</th>
			<th>SuggestedAgent</th>
			<th>mapToAgent</th>
		</tr>
		<cfloop query="d">
			<tr id="row#key#">
				<td id="agent_type__#key#">#agent_type#&nbsp;</td>
				<td id="preferred_name__#key#">#preferred_name#</td>
				<td id="first_name__#key#">#first_name#&nbsp;</td>
				<td id="middle_namee__#key#">#middle_name#&nbsp;</td>
				<td id="last_name__#key#">#last_name#&nbsp;</td>
				<td id="birth_date__#key#">#birth_date#&nbsp;</td>
				<td id="death_date__#key#">#death_date#&nbsp;</td>
				<td id="prefix__#key#">#prefix#&nbsp;</td>
				<td id="suffix__#key#">#suffix#&nbsp;</td>
				<td id="other_name_1__#key#">#other_name_1# (#other_name_type_1#)</td>
				<td id="other_name_2__#key#">#other_name_2# (#other_name_type_2#)</td>
				<td id="other_name_3__#key#">#other_name_3# (#other_name_type_3#)</td>
				<td id="suggested__#key#">-</td>
				<td id="picked__#key#">No Suggestions</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</cfif>


<cfinclude template="/includes/_footer.cfm">