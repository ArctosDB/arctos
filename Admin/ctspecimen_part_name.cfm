<cfinclude template="/includes/_header.cfm">
<script>
	function doneSaving(){
		$('#frame_ctspid').remove();
		$('#annotateDiv').remove();
		$('#bgDiv').remove();
	}
	function deletePart(ctspnid){
		var answer = confirm("Delete Part?")
		if (answer){
			$.getJSON("/component/functions.cfc",
				{
					method : "deleteCtPartName",
					ctspnid : ctspnid,
					returnformat : "json",
					queryformat : 'column'
				},
				function(r) {
					if (r == ctspnid) {
						$('tr#r' + ctspnid).remove();
					} else {
						alert('An error occured! \n ' + r);
					}
				}
			);
		}
	}
	function updatePart(ctspnid) {
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		document.body.appendChild(bgDiv);
		bgDiv.setAttribute('onclick','doneSaving()');
		var theDiv = document.createElement('div');
		theDiv.id = 'annotateDiv';
		theDiv.className = 'annotateBox';
		theDiv.innerHTML='';
		theDiv.src = "";
		document.body.appendChild(theDiv);
		$('#annotateDiv').append('<IFRAME id="frame_ctspid" width="100%" height="100%">');
	  	var guts = "/includes/forms/f_ctspecimen_part_name.cfm?ctspnid=" + ctspnid;
	    $('iframe#frame_ctspid').attr('src', guts);
	    $('iframe#frame_ctspid').load(function()
	    {
	        viewport.init("#annotateDiv");
	    });
	}
	function successUpdate(ctspnid,collection_cde,part_name,is_tissue,description,upAllDesc,upAllTiss) {
		if(	upAllDesc==1 || upAllTiss==1 ) {
			document.location=document.location;
		}

		var r='<td>' + collection_cde + '</td><td>' + part_name + '</td><td>' + is_tissue + '</td>';
		r+='<td>' + unescape(description) + '</td><td nowrap="nowrap">';
		r+='<span class="likeLink" onclick="deletePart(' + ctspnid + ')">[ Delete ]</span><br>';
		r+='<span class="likeLink" onclick="updatePart(' + ctspnid + ')">[ Update ]</span>';
		$('tr#r' + ctspnid).children().remove();
		$('tr#r' + ctspnid).append(r);
		doneSaving();
	}


</script>




<cfif action is "nothing">
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from ctspecimen_part_name
		ORDER BY
			collection_cde,part_name
	</cfquery>
	<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct collection_cde from ctcollection_cde order by collection_cde
	</cfquery>
	<cfoutput>
		Add record:
		<table class="newRec" border="1">
			<tr>
				<th>Collection Type</th>
				<th>Part Name</th>
				<td>IsTissue</td>
				<th>Description</th>
			</tr>
			<form name="newData" method="post" action="">
				<input type="hidden" name="action" value="insert">
				<tr>
					<td>
						<select name="collection_cde" size="1">
							<cfloop query="ctcollcde">
								<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="part_name">
					</td>
					<td>
						<select name="is_tissue">
							<option value="0">no</option>
							<option value="1">yes</option>
						</select>
					</td>
					<td>
						<textarea name="description" id="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="submit" value="Insert" class="insBtn">
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit
		<table border="1">
			<tr>
				<th>Collection Type</th>
				<th>part_name</th>
				<th>IsTissue</th>
				<th>Description</th>
			</tr>
			<cfquery name="pname" dbtype="query">
				select part_name from q group by part_name order by part_name
			</cfquery>
			<cfloop query="pname">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<cfquery name="pd" dbtype="query">
						select * from q where part_name='#part_name#' order by collection_cde
					</cfquery>
					<td>
						<cfloop query="pd">
							<div>
								#collection_cde#
							</div>
						</cfloop>
					</td>
					<td>
						#part_name#
					</td>
					<td>
						<cfquery name="ist" dbtype="query">
							select is_tissue from pd group by is_tissue
						</cfquery>
						<cfif ist.recordcount gt 0>
							is tissue inconsistency!!!
						<cfelse>
							#ist.is_tissue#

						</cfif>

					</td>
				</tr>
			</cfloop>

			<!----
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# id="r#ctspnid#">
					<td>#collection_cde#</td>
					<td>#q.part_name#</td>
					<td>#is_tissue#</td>
					<td>#q.description#</td>
					<td nowrap="nowrap">
						<span class="likeLink" onclick="deletePart(#ctspnid#)">[ Delete ]</span>
						<br><span class="likeLink" onclick="updatePart(#ctspnid#)">[ Update ]</span>
					</td>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
			---->
		</table>
	</cfoutput>
</cfif>
<cfif action is "insert">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) from ctspecimen_part_name where part_name='#part_name#' and
		(
			nvl(description,'NULL') != nvl('#description#','NULL') or
			is_tissue != #is_tissue#
		)
	</cfquery>
	<cfif d.recordcount gt 0>
		Definition and tissue status must match across collections.<cfabort>
	</cfif>
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into ctspecimen_part_name (
			collection_cde,
			part_name,
			DESCRIPTION,
			is_tissue
		) values (
			'#collection_cde#',
			'#part_name#',
			'#description#',
			#is_tissue#
		)
	</cfquery>
	<cflocation url="ctspecimen_part_name.cfm" addtoken="false">
</cfif>
<cfinclude template="/includes/_footer.cfm">