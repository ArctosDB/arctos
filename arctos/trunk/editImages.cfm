<cfinclude template="/includes/alwaysInclude.cfm">
<script>
	function showMe(s) {
		d = document.getElementById('scaleDiv');
		t = document.getElementById('testSize');
		d.style.height=s;
		t.value=s;
	}
</script>

<cfquery name="ctViewer" datasource="#Application.web_user#">
	select distinct(viewer) from viewer
</cfquery>
<cfquery name="ctSubject" datasource="#Application.web_user#">
	select subject from ctbin_obj_subject
</cfquery>
<cfquery name="ctAspect" datasource="#Application.web_user#">
	select aspect from ctbin_obj_aspect
</cfquery>
<cfquery name="ins" datasource="#Application.web_user#">
	select institution_acronym from collection,
		cataloged_item
		where
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id=#collection_object_id#
</cfquery>
<!------------------------------------------------------------>
<cfif #Action# is "nothing">
<cfoutput>
	<cfquery name="defs" datasource="#Application.web_user#">
		select collector.agent_id,agent_name,
		began_date
		 from collector, collecting_event,cataloged_item,
		 preferred_agent_name
		 where
		coll_order=1 and collector_role='c'
		and collector.collection_object_id = cataloged_item.collection_object_id
		and collecting_event.collecting_event_id = cataloged_item.collecting_event_id
		and preferred_agent_name.agent_id = collector.agent_id
		and cataloged_item.collection_object_id = #collection_object_id#
	</cfquery>
<cfquery name="getImages" datasource="#Application.web_user#">
	select 
		level,
		binary_object.collection_object_id as ImageID,
		cat_num,
		cataloged_item.collection_cde,
		coll_obj_disposition,
		condition,
		viewer,
		derived_from_coll_obj,
		made_date,
		subject,
		aspect,
		description,
		full_URL,
		thumbnail_url,
		agent_name
	 from 
		cataloged_item, 
		coll_object,
		binary_object,
		preferred_agent_name,
		viewer
	WHERE
		cataloged_item.collection_object_id = binary_object.derived_from_cat_item AND
		binary_object.collection_object_id = coll_object.collection_object_id AND
		binary_object.viewer_id = viewer.viewer_id AND		
		binary_object.made_agent_id = preferred_agent_name.agent_id
		AND cataloged_item.collection_object_id=#collection_object_id#
	connect by prior binary_object.collection_object_id = derived_from_coll_obj
	start with derived_from_coll_obj is null
</cfquery>
<!--- we won't have images most of the time, so get the cat num and collection cde for the links --->

<cfquery name="thisRecord" datasource="#Application.web_user#">
	select cat_num, cataloged_item.collection_cde, institution_acronym 
	from cataloged_item,collection
	where 
	cataloged_item.collection_id = collection.collection_id and
	collection_object_id = #collection_object_id#
