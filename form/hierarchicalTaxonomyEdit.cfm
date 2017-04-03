<cfinclude template="/includes/alwaysInclude.cfm">
<cfquery name="cttaxon_term" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from cttaxon_term
</cfquery>
<cfquery name="c" dbtype="query">
	select TAXON_TERM from cttaxon_term where IS_CLASSIFICATION=1 order by RELATIVE_POSITION
</cfquery>
<cfquery name="nc" dbtype="query">
	select TAXON_TERM from cttaxon_term where IS_CLASSIFICATION=0 order by TAXON_TERM
</cfquery>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select term,rank from hierarchical_taxonomy where tid=#tid#
</cfquery>
<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nc_tid,term_type,term_value from htax_noclassterm where tid=#tid#
</cfquery>
<!----------



			-------->
<script>
	function fcreateNewChildTerm(){
		alert('fcreateNewChildTerm');

		// create the term; if success, just expand the node to view
			var theID=$("#tid").val();

$.getJSON("/component/test.cfc",
				{
					method : "createTerm",
					//dataset_id: $("#dataset_id").val(),
					id : theID,
					newChildTerm: $("#newChildTerm").val(),
					newChildTermRank: $("#newChildTermRank").val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					alert(r);


					//console.log(r);
				//	if (r=='success'){
					//	alert('going to createdNewTerm');
						//parent.createdNewTerm(theID);
				//	} else {
					//	alert(r);
				//	}
				}
			);
	    }





	function deleteThis(){
		var d='Are you sure you want to DELETE this record?\n';
		d+='Deleting will NOT do anything to data in Arctos; delete incorrect';
		d+=' data in Arctos separately. Deleting this record will update all of this record\'s children to children of this';
		d+=' record\'s parent and remove this record from your dataset.\n'
	 	d+='Click confirm if you are absolutely sure that\'s what you want to do.\n'
	 	d+='IMPORTANT: If you delete a root node, and you probably should not delete a root node, the tree may disappear.';
	 	d+=' Click "reset tree" to rebuild.';
		var r = confirm(d);
		if (r == true) {
			var theID=$("#tid").val();
			$.getJSON("/component/test.cfc",
				{
					method : "deleteTerm",
					//dataset_id: $("#dataset_id").val(),
					id : theID,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					//console.log(r);
					alert(r);
					if (r=='success'){

						//alert('back; update parent and close if success');
						//alert('calling parent t with tid=' + theID + ' newVal=' + newVal);
						parent.deletedRecord(theID);
					} else {
						alert(r);
					}
				}
			);
		} else {
		    x = "You pressed Cancel!";
		}
	}
	function saveAllEdits(){
		// get vars
		var theID=$("#tid").val();
		var newVal=$("#term").val() + ' (' + $("#rank").val() + ')';
		var frm=$("#tEditFrm").serialize();
		console.log(frm);
		// save metadata

		 $.getJSON("/component/test.cfc",
				{
					method : "saveMetaEdit",
					//dataset_id: $("#dataset_id").val(),
					id : theID,
					q: frm,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					//console.log(r);
					if (r=='success'){

						//alert('back; update parent and close if success');
						//alert('calling parent t with tid=' + theID + ' newVal=' + newVal);
						parent.savedMetaEdit(theID,newVal);
					} else {
						alert(r);
					}
				}
			);


	}
</script>

		<br><input type="button" onclick="saveAllEdits()" class="savBtn" value="saveAllEdits">
		<br><input type="button" onclick="deleteThis()" class="delBtn" value="Delete">

<cfoutput>
<form id="tEditFrm">
	<input type="hidden" id="tid" name="tid" value="#tid#">
	<input type="hidden" id="term" name="term" value="#d.term#">


	<br>
	[ maybe a delete button too.
	<br>but not sure what that could do.
	<br>update {children_of_this} set parent_id={parent_of_this} and then flush the term maybe??
	<br>does that break anything??

	<table border>
		<tr>
			<td>
				Editing <strong>#d.term#</strong>
			</td>
			<td>
				<label for="rank">Rank</label>
				<select name="rank" id="rank">
					<cfloop query="c">
						<option value="#TAXON_TERM#" <cfif c.taxon_term is d.rank> selected="taxon_term" </cfif> >#TAXON_TERM#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>

	<p>
		Create a new child of this term.
		Adding here will NOT create Arctos taxonomy; if the taxon name of the term you are trying to add
		does not already exist, you must create it before saving this dataset back to Arctos.
		<br>New nodes will be created as a child of the term you are editing. Drag them to where they need to be and edit as usual.
		<br>
		<label for="newChildTerm">New Child Term Value</label>
		<input name="newChildTerm" id="newChildTerm" type="text" value="" placeholder='new taxon term' size="60">
		<label for="newChildTermRank">New Child Term Rank</label>
		<select name="newChildTermRank" id="newChildTermRank">
			<cfloop query="c">
				<option value="#TAXON_TERM#">#TAXON_TERM#</option>
			</cfloop>
		</select>
		<br><input type="button" onclick="fcreateNewChildTerm()" class="insBtn" value="fcreateNewChildTerm">


	</p>


	<table border>
		<tr>
			<th>Term</th>
			<th>Value</th>
		</tr>
	<cfloop query="t">
		<tr>
			<td>
				<select name="nctermtype_#nc_tid#" id="nctermtype_#nc_tid#">
					<option value='DELETE'>DELETE</option>
					<cfloop query="nc">
						<option value="#nc.taxon_term#" <cfif t.term_type is nc.taxon_term> selected="selected" </cfif> >#nc.taxon_term#</option>
					</cfloop>
				</select>
			</td>
			<td><input name="nctermvalue_#nc_tid#" id="nctermvalue_#nc_tid#" type="text" value="#t.term_value#" size="60"></td>
		</tr>
	</cfloop>
	<br>
	<cfloop from="1" to="10" index="i">
		<tr>
			<td>
				<select name="nctermtype_new_#i#" id="nctermtype_new_#i#">
					<option value="">pick to add term-value pair</option>
					<cfloop query="nc">
						<option value="#nc.TAXON_TERM#">#nc.TAXON_TERM#</option>
					</cfloop>
				</select>
			</td>
			<td><input name="nctermvalue_new_#i#" id="nctermvalue_new_#i#" type="text" size="60"></td>
		</tr>

	</cfloop>

	</table>
		<br><input type="button" onclick="saveAllEdits()" class="savBtn" value="saveAllEdits">

</form>
</cfoutput>