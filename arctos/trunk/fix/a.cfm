<cfinclude template="/includes/_header.cfm">


<style>
#cboxdiv {
   	width: 30em;
	height: 3em;
	border: 1px solid;
	resize: vertical;
	overflow: auto;
    min-height:2em;
    max-height:20em;
}


.cboxdiv_allnone {
	text-align:center;
}
.cboxdiv_allnone span {
	padding-left:2em;
	padding-right:2em;
}
.cboxdiv_option {
	border:1px light gray;
}
</style>
<cfoutput>
<cfif action is "ftest">
	<cfdump var=#form#>
</cfif>

	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT institution_acronym, collection, collection_id FROM collection order by collection
	</cfquery>
	<form method="post">
	<input name="action" value="ftest">
<select name="collection_id" id="collection_id" size="3" multiple="multiple">
								<cfloop query="ctInst">
									<option value="#ctInst.collection_id#">#ctInst.collection#</option>
								</cfloop>
							</select>
							<input type="submit">
							
							
							<div id="cboxdiv">
								<div class="cboxdiv_allnone">
									<span class="likeLink" onclick="$('input[name^=cid]').prop('checked',true);">[ all ]</span>									
									<span class="likeLink" onclick="$('input[name^=cid]').prop('checked',false);">[ none ]</span>
								</div>
							<cfloop query="ctinst">
								<div class="cboxdiv_option">
									<input type="checkbox" name="cid" value=#collection_id#> #collection#
								</div>
							</cfloop>
							</div>
			</form>		



</cfoutput>