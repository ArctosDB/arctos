
<cfoutput>

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