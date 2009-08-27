<cfinclude template="/includes/_header.cfm">
<cfset title="Specimen Search">
<cfset helpBaseUrl="">
<cfoutput>
<cfset metaDesc="Provides plain HTML functinality to search for museum specimens and observations by taxonomy, identifications, specimen attributes, and usage history.">
<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(collection_object_id) as cnt from cataloged_item
</cfquery>
<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select SEARCH_NAME,URL
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username='#session.username#'
	order by search_name
</cfquery>
You are searching Arctos with the non-JavaScript form. Please consider turning JavaScript on and 
using the <a href="/SpecimenSearch.cfm">standard search form</a>.
<table cellpadding="0" cellspacing="0">
	<tr>
		<td></td>
	</tr>
	<tr>
		<td>
			Access to #getCount.cnt# records
		</td>
		<td style="padding-left:2em;padding-right:2em;">
			<a class="infoLink" href="http://arctos-test.arctos.database.museum/info/help.cfm?content=CollStats">
				Holdings Details
			</a>
		</td>
		
		<td style="padding-left:2em;padding-right:2em;">
			
		</td>
	</tr>
</table>	
<form method="post" action="SpecimenResultsHTML.cfm" name="SpecData" id="SpecData">
<table border="0">
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn">
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn">
		</td>
		<td valign="top">
			
		</td>
		<td align="right" valign="top">
			
		</td>
		<td valign="top">
		 	
		</td>
		<td align="left">
			
		</td>
		<td valign="top">
			Show&nbsp;Observations?
			<input type="checkbox" name="showObservations" id="showObservations" value="1" <cfif #session.showObservations# eq 1> checked="checked" </cfif>>
		</td>
		<td valign="top">
			Tissues?
			<input type="checkbox" name="is_tissue" id="is_tissue" value="1">
		</td>
	</tr>
</table>
<input type="hidden" name="Action" value="#Action#">
<div class="secDiv">
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT institution_acronym, collection, collection_id FROM collection order by collection
	</cfquery>
	<cfif isdefined("collection_id") and len(#collection_id#) gt 0>
		<cfset thisCollId = #collection_id#>
	<cfelse>
		<cfset thisCollId = "">
	</cfif>
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Identifiers</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Collection:
			</td>
			<td class="srch">
				<select name="collection_id" id="collection_id" size="1">
						<option value="">All</option>
					<cfloop query="ctInst">
						<option <cfif #thisCollId# is #ctInst.collection_id#>
					 		selected </cfif>
							value="#ctInst.collection_id#">
							#ctInst.collection#</option>
					</cfloop>
				</select>
				Number:
				<cfif #ListContains(session.searchBy, 'bigsearchbox')# gt 0>
					<textarea name="listcatnum" id="listcatnum" rows="6" cols="40" wrap="soft"></textarea>
				<cfelse>
					<input type="text" name="listcatnum" id="listcatnum" size="21" value="">
				</cfif>			
			</td>
		</tr>
	<cfif isdefined("session.CustomOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
		<tr>
			<td class="lbl">
				#replace(session.CustomOtherIdentifier," ","&nbsp;","all")#:
			</td>
			<td class="srch">
				<label for="CustomOidOper">Display Value</label>
				<select name="CustomOidOper" id="CustomOidOper" size="1">
					<option value="IS">is</option>
					<option value="" selected="selected">contains</option>
					<option value="LIST">in list</option>
					<option value="BETWEEN">in range</option>								
				</select>&nbsp;<input type="text" name="CustomIdentifierValue" id="CustomIdentifierValue" size="50">
			</td>
		</tr>
		<tr>
		<td class="lbl">
			<cfif isdefined("session.fancyCOID") and #session.fancyCOID# is 1>
				&nbsp;
		</td>
			<td class="srch">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td>
							<label for="custom_id_prefix">OR: Prefix</label>
							<input type="text" name="custom_id_prefix" id="custom_id_prefix" size="12">
						</td>
						<td>
							<label for="custom_id_number">Number</label>
							<input type="text" name="custom_id_number" id="custom_id_number" size="24">
						</td>
						<td>
							<label for="custom_id_suffix">Suffix</label>
							<input type="text" name="custom_id_suffix" id="custom_id_suffix" size="12">
						</td>
					</tr>
				</table>
			</td>
			</cfif>
		</tr>
	</cfif>
</table>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Identification and Taxonomy</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Any Taxonomic Element:
			</td>
			<td class="srch">
				<input type="text" name="any_taxa_term" id="any_taxa_term" size="50">
			</td>
		</tr>
	</table>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Locality</span>
			</td>
		</tr>
		<tr>	
			<td class="lbl">
				Any&nbsp;Geographic&nbsp;Element:
			</td>
			<td class="srch">
				<input type="text" name="any_geog" id="any_geog" size="50">
			</td>
		</tr>	
	</table>
	<div id="e_locality"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Date/Collector</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Year Collected:
			</td>
			<td class="srch">
				<input name="begYear" id="begYear" type="text" size="6">&nbsp;to
				&nbsp;<input name="endYear" id="endYear" type="text" size="6">
			</td>
		</tr>
	</table>
	<div id="e_collevent"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Biological Individual</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Part Name:
			</td>
			<td class="srch">
				<input type="text" name="partname" id="partname">
			</td>
		</tr>
	</table>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Usage</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Basis of Citation:
			</td>
			<td class="srch">
				<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select type_status from ctcitation_type_status
				</cfquery>
				<select name="type_status" id="type_status" size="1">
					<option value=""></option>
					<option value="any">Any</option>
					<option value="type">Any TYPE</option>
					<cfloop query="ctTypeStatus">
						<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>
	<div id="e_usage"></div>
</div>
<cfif listcontainsnocase(session.roles,"coldfusion_user")>
	<div class="secDiv">
		<table class="ssrch">
			<tr>
				<td colspan="2" class="secHead">
					<span class="secLabel">Curatorial</span>
				</td>
			</tr>
			<tr>
				<td class="lbl">
					Barcode:
				</td>
				<td class="srch">
					<input type="text" name="barcode" id="barcode" size="50">
				</td>
			</tr>
		</table>
		<div id="e_curatorial"></div>
	</div>
</cfif>	
<table>
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn"
   				onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn"
   				onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'">
		</td>
		<td valign="top">
		</td>
		<td valign="top" align="right">
		</td>
		<td align="left" colspan="2" valign="top">
			
		</td>
		<td align="left">
			
		</td>
	</tr>
</table> 
<cfif isdefined("transaction_id") and len(#transaction_id#) gt 0>
	<input type="hidden" name="transaction_id" value="#transaction_id#">
</cfif>
<input type="hidden" name="newQuery" value="1"><!--- pass this to the next form so we clear the cache and run the proper queries--->
</form>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">