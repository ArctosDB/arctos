<cfinclude template="includes/_header.cfm">
<style>
	.acceptedIdDiv { border:1px dotted green; }
	.unAcceptedIdDiv{ border:1px dotted gray; background-color:#F8F8F8; color:gray; font-size:.8em; }
	.taxDetDiv { padding-left:1em; }
	.sdItemBlock {
	   border:1px dotted green;
	 }
	 .sdMetadata{
	   font-size:smaller;
	   margin-left:.5em;
	  }





</style>
<cfoutput>
	<cfif isdefined("guid")>
		<!----
			<cfif cgi.script_name contains "/SpecimenDetail.cfm">
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="/guid/#guid#">
			<cfabort>
			</cfif>
			---->
		<cfset checkSql(guid)>
		<cfif guid contains ":">
			<cfset sql="select collection_object_id from
				#session.flatTableName#
				WHERE
				upper(guid)='#ucase(guid)#'">
			<cfset checkSql(sql)>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>
		</cfif>
		<cfif isdefined("c.collection_object_id") and len(c.collection_object_id) gt 0>
			<cfset collection_object_id=c.collection_object_id>
		<cfelse>
			<cfinclude template="/errors/404.cfm">
			<cfabort>
		</cfif>
	<cfelse>
		<cfinclude template="/errors/404.cfm">
		<cfabort>
	</cfif>
	<cfquery name="flatone"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select * from filtered_flat where guid='#guid#'
</cfquery>
	<div id="sdFullPage">
		<div id="sdLeftHalfPage">
			<div class="sdItemBlock">
				<div class="sdRow">
					<div class="sdOne">
						#flatone.guid#: #flatone.scientific_name#
						<div class="sdMetadata">
							Identified By: #flatone.IDENTIFIEDBY#
						</div>
						<div class="sdMetadata">
							Identified Date: #flatone.MADE_DATE#
						</div>
						<div class="sdMetadata">
							Nature of ID: #flatone.NATURE_OF_ID#
						</div>
						<cfif len(flatone.ID_SENSU) gt 0>
							<div class="sdMetadata">
								Sensu: #flatone.ID_SENSU#
							</div>
						</cfif>
						<div class="sdMetadata">
							Taxonomy: #flatone.FULL_TAXON_NAME#
						</div>
						<cfif len(flatone.PREVIOUSIDENTIFICATIONS) gt 0>
							<div class="sdMetadata">
								Previous ID: #flatone.PREVIOUSIDENTIFICATIONS#
							</div>
						</cfif>
					</div>
					<div class="sdOne">
						Location: #flatone.HIGHER_GEOG#: #flatone.SPEC_LOCALITY#
						<cfif len(flatone.DEC_LAT) gt 0>
							<div class="sdMetadata">
								#flatone.DEC_LAT# / #flatone.DEC_LONG#
							</div>
							<cfif len(flatone.DATUM) gt 0>
								<div class="sdMetadata">
									Datum: #flatone.DATUM#
								</div>
							</cfif>
							<cfif len(flatone.COORDINATEUNCERTAINTYINMETERS) gt 0>
								<div class="sdMetadata">
									Error (m): #flatone.COORDINATEUNCERTAINTYINMETERS#
								</div>
							</cfif>
							<cfif len(flatone.VERIFICATIONSTATUS) gt 0>
								<div class="sdMetadata">
									Verification Status: #flatone.VERIFICATIONSTATUS#
								</div>
							</cfif>
							<cfif len(flatone.SPECIMEN_EVENT_TYPE) gt 0>
								<div class="sdMetadata">
									Event Type: #flatone.SPECIMEN_EVENT_TYPE#
								</div>
							</cfif>
							<cfif len(flatone.EVENT_ASSIGNED_BY_AGENT) gt 0>
								<div class="sdMetadata">
									Assigned By: #flatone.EVENT_ASSIGNED_BY_AGENT#
								</div>
							</cfif>
							<cfif len(flatone.EVENT_ASSIGNED_DATE) gt 0>
								<div class="sdMetadata">
									Assigned Date: #flatone.EVENT_ASSIGNED_DATE#
								</div>
							</cfif>
							<cfif len(flatone.SPECIMEN_EVENT_REMARK) gt 0>
								<div class="sdMetadata">
									Event Remark: #flatone.SPECIMEN_EVENT_REMARK#
								</div>
							</cfif>
						</cfif>
					</div>
					<div class="sdOne">
						Date: #flatone.BEGAN_DATE#- #flatone.ENDED_DATE# (#flatone.VERBATIM_DATE#)
					</div>
					<cfif len(flatone.COLLECTING_METHOD) gt 0>
						<div class="sdOne">
							Collecting Method: #flatone.COLLECTING_METHOD#
						</div>
					</cfif>
					<cfif len(flatone.COLLECTING_SOURCE) gt 0>
						<div class="sdOne">
							Collecting Source: #flatone.COLLECTING_SOURCE#
						</div>
					</cfif>
					<cfif len(flatone.HABITAT) gt 0>
						<div class="sdOne">
							Habitat: #flatone.HABITAT#
						</div>
					</cfif>
					<cfif len(flatone.ASSOCIATED_SPECIES) gt 0>
						<div class="sdOne">
							Associated Species: #flatone.ASSOCIATED_SPECIES#
						</div>
					</cfif>
					<cfif len(flatone.TYPESTATUS) gt 0>
						<div class="sdOne">
							Citation: #flatone.TYPESTATUS#
						</div>
					</cfif>
					<cfif len(flatone.COLLECTORS) gt 0>
						<div class="sdOne">
							Collector: #flatone.COLLECTORS#
						</div>
					</cfif>
					<cfif len(flatone.PREPARATORS) gt 0>
						<div class="sdOne">
							Preparator: #flatone.PREPARATORS#
						</div>
					</cfif>
					<cfif len(flatone.ACCESSION) gt 0>
						<div class="sdOne">
							Accession: #flatone.ACCESSION#
						</div>
					</cfif>
					<cfif len(flatone.OTHERCATALOGNUMBERS) gt 0>
						<div class="sdOne">
							IDs: #flatone.OTHERCATALOGNUMBERS#
						</div>
					</cfif>
					<cfif len(flatone.RELATEDCATALOGEDITEMS) gt 0>
						<div class="sdOne">
							Related: #flatone.RELATEDCATALOGEDITEMS#
						</div>
					</cfif>
					<cfif len(flatone.SEX) gt 0>
						<div class="sdOne">
							Sex: #flatone.SEX#
						</div>
					</cfif>
					<cfif len(flatone.ATTRIBUTES) gt 0>
						<div class="sdOne">
							Attributes: #flatone.ATTRIBUTES#
						</div>
					</cfif>
					<cfif len(flatone.PARTS) gt 0>
						<div class="sdOne">
							Parts: #flatone.PARTS#
						</div>
					</cfif>
					<cfif len(flatone.REMARKS) gt 0>
						<div class="sdOne">
							Remark: #flatone.REMARKS#
						</div>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</cfoutput>
<cfinclude template="includes/_footer.cfm">
