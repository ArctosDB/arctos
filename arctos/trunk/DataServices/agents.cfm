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
	agent_remark varchar2(4000)
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
	function saveAll() {
		var keyList = document.getElementById('keyList').value;
	  	kAry=keyList.split(",");
	  	for (i=0; i<kAry.length; ++i) {
	  		jQuery.getJSON("/component/DSFunctions.cfc",
				{
					method : "loadAgent",
					key : kAry[i],
					agent_id : $('#agent_id_' + kAry[i]).val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					var key=r.[0];
					var msg=r.[1];
					alert(msg);
				}
			);
		}
	}
	function useThis(key,name,id) {
		$('#name_' + key).val(name);
		$('#agent_id_' + key).val(id);
	}
	jQuery(document).ready(function() {
	  	var keyList = document.getElementById('keyList').value;
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
					var key=r.DATA.KEY[0];
					for (a=0; a<r.ROWCOUNT; ++a) {
						var ns='<br><span class="infoLink" onclick="';
						ns+="useThis('" + key + "','" + r.DATA.PREFERRED_AGENT_NAME[a] + "',";
						ns+="'" + r.DATA.AGENT_ID[a] + "')";
						ns+='">' + r.DATA.PREFERRED_AGENT_NAME[a] + '</span>';
						ns+='&nbsp;<a class="infoLink" href="/agents.cfm?agent_id=' + r.DATA.AGENT_ID[a] + '" target="_blank">[info]</a>';
						$('#suggested__' + key).append(ns);
					}
				}
			);
	  	}
	});
</script>
<cfoutput>
	<hr>
	Let all the JavaScript run. It'll take a while, and your page will bounce around while it's doing it's thing.
	You might need to split your load up into smaller batches, depending on your computer and how many
	suggestions we have. There is no recordlimit, and at least several thousand agents are possible with lots of RAM, 
	but who wants to look at that many records on one screen anyway?
	<p>
		Then, for each agent, do one of three things:
	</p>
	<ul>
		<li>Create a new agent by clicking the preferred name you uploaded. It's the one in [ square brackets ].</li>
		<li>Map your agent to an existing agent by clicking one of the suggest links. They're not in square brackets.</li>
		<li>Pick another existing agent by typing in the box and tabbing out, just like any other agent pick.</li>
	</ul>
	Click Save when you're done. 
	<p>
		If you picked an existing agent, we'll add all of your names to that agent. 
	</p>
	<p>
		If you chose to use your agent, we'll create an agent with all the names you supplied.
	</p>
	
	<p>
		Once everything has saved you can load specimen data using any of the names you loaded or, for pre-existing agents,
		any name that they already had.
	</p>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent
	</cfquery>
	<cfquery name="p" dbtype="query">
		select distinct(agent_type) agent_type from d
	</cfquery>
	<cfif valuelist(p.agent_type) is not "person">
		<div class="error">Sorry, we can only deal with agent type=person here.</div>
		<cfabort>
	</cfif>
	<form name="f">
	<input type="button" onclick="saveAll()" value="save to Arctos">
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
			<th>Remark</th>
		</tr>
		<cfloop query="d">
			<tr id="row_#key#">
				<td>#agent_type#</td>
				<td>#preferred_name#</td>
				<td>#first_name#&nbsp;</td>
				<td>#middle_name#&nbsp;</td>
				<td>#last_name#&nbsp;</td>
				<td>#birth_date#&nbsp;</td>
				<td>#death_date#&nbsp;</td>
				<td>#prefix#&nbsp;</td>
				<td>#suffix#&nbsp;</td>
				<td>
					<cfif len(other_name_1) gt 0>
						#other_name_1# (#other_name_type_1#)
					</cfif>
				</td>
				<td>
					<cfif len(other_name_2) gt 0>
						#other_name_2# (#other_name_type_2#)
					</cfif>
				</td>
				<td>
					<cfif len(other_name_3) gt 0>
						#other_name_3# (#other_name_type_3#)
					</cfif>
				</td>
				<td nowrap="nowrap" id="suggested__#key#">
					<label for="">Map To Agent</label>
					<input type="text" name="name_#key#" id="name_#key#" class="reqdClr" 
						onchange="getAgent('agent_id_#key#',this.id,'f',this.value); return false;"
		 				onKeyPress="return noenter(event);">
					<input type="hidden" name="agent_id_#key#" id="agent_id_#key#">
					<br><span class="infoLink" onclick="useThis('#key#','#preferred_name#','-1')">[ #preferred_name# ]</span>
				</td>
				<td>#agent_remark#</td>
			</tr>
		</cfloop>
	</table>
	</form>
</cfoutput>
</cfif>
<!----



var n='<input type="text" name="name' + key + '" class="reqdClr"';
					n+='onchange="getAgent(\'agentID_' + key + '\',\'name\',\'f\',this.value); return false;"';
					n+='onKeyPress="return noenter(event);">';
					n+='<input type="hidden" name="agentID_' + key + ' id="agentID_' + key + '">';
					
					---->

<cfinclude template="/includes/_footer.cfm">