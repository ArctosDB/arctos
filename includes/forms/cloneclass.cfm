<cfinclude template="/includes/alwaysInclude.cfm">
<cfoutput>
<cfif action is "nothing">
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<p>
		This form clones (copies) a classification from one name to another. You MUST edit the new data, which will contain
		information from the source classification, and you may need to delete
		any "old" classification data in the record to which you're adding this classification.
	</p>
	<p>
		Terms not in cttaxon_term will be ignored.
	</p>
	<form name="newCC" method="post" action="cloneclass.cfm">
		<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
		<input type="hidden" name="tgt_taxon_name_id">
		<input type="hidden" name="classification_id" value="#classification_id#">
		<input type="hidden" name="action" value="newCC">
		<p>
			1) Pick a target taxon name (the one which will get the new data)
			<input type="text" name="tgtName" class="reqdClr" size="50" required
				onChange="taxaPick('tgt_taxon_name_id','tgtName','newCC',this.value); return false;"
				onKeyPress="return noenter(event);">
		</p>
		<p>
			2) Pick a source for the new classification
			<br>
			<select name="source" id="source" class="reqdClr" required>
				<option></option>
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
		</p>
		<p>
			3) Review what's being cloned into the name you picked above. (You'll be able to edit after the cloning process.)

			<cfquery name="d" datasource="uam_god">
				select
					v_mv_sciname_term.term,
					v_mv_sciname_term.term_type,
					v_mv_sciname_term.position_in_classification
				from
					v_mv_sciname_term,
					cttaxon_term
				where
					taxon_name_id=#taxon_name_id# and
					classification_id='#classification_id#' and
					v_mv_sciname_term.term_type=cttaxon_term.TAXON_TERM
			</cfquery>
			<cfquery name="nct" dbtype="query">
				select term,term_type from d where position_in_classification is null order by term_type
			</cfquery>
			<p>
				Non-classification terms
				<ul>
					<cfloop query="nct">
						<li>#term_type#=#term#</li>
					</cfloop>
				</ul>
				<cfquery name="ct" dbtype="query">
					select term,term_type from d where position_in_classification is not null order by position_in_classification
				</cfquery>
				<br>Classification terms
				<cfset indent=0>
				<ul>
					<cfloop query="ct">
						<li style="margin-left:#indent#em;">#term_type#=#term#</li>
						<cfset indent=indent+1>
					</cfloop>
				</ul>
			</p>
		</p>
		4) Finalize. A new window with the new data under the name you picked above will open when you click the button below.
			The new classification record
			will contain data from the "source" and must be edited. You may need to delete "old" data as well. Click "view taxon page"
			and carefully review what you've done before leaving.
		<p>
			<input type="submit" class="insBtn" value="create and edit classification">
		</p>
	</form>
</cfif>
<cfif action is "newCC">
	<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			TERM,
			TERM_TYPE,
			POSITION_IN_CLASSIFICATION
		from
			taxon_term,
			cttaxon_term
		where
			taxon_name_id=#taxon_name_id# and
			classification_id='#classification_id#' and
			taxon_term.term_type=cttaxon_term.TAXON_TERM
		group by
			TERM,
			TERM_TYPE,
			POSITION_IN_CLASSIFICATION
	</cfquery>
	<cfset thisSourceID=CreateUUID()>
	<cftransaction>
		<cfloop query="seedClassification">
			<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into taxon_term (
					TAXON_NAME_ID,
					CLASSIFICATION_ID,
					TERM,
					TERM_TYPE,
					SOURCE,
					POSITION_IN_CLASSIFICATION
				) values (
					#tgt_taxon_name_id#,
					'#thisSourceID#',
					'#TERM#',
					'#TERM_TYPE#',
					'#SOURCE#',
					<cfif len(POSITION_IN_CLASSIFICATION) is 0>
						NULL
					<cfelse>
						#POSITION_IN_CLASSIFICATION#
					</cfif>
				)
			</cfquery>
		</cfloop>
	</cftransaction>
	Classification cloned, it is now safe to close this window.
	<p>
		You should have already been redirected to
		<a href="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#&TAXON_NAME_ID=#tgt_taxon_name_id#" target="_blank">
			/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#&TAXON_NAME_ID=#tgt_taxon_name_id#
		</a> in a new window
	</p>
	 <script type="text/javascript">
        window.open("/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#&TAXON_NAME_ID=#tgt_taxon_name_id#", '_blank');
    </script>
</cfif>
</cfoutput>