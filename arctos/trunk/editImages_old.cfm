  <cfinclude template="/includes/alwaysInclude.cfm">
 

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

<cfif #Action# is "nothing">
<cfoutput>
<cfquery name="getImages" datasource="#Application.web_user#">
	select 
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
</cfquery>
<!--- we won't have images most of the time, so get the cat num and collection cde for the links --->

<cfquery name="thisRecord" datasource="#Application.web_user#">
	select cat_num, cataloged_item.collection_cde, institution_acronym 
	from cataloged_item,collection
	where 
	cataloged_item.collection_id = collection.collection_id and
	collection_object_id = #collection_object_id#
</cfquery>

<!--- some default stuff ---->
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

  
</cfoutput>
<cfoutput>
<table class="newRec"><tr><td>
<b>Add Image:</b>

  <!--- start by forcing them to upload an image --->
  <cfif not isdefined("newURL") OR len(#newURL#) is 0>
  <p>Step 1: Upload a file <em><font size="-1">(no spaces or special characters in file name!)</font></em>    <!--- they haven't been assigned a newURL - ie, they haven't loaded
		a file yet --->
		<cfform name="getBinFil" method="post" enctype="multipart/form-data" action="editImages.cfm">
			
			<input type="hidden" name="content_url" value="editImages.cfm">
			
			<input type="hidden" name="Action" value="sendFile">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<cfset thisPath = "#thisRecord.institution_acronym#/#thisRecord.collection_cde#/#thisRecord.cat_num#">
				
			<input type="hidden" name="thisPath" value="#thisPath#">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			   <input type="submit" 
	value="Upload this file" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'">	
			
		</cfform>
		
  <cfelse>
  <br>Step 2: Add data:
  	<!--- they have loaded a file, let them add data about it --->
		<form name="newimage" method="post" action="editImages.cfm">
	<input type="hidden" name="Action" value="newImage">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<tr>
		<td>URL</td>
		<td><input type="text" value="#newURL#" name="full_url" size="90" class="reqdClr"></td>
	</tr>
	<tr>
	<td>Description:</td>
	<td> 
	<textarea name="description" cols="40" rows="4"></textarea>
	</td>
	</tr>
	
	<tr>
	<td>Subject:</td>
	<td> <select name="subject" size="1" class="reqdClr">
			<option value=""></option>
			<cfloop query="ctsubject">
				<option value="#ctsubject.subject#">#ctsubject.subject#</option>
			</cfloop>
		</select></td>
	</tr>
	<tr>
	<td>Made Date:</td>
		<cfset defDate = dateformat(defs.began_date,"dd mmm yyyy")>
	<td> <input type="text" name="made_date" class="reqdClr" value="#defDate#"></td>
	</tr>
	<tr>
	<td>Aspect:</td>
	<td> 
		<select name="aspect" size="1">
			<option value=""></option>
			<cfloop query="ctAspect">
				<option value="#ctAspect.aspect#">#ctAspect.aspect#</option>
			</cfloop>
		</select>
	</td>
	</tr>
	<tr>
	<td>Viewer:</td>
	<td> 
		<select name="viewer" size="1">
			<cfloop query="ctViewer">
				<option value="#ctViewer.viewer#">#ctViewer.viewer#</option>
			</cfloop>
		</select>
	</td>
	</tr>
	<tr>
	<td>Made By:</td>
	<td> 
		<input type="hidden" name="made_agent_id" value="#defs.agent_id#">
		
				
		<input type="text" name="made_agent" class="reqdClr" size="50" value="#defs.agent_name#"
		 onchange="getAgent('made_agent_id','made_agent','newimage',this.value); return false;"
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
				
	</td>
	</tr>
	 </form>
  </cfif>
  
  
  
  
  



	  
	  
	  </tr>
    </table>
<cfset i = 1>
<font size="+1"><strong>Existing Images:</strong></font>
<table>
<cfloop query="getImages">
<cfif #full_url# contains #Application.ServerRootUrl#>
	<cfset thisImgFile = "#Application.webDirectory##right(full_url,len(full_url) - len(serverRootUrl))#">
	<cfset imgDir = #left(thisImgFile,len(thisImgFile) - find("/",reverse(thisImgFile)))#>
	<cfset thisFileName = #right(thisImgFile,find("/",reverse(thisImgFile))-1)#>
	<cfset thisExtension = #right(thisImgFile,find(".",reverse(thisImgFile)))#>
	<cfset thisRelativePath = replace(full_url,serverRootUrl,"")>
	<cfset thisRelativePath = replace(thisRelativePath,thisFileName,"")>
	<cfset thisThumbnail = #right(thisImgFile,find("/",reverse(thisImgFile))-1)#>
						<cfset thisThumbnail = "tn_#thisThumbnail#">
									<cfset thisThumbnail = replace(thisThumbnail,thisExtension,"","last")>
									<cfset thisThumbnail = "#thisThumbnail#.jpg">
									<cfset thisJpeg = replace(thisThumbnail,"tn_","mjp_")>
									<cfdirectory action="list" name="thisTN" directory="#imgDir#" filter="#thisThumbnail#">
									<cfdirectory action="list" name="thisMJP" directory="#imgDir#" filter="#thisJpeg#">
<cfelse>
	<cfset thisTN.name=''>
	<cfset thisMJP.name=''>
	<cfset thisJPG.name=''>
	<cfset sizeInK='unknown'>
	<cfset thisExtension='unknown extension'>
</cfif>
									
<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
	<td>
		<table>
		

	

<form name="image#i#" method="post" action="editImages.cfm">
	<input type="hidden" name="Action">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="imageID" value="#getImages.imageID#">
	
	<tr>
		<td></td>
		<td></td>
		<td rowspan="6" align="right">
		<cfif len(#thisTN.name#) gt 0>
			<img src="#thisRelativePath#/#thisThumbnail#" alt="thumbnail">
		</cfif>
		<cfif len(#thisMJP.name#) gt 0>
			<br><a class="infoLink" href="#thisRelativePath##thisJpeg#" target="_blank">Resized JPG</a>
		</cfif>
			<br><a class="infoLink" href="#full_url#"  target="_blank">Original Image</a>
			
			
		</td>
	</tr>
	
	<tr>
		<td align="right">Description:</td>
		<td>#getImages.description#</td>	
	</tr>
	<tr>
		<td align="right">Subject:</td>
		<td>#getImages.subject#</td>	
	</tr>
	<tr>
		<td align="right">Made Date:</td>
		<td>#dateformat(getImages.made_date,"dd mmm yyyy")#</td>	
	</tr>
	<tr>
		<td align="right">Aspect:</td>
		<td>#getImages.aspect#</td>	
	</tr>
	<tr>
		<td align="right">Viewer:</td>
		<td>#getImages.viewer#</td>	
	</tr>
	<tr>
		<td align="right">Made By:</td>
		<td>#getImages.agent_name#</td>	
	</tr>
	<tr>
		<td align="right">URL:</td>
		<td>#getImages.full_url#</td>	
	</tr>
	<tr>
		
		<td colspan="2">
		
		 <input type="button" 
	value="Edit" 
	class="lnkBtn"
   	onmouseover="this.className='lnkBtn btnhov'" 
   	onmouseout="this.className='lnkBtn'"
	onClick="image#i#.Action.value='editImage';submit();">	
	
	 <input type="button" 
	value="Delete" 
	class="delBtn"
   	onmouseover="this.className='delBtn btnhov'" 
   	onmouseout="this.className='delBtn'"
	onClick="image#i#.Action.value='deleteImage';submit();">	
	</td>	
	</tr>
	
	

	 </form>

<cfset i = #i#+1>
		</table>
	</td>
</tr>
</cfloop>
</table>


   
  
</cfoutput>
</td></tr></table>
</cfif>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "deleteImage">
<cfoutput>
	<!-----
	<cfquery name="getURL" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select full_url from binary_object where collection_object_id=#imageID#
	</cfquery>
	<!--- get URL bits --->
	<cfset fullURL = #getURL.full_url#>
	<cfset thisURL = "http://#cgi.HTTP_HOST#/">
	thisURL: #thisURL#
	<cfset thisPath = replace(fullURL,thisURL,"")>
	<br>thisPath: #thisPath#
	<cfset webDir = "/var/www/html/#thisPath#"><!---- static-coded web directory ---->
	<cfdirectory name="isItThere" directory="#webdir#">
	size: #isItThere.size#
	<cfabort>
	------>
	<cfquery name="deleImg" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		delete from binary_object where collection_object_id=#imageID#
	</cfquery>
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editImages.cfm?collection_object_id=#collection_object_id#&content_url=editImages.cfm">
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
		,full_url='#full_url#'
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
		<cf_logEdit collection_object_id="#collection_object_id#">
		<cflocation url="editImages.cfm?Action=editImage&imageID=#imageID#">
		
	
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
		made_agent_id
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
			<input type="hidden" name="Action" value="saveEdits">
			<input type="hidden" name="imageID" value="#imageID#">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		
<table>
	<tr>
	<td>Description:</td>
	<td> <textarea name="description" cols="40" rows="4">#description#</textarea></td>
	</tr>
	
	<tr>
	<td>Subject:</td>
	<td> <select name="subject" size="1">
			<option value=""></option>
			<cfset thisSubject = #subject#>
			<cfloop query="ctsubject">
				<option 
					<cfif #thisSubject# is "#ctsubject.subject#"> selected</cfif>
				value="#ctsubject.subject#">#ctsubject.subject#</option>
			</cfloop>
		</select></td>
	</tr>
	<tr>
	<td>Made Date:</td>
	<td> <input type="text" name="made_date" value="#dateformat(made_date,"dd-mmm-yyyy")#" ></td>
	</tr>
	<tr>
	<td>aspect:</td>
	<td> 
		<select name="aspect" size="1">
			<option value=""></option>
			<cfset thisAspect = #aspect#>
			<cfloop query="ctAspect">
				<option 
				<cfif #thisAspect# is "#ctAspect.aspect#"> selected</cfif>
				value="#ctAspect.aspect#">#ctAspect.aspect#</option>
			</cfloop>
		</select>
	</td>
	</tr>
	<tr>
	<td>viewer:</td>
	<td> 
		<select name="viewer" size="1">
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
	<td>URL: </td>
	<td> <input type="text" name="full_URL"  size="50"  value="#full_url#"></td>
	</tr>
	<tr>
	<td>Made By:</td>
	<td> 
		<input type="hidden" name="made_agent_id" value="#made_agent_id#">
		<input type="text" 
			name="made_agent" 
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
	</td>
	</tr>
	</table>		
		</form>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<cfif #Action# is "sendFile">
	<cfoutput>
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
		<a href="javascript:back();">Go Back</a>   
		<cfabort>
	<cfelse>
		<!----This name contains only alphanumeric characters, check the extension---->
			<cfset ext=right(extension,len(extension)-1)>
			<br>ext: #ext#
			<cfif REFind("[^A-Za-z]",ext,1) gt 0>
				The extension you provided contains inappropriate characters.
				Please rename your file and try again.
				<cfabort>
			<cfelse>
				<!--- good extension, see if it matches what we'll accept ---->
				<cfset goodExtensions="gif,jpg,jpeg,png,pdf,tiff,tif,dng">
				<cfif listfindnocase(goodExtensions,ext,",")>
					<!---good extension, everything checks out, move the file---->
					<cfset loadPath = "#Application.webDirectory#/SpecimenImages/#thisPath#">
					<cftry>
						<cfdirectory action="create" directory="#loadPath#">
						<cfcatch>
							<!--- it already exists, do nothing--->
						</cfcatch>
					</cftry>
					loadpath: #loadPath#
					fileName: #fileName#
					<cffile action="copy" source="#Application.webDirectory#/temp/#fileName#" 
       			 	destination="#loadPath#" 
        			nameConflict="OVERWRITE">
		
						<cfset thisExtension = #right(fileName,find(".",reverse(fileName)))#>
						<cfset thumbnailName = "tn_#fileName#">
						<cfset thumbnailName = replace(thumbnailName,thisExtension,"","last")>
						<cfset thumbnailName = "#thumbnailName#.jpg">
								thumbnailName: #thumbnailName#	
						<cfset jpegName = replace(thumbnailName,"tn_","mjp_")>
								jpegName: #jpegName#
								
						<!--- remove previous thumbnails and small jpegs --->
						<cftry>
							<cffile action="delete" file="#loadPath#/#thumbnailName#">
							<cfcatch><!--- whatever, doesn't exist ---></cfcatch>
						</cftry>
						<cftry>
							<cffile action="delete" file="#loadPath#/#jpegName#">
							<cfcatch><!--- whatever, doesn't exist ---></cfcatch>
						</cftry>
						<cfexecute name="#Application.convertPath#" 
							arguments="-thumbnail 100x100 #loadPath#/#fileName# #loadPath#/#thumbnailName#">
						</cfexecute>
						<cfexecute name="#Application.convertPath#" 
							arguments="-adaptive-resize x800 -quality 20 #loadPath#/#fileName# #loadPath#/#jpegName#">
						</cfexecute>
				<cfelse>
					The extension you provided is not recognized. Accepted extensions are #goodExtensions#.
				Please rename your file and try again.
				<cfabort>
				</cfif>
			</cfif>
	</cfif>
	<!-- kill the temp file --->
	<cffile action="delete" file="#Application.webDirectory#/temp/#fileName#">
	
	<cfset newURL = "#Application.ServerRootUrl#/SpecimenImages/#thisPath#/#fileName#">

<cflocation url="editImages.cfm?collection_object_id=#collection_object_id#&newURL=#newURL#" addtoken="no">
<!---

--->

</cfoutput>

</cfif>

<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "newImage">
	<cfquery name= "getEntBy" datasource="#Application.web_user#">
		SELECT agent_id FROM agent_name WHERE agent_name = '#client.username#' 
	</cfquery>
				<cfif getEntBy.recordcount is 0>
					<cfabort showerror = "You aren't a recognized agent!">
				<cfelseif getEntBy.recordcount gt 1>
					<cfabort showerror = "Your login has has multiple matches.">
				</cfif>
				<cfset enteredbyid = getEntBy.agent_id>
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
	<cftransaction action="commit">
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
			 </cfif> )

	</cfquery>
	
	</cftransaction>
	<cflocation url="editImages.cfm?collection_object_id=#collection_object_id#&content_url=#cgi.SCRIPT_NAME#">
</cfif>
<!----------------------------------------------------------------------------------->

<cfoutput>
<script type="text/javascript" language="javascript">
		changeStyle('#ins.institution_acronym#');
		parent.dyniframesize();
</script>
</cfoutput>