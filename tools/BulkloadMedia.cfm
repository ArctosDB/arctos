<!-------- /ScheduledTasks/BulkloadMedia.cfm is necessary ------------->
<!---
drop table cf_temp_media;
drop table cf_temp_media_relations;
drop table cf_temp_media_labels;


create table cf_temp_media (
 key NUMBER,
 status varchar2(255),
 username varchar2(255),
user_agent_id number,
loaded_media_id number,
media_license_id number,
 MEDIA_URI VARCHAR2(255),
 MIME_TYPE VARCHAR2(255),
 MEDIA_TYPE VARCHAR2(255),
 PREVIEW_URI VARCHAR2(255),
 media_license varchar2(60),
 media_relationship_1 varchar2(60),
 media_related_key_1 number,
 media_related_term_1 varchar2(255),
 media_relationship_2 varchar2(60),
 media_related_key_2 number,
 media_related_term_2 varchar2(255),
 media_relationship_3 varchar2(60),
 media_related_key_3 number,
 media_related_term_3 varchar2(255),
 media_relationship_4 varchar2(60),
 media_related_key_4 number,
 media_related_term_4 varchar2(255),
 media_relationship_5 varchar2(60),
 media_related_key_5 number,
 media_related_term_5 varchar2(255),
 media_label_1 varchar2(60),
 media_label_value_1 varchar2(60),
 media_label_2 varchar2(60),
 media_label_value_2 varchar2(60),
 media_label_3 varchar2(60),
 media_label_value_3 varchar2(60),
 media_label_4 varchar2(60),
 media_label_value_4 varchar2(60),
 media_label_5 varchar2(60),
 media_label_value_5 varchar2(60),
 media_label_6 varchar2(60),
 media_label_value_6 varchar2(60),
 media_label_7 varchar2(60),
 media_label_value_7 varchar2(60),
 media_label_8 varchar2(60),
 media_label_value_8 varchar2(60),
 media_label_9 varchar2(60),
 media_label_value_9 varchar2(60),
 media_label_10 varchar2(60),
 media_label_value_10 varchar2(60)
);


create table cf_temp_media_relations (
 key NUMBER,
 MEDIA_RELATIONSHIP VARCHAR2(40),
 CREATED_BY_AGENT_ID NUMBER,
 RELATED_PRIMARY_KEY NUMBER
);

create table cf_temp_media_labels (
key NUMBER,
 MEDIA_LABEL VARCHAR2(255),
 LABEL_VALUE VARCHAR2(255),
 ASSIGNED_BY_AGENT_ID NUMBER
);

create or replace public synonym cf_temp_media for cf_temp_media;
grant all on cf_temp_media to manage_media;
grant select on cf_temp_media to public;

create public synonym cf_temp_media_relations for cf_temp_media_relations;
grant all on cf_temp_media_relations to manage_media;
grant select on cf_temp_media_relations to public;

create public synonym cf_temp_media_labels for cf_temp_media_labels;
grant all on cf_temp_media_labels to manage_media;
grant select on cf_temp_media_labels to public;

CREATE OR REPLACE TRIGGER cf_temp_media_key                                         
 before insert  ON cf_temp_media  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err

--->

<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Media">
<cfset numLabels=10>
<cfset numRelns=5>