</cfquery>
Existing Images:
<cfset i=1>
<table>
	<cfloop query="getImages">
		<cfset offset = (#level#-1) * 50>
		<cfif #full_url# contains #Application.ServerRootUrl#>
			<cfset thisImgFile = "#Application.webDirectory##right(full_url,len(full_url) - len(serverRootUrl))#">
			<cfset imgDir = #left(thisImgFile,len(thisImgFile) - find("/",reverse(thisImgFile)))#>
			<cfset thisFileName = #right(thisImgFile,find("/",reverse(thisImgFile))-1)#>
			<cfset thisExtension = #right(thisImgFile,find(".",reverse(thisImgFile)))#>
			<cfdirectory action="list" name="thisImg" directory="#imgDir#" filter="#thisFileName#">
			<cfif isdefined("thisImg.size") and len(#thisImg.size#) gt 0>
				<cfset sizeInK=round(thisImg.size/1024)>
				<cfset sizeInK="#sizeInK#&nbsp;K&nbsp;#thisExtension#">
			<cfelse>
				<cfset sizeInK='unknown filesize #thisExtension#'>
			</cfif>
		<cfelse>
			<cfset sizeInK='external link'>
		</cfif>		
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
			<td>
				<div style="padding-left: #offset#px;">&nbsp;
					<cfif len(#thumbnail_url#) gt 0>
						<a href="#full_url#" target="_blank">
							<img src="#thumbnail_url#">
						</a>
					<cfelse>
						<a href="#full_url#" target="_blank">
							<img src="/images/noThumb.jpg">
						</a>
					</cfif>
					<span style="font-size:small">
						<br>#sizeInK#
					</span>
				</div>
			</td>
			<td>
				<div style="font-size:smaller">
						<strong>Made by</strong> #agent_name# <strong>on</strong> #dateformat(made_date,"dd mmm yyyy")#
						<br><strong>Subject:</strong> #subject#
						<cfif len(#aspect#) gt 0>
								<br><strong>Aspect:</strong> #aspect#
						</cfif>
						<cfif len(#Viewer#) gt 0>
							<br><strong>Viewer:</strong> #Viewer#
						</cfif>
					
					<cfif len(#description#) gt 0>
						<br><strong>Description:</strong> #description#
					</cfif>
					<br><strong>URL:</strong> #full_url#
				</div>
			</td>
			<td>
				<a href="editImages.cfm?imageID=#imageID#&collection_object_id=#collection_object_id#&action=editImage">Edit</a>
			</td>
		</tr>
		<cfset i=#i# + 1>
	</cfloop>
</table>
<div id="scaleDiv" style="background-color:gray;font-size:small;overflow:visible;float:right;position:absolute; right:20px;top:20px">
	<strong>Image scale test</strong>
	<br>Make the height of this box:
	<br>
	<select name="testSize" id="testSize"  onchange="showMe(this.value)">
		<option value="50">50 px</option>
		<option value="100">100 px</option>
		<option value="200">200 px</option>
		<option value="300">300 px</option>
		<option value="400">400 px</option>
		<option value="500">500 px</option>
		<option value="600">600 px</option>
		<option value="700">700 px</option>
		<option value="800">800 px</option>
		<option value="900">900 px</option>
		<option value="1000">1000 px</option>
		<option value="1100">1100 px</option>
		<option value="1200">1200 px</option>
	</select>
</div>
<table class="newRec"><tr>
<td colspan="2">
<b>Add Image: Upload a file</b>
</td>

</tr>
	<form name="getBinFil" method="post" enctype="multipart/form-data" action="editImages.cfm">
		<input type="hidden" name="Action" value="newImage">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<cfset thisPath = "#thisRecord.institution_acronym#/#thisRecord.collection_cde#/#thisRecord.cat_num#">
		<input type="hidden" name="thisPath" value="#thisPath#">
		<tr>
			<td colspan="2">
				<label for="FiletoUpload">No spaces or special characters in file name</label>
				<input type="file" name="FiletoUpload" id="FiletoUpload" size="45">
			</td>
		</tr>		
		<tr>
			<td colspan="2">
				<label for="description">Description</label>
				<textarea name="description" id="description" cols="40" rows="4"></textarea>
			</td>
		</tr>
		<tr>
			<td>
				<label for="description">Subject</label>
				<select name="subject" id="subject" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="ctsubject">
						<option value="#ctsubject.subject#">#ctsubject.subject#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<cfset defDate = dateformat(defs.began_date,"dd mmm yyyy")>
				<label for="made_date">Made Date</label>
				<input type="text" name="made_date" id="made_date" class="reqdClr" value="#defDate#">
			</td>
		</tr>
		<tr>
		<td>
			<label for="aspect">Aspect</label>
			<select name="aspect" id="aspect" size="1">
				<option value=""></option>
				<cfloop query="ctAspect">
					<option value="#ctAspect.aspect#">#ctAspect.aspect#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="viewer">Viewer</label>
			<select name="viewer" id="viewer" size="1">
				<cfloop query="ctViewer">
					<option value="#ctViewer.viewer#">#ctViewer.viewer#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<label for="made_agent">Made By</label>
			<input type="hidden" name="made_agent_id" value="#defs.agent_id#">
			<input type="text" name="made_agent" 
				id="made_agent" class="reqdClr" size="50" value="#defs.agent_name#"
		 		onchange="getAgent('made_agent_id','made_agent','newimage',this.value); return false;"
			  	onKeyUp="return noenter();"> 
		</td>
	</tr>
	<tr>
		<td>
			<label for="tnh">Thumbnail Height (0 for no thumbnail)</label>
			<select name="tnh" id="tnh">
				<option value="0">0</option>
				<option value="50">50</option>
				<option value="100" selected="selected">100</option>
				<option value="150">150</option>
				<option value="200">200</option>
			</select>
		</td>
		<td>
			<label for="pvh">JPG Preview Height (0 for no JPG)</label>
			<select name="pvh" id="pvh">
				<option value="0">0</option>
				<option value="200">200</option>
				<option value="400">400</option>
				<option value="600">600</option>
				<option value="800" selected="selected">800</option>
				<option value="1000">1000</option>
				<option value="1200">1200</option>
			</select>
			<label for="pvq">JPG Preview Quality (reduce for large originals)</label>
			<select name="pvq" id="pvq">
				<option value="10">10</option>
				<option value="20">20</option>
				<option value="30" selected="selected">30</option>
				<option value="40">40</option>
				<option value="50">50</option>
				<option value="60">60</option>
				<option value="70">70</option>
				<option value="80">80</option>
				<option value="90">90</option>
				<option value="100">100</option>
			</select>
		</td>
	</tr>
	<tr>
		<td>
			<input type="submit" 
				value="Upload" 
				class="savBtn"
	   			onmouseover="this.className='savBtn btnhov'" 
	   			onmouseout="this.className='savBtn'">	
		</td>
	</tr>
	<tr>
		<td></td>
	</tr>
	</form>
	<script>showMe(100);</script>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------->
<cfif #Action# is "deleteImage">
<cfoutput>
	<cftransaction>
		<cfquery name="predeleImg" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select * from binary_object where collection_object_id=#imageID#
		</cfquery>
		<cfquery name="deleImgObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from coll_object where collection_object_id=#imageID#
		</cfquery>
		<cfquery name="deleImg" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from binary_object where collection_object_id=#imageID#
		</cfquery>
	</cftransaction>
		
		<cfif #predeleImg.full_url# contains #Application.ServerRootUrl#>
			<cfset thisImgFile = "#Application.webDirectory##right(predeleImg.full_url,len(predeleImg.full_url) - len(serverRootUrl))#">
			<cftry>
					<cffile action="delete" file="#thisImgFile#">
				<cfcatch><!--- so ---></cfcatch>
				</cftry>				
		</cfif>
		<cfif #predeleImg.thumbnail_url# contains #Application.ServerRootUrl#>
			<!--- thumbnails are sometimes shared --->
			<cfquery name="sharedTN" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select count(*) cnt from binary_object where collection_object_id != #imageID#
				and thumbnail_url='#predeleImg.thumbnail_url#'
			</cfquery>
			<cfif #sharedTN.cnt# is 0>
				<cfset thisImgFile = "#Application.webDirectory##right(predeleImg.thumbnail_url,len(predeleImg.thumbnail_url) - len(serverRootUrl))#">
				<cftry>
					<cffile action="delete" file="#thisImgFile#">
				<cfcatch><!--- so ---></cfcatch>
				</cftry>				
			</cfif>
		</cfif>
		
		
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editImages.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
<cfoutput>
	<cfquery name="viewer_id" datasource="#Application.web_user#">
		select viewer_id from viewer where viewer='#viewer#'
	</cfquery>
	<cfquery name="upBin" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	UPDATE binary_object SET
		viewer_id=#viewer_id.viewer_id#
		,made_date='#dateformat(made_date,"dd-mmm-yyyy")#'
		,subject='#subject#'
		,made_agent_id=#made_agent_id#
		<cfif len(#aspect#) gt 0>
			,aspect='#aspect#'
		  <cfelse>
		  	,aspect=null
		</cfif>
		<cfif len(#description#) gt 0>
			,description='#description#'
		  <cfelse>
		  	,description=null
		</cfif>
	WHERE
		collection_object_id=#imageID#
		</cfquery>
			<cfquery name="upColObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update coll_object set LAST_EDITED_PERSON_ID=#application.agent_id#,LAST_EDIT_DATE=sysdate
				where collection_object_id=#imageID#
			</cfquery>
			<cfquery name="upSpecColObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update coll_object set LAST_EDITED_PERSON_ID=#application.agent_id#,LAST_EDIT_DATE=sysdate
				where collection_object_id=#collection_object_id#
			</cfquery>
		<cf_logEdit collection_object_id="#collection_object_id#">
		<cflocation url="editImages.cfm?Action=editImage&imageID=#imageID#&collection_object_id=#collection_object_id#">
		
	
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "editImage">
Edit Image:
	<cfoutput>
	<cfquery name="getData" datasource="#Application.web_user#">
	select 
		binary_object.collection_object_id as ImageID,
		cataloged_item.collection_object_id as collection_object_id,
		cat_num,
		collection_cde,
		coll_obj_disposition,
		condition,
		viewer,
		derived_from_coll_obj,
		made_date,
		subject,
		aspect,
		description,
		full_URL,
		agent_name,
		made_agent_id,
		thumbnail_url
	 from 
		cataloged_item, 
		coll_object,
		binary_object,
		preferred_agent_name,
		viewer
	WHERE
		cataloged_item.collection_object_id = binary_object.derived_from_cat_item AND
		binary_object.collection_object_id = coll_object.collection_object_id AND
		binary_object.viewer_id = viewer.viewer_id AND
		binary_object.made_agent_id = preferred_agent_name.agent_id
		AND binary_object.collection_object_id=#imageID#
		</cfquery>
	</cfoutput>
	<cfoutput query="getData">
	
		<form name="editImage" method="post" action="editImages.cfm">
			<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="imageID" value="#imageID#">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">	
<table>
	<tr>
		<td>
			<label for="description">Description</label>
			<textarea name="description" id="description" cols="40" rows="4">#description#</textarea>
		</td>
	</tr>
	
	<tr>
		<td>
			<label for="subject">Subject</label>
			<select name="subject" id="subject" size="1">
				<option value=""></option>
				<cfset thisSubject = #subject#>
				<cfloop query="ctsubject">
					<option 
						<cfif #thisSubject# is "#ctsubject.subject#"> selected</cfif>
					value="#ctsubject.subject#">#ctsubject.subject#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td>
			<label for="made_date">Made Date</label>
			<input type="text" name="made_date" id="made_date" value="#dateformat(made_date,"dd-mmm-yyyy")#" >
		</td>
	</tr>
	<tr>
		<td>
			<label for="aspect">Aspect</label>
			<select name="aspect" id="aspect" size="1">
				<option value=""></option>
				<cfset thisAspect = #aspect#>
				<cfloop query="ctAspect">
					<option 
					<cfif #thisAspect# is "#ctAspect.aspect#"> selected</cfif>
					value="#ctAspect.aspect#">#ctAspect.aspect#</option>
				</cfloop>
			</select>
		<td> 
	</tr>
	<tr>
		<td>
			<label for="viewer">Viewer</label>
			<select name="viewer" id="viewer" size="1">
				<cfset thisViewer = #viewer#>
				<cfloop query="ctViewer">
					<option 
					<cfif #thisViewer# is "#ctViewer.viewer#"> selected</cfif>
					value="#ctViewer.viewer#">#ctViewer.viewer#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td>
			<label for="made_agent">Made By</label>
			<input type="hidden" name="made_agent_id" id="made_agent_id" value="#made_agent_id#">
			<input type="text" 
				name="made_agent" id="made_agent" 
				class="reqdClr" 
				size="50"
				value="#agent_name#"
				onchange="getAgent('made_agent_id','made_agent','editImage',this.value); return false;"
				onKeyUp="return noenter();">
		</td>
	</tr>
	<tr>	
	<td>
		 <input type="submit" 
				value="Save" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'">
		 <input type="button" 
				value="Quit" 
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'" 
				onmouseout="this.className='qutBtn'"
				onClick="document.location='editImages.cfm?collection_object_id=#collection_object_id#';">
		<input type="button" 
				value="Delete" 
				class="delBtn"
				onmouseover="this.className='delBtn btnhov'" 
				onmouseout="this.className='delBtn'"
				onClick="document.editImage.action.value='deleteImage';submit();">
	</td>
	</tr>
	</form>
	</table>		
	</cfoutput>
</cfif>

<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "newImage">
<cfoutput>
	<!--- load the file --->
	<cffile action="upload"
    	destination="#Application.webDirectory#/temp/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	<cfset fileName=#cffile.serverfile#>
	<cfset dotPos=find(".",fileName)>
	<cfset name=left(fileName,dotPos-1)>
	<cfset extension=right(fileName,len(fileName)-dotPos+1)>
	<cfif REFind("[^A-Za-z0-9_]",name,1) gt 0>
		<font color="##FF0000" size="+2">The filename (<strong>#fileName#</strong>) you entered contains characters that are not alphanumeric.
		Please rename your file and try again.</font>
		<a href="javascript:back()">Go Back</a>
		<cfabort>   
	</cfif>
	<!----This name contains only alphanumeric characters, check the extension---->
	<cfset ext=right(extension,len(extension)-1)>
	<cfif REFind("[^A-Za-z]",ext,1) gt 0>
		The extension you provided contains inappropriate characters.
		Please rename your file and <a href="javascript:back()">try again</a>.
		<cfabort>
	</cfif>
	<!--- good extension, see if it matches what we'll accept ---->
	<cfset goodExtensions="gif,jpg,jpeg,png,pdf,tiff,tif,dng">
	<cfif not listfindnocase(goodExtensions,ext,",")>
		The extension you provided is not acceptable. Acceptable extensions are: #goodExtensions#
		Please <a href="/info/bugs.cfm">file a bug report</a> if you feel that this message is in error, or
		<a href="javascript:back()">try again</a>.
		<cfabort>
	</cfif>
	<!---good extension, everything checks out, move the file---->
	<cfset loadPath = "#Application.webDirectory#/SpecimenImages/#thisPath#">
	<cftry>
		<cfdirectory action="create" directory="#loadPath#">
		<cfcatch><!--- it already exists, do nothing---></cfcatch>
	</cftry>
	<cfset full_url = "#Application.ServerRootUrl#/SpecimenImages/#thisPath#/#fileName#">
	<cffile action="copy" source="#Application.webDirectory#/temp/#fileName#" 
    	destination="#loadPath#" 
        nameConflict="OVERWRITE">
	<cfset thisExtension = #right(fileName,find(".",reverse(fileName)))#>
	<!--- remove previous thumbnails and small jpegs --->
	<cftry>
		<cffile action="delete" file="#loadPath#/#thumbnailName#">
		<cfcatch><!--- whatever, doesn't exist ---></cfcatch>
	</cftry>
	<cftry>
		<cffile action="delete" file="#loadPath#/#jpegName#">
		<cfcatch><!--- whatever, doesn't exist ---></cfcatch>
	</cftry>
	<!--- make thumbnail and preview --->
	<cfset thumbnailName = "tn_#fileName#">
	<cfset thumbnailName = replace(thumbnailName,thisExtension,"","last")>
	<cfset thumbnailName = "#thumbnailName#.jpg">
	<cfset jpegName = replace(thumbnailName,"tn_","mjp_")>
	<cftry>
		<cfif #tnh# gt 0>
			<cfexecute name="#Application.convertPath#" 
				arguments="-thumbnail 250x#tnH# #loadPath#/#fileName# #loadPath#/#thumbnailName#">
			</cfexecute>
			<cfset thumbnail_url="#Application.ServerRootUrl#/SpecimenImages/#thisPath#/#thumbnailName#">
		<cfelse>
			<cfset thumbnail_url="">
		</cfif>
		<cfif #pvh# gt 0>
			<cfexecute name="#Application.convertPath#" 
				arguments="-adaptive-resize x#pvh# -quality #pvq# #loadPath#/#fileName# #loadPath#/#jpegName#">
			</cfexecute>
			<cfset preview_url="#Application.ServerRootUrl#/SpecimenImages/#thisPath#/#jpegName#">
		<cfelse>
			<cfset preview_url="">
		</cfif>
		<cfcatch>
			<!--- dammit! --->
			<cfset thumbnail_url="">
			<cfset preview_url="">
		</cfcatch>
	</cftry>
	<cfset enteredbyid = application.agent_id>
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<cfquery name="nextID" datasource="#Application.web_user#">
		select max(collection_object_id) + 1 as nextID from coll_object
	</cfquery>
	<cfquery name="viewer" datasource="#Application.web_user#">
		select viewer_id from viewer where viewer = '#viewer#'
	</cfquery>
	<cftransaction>
	<cfquery name="updateColl" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO coll_object (
			collection_object_id,
			coll_object_type,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			LAST_EDITED_PERSON_ID,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			FLAGS )
		VALUES (
			#nextID.nextID#,
			'IO',
			#enteredbyid#,
			'#thisDate#',
			#enteredbyid#,
			'not applicable',
			1,
			'not applicable',
			0 )
	</cfquery>
	<cfquery name="instImage" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO binary_object (
			 COLLECTION_OBJECT_ID,
			 VIEWER_ID,
			 DERIVED_FROM_CAT_ITEM,
			 MADE_DATE,
			 SUBJECT,
			 FULL_URL,
			 made_agent_id
			 <cfif len(#ASPECT#) gt 0>
			 	,ASPECT
			 </cfif> 
			 <cfif len(#DESCRIPTION#) gt 0>
			 	,DESCRIPTION
			 </cfif>
			 ,thumbnail_url  
			)
			VALUES (
			 #nextID.nextID#,
			 #viewer.viewer_id#,
			 #collection_object_id#,
			 '#dateformat(MADE_DATE,"dd-mmm-yyyy")#',
			 '#SUBJECT#',
			 '#FULL_URL#'
			 ,#made_agent_id#
			 <cfif len(#ASPECT#) gt 0>
			 	,'#ASPECT#'
			 </cfif> 
			 <cfif len(#DESCRIPTION#) gt 0>
			 	,'#DESCRIPTION#'
			 </cfif>
			 ,'#thumbnail_url#' )
	</cfquery>
	<cfif len(#preview_url#) gt 0>
		<cfset thisCollObjId = #nextID.nextID# + 1>
		<cfquery name="updateColl" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			INSERT INTO coll_object (
				collection_object_id,
				coll_object_type,
				ENTERED_PERSON_ID,
				COLL_OBJECT_ENTERED_DATE,
				LAST_EDITED_PERSON_ID,
				COLL_OBJ_DISPOSITION,
				LOT_COUNT,
				CONDITION,
				FLAGS )
			VALUES (
				#thisCollObjId#,
				'IO',
				#enteredbyid#,
				'#thisDate#',
				#enteredbyid#,
				'not applicable',
				1,
				'not applicable',
				0 )
		</cfquery>
		<cfquery name="instImage" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			INSERT INTO binary_object (
				 COLLECTION_OBJECT_ID,
				 DERIVED_FROM_COLL_OBJ,
				 VIEWER_ID,
				 DERIVED_FROM_CAT_ITEM,
				 MADE_DATE,
				 SUBJECT,
				 FULL_URL,
				 made_agent_id
				 <cfif len(#ASPECT#) gt 0>
				 	,ASPECT
				 </cfif> 
				 <cfif len(#DESCRIPTION#) gt 0>
				 	,DESCRIPTION
				 </cfif>
				 ,thumbnail_url  
				)
				VALUES (
				 #thisCollObjId#,
				 #nextID.nextID#,
				 1,
				 #collection_object_id#,
				 '#dateformat(now(),"dd-mmm-yyyy")#',
				 '#SUBJECT#',
				 '#preview_url#'
				 ,#enteredbyid#
				 <cfif len(#ASPECT#) gt 0>
				 	,'#ASPECT#'
				 </cfif> 
				 <cfif len(#DESCRIPTION#) gt 0>
				 	,'#DESCRIPTION#'
				 </cfif>
				 ,'#thumbnail_url#' )
		</cfquery>
	</cfif>
	</cftransaction>
	<cflocation url="editImages.cfm?collection_object_id=#collection_object_id#&ImageID=#nextID.nextID#">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<cfoutput>
<script type="text/javascript" language="javascript">
		changeStyle('#ins.institution_acronym#');
		parent.dyniframesize();
</script>
</cfoutput>