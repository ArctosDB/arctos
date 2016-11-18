<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfset title="bulkloader pre-bulkloader">
	<cfif action is "nothing">
		Pre-bulkloader magic lives here.
		<p>
			This app is in early beta. Lots of stuff won't work. Some stuff will probably make messes.
			Make backups of your backups at every step.
			<p>
				<a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulkloader">grab a copy of your data here</a>
			</p>
		</p>

		<p>
			Being beta, we may have stuff disabled. The "grab a donut" steps should take <1h for a few thousand records,
			a couple days for 500K - contact a DBA if it seems stuck.
		</p>

		<p>
			This form will NOT deal with multi-agent strings ("collector=you and me"). Split them out (there are agent tools) and load them
			as collector_agent_1=you,collector_agent_2=me, then use this form to download, standardize, and repatriate.
		</p>
		<p>
			Very few datasets will need everything in there.
		</p>
		<p>
			This may require iterative processes, eg, load, download geography, realize you have a giant mess, delete, fix your mess,
			load, download geography, rinse and repeat.
		</p>
		<p>
			File an Issue if we've missed something.
		</p>
		<p>
			This form deals in controlled data. Check code tables. All of Arctos is bitwise-indexed; characters that you cannot see still
			matter, values are case-sensitive, etc. Much of Arctos is data-driven - acceptable values for "attribute_value_x" depend on
			what's in "attribute_x."
		</p>
		<p>
			tl;dr:
			<ul>
				<li>Make lookup tables</li>
				<li>Repatriate data from them</li>
				<li>Rinse and repeat until all lookup tables are empty</li>
				<li>Fill in some defaults</li>
				<li>Bulkload</li>
			</ul>
		</p>
		<cfquery name="sts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select loaded,enteredby,count(*) numrecs from pre_bulkloader group by loaded,enteredby
		</cfquery>
		<p>
			Currrent state of pre-bulkloader:
			<div style="max-height:10em; overflow:scroll">
				<table border>
					<tr>
						<th>
							enteredby
						</th>
						<th>
							numrecs
						</th>
						<th>
							loaded
						</th>
					</tr>
					<cfloop query="sts">
						<tr>
							<td>#enteredby#</td>
							<td>#numrecs#</td>
							<td>#loaded#</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</p>
		<p>Howto:</p>

		<ol>
			<li><a href="pre_bulkloader.cfm?action=deleteAll">DELETE EVERYTHING from the pre-bulkloader</a>. Use with caution. Be courteous.</li>
			<li>
				Get your data into pre-bulkloader. The specimen bulkloader will push here. Dirty data is fine - that's the point.
				This form will do nothing for poorly-structured data (multi-agent strings, etc.).
			</li>
			<li>
				No collection_object_ids? Add them (any unique integer is OK) and re-load or
				<a href="pre_bulkloader.cfm?action=buildCollectionObjectID">click this to create them now</a>. Some checks will
				not run without them.
			</li>
			<li><a href="pre_bulkloader.cfm?action=precheckLoaded">Mark for pre-check</a>. NOTE: This will DELETE ALL lookup tables.</li>
			<li>Grab a donut. It'll take a while.</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The checks are done when ALL loaded=init_pull_complete</li>

			<cfset tbls="pre_bulk_agent,pre_bulk_taxa,pre_bulk_attributes,pre_bulk_oidt,pre_bulk_date,pre_bulk_parts">
			<cfset tbls=tbls & ",pre_bulk_disposition,pre_bulk_collrole,pre_bulk_accn,pre_bulk_geog,pre_bulk_NATURE_OF_ID,">
			<cfset tbls=tbls & "pre_bulk_ORIG_LAT_LONG_UNITS,pre_bulk_GEOREFERENCE_PROTOCOL,pre_bulk_VERIFICATIONSTATUS,pre_bulk_MAX_ERROR_UNITS,">
			<cfset tbls=tbls & "pre_bulk_COLLECTING_SOURCE,pre_bulk_DEPTH_UNITS,pre_bulk_DATUM">
			<li>
				Download Tables. Fill in shouldbe, reload below. Some table contain collection_cde, which will be ignored.
				<br>Do not edit the original column or replace will fail.
				<br>There are many agent cleanup tools in Arctos; use them, or contact a DBA for help.
				<br>There is a geography lookup/translation tool in Arctos; use it.
			<cfloop list="#tbls#" index="tbl">
				<cfquery name="rc" datasource='uam_god'>
					select count(*) c from #tbl#
				</cfquery>
				<ul>
					<li>
						Download <a href="/Admin/CSVAnyTable.cfm?tableName=#tbl#">#tbl#</a> (#rc.c#)
					</li>
				</ul>
			</cfloop>
			</li>
			<li>Fill in the blanks,then reload the lookup files.</li>
			<li>
				<cfloop list="#tbls#" index="tbl">
					<ul>
						<li>
							<a name="u_#tbl#"></a>
							<form name="up#tbl#" method="post" enctype="multipart/form-data" action="pre_bulkloader.cfm">
								<input type="hidden" name="action" value="getFile">
								<input type="hidden" name="table" value="#tbl#">
								<label for="FiletoUpload">Upload #tbl#</label>
								<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
								<input type="submit" value="Upload CSV" class="savBtn">
							 </form>
						</li>
					</ul>
				</cfloop>
			</li>

			<li>
				 <a href="pre_bulkloader.cfm?action=repatriate">repatriate the stuff you just re-loaded</a>
			</li>
			<li>
				Grab another donut. It'll take a while for the scripts to run.
			</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The repatriation is done when ALL loaded=repatriation_complete</li>
			<li>
				<cfset dfltnls=StructNew()>
				<cfset dfltnls.COLLECTOR_AGENT_1="unknown">
				<cfset dfltnls.COLLECTOR_ROLE_1="collector">
				<cfset dfltnls.EVENT_ASSIGNED_DATE="#dateformat(now(),'yyyy-mm-dd')#">
				<cfset dfltnls.EVENT_ASSIGNED_BY_AGENT="unknown">
				<cfset dfltnls.ID_MADE_BY_AGENT="unknown">
				<cfset dfltnls.SPECIMEN_EVENT_TYPE="accepted place of collection">
				<cfset dfltnls.PART_NAME_1="unknown">
				<cfset dfltnls.VERIFICATIONSTATUS="unverified">
				<cfset dfltnls.NATURE_OF_ID="legacy">
				<cfset dfltnls.MADE_DATE="#dateformat(now(),'yyyy-mm-dd')#">
				<cfset dfltnls.BEGAN_DATE="1800">
				<cfset dfltnls.ENDED_DATE="#dateformat(now(),'yyyy-mm-dd')#">
				<cfset dfltnls.VERBATIM_DATE="before #dateformat(now(),'yyyy-mm-dd')#">
				<cfset dfltnls.HIGHER_GEOG="no higher geography recorded">
				<cfset dfltnls.SPEC_LOCALITY="no specific locality recorded">
				<cfset dfltnls.VERBATIM_LOCALITY="no verbatim locality recorded">
				<cfset dfltnls.GUID_PREFIX="">
				<cfset dfltnls.ENTEREDBY="">

				Set defaults. ONLY when the following values are NULL, update them to...
				<br>(Clear the suggestion to do nothing.)
				<br>UPDATE pre_bulkloader SET
				<form name="dflt" method="post" action="pre_bulkloader.cfm">
					<!---
						coldfusion is stupid and doesn't put fields which end with
						_date in form.FIELDNAMES so....
					---->
					<cfset fldlist="">
					<cfloop collection = #dfltnls# item = "fld">
						<cfset fldlist=listappend(fldlist,fld)>
					</cfloop>
					<input type="hidden" name="fldlist" value="#fldlist#">
					<input type="hidden" name="action" value="setNullDefaults">
					<cfloop collection = #dfltnls# item = "fld">
						<label for="#fld#">#fld#=</label>
						<input type="text" name="#fld#" value="#StructFind(dfltnls, fld)#">,
					</cfloop>
					<br><input type="submit" value="make all changes">
				</form>

			</li>
			<li>
				Parts: when null, for each (not-null) part, update....
				<br>(remove suggestion to do nothing)
				<form name="pdflt" method="post" action="pre_bulkloader.cfm">
					<input type="hidden" name="action" value="setNullDefaultsParts">
					<label for="PART_CONDITION_n">PART_CONDITION_n=</label>
					<input type="text" name="PART_CONDITION_n" value="unchecked">,
					<label for="PART_LOT_COUNT_n">PART_LOT_COUNT_n=</label>
					<input type="text" name="PART_LOT_COUNT_n" value="1">,
					<label for="PART_DISPOSITION_n">PART_DISPOSITION_n=</label>
					<input type="text" name="PART_DISPOSITION_n" value="in collection">,
					<br><input type="submit" value="make all changes">
				</form>
			</li>
			<li>
				Attributes: when null, for each (not-null) attribute, update....
				<br>(remove suggestion to do nothing)
				<form name="atdflt" method="post" action="pre_bulkloader.cfm">
					<input type="hidden" name="action" value="setNullDefaultsAttribute">
					<label for="attribute_determiner_n">attribute_determiner_n=</label>
					<input type="text" name="attribute_determiner_n" value="unknown">,
					<label for="attribute_date_n">attribute_date_n=</label>
					<input type="text" name="attribute_date_n" value="#dateformat(now(),'yyyy-mm-dd')#">,
					<br><input type="submit" value="make all changes">
				</form>
			</li>

			<li>
				<a href="pre_bulkloader.cfm?action=goGoCoordinateMagic">goGoCoordinateMagic</a>. Guess at orig_lat_long_units,
				set metadata defaults for NULL fields, flag problems.
			</li>
			<li>
				<a name="tysql"></a>
				<form name="pdflt" method="post" action="pre_bulkloader.cfm">
					<input type="hidden" name="action" value="execSQL">
					SQL: SQL update anything.
					<label for="spf">Update pre_bulkloader set</label>
					<textarea name="spf" class="hugetextarea"></textarea>
					<label for="spw">WHERE (leave blank to update everything)</label>
					<textarea name="spw" class="hugetextarea"></textarea>
					<br><input type="submit" value="execute">
				</form>
			</li>
			<li>
				<a href="pre_bulkloader.cfm?action=deleteUnusedStuff">deleteUnusedStuff</a>. Removed data from eg, part_remarks when
				corresponding part_name is NULL. These are already ignored by bulkloader; this exists only to make the data
				more readable/portable.
			</li>

			<li>
				<a href="pre_bulkloader.cfm?action=ready_for_checkall">Mark for final check</a>. Click this when you think
				everything will load. It'll take some time.
			</li>
			<li>
				<a href="pre_bulkloader.cfm?action=instobulk">Push to bulkloader</a>. This may take a while; contact us if
				you have timeout issues. You'll have to click a couple buttons.
				Collection_object_id will be replaced. LOADED will be set to "pushed_from_prebulk."
			</li>
		</ol>
	</cfif>

	<cfif action is "goGoCoordinateMagic">
		<cfquery name="bah" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			select count(*) c from pre_bulkloader where
			(
				(dec_lat is not null or dec_long is not null) and
				(
					LATDEG is not null or
					DEC_LAT_MIN is not null or
					LATMIN is not null or
					LATSEC is not null or
					LATDIR is not null or
					LONGDEG is not null or
					DEC_LONG_MIN is not null or
					LONGMIN is not null or
					LONGSEC is not null or
					LONGDIR is not null or
					UTM_ZONE is not null or
					UTM_EW is not null or
					UTM_NS is not null
				)
			)
		</cfquery>

		<cfdump var=#bah#>

		<cfif bah.c gt 0>
			coordinate conflicts detected: dec_lat and other coordinates are given.

			<cfquery name="bah" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
				select * from pre_bulkloader where
				(
					(dec_lat is not null or dec_long is not null) and
					(
						LATDEG is not null or
						DEC_LAT_MIN is not null or
						LATMIN is not null or
						LATSEC is not null or
						LATDIR is not null or
						LONGDEG is not null or
						DEC_LONG_MIN is not null or
						LONGMIN is not null or
						LONGSEC is not null or
						LONGDIR is not null or
						UTM_ZONE is not null or
						UTM_EW is not null or
						UTM_NS is not null
					)
				)
			</cfquery>
			<cfdump var=#bah#>

			<cfabort>
		</cfif>
		<cfquery name="bah" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			select count(*) c from pre_bulkloader where
			(
				(LATDEG is not null or LONGDEG is not null) and
				(
					DEC_LAT is not null or
					DEC_LONG is not null or
					UTM_ZONE is not null or
					UTM_EW is not null or
					UTM_NS is not null
				)
			)
		</cfquery>
		<cfif bah.c gt 0>
			coordinate conflicts detected: LATDEG and other coordinates are given.
			<cfabort>
		</cfif>


		<cfquery name="bah" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			select count(*) c from pre_bulkloader where
			(
				(LATDEG is not null or LONGDEG is not null) and
				(
					DEC_LAT is not null or
					DEC_LONG is not null or
					UTM_ZONE is not null or
					UTM_EW is not null or
					UTM_NS is not null
				)
			)
		</cfquery>
		<cfif bah.c gt 0>
			coordinate conflicts detected: LATDEG and other coordinates are given.
			<cfabort>
		</cfif>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update
				pre_bulkloader
			set
				ORIG_LAT_LONG_UNITS='decimal degrees'
			where
				ORIG_LAT_LONG_UNITS is null and
				(DEC_LAT is not null or DEC_LONG is not null)
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update
				pre_bulkloader
			set
				ORIG_LAT_LONG_UNITS='UTM'
			where
				ORIG_LAT_LONG_UNITS is null and
				(UTM_ZONE is not null or UTM_EW is not null or UTM_NS is not null)
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update
				pre_bulkloader
			set
				ORIG_LAT_LONG_UNITS='deg. min. sec.'
			where
				ORIG_LAT_LONG_UNITS is null and
				(LATDEG is not null or LONGDEG) and
				(DEC_LAT_MIN is null and DEC_LONG_MIN is null)
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update
				pre_bulkloader
			set
				ORIG_LAT_LONG_UNITS='degrees dec. minutes'
			where
				ORIG_LAT_LONG_UNITS is null and
				(LATDEG is not null or LONGDEG) and
				(DEC_LAT_MIN is not null or DEC_LONG_MIN is not null)
		</cfquery>
		<cfdump var=#myQueryResult#>
		<!-- miss anything? Make it obvious -->
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update
				pre_bulkloader
			set
				ORIG_LAT_LONG_UNITS='SOMETHING FUNKY HAPPENED!!'
			where
				ORIG_LAT_LONG_UNITS is null and
				(
					DEC_LAT is not null or
					DEC_LONG is not null or
					UTM_ZONE is not null or
					UTM_EW is not null or
					UTM_NS is not null or
					LATDEG is not null or
					LATMIN is not null or
					LATSEC is not null or
					LATDIR is not null or
					LONGDEG is not null or
					LONGMIN is not null or
					LONGSEC is not null or
					LONGDIR is not null or
					DEC_LAT_MIN is not null or
					DEC_LONG_MIN is not null
				)
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update pre_bulkloader set DATUM='unknown' where DATUM is null and ORIG_LAT_LONG_UNITS is not null
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update pre_bulkloader set GEOREFERENCE_SOURCE='unknown' where GEOREFERENCE_SOURCE is null and ORIG_LAT_LONG_UNITS is not null
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update pre_bulkloader set GEOREFERENCE_PROTOCOL='not recorded' where GEOREFERENCE_PROTOCOL is null and ORIG_LAT_LONG_UNITS is not null
		</cfquery>
		<cfdump var=#myQueryResult#>
		<cfquery name="udllu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			update pre_bulkloader set VERIFICATIONSTATUS='unverified' where VERIFICATIONSTATUS is null and ORIG_LAT_LONG_UNITS is not null
		</cfquery>
		<cfdump var=#myQueryResult#>
		<p>
			All done, <a href="pre_bulkloader.cfm">continue</a>
		</p>
	</cfif>

	<!------------------------------------------------------->
	<cfif action is "ready_for_checkall">
		<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			UPDATE pre_bulkloader SET loaded='ready_for_checkall'
		</cfquery>

		<p>
			Results:
			<cfdump var=#myQueryResult#>
		</p>
		<p>
			Use your back button or <a href="pre_bulkloader.cfm">continue</a>
		</p>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "buildCollectionObjectID">
		<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			UPDATE pre_bulkloader SET collection_object_id=bulkloader_pkey.nextval WHERE collection_object_id is null
		</cfquery>

		<p>
			Results:
			<cfdump var=#myQueryResult#>
		</p>
		<p>
			Use your back button or <a href="pre_bulkloader.cfm">continue</a>
		</p>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "execSQL">
		<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			UPDATE pre_bulkloader SET #preserveSingleQuotes(spf)# <cfif len(spw) gt 0>WHERE #preserveSingleQuotes(spw)#</cfif>
		</cfquery>

		<p>
			Results:
			<cfdump var=#myQueryResult#>
		</p>
		<p>
			Use your back button or <a href="pre_bulkloader.cfm?action=nothing##tysql">continue</a>
		</p>
	</cfif>

	<!------------------------------------------------------->
	<cfif action is "setNullDefaultsAttribute">
		<cfset numberOfAttributes=10>
		<cfif len(attribute_determiner_n) gt 0>
			<cfloop from="1" to="#numberOfAttributes#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						attribute_determiner_#i#='#escapeQuotes(attribute_determiner_n)#'
					where
						attribute_#i# is not null and
						attribute_determiner_#i# is null
				</cfquery>
			</cfloop>
		</cfif>
		<cfif len(attribute_date_n) gt 0>
			<cfloop from="1" to="#numberOfAttributes#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						attribute_date_#i#='#escapeQuotes(attribute_date_n)#'
					where
						attribute_#i# is not null and
						attribute_date_#i# is null
				</cfquery>
			</cfloop>
		</cfif>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "setNullDefaultsParts">
		<cfset numberOfParts=12>
		<cfif len(PART_CONDITION_n) gt 0>
			<cfloop from="1" to="#numberOfParts#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						PART_CONDITION_#i#='#escapeQuotes(PART_CONDITION_n)#'
					where
						part_name_#i# is not null and
						PART_CONDITION_#i# is null
				</cfquery>
			</cfloop>
		</cfif>
		<cfif len(PART_LOT_COUNT_n) gt 0>
			<cfloop from="1" to="#numberOfParts#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						PART_LOT_COUNT_#i#='#escapeQuotes(PART_LOT_COUNT_n)#'
					where
						part_name_#i# is not null and
						PART_LOT_COUNT_#i# is null
				</cfquery>
			</cfloop>
		</cfif>
		<cfif len(PART_DISPOSITION_n) gt 0>
			<cfloop from="1" to="#numberOfParts#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						PART_DISPOSITION_#i#='#escapeQuotes(PART_DISPOSITION_n)#'
					where
						part_name_#i# is not null and
						PART_DISPOSITION_#i# is null
				</cfquery>
			</cfloop>
		</cfif>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "deleteUnusedStuff">
		<cftransaction>
			<cfset numberOfParts=12>
			<cfloop from="1" to="#numberOfParts#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						PART_CONDITION_#i#=null,
						PART_BARCODE_#i#=null,
						PART_CONTAINER_LABEL_#i#=null,
						PART_LOT_COUNT_#i#=null,
						PART_DISPOSITION_#i#=null,
						PART_REMARK_#i#=null
					where
						PART_NAME_#i# is null
				</cfquery>
			</cfloop>
			<cfset numberOfAttributes=10>
			<cfloop from="1" to="#numberOfAttributes#" index="i">
				<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						pre_bulkloader
					set
						ATTRIBUTE_VALUE_#i#=null,
						ATTRIBUTE_UNITS_#i#=null,
						ATTRIBUTE_REMARKS_#i#=null,
						ATTRIBUTE_DATE_#i#=null,
						ATTRIBUTE_DET_METH_#i#=null,
						ATTRIBUTE_DETERMINER_#i#=null
					where
						ATTRIBUTE_#i# is null
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "setNullDefaults">
		<cfset flds=form.FIELDNAMES>
		<cfloop list="#fldlist#" index="fld">
			<cfset v=evaluate("form." & fld)>
			<br>update pre_bulkloader set #fld#='#escapeQuotes(v)#' where #fld# is null
			<cfquery name="upnull" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update pre_bulkloader set #fld#='#escapeQuotes(v)#' where #fld# is null
			</cfquery>
		</cfloop>
		<p>
			<a href="pre_bulkloader.cfm">continue</a>
		</p>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "repatriate">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded='go_go_gadget_repatriate'
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "getFile">
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<cftransaction>
			<cfquery name="clear" datasource="uam_god">
				delete from #table#
			</cfquery>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into #table# (#cols#) values (
		            <cfloop list="#cols#" index="i">
		            	'#escapeQuotes(evaluate(i))#'
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to #table# <a href="pre_bulkloader.cfm?action=nothing##u_#table#">return</a>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "uDATUM">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			create table pre_bulk_datum as select distinct DATUM from pre_bulkloader where DATUM not in (select DATUM from CTDATUM)
		</cfquery>
		<a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_datum">download</a>
		DO NOT change any data. DO change "shouldbe." (if you get ORA-00942, there are no problems with the data)
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "checkStatus">
		<cfquery name="checkStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select loaded,count(*) c from pre_bulkloader group by loaded
		</cfquery>
		<cfdump var=#checkStatus#>
		<a href="pre_bulkloader.cfm">return</a>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "precheckLoaded">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded='go_go_gadget_precheck'
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "deleteAll">
		<cfquery name="deleteAll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from pre_bulkloader
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "instobulk">
		<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			UPDATE pre_bulkloader SET collection_object_id=bulkloader_pkey.nextval
		</cfquery>
		<p>
			collection_object_id updated.
			<a href="pre_bulkloader.cfm?action=setLoadedForLoad">click here to proceed to the next step</a>.
		</p>

	</cfif>
	<!------------------------------------------------------->
	<cfif action is "setLoadedForLoad">
		<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			UPDATE pre_bulkloader SET loaded='pushed_from_prebulk'
		</cfquery>
		<p>
			LOADED updated to pushed_from_prebulk.
			<a href="pre_bulkloader.cfm?action=pushToBL">click here to proceed to the next step</a>.
		</p>

	</cfif>
	<!------------------------------------------------------->
	<cfif action is "pushToBL">
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			select * from pre_bulkloader where 1=2
		</cfquery>
		<cfset cl=c.columnList>
		<cfset cl=listdeleteat(cl,listfindnocase(cl,'collection_cde'))>
		<cfquery name="ibl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			insert into bulkloader (#cl#) (select #cl# from pre_bulkloader)
		</cfquery>
		<p>
			Inserted to bulkloader.
			<a href="pre_bulkloader.cfm?action=pushToBL_SUCCESS">click here to avoid confusing yourself</a>.
		</p>
	</cfif>
	<cfif action is "pushToBL_SUCCESS">
		<cfquery name="uppc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="myQueryResult">
			UPDATE pre_bulkloader SET loaded='pushed to BULKLOADER #dateformat(now(),"yyyy-mm-dd")# by #session.username#'
		</cfquery>
		<p>
			You're all done here.
			<a href="pre_bulkloader.cfm?action=deleteAll">DELETE EVERYTHING from the pre-bulkloader</a> or

			<a href="/Bulkloader/browseBulk.cfm">continue on to the specimen bulkloader</a>.
		</p>

	</cfif>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">
