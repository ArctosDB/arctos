<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/internalAjax.js'></script>
<cfif action is "nothing" and isdefined("publication_id") and isnumeric(publication_id)>
	<cfoutput><cflocation url="Publication.cfm?action=edit&publication_id=#publication_id#" addtoken="false"></cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "edit">
<cfset title = "Edit Publication">
<cfoutput>
	<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">Publication Details</a>
	<br>
	<cfquery name="ctpublication_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select publication_type from ctpublication_type order by publication_type
	</cfquery>
	<cfquery name="pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from publication where publication_id=#publication_id#
	</cfquery>
	<cfquery name="auth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			publication_agent_id,
			publication_agent.agent_id,
			agent_name,
			author_role 
		from 
			publication_agent,
			preferred_agent_name 
		where 
			publication_agent.agent_id=preferred_agent_name.agent_id and 
			publication_id=#publication_id#
		order by agent_name
	</cfquery>
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	<form name="editPub" method="post" action="Publication.cfm">
		<input type="hidden" name="publication_id" value="#pub.publication_id#">
		<input type="hidden" name="action" value="saveEdit">
		<table>
			<tr>
				<td>
					<label for="full_citation" onclick="getDocs('publication','full_citation')" class="likeLink">Full Citation</label>
					<textarea name="full_citation" id="full_citation" class="reqdClr" rows="3" cols="80">#pub.full_citation#</textarea>
				</td>
				<td>
					<span class="infoLink" onclick="italicize('publication_title')">italicize selected text</span>
					<br><span class="infoLink" onclick="bold('publication_title')">bold selected text</span>
					<br><span class="infoLink" onclick="superscript('publication_title')">superscript selected text</span>
					<br><span class="infoLink" onclick="subscript('publication_title')">subscript selected text</span>
				</td>
			</tr>
		</table>
		<label for="short_citation" onclick="getDocs('publication','short_citation')" class="likeLink">Short Citation</label>
		<input type="text" id="short_citation" name="short_citation" value="#pub.short_citation#" size="80">
		<table>
			<tr>
				<td>
					<label for="publication_type" onclick="getDocs('publication','type')" class="likeLink">Publication Type</label>
					<select name="publication_type" id="publication_type" class="reqdClr">
						<option value=""></option>
						<cfloop query="ctpublication_type">
							<option <cfif publication_type is pub.publication_type> selected="selected" </cfif>
								value="#publication_type#">#publication_type#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<label for="is_peer_reviewed_fg" onclick="getDocs('publication','peer_review')" class="likeLink">Peer Reviewed?</label>
					<select name="is_peer_reviewed_fg" id="is_peer_reviewed_fg" class="reqdClr">
						<option <cfif pub.is_peer_reviewed_fg is 1> selected="selected" </cfif>value="1">yes</option>
						<option <cfif pub.is_peer_reviewed_fg is 0> selected="selected" </cfif>value="0">no</option>
					</select>	
				</td>
				<td>
					<label for="published_year" onclick="getDocs('publication','published_year')" class="likeLink">Published Year</label>
					<input type="text" name="published_year" id="published_year" value="#pub.published_year#">
				</td>
			</tr>
		</table>
		<label for="publication_loc">Storage Location</label>
		<input type="text" name="publication_loc" id="publication_loc" size="80" value="#pub.publication_loc#">
		<label for="publication_remarks">Remark</label>
		<input type="text" name="publication_remarks" id="publication_remarks" size="80" value="#pub.publication_remarks#">
		<p></p>
		<span class="likeLink" onclick="getDocs('publication','author')">Current Authors</span>
		<table border id="authTab">
			<tr>
				<th>Role</th>
				<th>Name</th>
				<th></th>
			</tr>
			<cfset i=0>
			<cfloop query="auth">
				<cfset i=i+1>
				<input type="hidden" name="agent_id#i#" id="agent_id#i#" value="#agent_id#">
				<input type="hidden" name="publication_agent_id#i#" id="publication_agent_id#i#" value="#publication_agent_id#">
				<tr id="authortr#i#">
					<td>
						<select name="author_role#i#" id="author_role#i#">
							<option <cfif author_role is "author"> selected="selected" </cfif>value="author">author</option>
							<option <cfif author_role is "editor"> selected="selected" </cfif>value="editor">editor</option>
						</select>
					</td>
					<td>
						<input type="text" name="author_name#i#" id="author_name#i#" class="reqdClr" size="50"
							onchange="getAgent('agent_id#i#',this.name,'editPub',this.value)"
		 					onkeypress="return noenter(event);"
		 					value="#agent_name#">
					</td>
					<td>
						<span class="infoLink" onclick="deleteAgent(#i#)">Delete</span>
					</td>
				</tr>
			</cfloop>
			<input type="hidden" name="numberAuthors" id="numberAuthors" value="#i#">
		</table>
		<span class="likeLink" onclick="getDocs('publication','author')">Add Authors</span>
		<table border id="authTab" class="newRec">
			<tr>
				<th>Role</th>
				<th>Name</th>
				<th></th>
			</tr>
			<cfset numNewAuths="3">
			<cfloop from="1" to="#numNewAuths#" index="i">
				<input type="hidden" name="n_agent_id#i#" id="n_agent_id#i#">
				<tr id="n_authortr#i#">
					<td>
						<select name="n_author_role#i#" id="n_author_role#i#">
							<option value="author">author</option>
							<option value="editor">editor</option>
						</select>
					</td>
					<td>
						<input type="text" name="n_author_name#i#" id="n_author_name#i#" class="reqdClr" size="50"
							onchange="getAgent('n_agent_id#i#',this.name,'editPub',this.value)"
		 					onkeypress="return noenter(event);">
					</td>
					<td>
						-
					</td>
				</tr>
			</cfloop>
			<input type="hidden" name="numNewAuths" id="numNewAuths" value="#numNewAuths#">
		</table>
		<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		    select distinct 
		        media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri
		     from
		         media,
		         media_relations,
		         media_labels
		     where
		         media.media_id=media_relations.media_id and
		         media.media_id=media_labels.media_id (+) and
		         media_relations.media_relationship like '%publication' and
		         media_relations.related_primary_key = #publication_id#
		</cfquery>
		<cfif media.recordcount gt 0>
			Click Media Details to edit Media or remove the link to this Publication.
			<div class="thumbs">
				<div class="thumb_spcr">&nbsp;</div>
				<cfloop query="media">
					<cfset puri=getMediaPreview(preview_uri,media_type)>
	            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select
							media_label,
							label_value
						from
							media_labels
						where
							media_id=#media_id#
					</cfquery>
					<cfquery name="desc" dbtype="query">
						select label_value from labels where media_label='description'
					</cfquery>
					<cfset alt="Media Preview Image">
					<cfif desc.recordcount is 1>
						<cfset alt=desc.label_value>
					</cfif>
	               <div class="one_thumb">
		               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#" class="theThumb"></a>
	                   	<p>
							#media_type# (#mime_type#)
		                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
							<br>#alt#
						</p>
					</div>
				</cfloop>
				<div class="thumb_spcr">&nbsp;</div>
			</div>
		</cfif>
		<div class="cellDiv">
			Add Media:
			<div style="font-size:small">
				 Yellow cells are only required if you supply or create a URI. You may leave this section blank.
				 <br>Find Media and create a relationship to link existing Media to this Publication.
			</div>
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90" class="reqdClr"><span class="infoLink" id="uploadMedia">Upload</span>
			<label for="preview_uri">Preview URI</label>
			<input type="text" name="preview_uri" id="preview_uri" size="90">
			<label for="mime_type">MIME Type</label>
			<select name="mime_type" id="mime_type" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctmime_type">
					<option value="#mime_type#">#mime_type#</option>
				</cfloop>
			</select>
           	<label for="media_type">Media Type</label>
			<select name="media_type" id="media_type" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctmedia_type">
					<option value="#media_type#">#media_type#</option>
				</cfloop>
			</select>
			<label for="media_desc">Media Description</label>
			<input type="text" name="media_desc" id="media_desc" size="80" class="reqdClr">
		</div>
			<input type="hidden" name="origNumberLinks" id="origNumberLinks" value="#i#">
			<input type="hidden" name="numberLinks" id="numberLinks" value="#i#">
			<br><input type="button" value="save" class="savBtn" onclick="editPub.action.value='saveEdit';editPub.submit();">
			<input type="button" value="Delete Publication" class="delBtn" onclick="editPub.action.value='deletePub';confirmDelete('editPub');">
	</form>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "deletePub">
	<cftransaction>
		<cfquery name="dpublication_author_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from publication_author_name where publication_id=#publication_id#
		</cfquery>
		<cfquery name="dpublication" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from publication where publication_id=#publication_id#
		</cfquery>
	</cftransaction>
	it's gone.
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "saveEdit">
<cfoutput>
	<cftransaction>
		<cfquery name="pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update publication set
				published_year=<cfif len(published_year) gt 0>#published_year#<cfelse>NULL</cfif>,
				publication_type='#publication_type#',
				publication_loc='#publication_loc#',
				full_citation='#escapeQuotes(full_citation)#',
				short_citation='#escapeQuotes(short_citation)#',
				publication_remarks='#escapeQuotes(publication_remarks)#',
				is_peer_reviewed_fg=#is_peer_reviewed_fg#				
			where publication_id=#publication_id#
		</cfquery>
		<cfif len(media_uri) gt 0>
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_media_id.nextval nv from dual
			</cfquery>
			<cfset media_id=mid.nv>
			<cfquery name="makeMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media (media_id,media_uri,mime_type,media_type,preview_uri)
	            values (#media_id#,'#escapeQuotes(media_uri)#','#mime_type#','#media_type#','#preview_uri#')
			</cfquery>
			<cfquery name="makeRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media_relations (
					media_id,
					media_relationship,
					related_primary_key
				) values (
					#media_id#,
					'shows publication',
					#publication_id#
				)
			</cfquery>
			<cfquery name="makeRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media_labels (
					media_id,
					media_label,
					label_value)
				values (#media_id#,'description','#media_desc#')
			</cfquery>
		</cfif>
		
		<cfloop from="1" to="#numberAuthors#" index="n">
			<cfset publication_agent_id = evaluate("publication_agent_id" & n)>
			<cfset agent_id = evaluate("agent_id" & n)>
			<cfset author_role = evaluate("author_role" & n)>
			<cfset author_name = evaluate("author_name" & n)>
			<cfif author_name is "deleted">
				<cfquery name="delAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					delete from publication_agent where 
					publication_agent_id=#publication_agent_id# 
				</cfquery>
			<cfelse>
				<cfquery name="uAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update publication_agent set
						agent_id=#agent_id#,
						author_role='#author_role#'
					where
						publication_agent_id=#publication_agent_id# 
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop from="1" to="#numNewAuths#" index="n">
			<cfset agent_id = evaluate("n_agent_id" & n)>
			<cfset author_role = evaluate("n_author_role" & n)>
			<cfif len(agent_id) gt 0>
				<cfquery name="insAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into publication_agent (
						publication_id,
						agent_id,
						author_role
					) values (
						#publication_id#,
						#agent_id#,
						'#author_role#'
					)
				</cfquery>
			</cfif>
		</cfloop>
		
	</cftransaction>
	<cflocation url="Publication.cfm?action=edit&publication_id=#publication_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "newPub">
