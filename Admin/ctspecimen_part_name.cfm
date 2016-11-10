<cfinclude template="/includes/_header.cfm">

<script type="text/javascript" src="/includes/tablesorter/tablesorter.js"></script>
<link rel="stylesheet" href="/includes/tablesorter/themes/blue/style.css">

<cfset title="ctspecimen_part_name editor">

<style>
	.edited{background:#eaa8b4;}
</style>
<script>

	//$("tr:odd").addClass("odd");

	//$("tr:odd").addClass("odd");

	$(document).ready(function()
    {
        $("#partstbl").tablesorter();
    }
);

	function updatePart(pn) {
		var rid='prow_' + pn.replace(/\W/g, '_');
		$("#" + rid).addClass('edited');
		var guts = "/includes/forms/f2_ctspecimen_part_name.cfm?part_name=" + encodeURI(pn);
		$("<iframe src='" + guts + "' id='dialog' class='popupDialog' style='width:600px;height:600px;'></iframe>").dialog({
			autoOpen: true,
			closeOnEscape: true,
			height: 'auto',
			modal: true,
			position: ['center', 'center'],
			title: 'Edit Part',
				width:800,
	 			height:600,
			close: function() {
				$( this ).remove();
			}
		}).width(800-10).height(600-10);
		$(window).resize(function() {
			$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
		});
		$(".ui-widget-overlay").click(function(){
		    $(".ui-dialog-titlebar-close").trigger('click');
		});
	}
</script>
<cfif action is "nothing">
	<div class="importantNotification">
		IMPORTANT!
		<p>
			Parts (including description and tissue-status) must be consistent across collection types; the definition
			(and eg, expected result of a search for the part)
			must be the same for all collections in which the part is used. That is, "operculum" cannot be used for fish gill covers
			as it has already been claimed to describe snail anatomy.
		</p>
		<p class="edited">
			Rows that look like this have been edited and may not be current; reload to refresh.
		</p>
	</div>


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
		<table class="newRec" border="1" >
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
		<table id="partstbl" border="1" class="tablesorter">
			<thead>
			<tr>
				<th>Collection Type</th>
				<th>part_name</th>
				<th>IsTissue</th>
				<th>Description</th>
			</tr>
			</thead>
			<tbody>
			<cfquery name="pname" dbtype="query">
				select part_name from q group by part_name order by part_name
			</cfquery>
			<cfloop query="pname">
			<cfset rid=rereplace(part_name,"[^A-Za-z0-9]","_","all")>

				<cfset canedit=true>
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# id="prow_#rid#">
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
						<cfif ist.recordcount gt 1>
							is tissue inconsistency!!!
							#valuelist(ist.is_tissue)#
							<cfset canedit=false>
						<cfelse>
							#ist.is_tissue#
						</cfif>
					</td>
					<td>
						<cfquery name="dsc" dbtype="query">
							select description from pd group by description
						</cfquery>
						<cfif dsc.recordcount gt 1>
							#valuelist(dsc.description)#
							<cfset canedit=false>
							description inconsistency!!!
							<cfdump var=#dsc#>
						<cfelse>
							#dsc.description#
						</cfif>
					</td>
					<td nowrap="nowrap">
						<cfif canedit is false>
							Inconsistent data;contact a DBA.
						<cfelse>
							<br><span class="likeLink" onclick="updatePart('#part_name#')">[ Update ]</span>
						</cfif>
					</td>
				</tr>
				<cfset i=i+1>
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
			</tbody>
		</table>
	</cfoutput>
</cfif>
<cfif action is "insert">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) from ctspecimen_part_name where part_name='#part_name#'
	</cfquery>
	<cfif d.recordcount gt 0>
		<cfthrow message="Part already exists; edit to add collection types.">
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