<!------------------------------------------------------->
<cfif action is "killMine">
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_media where username='#session.username#' 
		<cfif len(status) gt 0>
			and status in (#ListQualify(status,"'")#)
		</cfif>
	</cfquery>
	<a href="BulkloadMedia.cfm?action=myStuff">return to my records</a>
</cfif>
<!------------------------------------------------------->
<cfif action is "csv">
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_media where username='#session.username#' order by key
		</cfquery>
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/BulkMediaBack.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(mine.columnList); 
		</cfscript>
		<cfloop query="mine">
			<cfset d=''>
			<cfloop list="#mine.columnList#" index="i">
				<cfif i is "loaded_media_id">
					<cfset t='"http://arctos.database.museum/media/#evaluate("mine." & i)#"'>
				<cfelse>
					<cfset t='"' & evaluate("mine." & i) & '"'>
				</cfif>
				<cfset d=listappend(d,t,",")>
			</cfloop>
			<cfscript>
				variables.joFileWriter.writeLine(d); 
			</cfscript>
		</cfloop>
		<cfscript>	
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=BulkMediaBack.csv" addtoken="false">
		<a href="/download/BulkMediaBack.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>

<!------------------------------------------------------->
<cfif action is "pulldir">
	<cfset title=title&": Pull from URL">
	<cfquery name="ctMEDIA_LICENSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT distinct(display)  MEDIA_LICENSE FROM ctMEDIA_LICENSE
		order by display
    </cfquery>
	<cfoutput>
		<cfif not isdefined("dirurl")>
			<cfset dirurl=''>
		</cfif>
		
		<cfif right(dirurl,1) is not "/">
			<cfset dirurl=dirurl & '/'>
			<p>Added required trailing slash to directory URL</p>
		</cfif>
		<cfif not isdefined("extfilter")>
			<cfset extfilter=''>
		</cfif>
		<cfif not isdefined("requirePrefix")>
			<cfset requirePrefix=''>
		</cfif>
		<cfif not isdefined("ignorePrefix")>
			<cfset ignorePrefix=''>
		</cfif>
		<cfif not isdefined("tndir")>
			<cfset tndir=''>
		<cfelseif right(tndir,1) is not "/">
			<cfset tndir=tndir & '/'>
			<p>Added required trailing slash to preview URL</p>
		</cfif>
		
		<cfif not isdefined("tnprefix")>
			<cfset tnprefix=''>
		</cfif>
		<cfif not isdefined("tnext")>
			<cfset tnext=''>
		</cfif>
		<cfif right(dirurl,1) is not "/">
			<cfset dirurl=dirurl & '/'>
			<p>Added required trailing slash to directory URL</p>
		</cfif>
		<cfif not isdefined("MEDIA_LICENSE")>
			<cfset MEDIA_LICENSE=''>
		</cfif>
		<form name="temp2" method="post" action="BulkloadMedia.cfm">
			<input type="hidden" name="action" value="pulldir">
			<label for="dirurl">Directory URL</label>
			<input type="text" name="dirurl" value="#dirurl#" size="80">
			<label for="extfilter">Filter for extension (eg, ".jpg")</label>
			<input type="text" name="extfilter" value="#extfilter#" size="6">
			
			
			<label for="requirePrefix">Require file to start with...</label>
			<input type="text" name="requirePrefix" value="#requirePrefix#" size="6">
			
			<label for="ignorePrefix">ignore files that start with...</label>
			<input type="text" name="ignorePrefix" value="#ignorePrefix#" size="6">
			
			<label for="tndir">Preview Directory URL</label>
			<input type="text" name="tndir" value="#tndir#" size="80">
			
			<label for="tnprefix">Preview prefix (eg, "tn_")</label>
			<input type="text" name="tnprefix" value="#tnprefix#" size="6">
			
			
			<label for="tnext">Preview extension (eg, ".jpg")</label>
			<input type="text" name="tnext" value="#tnext#" size="6">
			
			<label for="MEDIA_LICENSE">MEDIA_LICENSE</label>
			<cfset tml=MEDIA_LICENSE>
			<select name="MEDIA_LICENSE" id="MEDIA_LICENSE">
				<option value=""></option>
				<cfloop query="ctMEDIA_LICENSE">
					<option <cfif tml is MEDIA_LICENSE> selected="selected" </cfif>value="#MEDIA_LICENSE#">#MEDIA_LICENSE#</option>
				</cfloop>
			</select>
			
			
			<br><input type="submit" value="go">
		</form>
		
		
		<cfhttp url="#dirurl#" charset="utf-8" method="get">
		</cfhttp>
		
		<cfif len(dirurl) is 0>
			<cfabort>
		</cfif>		
		<cfif isXML(cfhttp.FileContent)>
			<cfset xStr=cfhttp.FileContent>
			<!--- goddamned xmlns bug in CF --->
			<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
			<cfset xdir=xmlparse(xStr)>
			<cfset dir = xmlsearch(xdir, "//td[@class='n']")>
			
			<table border>
					<tr>
						<th>MEDIA_URI</th>
						<th>PREVIEW_URI</th>
						<th>MEDIA_LICENSE</th>
					</tr>
				
				
			<cfloop index="i" from="1" to="#arrayLen(dir)#">
				<cfset thisFile = dir[i].XmlChildren[1].xmlText>
				<cfif len(extfilter) gt 0>
					<cfif right(thisFile,len(extfilter)) is extfilter>
						<cfset thisFile=thisFile>
					<cfelse>
						<cfset thisFile=''>
					</cfif>
				</cfif>
				<cfif len(requirePrefix) gt 0>
					<cfif left(thisFile,len(requirePrefix)) is requirePrefix>
						<cfset thisFile=thisFile>
					<cfelse>
						<cfset thisFile=''>
					</cfif>
				</cfif>
				<cfif len(ignorePrefix) gt 0>
					<cfif left(thisFile,len(ignorePrefix)) is ignorePrefix>
						<cfset thisFile=''>
					<cfelse>
						<cfset thisFile=thisFile>
					</cfif>
				</cfif>
				<cfif len(thisFile) gt 0>
					<cfset thisThumb="">
					<cfif len(tndir) gt 0>
						<cfif thisFile does not contain ".">
							You may only specify a preview directory if all the files contain a dot (eg, have an extension).
							<cfabort>
						</cfif>
						<cfif len(tnext) is 0>
							You must specify a preview extension.
							<cfabort>
						</cfif>
						<cfset thisBareFilename=listdeleteat(thisFile,listlen(thisFile,"."),".")>
						<cfset thisThumb="#tndir##tnprefix##thisBareFilename##tnext#">
					</cfif>
					<tr>
						<td>#dirurl##thisFile#</td>
						<td>#thisThumb#</td>
						<td>#MEDIA_LICENSE#</td>
					</tr>
				</cfif>
				<!----
				
				
				
				KEY									    NUMBER
 STATUS 								    VARCHAR2(255)
 USERNAME								    VARCHAR2(255)
 USER_AGENT_ID								    NUMBER
 LOADED_MEDIA_ID							    NUMBER
 MEDIA_LICENSE_ID							    NUMBER
 MIME_TYPE								    VARCHAR2(255)
 MEDIA_TYPE								    VARCHAR2(255)
 PREVIEW_URI								    VARCHAR2(255)
 MEDIA_LICENSE								    VARCHAR2(60)
 MEDIA_RELATIONSHIP_1							    VARCHAR2(60)
 MEDIA_RELATED_KEY_1							    NUMBER
 MEDIA_RELATED_TERM_1							    VARCHAR2(255)
 MEDIA_RELATIONSHIP_2							    VARCHAR2(60)
 MEDIA_RELATED_KEY_2							    NUMBER
 MEDIA_RELATED_TERM_2							    VARCHAR2(255)
 MEDIA_RELATIONSHIP_3							    VARCHAR2(60)
 MEDIA_RELATED_KEY_3							    NUMBER
 MEDIA_RELATED_TERM_3							    VARCHAR2(255)
 MEDIA_RELATIONSHIP_4							    VARCHAR2(60)
 MEDIA_RELATED_KEY_4							    NUMBER
 MEDIA_RELATED_TERM_4							    VARCHAR2(255)
 MEDIA_RELATIONSHIP_5							    VARCHAR2(60)
 MEDIA_RELATED_KEY_5							    NUMBER
 MEDIA_RELATED_TERM_5							    VARCHAR2(255)
 MEDIA_LABEL_1								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_1							    VARCHAR2(255)
 MEDIA_LABEL_2								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_2							    VARCHAR2(255)
 MEDIA_LABEL_3								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_3							    VARCHAR2(255)
 MEDIA_LABEL_4								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_4							    VARCHAR2(255)
 MEDIA_LABEL_5								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_5							    VARCHAR2(255)
 MEDIA_LABEL_6								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_6							    VARCHAR2(255)
 MEDIA_LABEL_7								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_7							    VARCHAR2(255)
 MEDIA_LABEL_8								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_8							    VARCHAR2(255)
 MEDIA_LABEL_9								    VARCHAR2(60)
 MEDIA_LABEL_VALUE_9							    VARCHAR2(255)
 MEDIA_LABEL_10 							    VARCHAR2(60)
 MEDIA_LABEL_VALUE_10							    VARCHAR2(255)



				<cfif len(folder) is 10 and listlen(folder,"_") is 3><!--- probably a yyyy_mm_dd folder --->
					<cfquery name="gotFolder" datasource="uam_god">
						select count(*) c from es_img where folder='#folder#'		
					</cfquery>
					<!---
					<cfquery name="gotFile" datasource="uam_god">
						select count(distinct(imgname)) cbc from es_img where folder='#folder#'			
					</cfquery>
					--->
					<cfif gotFolder.c is 0><!--- been here? --->
						<br>fetching http://web.corral.tacc.utexas.edu/UAF/es/#folder#
						<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/es/#folder#" charset="utf-8" method="get"></cfhttp>
						<cfset ximgStr=cfhttp.FileContent>
						<!--- goddamned xmlns bug in CF --->
						<cfset ximgStr = replace(ximgStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
						<cfset xImgAll=xmlparse(ximgStr)>
						<cfset xImage = xmlsearch(xImgAll, "//td[@class='n']")>
						<cfloop index="i" from="1" to="#arrayLen(xImage)#">
							<cfset fname = xImage[i].XmlChildren[1].xmlText>
							<br>adding fname: #fname#
							<cfif right(fname,4) is ".dng">
								<cfset imgname=replace(fname,".dng","")>
								<cftry>
								<cfquery name="upFile" datasource="uam_god">
									insert into es_img (
										imgname,
										folder
									) values (
										'#imgname#',
										'#folder#'
									)	
								</cfquery>
								<cfcatch>
									<br>failed@'#imgname#','#folder#'===#cfcatch.message#: #cfcatch.detail#
								</cfcatch>
								</cftry>
							</cfif> 
						</cfloop>
					</cfif> <!--- end not been here --->
				</cfif>	
				---->	
			</cfloop>
			</table>
		<cfelse>
			The directory structure is not XML - can't proceed.
		</cfif>	
		
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "myStuff">
	<cfset title=title&": My Stuff">
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_media where username='#session.username#' order by key
		</cfquery>
		<cfquery name="ss" dbtype="query">
			select status from mine group by status order by status
		</cfquery>
		<hr>
		<form name="d" method="post" action="BulkloadMedia.cfm">
			<input type="hidden" name="action" value="killMine">
			DELETE from temp media where status =
			<select name="status">
				<option value="#valuelist(ss.status)#">anything</option>
				<cfloop query="ss">
					<option value="#status#">#status#</option>
				</cfloop>
			</select>
			<input type="submit" value="go">
		</form>
		<hr>
		The following data are in the Media Bulkloader under your username. You must re-load anything with errors.
		<hr>
		<a href="BulkloadMedia.cfm?action=csv">download</a>
		<cfset cl=mine.columnList>
		<cfset cl=listdeleteat(cl,listfind(cl,'STATUS'))>
		<cfset cl=listprepend(cl,'STATUS')>
		<table border>
			<tr>
				<cfloop list="#cl#" index="i">
					<th>#i#</th>
				</cfloop>
			</tr>
		<cfloop query="mine">
			<tr>
				<cfloop list="#cl#" index="i">
					<td>
						<cfif i is "loaded_media_id">
							<a href="/media/#evaluate("mine." & i)#">#evaluate("mine." & i)#</a>
						<cfelse>
							#evaluate("mine." & i)#
						</cfif>
					</td>
				</cfloop>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "makeTemplate">
	<cfset header="MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,media_license">
	<cfloop from="1" to="#nL#" index="i">
		<cfset header=listappend(header,"media_label_#i#")>
		<cfset header=listappend(header,"media_label_value_#i#")>
	</cfloop>
	<cfloop from="1" to="#nR#" index="i">
		<cfset header=listappend(header,"media_relationship_#i#")>
		<cfif hK is 1>
			<cfset header=listappend(header,"media_related_key_#i#")>
		</cfif>
		<cfset header=listappend(header,"media_related_term_#i#")>
	</cfloop>
	<cffile action = "write" 
    file = "#Application.webDirectory#/download/BulkMedia.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkMedia.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
	<cfparam name="nL" default="#numLabels#">
	<cfparam name="nR" default="#numRelns#">
	<cfparam name="hK" default="1">
	<ul>
		<li>Binary objects to be created as Media (and preview) must exist in a web-accessible location and return a 200 statuscode in the HTML header</li>
		<li>Objects to which Media will be related - such as collecting events and cataloged items - must exist</li>
		<li>You may specify either a media_related_key_n OR media_related_term_n, but neither both</li>
		<li>There is no checking for media_related_key; just provide a primary key for the table name specified in media_relationship</li>
		<li><a href="/info/ctDocumentation.cfm?table=ctmedia_relationship">valid relationships</a></li>
		<li><a href="/info/ctDocumentation.cfm?table=ctmedia_label">valid labels</a></li>
		<li>
			There is limited handling for media_related_term, and required values are very specific. Valid data are:
			<UL>
				<li>
					project
					<ul>
						<li>Exact string match ("Willow Identification")</li>
						<li>
							"niceURL" (both a CF and Oracle function), of the form "willow-identification" (from project 
							"http://arctos.database.museum/project/willow-identification")
						</li>
					</ul>
				</li>
				<li>Cataloged Item - DWC GUID format ("UAM:Mamm:12") or part's container's barcode</li>
				<li>Agent: Distinct string match with agent_name</li>
				<li>Media - media_uri</li>
			</UL>
		</li>
	</ul>
<hr>
	Upload Media to TACC (may work elsewhere) and use a directory to build a bulkloader template.
	<form name="temp2" method="post" action="BulkloadMedia.cfm">
		<input type="hidden" name="action" value="pulldir">
		<label for="dirurl">Directory URL</label>
		<input type="text" name="dirurl" size="80">
		<br><input type="submit" value="go">
	</form>
<hr>
	Download CSV template:
	<form name="temp" method="post" action="BulkloadMedia.cfm">
		<input type="hidden" name="action" value="makeTemplate">
		<label for="nL">Number of Labels</label>
		<select name="nL" id="nL">
			<cfloop from="1" to="#numLabels#" index="i">
				<option <cfif i is nL> selected="selected" </cfif>value="#i#">#i#</option>
			</cfloop>
		</select>
		<label for="nR">Number of Relationships</label>
		<select name="nR" id="nR">
			<cfloop from="1" to="#numRelns#" index="i">
				<option <cfif i is nR> selected="selected" </cfif>value="#i#">#i#</option>
			</cfloop>
		</select>
		<label for="hK">include keys?</label>
		<select name="hK" id="hK">
			<option <cfif hK is 1> selected="selected" </cfif>value="1">yes</option>
			<option <cfif hK is 0> selected="selected" </cfif>value="0">no</option>
		</select>
		<br>
		<input type="submit" value="get template">
	</form>
<hr>
<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select count(*) c from cf_temp_media where username='#session.username#'
</cfquery>
<cfif isThere.c gt 0>
	You have #isThere.c# items in the queue. <a href="BulkloadMedia.cfm?action=myStuff">See what's there</a>
<cfelse>
	You have nothing in the queue.
</cfif>
<hr>
</cfoutput>
Upload a comma-delimited text file (csv). 

<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
			 <input type="submit" value="Upload this file" class="savBtn">
  </cfform>

</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <!---
				 <cfdump var="#arrResult[o]#">
				 --->
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
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_media (#colNames#,username) values (#preservesinglequotes(colVals)#,'#session.username#')
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
	<cflocation url="BulkloadMedia.cfm?action=gotUpload">
 <!---

---->
</cfif>
<!------------------------------------------------------->
<cfif action is "gotUpload">
	<cfquery name="c" datasource="uam_god">
		update cf_temp_media set user_agent_id=(select agent_id from agent_name where agent_name=cf_temp_media.username)
		where user_agent_id is null
	</cfquery>
	Your data have been loaded to the temporary tablespace, and will be processed as soon as possible.
	Processing is by small random chunks, and not all of your data may load.
	<br>
	You may check the status of your data at any time by visiting <a href="BulkloadMedia.cfm?action=mystuff">My Stuff</a>.
	<br>An email reminder will be sent daily. You must delete everything from your temporary table to stop 
	receiving reminders.
</cfif>

<cfinclude template="/includes/_footer.cfm">