<cfset title = "Create Publication">
	<cfquery name="ctpublication_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select publication_type from ctpublication_type order by publication_type
	</cfquery>
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	<style>
		.missing {
			border:2px solid red;
			}
	</style>
	<script>
		function confirmpub() {
			var r=true;
			var msg='';
			$('.missing').removeClass('missing');
			$('.reqdClr').each(function() {
                var thisel=$("#" + this.id)
                if ($(thisel).val().length==0){
                	msg += this.id + ' is required\n';
                	$(thisel).addClass('missing');
                }                
        	});
        	if (msg.length>0){
        		msg+='You may remove unwanted attributes';
        		alert(msg);
        		return false;
        	} else {
        		return true;
        	}
		}
		function toggleMedia() {
			if($('#media').css('display')=='none') {
				$('#mediaToggle').html('[ Remove Media ]');
				$('#media').show();
				$('#media_uri').addClass('reqdClr');
				$('#preview_uri').addClass('reqdClr');
				$('#mime_type').addClass('reqdClr');
				$('#media_type').addClass('reqdClr');
				$('#media_desc').addClass('reqdClr');
			} else {
				$('#mediaToggle').html('[ Add Media ]');
				$('#media').hide();
				$('#media_uri').val('').removeClass('reqdClr');
				$('#preview_uri').val('').removeClass('reqdClr');
				$('#mime_type').val('').removeClass('reqdClr');
				$('#media_type').val('').removeClass('reqdClr');
				$('#media_desc').val('').removeClass('reqdClr');
			}
		}
		function doiMagic(){
			$("#doilookup").html('<image src="/images/indicator.gif">');
			//alert('This isn\'t really magic. It just looks up a DOI at CrossRef. It will fail if you do not supply a valid DOI, or if the publisher does\'t use CrossRef, and probably for some other reasons. If you get results, check them VERY carefully.');
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "doiMagic",
					doi : $('#doi').val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (d) {
					if(d.DATA.STATUS=='FAIL'){
						alert('sorray');
					} else {
						$("#full_citation").val(d.DATA.LONGCITE);
						$("#short_citation").val(d.DATA.SHORTCITE);
						$("#publication_type").val(d.DATA.PUBLICATIONTYPE);
						$("#is_peer_reviewed_fg").val(1);
						$("#published_year").val(d.DATA.YEAR);
						$("#short_citation").val(d.DATA.SHORTCITE);
						for (i = 1; i<5; i++) {
							var thisAuthStr=eval("d.DATA.AUTHOR"+i);
							console.log('thisAuthStr:' + thisAuthStr);
							var thisAuthAry = new Array();
							
							var thisAuthStr="bob|jim";
							
							thisAuthAry=thisAuthStr.split("|");
							console.log('split it....');
							for (a = 0; i<thisAuthAry.length; i++) {
								var thisAuthRec=thisAuthAry[a].split('::');
								var thisAgentName=thisAuthRec[0];
								var thisAgentID=thisAuthRec[1];
								var thisSuggest='<span class="infoLink" onclick="useThisAuthor(' + "'" + thisAgentName + "','" + thisAgentID + "')>" + thisAgentName + "</span>";
								console.log(thisSuggest);
							}
						}
					}	
				}
			);
			$("#doilookup").html(' [ crossref ] ');
		}
	</script>
	<!----
	
	
		<cfset temp = QuerySetCell(d, "AUTHORS", rauths, 1)>
	
	------>
	<cfoutput>
		<form name="newpub" method="post" onsubmit="if (!confirmpub()){return false;}" action="Publication.cfm">
			<label for="doi" onclick="getDocs('publication','doi')" class="likeLink">DOI</label>
			<input type="text" id="doi" name="doi" value="10.1111/j.1365-294X.2005.02461.x" size="80"><span class="infoLink" id="doilookup" onclick="doiMagic()"> [ crossref ] </span>
			<input type="hidden" name="action" value="createPub">
			<table>
				<tr>
					<td>
						<label for="full_citation" onclick="getDocs('publication','full_citation')" class="likeLink">Full Citation</label>
						<textarea name="full_citation" id="full_citation" class="reqdClr" rows="3" cols="80"></textarea>
					</td>
					<td>
						<span class="infoLink" onclick="italicize('publication_title')">italicize selected text</span>
						<br><span class="infoLink" onclick="bold('publication_title')">bold selected text</span>
						<br><span class="infoLink" onclick="superscript('publication_title')">superscript selected text</span>
						<br><span class="infoLink" onclick="subscript('publication_title')">subscript selected text</span>
					</td>
				</tr>
			</table>
			<label for="short_citation" onclick="getDocs('publication','short_citation')" class="likeLink">Short Citation</label>
			<input type="text" id="short_citation" name="short_citation" value="" size="80">
			<table>
				<tr>
					<td>
						<label for="publication_type" onclick="getDocs('publication','type')" class="likeLink">Publication Type</label>
						<select name="publication_type" id="publication_type" class="reqdClr">
							<option value=""></option>
							<cfloop query="ctpublication_type">
								<option value="#publication_type#">#publication_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="is_peer_reviewed_fg" onclick="getDocs('publication','peer_review')" class="likeLink">Peer Reviewed?</label>
						<select name="is_peer_reviewed_fg" id="is_peer_reviewed_fg" class="reqdClr">
							<option value="1">yes</option>
							<option value="0">no</option>
						</select>	
					</td>
					<td>
						<label for="published_year" onclick="getDocs('publication','published_year')" class="likeLink">Published Year</label>
						<input type="text" name="published_year" id="published_year" value="">
					</td>
				</tr>
			</table>
			<label for="publication_loc">Storage Location</label>
			<input type="text" name="publication_loc" id="publication_loc" size="80" value="">
			<label for="publication_remarks">Remark</label>
			<input type="text" name="publication_remarks" id="publication_remarks" size="80" value="">
			<p></p>
			<span class="likeLink" onclick="getDocs('publication','author')">Add Authors</span>
			<table border id="authTab" class="newRec">
				<tr>
					<th>Role</th>
					<th>Name</th>
					<th></th>
				</tr>
				<cfset numNewAuths="5">
				<cfloop from="1" to="#numNewAuths#" index="i">
					<input type="hidden" name="n_agent_id#i#" id="n_agent_id#i#">
					<tr id="n_authortr#i#">
						<td>
							<select name="n_author_role#i#" id="n_author_role#i#">
								<option value="author">author</option>
								<option value="editor">editor</option>
							</select>
						</td>
						<td>
							<input type="text" name="n_author_name#i#" id="n_author_name#i#" class="reqdClr" size="50"
								onchange="getAgent('n_agent_id#i#',this.name,'newpub',this.value)"
			 					onkeypress="return noenter(event);">
						</td>
						<td id="authSugg#i#">
							
						</td>
					</tr>
				</cfloop>
			</table>
			<input type="hidden" name="numNewAuths" id="numNewAuths" value="#numNewAuths#">
			
			
			<span class="likeLink" id="mediaToggle" onclick="toggleMedia()">[ Add Media ]</span>
			<div class="cellDiv" id="media" style="display:none">
				Media:
				<label for="media_uri">Media URI</label>
				<input type="text" name="media_uri" id="media_uri" size="90"><span class="infoLink" id="uploadMedia">Upload</span>
				<label for="preview_uri">Preview URI</label>
				<input type="text" name="preview_uri" id="preview_uri" size="90">
				<label for="mime_type">MIME Type</label>
				<select name="mime_type" id="mime_type">
					<option value=""></option>
					<cfloop query="ctmime_type">
						<option value="#mime_type#">#mime_type#</option>
					</cfloop>
				</select>
            	<label for="media_type">Media Type</label>
				<select name="media_type" id="media_type">
					<option value=""></option>
					<cfloop query="ctmedia_type">
						<option value="#media_type#">#media_type#</option>
					</cfloop>
				</select>
				<label for="media_desc">Media Description</label>
				<input type="text" name="media_desc" id="media_desc" size="80">
			</div>
			<br><input type="submit" value="create publication" class="insBtn">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "createPub">
