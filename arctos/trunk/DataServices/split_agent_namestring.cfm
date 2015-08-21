<!---
drop table ds_temp_agent_namesplit;

create table ds_temp_agent_namesplit (
	key number not null,
	preferred_name varchar2(255),
	formatted_name  varchar2(255)
	);


create or replace public synonym ds_temp_agent_namesplit for ds_temp_agent_namesplit;
grant all on ds_temp_agent_namesplit to coldfusion_user;
grant select on ds_temp_agent_namesplit to public;

 CREATE OR REPLACE TRIGGER ds_temp_agent_namesplit_key
 before insert  ON ds_temp_agent_namesplit
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err

alter table ds_temp_agent_namesplit add remark varchar2(4000);

---->
<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title='Agent NameString Splitter Thingee'>
<cfsetting requestTimeOut = "600">
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent_namesplit
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/formattedAgentNames.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=formattedAgentNames.csv" addtoken="false">
</cfif>
<cfif action is "nothing">
<p>
	Upload a CSV file of agent names with one column, header "preferred_name". Get back properly-formatted agents and 
	remarks useful in finding non-person agents and non-agent data. Or garbage....
</p>
	<ul>
		<li>This app is a tool, not magic; you are fully responsible for the result.</li>
		
	</ul>
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<cfif action is "getFile">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
		<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from ds_temp_agent_namesplit
		</cfquery>
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
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into ds_temp_agent_namesplit (#colNames#) values (#preservesinglequotes(colVals)#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
	<cflocation url="split_agent_namestring.cfm?action=validate" addtoken="false">
</cfif>
<cfset dap="American,Animal,al,alaska,and,Anonymous,Acad,Academy,Abrasive,agents,agent,Association,Arkansas,Arizona,attributed,author,Automatic">
<cfset dap=dap & ",biol,biology,Bros,Bro,brought,by,Botanic ">
<cfset dap=dap & ",Class,california,company,co,Club,center,Coast,collector,Coll,collection,Collecting,College,Chicago,Corporation,Commission,Captive,commercial">
<cfset dap=dap & ",Division,Department,Donate,Donated,det,data">
<cfset dap=dap & ",Ecology,et,estate,Exchange,Expedition,Exch,Exc,Ex">
<cfset dap=dap & ",field,Forest,Florida,from,Fish,for,Fur,found">
<cfset dap=dap & ",Group,Growth,guard,Geological,Govt,Garden">
<cfset dap=dap & ",Hospital,hunter,High,History">
<cfset dap=dap & ",illegible,inc,Information,Institution,in,Institute,Instruments,Instrument,Illinois">
<cfset dap=dap & ",Kentucky,known">
<cfset dap=dap & ",Lab,Laboratories,Laboratory">
<cfset dap=dap & ",Management,Museum,Mexico,Mfg,Medical,Media,Machine,Monument">
<cfset dap=dap & ",National,native,Network,No,Natural,name">
<cfset dap=dap & ",Old,other,of,or,Office,Oklahoma">
<cfset dap=dap & ",Philadelphia,Production,Productions,prob,Probably,Park,Possibly,purchased,purchase">
<cfset dap=dap & ",Rangers,Ranger,research,remark,remarks,Railroad">
<cfset dap=dap & ",Predatory,Project,Puffin">
<cfset dap=dap & ",School,Sanctuary,Science,Sciences,Seabird,specimen,Staff,Service,Smithsonian,Southwestern">
<cfset dap=dap & ",Society,Study,student,students,station,summer,shop,service,store,system,Survey,State">
<cfset dap=dap & ",the,through,tag,Taxidermy,Taxidermist">
<cfset dap=dap & ",University,uaf">
<cfset dap=dap & ",various">
<cfset dap=dap & ",Wildlife,Wisconsin,Washington,Works,with">
 
<cfset dap=dap & ",Zoological,zoo,Zoology">

<cfset abr="Gov|Governor,Wm|William,Capt|Captain,Cpt|Captain,Chas|Charles,Col|Colonel,Geo|George,Prof|Professor,Rev|Reverend">
<cfif action is "validate">
	<cfoutput>
		<a href="split_agent_namestring.cfm?action=getCSV">get CSV</a>
		<a href="split_agent_namestring.cfm?action=nothing">load file</a>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ds_temp_agent_namesplit
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>orig</th>
				<th>manipulated</th>
				<th>comment</th>
			</tr>
			<cfloop query="d">
				<cfset cmnt="">
				<cfset tname=trim(preferred_name)>
				<cfset tname=replace(tname, ".",". ","all")>
				<cfset tname=replace(tname, "  "," ","all")>
				<cfset tname=replace(tname, "  "," ","all")>
				<cfset tname=rereplace(tname, "([A-Z])(?=[A-Z])","\1. \2","all")>
				<cfset tname=rereplace(tname, "([A-Z]) ","\1. ","all")>
				<cfset tname=rereplace(tname, "([A-Z])$","\1.","all")>
				<cfset tname=rereplace(tname, "(Jr)$","\1.","all")>
				<cfset tname=replace(tname, "Mrs ","Mrs. ","all")>
				<cfset tname=replace(tname, "Mr ","Mr. ","all")>
				<cfset tname=replace(tname, "St ","St. ","all")>
				<cfset tname=replace(tname, "Dr ","Dr. ","all")>
				<cfset intLength = Len(REReplace(tname,"[^ ]+","","ALL")) />
				<cfif intLength gt 3>
					<cfset cmnt=listappend(cmnt,'spaces',';')>
				</cfif>
				<cfif replace(tname,".","") contains "et al">
					<cfset cmnt=listappend(cmnt,'et al',';')>
				</cfif>
				<cfloop list="#dap#" index="i">
				  	<cfif listfindnocase(replace(tname,".","","all"),i,"() ;,.")>
						<cfset cmnt=listappend(cmnt,'#i#',';')>
					</cfif>
				</cfloop>
				<cfloop list="#abr#" index="i">
					<cfset a=listgetat(i,1,"|")>
					<cfset r=listgetat(i,2,"|")>
				  	<cfif listfindnocase(replace(tname,".","","all"),a," ")>
				  		<cfset tname=replace(replace(tname,a & '.',a,"all"), a,r,"all")>
					</cfif>
				</cfloop>
				<cfif refind("[0-9]",tname)>
					<cfset cmnt=listappend(cmnt,'number',';')>
				</cfif>
				<cfif refind("[^A-Za-z .]",tname)>
					<cfset cmnt=listappend(cmnt,'weirdchars',';')>
				</cfif>  
				<tr>
					<td>#preferred_name#</td>
					<td>#tname#</td>
					<td>#cmnt#</td>
				</tr>
				 
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update ds_temp_agent_namesplit set 
						FORMATTED_NAME='#escapeQuotes(tname)#',
						REMARK='#escapeQuotes(cmnt)#'
					where key=#key#
				</cfquery>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">