<cfoutput>
	<cftransaction>
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select sq_publication_id.nextval p from dual
		</cfquery>
		<cfset pid=p.p>
		<cfquery name="pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into publication (
				publication_id,
				published_year,
				publication_type,
				publication_loc,
				full_citation,
				short_citation,
				publication_remarks,
				is_peer_reviewed_fg
			) values (
				#pid#,
				<cfif len(published_year) gt 0>#published_year#<cfelse>NULL</cfif>,
				'#publication_type#',
				'#publication_loc#',
				'#escapeQuotes(full_citation)#',
				'#escapeQuotes(short_citation)#',
				'#publication_remarks#',
				#is_peer_reviewed_fg#
			)
		</cfquery>
		<cfloop from="1" to="#numNewAuths#" index="n">
			<cfset agent_id = evaluate("n_agent_id" & n)>
			<cfset author_role = evaluate("n_author_role" & n)>
			<cfif len(agent_id) gt 0>
				<cfquery name="insAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into publication_agent (
						publication_id,
						agent_id,
						author_role
					) values (
						#publication_id#,
						#agent_id#,
						'#author_role#'
					)
				</cfquery>
			</cfif>
		</cfloop>
		<cfif len(media_uri) gt 0>
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_media_id.nextval nv from dual
			</cfquery>
			<cfset media_id=mid.nv>
			<cfquery name="makeMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media (media_id,media_uri,mime_type,media_type,preview_uri)
	            values (#media_id#,'#escapeQuotes(media_uri)#','#mime_type#','#media_type#','#preview_uri#')
			</cfquery>
			<cfquery name="makeRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media_relations (
					media_id,
					media_relationship,
					related_primary_key
				) values (
					#media_id#,
					'shows publication',
					#pid#
				)
			</cfquery>
			<cfquery name="makeRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media_labels (
					media_id,
					media_label,
					label_value)
				values (#media_id#,'description','#media_desc#')
			</cfquery>
		</cfif>					
	</cftransaction>
	<cflocation url="Publication.cfm?action=edit&publication_id=#pid#" addtoken="false">
</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">