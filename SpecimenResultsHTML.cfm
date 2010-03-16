<cfinclude template="/includes/_header.cfm">
<script>
 function checkUncheck(formName,CollObjValue)
 {
 	var newStr;
	 {
         //if ( document.remove.exclCollObjId.checked )
		 // this works if ( document.forms['remove'].exclCollObjId.checked )
		 if ( document.forms[formName].exclCollObjId.checked )
		  //if ( document["formName"].exclCollObjId.checked )
		 //orms[\\''\''+tid+\''\\''].eleme  [\''''+tid+''\''
		 	{
              newStr = document.reloadThis.exclCollObjId.value + "," + CollObjValue + ",";
			  document.reloadThis.exclCollObjId.value=newStr;
			  //alert(newStr);
			 }
         else
		 	{
              newStr=replaceSubstring(document.reloadThis.exclCollObjId.value, "," + CollObjValue + ",", "");
			  document.reloadThis.exclCollObjId.value=newStr;
			  //alert(newStr);
			 }
     }
 }

</script>
<cfif not isdefined("detail_level") OR len(#detail_level#) is 0>
	<cfif isdefined("session.detailLevel") AND #session.detailLevel# gt 0>
		<cfset detail_level = #session.detailLevel#>
	<cfelse>
		<cfset detail_level = 1>
	</cfif>	
</cfif>
<cfoutput>
</cfoutput>
<cfset title="Specimen Results">
<cfif not isdefined("displayrows")>
	<cfset displayrows = session.displayrows>
</cfif>
<cfif not isdefined("SearchParams")>
	<cfset SearchParams = "">
</cfif>
<cfif not isdefined("newQuery")>
	<cfset newQuery = 1>
</cfif>
<cfif not isdefined("sciNameOper")>
	<cfset sciNameOper = "LIKE">
</cfif>
<cfif not isdefined("oidOper")>
	<cfset oidOper = "LIKE">
</cfif>
<cfif not isdefined("mapurl")>
	<cfset mapurl = "null">
</cfif>
<cfif #action# contains ",">
	<cfset action = #left(action,find(",",action)-1)#>
</cfif>
<cfif #detail_level# contains ",">
	<cfset detail_level = #left(detail_level,find(",",detail_level)-1)#>
</cfif>


<cfif #newQuery# is 1>	<!--- build and send the query--->
	<cfset basSelect = " SELECT 
		#session.flatTableName#.collection_object_id,
		#session.flatTableName#.cat_num,
		#session.flatTableName#.institution_acronym,
		#session.flatTableName#.collection_cde,
		#session.flatTableName#.collection_id,
		#session.flatTableName#.parts,
		#session.flatTableName#.sex,
		#session.flatTableName#.scientific_name,
		#session.flatTableName#.country,
		#session.flatTableName#.state_prov,
		#session.flatTableName#.spec_locality,
		#session.flatTableName#.verbatim_date
		">
	<cfif len(#session.CustomOtherIdentifier#) gt 0>
		<cfset basSelect = "#basSelect# 
			,concatSingleOtherId(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			to_number(ConcatSingleOtherIdInt(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#')) AS CustomIDInt">
	</cfif>
	<cfset basFrom = " FROM #session.flatTableName#">
	<cfset basJoin = "INNER JOIN cataloged_item ON (#session.flatTableName#.collection_object_id =cataloged_item.collection_object_id)">
	<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">	
<!--------------------------------------------------------------->
	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="includes/SearchSql.cfm">
	<cfif #detail_level# gte 2>
		<cfset basSelect = "#basSelect#,
			#session.flatTableName#.accession,
			#session.flatTableName#.coll_obj_disposition,
			#session.flatTableName#.county,
			#session.flatTableName#.feature,
			#session.flatTableName#.quad,
			#session.flatTableName#.remarks,
			#session.flatTableName#.ISLAND,
			#session.flatTableName#.ISLAND_GROUP,
			#session.flatTableName#.associated_species,
			#session.flatTableName#.habitat,
			 round(MIN_ELEV_IN_M) MIN_ELEV_IN_M,
			 round(MAX_ELEV_IN_M) MAX_ELEV_IN_M">
	</cfif><!--- end detail_level 2---->
	<cfif #detail_level# gte 3>
		<cfquery name="ctAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select distinct(attribute_type) from ctattribute_type
		</cfquery>
		<cfloop query="ctAtt">
			<cfset thisName = #ctAtt.attribute_type#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			<cfif #thisName# is not "sex"><!--- already got it --->
				<cfset basSelect = "#basSelect# ,
							ConcatAttributeValue(#session.flatTableName#.collection_object_id,'#ctAtt.attribute_type#') 
				#thisName#">
			</cfif>
		</cfloop>
		<cfset basSelect = "#basSelect# ,
					#session.flatTableName#.began_date, 
						#session.flatTableName#.ended_date, 
							get_scientific_name_auths(#session.flatTableName#.collection_object_id) sci_name_with_auth,
							concatAcceptedIdentifyingAgent(#session.flatTableName#.collection_object_id) identified_by">
	</cfif><!--- end detail_level 3---->
	<cfif #detail_level# gte 4>
		<cfset basSelect = "#basSelect#,
			#session.flatTableName#.datum,
			#session.flatTableName#.orig_lat_long_units,
			#session.flatTableName#.lat_long_determiner,
			#session.flatTableName#.lat_long_ref_source,
			#session.flatTableName#.lat_long_remarks,
			#session.flatTableName#.COORDINATEUNCERTAINTYINMETERS,
			#session.flatTableName#.CONTINENT_OCEAN,
			#session.flatTableName#.SEA,
			get_taxonomy(cataloged_item.collection_object_id,'family') family,
			get_taxonomy(cataloged_item.collection_object_id,'phylorder') phylorder
		">
	</cfif><!--- end detail_level 4---->
		<cfset basSelect = "#basSelect#,dec_lat,dec_long">
		
		<cfif #detail_level# gte 2>
			<cfset basSelect = "#basSelect#, collectors,VerbatimLatitude,VerbatimLongitude,OTHERCATALOGNUMBERS">
		</cfif>
		<!---
	</cfif>
	--->
	<!--- wrap everything up in a string --->
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">	
	<!--- define the list of search paramaters that we need to get back here --->
	<cfoutput>
	<cfset searchParams = "">
	<!--- set up hidden form variables to use when customizing.
			Explicitly exclude things we don't want --->
		<cfset searchParams = "">
		<cfset returnURL = "">
		<cfloop list="#StructKeyList(form)#" index="key">
			<cfif len(#form[key]#) gt 0>
					<cfif #key# is not "FIELDNAMES" 
						AND #key# is not "SEARCHPARAMS" 
						AND #key# is not "mapurl" 
						AND #key# is not "cbifurl" 
						and #key# is not "newquery"
						and #key# is not "ORDER_ORDER"
						and #key# is not "ORDER_BY"
						and #key# is not "newsearch"
						and #key# is not "STARTROW">
					<cfif len(#returnURL#) is 0>
						<cfset returnURL='SpecimenResults.cfm?#key#=#form[key]#'>
					<cfelse>
						<cfset returnURL='#returnURL#&#key#=#form[key]#'>
					</cfif>			 
					<cfif #key# is not "detail_level">
						<cfif len(#searchParams#) is 0>
							<cfset searchParams='<input type="hidden" name="#key#" value="#form[key]#">'>
						<cfelse>
							<cfset searchParams='#searchParams#<input type="hidden" name="#key#" value="#form[key]#">'>
						</cfif>
					</cfif>
				</cfif>
			 </cfif>
		</cfloop>
		<!---- also grab anything from the URL --->
		<cfloop list="#StructKeyList(url)#" index="key">
			 <cfif len(#url[key]#) gt 0>
				 <cfif #key# is not "FIELDNAMES" 
					AND #key# is not "SEARCHPARAMS" 
					AND #key# is not "mapurl" 
					AND #key# is not "cbifurl" 
					and #key# is not "newquery"
					and #key# is not "ORDER_ORDER"
					and #key# is not "ORDER_BY"
					and #key# is not "newsearch"
					and #key# is not "STARTROW"
					and #key# is not "detail_level">
				 <cfif len(#returnURL#) is 0>
					<cfset returnURL='SpecimenResults.cfm?#key#=#url[key]#'>
				<cfelse>
					<cfset returnURL='#returnURL#&#key#=#url[key]#'>
				</cfif>
				<cfif #key# is not "detail_level">
					<cfif len(#searchParams#) is 0>
						<cfset searchParams='<input type="hidden" name="#key#" value="#url[key]#">'>
					<cfelse>
						<cfset searchParams='#searchParams#<input type="hidden" name="#key#" value="#url[key]#">'>
					</cfif>
				</cfif>
				</cfif>
			 </cfif>
		</cfloop>
		<cfset strippyReturnURL = replace(returnURL,'"','&quot;','all')>
		<cfset searchParams = '#searchParams#<input type="hidden" name="returnURL" value="#strippyReturnURL#"'>
		
		
		<cfset searchParams = #replace(searchParams,"'","","all")#>
		
	</cfoutput>
		<cfif len(#basQual#) is 0 AND basFrom does not contain "binary_object">
			<CFSETTING ENABLECFOUTPUTONLY=0>
			
			<font color="##FF0000" size="+2">You must enter some search criteria!</font>	  
			<cfabort>
		</cfif>
<!-------------------------- dlkm debug --


<cfif isdefined("session.username") and (#session.username# is "dlm" or #session.username# is "dusty")>
		
	<cfoutput>
	--#session.username#--
	#preserveSingleQuotes(SqlString)#
	<br>ReturnURL: #returnURL#
	<br>MapURL: #mapURL#
	<cfdump var=#variables#>
	</cfoutput>
	</cfif>
	
	
	---------------<--------------------->	
	
	<!-------------------------- / dlm debug -------------------------------------->
	
	
<cftry>	
	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		#preserveSingleQuotes(SqlString)#
	</cfquery>
	<cfcatch>
		<cfif isdefined("cfcatch.sql")>
			<cfset sql=cfcatch.sql>
		<cfelse>
			<cfset sql="NOT DEFINED">
		</cfif>
		<cfif isdefined("cfcatch.message")>
			<cfset message=cfcatch.message>
		<cfelse>
			<cfset message="NOT DEFINED">
		</cfif>
		<cfif isdefined("cfcatch.queryError")>
			<cfset queryError=cfcatch.queryError>
		<cfelse>
			<cfset queryError="NOT DEFINED">
		</cfif>
		<cf_queryError>
	</cfcatch>
</cftry>
	<cfset userSql = #preserveSingleQuotes(SqlString)#>
	
	<cfif getData.recordcount is 0>
	<CFSETTING ENABLECFOUTPUTONLY=0>
			<cfoutput>
		<font color="##FF0000" size="+2">Your search returned no results.</font>	  
		<p>Some possibilities include:</p>
		<ul>
			<li>
				If you searched by taxonomy, please consult <a href="/TaxonomySearch.cfm" class="novisit">Arctos Taxonomy</a>.
			</li>
			<li>
				Try broadening your search criteria. Try the next-higher geographic element, remove criteria, etc. Don't assume we've accurately or predictably recorded data!
			</li>
			<li>
				Use dropdowns or partial word matches instead of text strings, which may be entered in unexpected ways. "Doe" is a good choice for a collector if "John P. Doe" didn't match anything.
			</li>
			<li>
				Read the documentation for individual search fields (click the title of the field to see documentation). Arctos fields may not be what you expect them to be.
			</li>
		</ul>
		</cfoutput>
		<cfabort>
	</cfif>
	<CFSETTING ENABLECFOUTPUTONLY=0>
	

<!---- clear old queries from cache and cache flatquery ---->
	<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,0,0)#">
		select * from getData where collection_object_id > 0
	</cfquery>
	<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,120,0)#">
		select * from getData where collection_object_id > 0
	</cfquery>
	<cfquery name="uCollObj" dbtype="query">
		select distinct(collection_object_id) as collection_object_id from getData
		 where collection_object_id > 0
	</cfquery>
	<cfset collObjIdList = valuelist(uCollObj.collection_object_id)>
<cfset newQuery=0>	
<cfset newSearch = 1><!---- assign a variable that says we've destroyed the cached query
	and should destroy the cache of it used to navigate pages ---->
</cfif><!---- end newquery ---->

<cfif not isdefined("order_by") or len(#order_by#) is 0>
	<cfset order_by = "cat_num">
</cfif>
<cfif not isdefined("order_order") or len(#order_order#) is 0>
	<cfset order_order = "asc">
</cfif>

<cfif isdefined("newSearch") and #newSearch# is 1>
	<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,0,0)#">
		select * from SpecRes#cfid##cftoken#
	</cfquery>
	<cfquery name="mapCount#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,0,0)#">
		select * from SpecRes#cfid##cftoken#
	</cfquery>
</cfif>
<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,120,0)#">
	select * from SpecRes#cfid##cftoken#
</cfquery>

<cfquery name="getBasic" dbtype="query">
	select * from SpecRes#cfid##cftoken# order by #order_by# #order_order#
</cfquery>
<!---
<cfif #getBasic.recordcount# is 1 and #action# is "nothing">
	<cflocation url="SpecimenDetail.cfm?collection_object_id=#getBasic.collection_object_id#">
</cfif>
--->
<cfquery name="mappable" dbtype="query">
	select count(distinct(collection_object_id)) as cnt from getBasic where dec_long is not null and
	dec_lat is not null 
	<!---
	and
	encumbrance_action <> 'mask coordinates'
	--->
</cfquery>
<cfset mapCount = #mappable.cnt#>
<!---- error reporting ---->
<cfquery name="collectionObjectIds" dbtype="query">
	select distinct(collection_object_id) from getBasic
</cfquery>
<cfif #getBasic.recordcount# lt 1000>
	<cfquery name="collectionObjectIds" dbtype="query">
		select distinct(collection_object_id) from getBasic
	</cfquery>
	<cfset collectionObjectIdList = "">
	<cfloop query="collectionObjectIds">
		<cfif len(#collectionObjectIdList#) is 0>
			<cfset collectionObjectIdList = #collection_object_id#>
		<cfelse>
			<cfset collectionObjectIdList = "#collectionObjectIdList#,#collection_object_id#">
		</cfif>
	</cfloop>
	<cfoutput>
	<span style="float:right; clear:left;">
		<span class="infoLink" onclick="document.location='/info/reportBadData.cfm?collection_object_id=#collectionObjectIdList#';">
			Report Bad Data
		</span>
	</span>
	</cfoutput>
</cfif>
<CFOUTPUT>
<!---- define values used to browse records ---->
<cfparam name="StartRow" default="1">
<CFSET ToRow = #StartRow# + (#DisplayRows# - 1)>
<CFIF ToRow GT collectionObjectIds.RecordCount>
    <CFSET ToRow = collectionObjectIds.RecordCount>
</CFIF>
<cfif ToRow lt collectionObjectIds.recordcount AND ToRow lt displayRows>
	<cfset ToRow = displayRows>
</cfif>
<cfif #StartRow# lt 0>
	<cfset StartRow = 1>
</cfif>
<CFSET LastRecs = #collectionObjectIds.RecordCount# - DisplayRows + 1>
<CFSET Next = StartRow + DisplayRows>
<CFSET Previous = StartRow - DisplayRows>
<cfif  #collectionObjectIds.RecordCount# - #toRow#  lt #DisplayRows#>
	<cfset nextRows = #collectionObjectIds.RecordCount# - #torow#>
<cfelse>
	<cfset nextRows = #DisplayRows#>
</cfif>

<form name="map" method="post" action="/bnhmMaps/bnhmMapData.cfm?#mapurl#" target="_blank">

  <H4>List of specimens #StartRow# through #ToRow# of the #collectionObjectIds.RecordCount# records that matched your criteria.
  <br>Click on catalog numbers for individual details.

<cfset bnhmUrl="/bnhmMaps/bnhmMapData.cfm?#mapurl#">
<br>Map #mapCount# of these #collectionObjectIds.RecordCount# records using
<input type="submit" value="BerkeleyMapper" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
	<span class="infoLink" onclick="getDocs('maps');">
		What's this?
	</span>   
</td>
   </H4>
</form>
<script>
function cForm(){
mywin=windowOpener('','myWin','height=300,width=400,resizable,location,menubar ,scrollbars ,status ,titlebar,toolbar');
document.getElementById('saveme').submit();
}
</script>
		<cfif isdefined("returnURL")>
		<form name="saveme" id="saveme" method="post" action="saveSearch.cfm" target="myWin">
			<input type="hidden" name="returnURL" value="#Application.ServerRootUrl#/SpecimenResults.cfm?#mapURL#&detail_level=#detail_level#" />
			<input type="button" value="Save This Search" onclick="cForm();" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
		</form>
		</cfif>
<cfif #Action# is "dispCollObj">
	<br><a href="Loan.cfm?transaction_id=#transaction_id#&Action=editLoan">Back to Loan</a>
</cfif>
	
<form name="browse" action="SpecimenResults.cfm" method="post">
				#searchparams#
				
				
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="StartRow" type="hidden" value="1">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input type="hidden" name="collobjidlist" value="#collobjidlist#">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<input type="hidden" name="displayRows" value="#session.displayRows#">
				</form>
				
				

	<!---- browse buttons ---->
	<table cellpadding="10">
		<tr>
		<CFIF startrow GT 1>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='1';
				document.browse.submit();">First&nbsp;Page</span>
		</td>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='#previous#';
				document.browse.submit();">Previous&nbsp;Page</span>
		</td>
	</CFIF>
	<CFIF Next LTE getBasic.RecordCount>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='#Next#';
				document.browse.submit();">Next&nbsp;Page</span>
		</td>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='#LastRecs#';
				document.browse.submit();">Last&nbsp;Page</span>
		</td>
	</CFIF>
	<CFIF displayrows LT getBasic.RecordCount + 1>
		<td>
			<span class="infoLink" onclick="document.browse.StartRow.value='1';
				document.browse.displayRows.value='#getBasic.RecordCount#';
				document.browse.submit();">View&nbsp;All</span>
		</td>
	</CFIF>
	<CFIF displayrows is getBasic.RecordCount>
		<td>
			<span class="infoLink" onclick="document.browse.StartRow.value='1';
				document.browse.displayRows.value='#session.displayRows#';
				document.browse.submit();">View&nbsp;Pages</span>
		</td>	
	</CFIF>
		</tr>
	</table>
	<!---- end browse buttons ---------------------->


	
	
<table width="95%" border="1">
<tr>
 
	

	
				
				
<form name="reorder" action="SpecimenResults.cfm" method="post">
				#searchParams#
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="StartRow" type="hidden" value="1">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="NewSearch" type="hidden" value="0">
					<input type="hidden" name="order_by" value="#order_by#">
					<input type="hidden" name="order_order" value="#order_order#">
					<input type="hidden" name="collobjidlist" value="#collobjidlist#">
				
				
<cfquery name="ctAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(attribute_type) from ctAttribute_type order by attribute_type
</cfquery>
<cfset attList = "">
<cfloop query="ctAtt">
	<cfif len(#attList#) is 0>
		<cfset attList = "#ctAtt.attribute_type#">
	<cfelse>
		<cfset attList = "#attList#,#ctAtt.attribute_type#">
	</cfif>
</cfloop>

<cfquery name="ctOID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(other_id_type) from ctcoll_other_id_type order by other_id_type
</cfquery>
<cfset OIDlist = "">
<cfloop query="ctOID">
	<cfif len(#OIDlist#) is 0>
		<cfset OIDlist = "#ctOID.other_id_type#">
	<cfelse>
		<cfset OIDlist = "#OIDlist#,#ctOID.other_id_type#">
	</cfif>
</cfloop>
	<!---- always on --->
<cfif #detail_level# gte 1>

<cfif #session.killrow# is 1>
	<td nowrap>
	<form name="UpSubRem" method="post" action="SpecimenResults.cfm">
		<img src="/images/delete.gif" border="0" width="24" onClick="reloadThis.submit();">
	</form>
	</td>
</cfif>
<cfif isdefined("session.loan_request_coll_id") and #session.loan_request_coll_id# gt 0>
	<cfquery name="active_loan_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select  USER_LOAN_ID from 
		cf_user_loan,cf_users where
		cf_user_loan.user_id=cf_users.user_id and
		IS_ACTIVE=1
		and username='#session.username#'
	</cfquery>
	<cfif len(#active_loan_id.USER_LOAN_ID#) is 0>
		<cfset thisLoanId = "-1">
	<cfelse>
		<cfset thisLoanId = #active_loan_id.USER_LOAN_ID#>
	</cfif>
	
	<td><b>Request</b></td>
</cfif>
	<td nowrap><strong>Catalog ##</strong>
	<cfif 
		(isdefined("session.username") AND #detail_level# gte 2)
			and (
				#session.username# is "cindy" 
				OR #session.username# is "dusty"
				OR #session.username# is "ahope"
				OR #session.username# is "jmalaney"
				OR #session.username# is "rsampson"
				OR #session.username# is "cmcclarin"
				)
		>
		<a href="##" 
			onClick="reorder.order_by.value='scientific_name,country,state_prov,county,cat_num';reorder.order_order.value='asc';reorder.submit();"
			>
		Cindy Sort</a>
	</cfif>
	<a href="##" 
		onClick="reorder.order_by.value='cat_num';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';catup.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';catup.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="catup"></a>
	<a href="##" 
		onClick="reorder.order_by.value='cat_num';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';catdn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';catdn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="catdn"></a>
	</td>
	<cfif len(#session.CustomOtherIdentifier#) gt 0>
		<td nowrap>
			<strong>#session.CustomOtherIdentifier#</strong>
			<cfset thisTerm = "CustomID">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="##" 
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="##" 
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
			<cfset thisTerm = "CustomIDInt">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			(
			<a href="##" 
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="##" 
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
				)
				
		</td>
		
	</cfif>
	<td nowrap><strong>Identified As</strong>
		<a href="##" 
		onClick="reorder.order_by.value='scientific_name';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';sciup.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';sciup.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="sciup"></a>
	<a href="##" 
		onClick="reorder.order_by.value='scientific_name';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';scidn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';scidn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="scidn"></a>	
	</td>
</cfif>
<cfif #detail_level# gte 3>
	<td nowrap><strong>Scientific Name</strong></td>
	<td nowrap><strong>Identified By</strong></td>
</cfif>
<cfif #detail_level# gte 4>
	<td nowrap><strong>Order</strong></td>
	<td nowrap><strong>Family</strong></td>
</cfif>
<cfif #detail_level# gte 2>
		<td nowrap>
			<strong>Other Identifiers</strong>		
	<cfset thisTerm = "OTHERCATALOGNUMBERS">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="##" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="##" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
	
		<td nowrap>
			<strong>Accession</strong>		
			<cfset thisTerm = "accession">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
	
		<td nowrap>
			<strong>Collectors</strong>	
	<cfset thisTerm = "collectors">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
	<td nowrap>
	<strong>Latitude</strong>&nbsp;
	<cfset thisTerm = "verbatimlatitude">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
			
			
		</td>
		<td nowrap>
		<strong>Longitude</strong>&nbsp;
		<cfset thisTerm = "verbatimlongitude">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
			
			
		</td>
</cfif>
<cfif #detail_level# gte 4>
				<td nowrap>
					<strong>Decimal Latitude</strong>
					<cfset thisTerm = "dec_lat">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
				</td>
				<td nowrap>
					<strong>Decimal Longitude</strong>
					<cfset thisTerm = "dec_long">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
				</td>
				<td nowrap>
				<cfset thisTerm = "COORDINATEUNCERTAINTYINMETERS">
	<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
					<strong>Max Error</strong>
				</td>
				<td nowrap>
					<strong>Datum</strong>
				</td>
				<td nowrap>
					<strong>Original Units</strong>
				</td>
				<td nowrap>
					<strong>Georeferenced By</strong>
				</td>
				<td nowrap>
					<strong>Reference</strong>
				</td>
				<td nowrap>
					<strong>Lat/Long Remarks</strong>
				</td>
</cfif>
<cfif #detail_level# gte 4>
	<td nowrap><strong>Continent</strong></td>
</cfif>
<cfif #detail_level# gte 1>
		<td nowrap><strong>Country</strong>
		<a href="##" 
			onClick="reorder.order_by.value='country';reorder.order_order.value='asc';reorder.submit();"
			onMouseOver="self.status='Sort Ascending.';cntup.src='/images/up_mo.gif';return true;"
			onmouseout="self.status='';cntup.src='/images/up.gif';return true;">
			<img src="/images/up.gif" border="0" name="cntup"></a>
		<a href="##" 
			onClick="reorder.order_by.value='country';reorder.order_order.value='desc';reorder.submit();"
			onMouseOver="self.status='Sort Descending.';cntdn.src='/images/down_mo.gif';return true;"
			onmouseout="self.status='';cntdn.src='/images/down.gif';return true;">
			<img src="/images/down.gif" border="0" name="cntdn">	</a>
		</td>
	
		<td nowrap><strong>State</strong>
		<a href="##" 
			onClick="reorder.order_by.value='state_prov';reorder.order_order.value='asc';reorder.submit();"
			onMouseOver="self.status='Sort Ascending.';stup.src='/images/up_mo.gif';return true;"
			onmouseout="self.status='';stup.src='/images/up.gif';return true;">
			<img src="/images/up.gif" border="0" name="stup"></a>
		<a href="##" 
			onClick="reorder.order_by.value='state_prov';reorder.order_order.value='desc';reorder.submit();"
			onMouseOver="self.status='Sort Descending.';stdn.src='/images/down_mo.gif';return true;"
			onmouseout="self.status='';stdn.src='/images/down.gif';return true;">
			<img src="/images/down.gif" border="0" name="stdn">	</a>
		</td>
</cfif>
<cfif #detail_level# gte 4>
	<td nowrap><strong>Sea</strong></td>
</cfif>
<cfif #detail_level# gte 2>
		<td nowrap><strong>Map Name</strong>
		<a href="javascript: void" 
		onClick="reorder.order_by.value='quad';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="qdup.src='/images/up_mo.gif';return true;"
		onmouseout="qdup.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="qdup"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='quad';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';qddn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';qddn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="qddn"></a>	</td>
	
		<td nowrap>
			<strong>Feature</strong>		
		</td>


		<td nowrap><strong>County</strong>
		<a href="javascript: void" 
			onClick="reorder.order_by.value='county';reorder.order_order.value='asc';reorder.submit();"
			onMouseOver="self.status='Sort Ascending.';cotup.src='/images/up_mo.gif';return true;"
			onmouseout="self.status='';cotup.src='/images/up.gif';return true;">
			<img src="/images/up.gif" border="0" name="cotup"></a>
		<a href="javascript: void" 
			onClick="reorder.order_by.value='county';reorder.order_order.value='desc';reorder.submit();"
			onMouseOver="self.status='Sort Descending.';cotdn.src='/images/down_mo.gif';return true;"
			onmouseout="self.status='';cotdn.src='/images/down.gif';return true;">
			<img src="/images/down.gif" border="0" name="cotdn"></a>	
		</td>
		<td nowrap><strong>Island Group</strong></td>
		<td nowrap><strong>Island</strong></td>	
		<td nowrap><strong>Associated Species</strong></td>
		<td nowrap><strong>Microhabitat</strong></td>
		<td nowrap><strong>Elevation in Meters</strong></td>
</cfif>
<cfif #detail_level# gte 1>
	<td nowrap>
		<strong>Specific Locality</strong>
		<a href="javascript: void" 
			onClick="reorder.order_by.value='spec_locality';reorder.order_order.value='asc';reorder.submit();"
			onMouseOver="self.status='Sort Ascending.';cotup.src='/images/up_mo.gif';return true;"
			onmouseout="self.status='';cotup.src='/images/up.gif';return true;">
			<img src="/images/up.gif" border="0" name="cotup"></a>
		<a href="javascript: void" 
			onClick="reorder.order_by.value='spec_locality';reorder.order_order.value='desc';reorder.submit();"
			onMouseOver="self.status='Sort Descending.';cotdn.src='/images/down_mo.gif';return true;"
			onmouseout="self.status='';cotdn.src='/images/down.gif';return true;">
			<img src="/images/down.gif" border="0" name="cotdn"></a>	
	</td>
	<td nowrap>
		<strong>Verbatim Date</strong>
		<cfset thisTerm = "verbatim_date">
		<cfset thisName = #replace(thisTerm,",","_","all")#>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisName#up"></a>
	<a href="javascript: void" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
	</td>
</cfif>		
<cfif #detail_level# gte 3>
	<td nowrap>
		<strong>
			Coll Date
		</strong>
	</td>
</cfif>
<cfif #detail_level# gte 1>
	<td nowrap>
		<strong>Parts</strong>
	</td>
	<td nowrap>
		<strong>Sex</strong>&nbsp;
	</td>
</cfif>
<cfif #detail_level# gte 3>
	<cfloop list="#attList#" index="val">
		<cfif #val# is not "sex">
			<td nowrap>
				<b>#val#</b>
			</td>
		</cfif>
	</cfloop>
</cfif>
<cfif #detail_level# gte 2>
	<td nowrap>
		<strong>Specimen Remarks</strong>		
	</td>
	<td nowrap>
		<strong>Specimen Disposition</strong>		
	</td>
</cfif>
</cfoutput>
</form>

<cfif #Action# is "dispCollObj">
	<td><strong>Pick Parts</strong></td>
	<td><strong>Encumbrances</strong></td>
</cfif>
</tr>
<cfset i=1>
<cfquery name="colls" dbtype="query">
	select distinct(collection_cde) from getBasic
</cfquery>
<cfset coll="">
<cfloop query="colls">
	<cfif len(#coll#) is 0>
		<cfset coll = "#colls.collection_cde#">
	<cfelse>
		<cfset coll = "#coll#; #colls.collection_cde#">
	</cfif>
</cfloop>
<cfset orderedCollObjIdList = "">
<cfif #getBasic.RecordCount# lt 200>
<cfloop query="getBasic">
	<cfset orderedCollObjIdList="#orderedCollObjIdList#,#collection_object_id#">
</cfloop>
</cfif>

<cfoutput query="getBasic" StartRow="#StartRow#" MaxRows="#DisplayRows#" group="collection_object_id">
 
    <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
	
<cfif #session.killrow# is 1>
<td>

<form name="remove#i#" action="SpecimenResults.cfm" method="post">
	<input type="checkbox" name="exclCollObjId" value="#collection_object_id#" onchange="checkUncheck('remove#i#','#collection_object_id#');">
</form>
	
	</td>
</cfif>	
<cfif isdefined("session.loan_request_coll_id") and #session.loan_request_coll_id# gt 0>
	<td>
	<cfif listfind(#session.loan_request_coll_id#,#collection_id#,",")>
	
		<!--- see if they've already got a part --->
		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select cf_loan_item.collection_object_id from 
			cf_loan_item,specimen_part
			where cf_loan_item.collection_object_id=specimen_part.collection_object_id
			and specimen_part.derived_from_cat_item=#collection_object_id#
			and cf_loan_item.user_loan_id = #thisLoanId#
		</cfquery>
		<a href="javascript:void(0);" onClick="addLoanItem(#collection_object_id#)"><img src="/images/cart.gif" border="0"></a>
		<span id="shopcart#collection_object_id#">
			<cfif len(#isThere.collection_object_id#) gt 0>
				<img src="/images/check.gif" border="0">
			</cfif>
		</span>
	<cfelse>
		<img src="/images/del.gif" border="0">
	</cfif>
	</td>
</cfif>
      <td nowrap>
	 
	  <a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#&orderedCollObjIdList=#orderedCollObjIdList#">
	 <div class="linkButton"
			onmouseover="this.className='linkButton btnhov'" 
			onmouseout="this.className='linkButton'"
			>
			<cfif #cgi.HTTP_HOST# contains "harvard.edu">
				<img src="images/#institution_acronym#_icon.gif" border="0" alt="" width="18" height="18">	
			<cfelse>
				<img src="images/#institution_acronym#_icon.gif" border="0" alt="#institution_acronym#" width="18" height="18">		
			</cfif>	 
			#institution_acronym#&nbsp;#collection_cde#&nbsp;#cat_num#
								</div></a>
  	   
      	</td>
		<cfif len(#session.CustomOtherIdentifier#) gt 0>
		<td>
			#CustomID#
		</td>
		
	</cfif>
		<td nowrap>
			<i>#replace(Scientific_Name," or ","</i> or <i>")#</i>
		</td>
		<cfif #detail_level# gte 3>
			<td nowrap>#sci_name_with_auth#</td>
			<td nowrap>#identified_by#</td>			
		</cfif>
		<cfif #detail_level# gte 4>
	<td>#phylorder#</td>
	<td>#family#</td>
</cfif>

<cfif #detail_level# gte 2> 
			
		<td nowrap>
		<cfset oid = #replace(OTHERCATALOGNUMBERS,";","<br>","all")#>
			<cfset oid = #replace(oid," ","&nbsp;","all")#>
			<cfset oid = #replace(oid,"<br>&nbsp;","<br>","all")#>
			#oid#&nbsp;
		</td>
	
		<td nowrap>
			#Accession#
		</td>

	
			
		<td nowrap>
			<cfset c = #replace(Collectors,",","<br>","all")#>
			<cfset c = #replace(c," ","&nbsp;","all")#>
			<cfset c = #replace(c,"<br>&nbsp;","<br>","all")#>
				#c#
		</td>
		</cfif>
	<cfif #detail_level# gte 2>
		
			<td nowrap>
				
				
						#verbatimLatitude#&nbsp;
				
			</td>
			<td nowrap>
				
						#verbatimLongitude#&nbsp;
			</td>
	</cfif>
<cfif #detail_level# gte 4>
				<td nowrap>
					
				
						#dec_lat#&nbsp;
				</td>
				<td nowrap>
			
						#dec_long#&nbsp;
					
				</td>
				<td nowrap>
					#COORDINATEUNCERTAINTYINMETERS#&nbsp;
				</td>
				<td nowrap>
					#datum#&nbsp;
				</td>
				<td nowrap>
					#orig_lat_long_units#&nbsp;
				</td>
				<td nowrap>
					#lat_long_determiner#&nbsp;
				</td>
				<td nowrap>
					#lat_long_ref_source#&nbsp;
				</td>
				<td>
					#lat_long_remarks#&nbsp;
				</td>
				
</cfif>
<cfif #detail_level# gte 4>
	<td>#CONTINENT_OCEAN#&nbsp;</td>
</cfif>			

			<td>#Country#&nbsp;</td>
	 
		 <td>#State_Prov#&nbsp;</td>
<cfif #detail_level# gte 4>
	<td>#sea#&nbsp;</td>
</cfif>			
<cfif #detail_level# gte 2>
		 <td>#quad#&nbsp;</td>
	
		<td nowrap>
			#feature#&nbsp;
		</td>
	
		  <td>#county#&nbsp;</td>
		  <td>#island_group#&nbsp;</td>
			<td>#island#&nbsp;</td>
	<td nowrap>#associated_species#&nbsp;</td>
		<td nowrap>#habitat#&nbsp;</td>
		<td>
			<cfif len(#MIN_ELEV_IN_M#) gt 0 or len(#MAX_ELEV_IN_M#) gt 0>
				#MIN_ELEV_IN_M#&nbsp;-&nbsp;#MAX_ELEV_IN_M#
			</cfif>
		</td>
		
</cfif>  
	<td>
			#spec_locality#&nbsp;
		</td>
		<td>
			#verbatim_date#&nbsp;
		</td>

<cfif #detail_level# gte 3>
	<cfif #began_date# is #ended_date# AND len(#began_date#) gt 0>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")#">
	<cfelseif len(#ended_date#) is 0 AND len(#began_date#) is 0>
		<cfset collDate = "Not recorded.">
	<cfelse>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#">
	</cfif>
	<td nowrap>
		#collDate#&nbsp;
	</td>
</cfif>
	<td>
		<cfset p = #replace(parts,";","<br>","all")#>
		<cfset p = #replace(p," ","&nbsp;","all")#>
		<cfset p = #replace(p,"<br>&nbsp;","<br>","all")#>
		#p#&nbsp;
	</td>
	<cfif #detail_level# gte 1>
		<td nowrap>
			#sex#&nbsp;
		</td>
	</cfif>
	<cfif #detail_level# gte 3>
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #thisName# is not "sex">
			<td nowrap="nowrap">
				#evaluate("getBasic." &  thisName)# &nbsp;
				</td>
			</cfif>
		</cfloop>
	</cfif>
		
	<cfif #detail_level# gte 2>
		<td nowrap>
			#remarks#&nbsp;
		</td>
		<td nowrap>
			#coll_obj_disposition#
		</td>
	</cfif>
<!----------------------------------------------------------------------------------------------------->
  <!--- The following bits add items to a loan --->
  <!----------------------------------------------------------------------------------------------------->	
  <cfif #Action# is "dispCollObj">
  
	<!----
	<cfquery name="getParts" dbtype="query">
	    select part_name, partID, coll_obj_disposition
		  from getBasic where collection_object_id = #collection_object_id# group by part_name, partID,coll_obj_disposition
	  </cfquery>
	  ---->
	<cfquery name="getParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    select 
			part_name, 
			specimen_part.collection_object_id partID, 
			coll_obj_disposition,
			encumbrance_action
		  from 
		 	specimen_part,
			coll_object,
			coll_object_encumbrance,
			encumbrance
		where 
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			specimen_part.collection_object_id = coll_object_encumbrance.collection_object_id (+) AND
			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
			specimen_part.derived_from_cat_item = #collection_object_id# 
		group by part_name, specimen_part.collection_object_id,coll_obj_disposition,encumbrance_action
	  </cfquery>
	    <td nowrap>
	  <cfset i=1>
	 
	  <cfloop query="getParts">
	  	#part_name#
		  <cfif len (#getParts.partID#) gt 0 AND isdefined("transaction_id")>
			    <!--- they are trying to add a loan item to a loan as a curatorial user --->
			    <!--- check for rights ---->
			    <!----and give them a button to click --->
	  <cfset thisName = "p#getParts.partID#">
	  <form name="parts#getParts.partID#">
		  <input type="button" value="Add #getParts.part_name# (details)" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
   onClick="window.open('/picks/internalAddLoanItem.cfm?collection_object_id=#getParts.partID#&transaction_id=#transaction_id#&item=#getParts.part_name#','_AddLoanItem','width=500,height=400');parts#getParts.partID#.#thisName#.checked=1;">	
  
		<br>
		   <input type="button" value="Add whole" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
    onClick="window.open('/picks/internalAddLoanItem.cfm?collection_object_id=#getParts.partID#&transaction_id=#transaction_id#&item=#getParts.part_name#&Action=AddItem&selfClose=y&isSubsample=n','_AddLoanItem');parts#getParts.partID#.#thisName#.checked=1;">	
   
   <input type="button" value="Add subsample" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
		onClick="window.open('/picks/internalAddLoanItem.cfm?collection_object_id=#getParts.partID#&transaction_id=#transaction_id#&item=#getParts.part_name#&Action=AddItem&selfClose=y&isSubsample=y','_AddLoanItem');parts#getParts.partID#.#thisName#.checked=1;">
				  
				  
				<br>(#coll_obj_disposition#)&nbsp;&nbsp;Added? <input type="checkbox" name="#thisName#">
			  </form>	
  <hr>
		  <cfelse>
			  You don't seem to have the proper rights to be here!
			  <cfabort>	
		  </cfif>
	  <cfset i=#i#+1>
	  </cfloop>
	  </td>
	  

  <td>
	  <cfif len(#getParts.encumbrance_action#) gt 0>
		 #getParts.encumbrance_action#<br>
	  <cfelse>
		  None
	  </cfif> 
  </td>
  </cfif>
  <!-----------------------------------------------------------------------------------------
					End loan items bit
---------------------------------------------------------------------->
  </tr>
  
  <cfset i=#I#+1>
  </cfoutput>
<cfif #session.killrow# is 1>
  <tr>
  	
	<td>
	
	<form name="DnSubRem" method="post" action="SpecimenResults.cfm">
		<img src="/images/delete.gif" border="0" width="24" onClick="reloadThis.submit();">
	</form>
	
	</td>
	
  </tr>
 </cfif>  
</table>
<cfset maxI=#I#>

	

<cfoutput>
	<!---- browse buttons ---->
	<table cellpadding="10">
		<tr>
		<CFIF startrow GT 1>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='1';
				document.browse.submit();">First&nbsp;Page</span>
		</td>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='#previous#';
				document.browse.submit();">Previous&nbsp;Page</span>
		</td>
	</CFIF>
	<CFIF Next LTE getBasic.RecordCount>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='#Next#';
				document.browse.submit();">Next&nbsp;Page</span>
		</td>
		<td width="20">
			<span class="infoLink" onclick="document.browse.StartRow.value='#LastRecs#';
				document.browse.submit();">Last&nbsp;Page</span>
		</td>
	</CFIF>
	<CFIF displayrows LT getBasic.RecordCount + 1>
		<td>
			<span class="infoLink" onclick="document.browse.StartRow.value='1';
				document.browse.displayRows.value='#getBasic.RecordCount#';
				document.browse.submit();">View&nbsp;All</span>
		</td>
	</CFIF>
	<CFIF displayrows is getBasic.RecordCount>
		<td>
			<span class="infoLink" onclick="document.browse.StartRow.value='1';
				document.browse.displayRows.value='#session.displayRows#';
				document.browse.submit();">View&nbsp;Pages</span>
		</td>	
	</CFIF>
		</tr>
	</table>
	<!---- end browse buttons ---------------------->
	<!---
<!---- browse buttons ---->
	<table>
		<CFIF startrow GT 1>
		<td width="20">
			<img src="/images/first.gif" 
				border="0" 
				alt="First Records" 
				class="likeLink" 
				onClick="document.browse.StartRow.value='1';document.browse.submit();"
				onMouseOver="self.status='First Records';"
				onMouseOut="self.status='';">
		</td>
		<td width="20">
			<img src="/images/previous.gif" 
				border="0" 
				alt="previous" 
				class="likeLink" 
				onClick="document.browse.StartRow.value='#previous#';document.browse.submit();"
				onMouseOver="self.status='Previous Records';"
				onMouseOut="self.status='';">
		</td>
	<cfelse>
		<td width="20">
			<img src="/images/no_first.gif" 
				border="0">
		</td>
		<td width="20">
			<img src="/images/no_previous.gif" 
				border="0">
		</td>
	</CFIF>
	<CFIF Next LTE getBasic.RecordCount>
		<td width="20">
			<img src="/images/next.gif" border="0" alt="next" class="likeLink" 
				onClick="document.browse.StartRow.value='#Next#';document.browse.submit();"
				onMouseOver="self.status='Next Records';"
				onMouseOut="self.status='';">
		</td>
		<td width="20">
			<img src="/images/last.gif" border="0" alt="last" class="likeLink" 
				onClick="document.browse.StartRow.value='#LastRecs#';document.browse.submit();"
				onMouseOver="self.status='Last Records';"
				onMouseOut="self.status='';">
		</td>
	<cfelse>
		<td width="20">
			<img src="/images/no_next.gif" 
				border="0">
		</td>
		<td width="20">
			<img src="/images/no_last.gif" 
				border="0">
		</td>
	
	</CFIF>	

	</table>
	<!---- end browse buttons ---------------------->
	---->
<form name="level" action="SpecimenResults.cfm" method="post">
#searchParams#
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="StartRow" type="hidden" value="1">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="1">
				<input type="hidden" name="detail_level">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="collobjidlist" value="#collobjidlist#">
				
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				<table border>
					<tr>
						<td colspan="6" align="center" nowrap="nowrap">
							Detail Level&nbsp;&nbsp;
							<span class="infoLink" onclick="getHelp('detail_level');">
								What's this?
							</span>
						</td>
					</tr>
					<tr>
						<td><font size="-1">Less</font></td>
						<td>
							<div id="lev1" style="padding:2px; background-color:##6600CC ">
							<input type="button" value="1" class="lnkBtn"
							   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
							   onClick="level.detail_level.value='1';submit();">
						  </div>
							  <cfif #detail_level# is 1>
							  	<SCRIPT language="javascript" type="text/javascript">
									document.getElementById('lev1').style.backgroundColor = 'red';
								</script>
							  </cfif>
						</td>
						<td>
							<div id="lev2" style="padding:2px; background-color:##6600CC ">
							<input type="button" value="2" class="lnkBtn"
							   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
							   onClick="level.detail_level.value='2';submit();">
						  </div>
							  <cfif #detail_level# is 2>
							  	<SCRIPT language="javascript" type="text/javascript">
									document.getElementById('lev2').style.backgroundColor = 'red';
								</script>
							  </cfif>
						</td>
						<td>
							<div id="lev3" style="padding:2px; background-color:##6600CC ">
							<input type="button" value="3" class="lnkBtn"
							   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
							   onClick="level.detail_level.value='3';submit();">
						  </div>
							  <cfif #detail_level# is 3>
							  	<SCRIPT language="javascript" type="text/javascript">
									document.getElementById('lev3').style.backgroundColor = 'red';
								</script>
							  </cfif>
						</td>
						<td>
							<div id="lev4" style="padding:2px; background-color:##6600CC ">
							<input type="button" value="4" class="lnkBtn"
							   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
							   onClick="level.detail_level.value='4';submit();">
						  </div>
							  <cfif #detail_level# is 4>
							  	<SCRIPT language="javascript" type="text/javascript">
									document.getElementById('lev4').style.backgroundColor = 'red';
								</script>
							  </cfif>
						</td>
						<td><font size="-1">More</font></td>
					</tr>
				</table>
				
</form>		
</cfoutput>
<!---------------------------- reload this page -------------------------------------------->
<cfoutput>
<cfif not isdefined("ExclCollObjId")>
	<cfset passExclCollObjId = "">
<cfelse>
	<!---- append any passed values ---->
	<cfset passExclCollObjId = #ExclCollObjId#>
	<cfset ExclCollObjId = "">
	<cfset searchParams = replace(searchParams,"ExclCollObjId","nothing","all")>
</cfif>
<form name="reloadThis" action="SpecimenResults.cfm" method="post" id="reloadThis">
	<input type="hidden" name="exclCollObjId" value="#passExclCollObjId#">
#searchParams#
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="StartRow" type="hidden" value="1">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="1">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="NewSearch" type="hidden" value="1">
				
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				<input type="Submit" value="Refresh Form" class="lnkBtn"
							   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
				
</form>				
</cfoutput>
<!---------------------------- /reload this page -------------------------------------------->



<cfoutput>
<form name="dlData" action="SpecimenResultsHTML.cfm" method="post">
			<input type="hidden" name="searchParams" value='#searchParams#'>
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input type="hidden" name="cnt" value="#getBasic.recordcount#">
				<input type="hidden" name="Action" value="Download">
				<input name="NewQuery" type="hidden" value="0">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<input type="hidden" name="collobjidlist" value="#collobjidlist#">
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				<cfif isdefined("session.username") and len(#session.username#) gt 0>
					<input type="submit" value="Download" class="lnkBtn"
	   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
   				<cfelse>
					<br /><a href="/login.cfm">Create an Account or Sign In</a> to download these data.
				</cfif>
				</form>
</cfoutput>
<!-----			one-size fits all management widget				------>
<cfif getBasic.recordcount lt 1000>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
	<cfoutput>
		<!---
			<option  value="/CustomPages/ALALabels.cfm">ALA Labels</option>
			<option  value="/CustomPages/ALALabelsOnline.cfm">ALA Labels online</option>
		--->
	<form name="goSomewhereElseNow" method="post">
		<select name="goWhere" size="1">
			<option value="Encumbrances.cfm?collection_object_id=#collObjIdList#">
				Encumbrances
			</option>
			<option value="UamMammalVialLabels_pdffile.cfm?collection_object_id=#collObjIdList#">
				UAM Mammals Vial Labels
			</option>
			<option value="mammalLabels.cfm?collection_object_id=#collObjIdList#&action=box">
				UAM Mammals Box Labels
			</option>
			<option value="MSBMammLabels.cfm?collection_object_id=#collObjIdList#">
				MSB Mammals Labels
			</option>
			<option value="narrowLabels.cfm?collection_object_id=#collObjIdList#">
				MVZ narrow Labels
			</option>
			<option value="wideLabels.cfm?collection_object_id=#collObjIdList#">
				MVZ wide Labels
			</option>
			<option value="tissueParts.cfm?collection_object_id=#collObjIdList#">
				Flag Parts as Tissues
			</option>
			<option value="editIdentification.cfm?collection_object_id=#collObjIdList#&Action=multi">
				Identification
			</option>
			<option value="location_tree.cfm?collection_object_id=#collObjIdList#&srch=part">
				Part Locations
			</option>
			<option value="bulkCollEvent.cfm?collection_object_id=#collObjIdList#">
				Collecting Events
			</option>
			<option value="addAccn.cfm?collection_object_id=#collObjIdList#">
				Accession
			</option>
			<option value="compDGR.cfm?collection_object_id=#collObjIdList#">
				MSB<->DGR
			</option>
			<option value="/Reports/print_nk.cfm?collection_object_id=#collObjIdList#">
				Print NK pages
			</option>
		</select>
		<input type="button" 
			value="Go" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'"
			onClick="document.location=goWhere.value">
	</form>
	</cfoutput>
	
</cfif>
<cfelse>
	Management functions only work when your search returns less than 1000 records.
</cfif>
<!-----			end one-size fits all management widget				------>
</div>

<!------------------------- make download ----------------------------------------------------------->
<cfif #Action# is "download">
<cfset dlPath = "#Application.DownloadPath#">
<cfset dlFile = "#session.DownloadFileName#">
	<cfset header = "Catalog_Number">
	<cfif len(#session.CustomOtherIdentifier#) gt 0>
		<cfset header = "#header##chr(9)##session.CustomOtherIdentifier#">
	</cfif>
	<cfset header = "#header##chr(9)#Identified_As">
<cfif #detail_level# gte 3>
	<cfset header = "#header##chr(9)#Scientific_Name#chr(9)#Identified_By">
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Order#chr(9)#Family">
</cfif>
<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Other_Identifiers#chr(9)#Accession#chr(9)#Collectors#chr(9)#Latitude#chr(9)#Longitude">
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Decimal_Latitude#chr(9)#Decimal_Longitude#chr(9)#Maximum_Error#chr(9)#Datum#chr(9)#Original_Lat_Long_Units#chr(9)#Georeferenced_By#chr(9)#Lat_Long_Reference#chr(9)#Lat_Long_Remarks">
				
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Continent">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Country#chr(9)#State">
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Sea">
</cfif>
<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Map_Name#chr(9)#Feature#chr(9)#County#chr(9)#Island_Group#chr(9)#Island#chr(9)#Associated_Species#chr(9)#Microhabitat#chr(9)#Elevation_In_Meters">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Specific_Locality#chr(9)#Verbatim_Date">
</cfif>
<cfif #detail_level# gte 3>
	<cfset header = "#header##chr(9)#Coll_Date">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Parts#chr(9)#Sex">
</cfif>

<cfif #detail_level# gte 3>
	<cfloop list="#attList#" index="val">
		<cfif #val# is not "sex">
			<cfset val = #replace(val," ","_","all")#>
			<cfset header = "#header##chr(9)##val#">
		</cfif>
	</cfloop>
</cfif>

	<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Specimen_Remarks#chr(9)#Specimen_Disposition">
		
	</cfif>
<cfset header=#trim(header)#>
	<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">

 <cfoutput query="getBasic" group="collection_object_id">
 	<cfset oneLine = "#institution_acronym# #collection_cde# #cat_num#">
	<cfif len(#session.CustomOtherIdentifier#) gt 0>
		<cfset oneLine = "#oneLine##chr(9)##CustomID#">
	</cfif>
	<cfset oneLine = "#oneLine##chr(9)##Scientific_Name#">
	<cfif #detail_level# gte 3>
		<cfset oneLine = "#oneLine##chr(9)##sci_name_with_auth##chr(9)##Identified_By#">
	</cfif>
	
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##phylorder##chr(9)##family#">
</cfif>
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##OTHERCATALOGNUMBERS##chr(9)##Accession##chr(9)##Collectors#">
</cfif>
<cfif #detail_level# gte 2>
					<cfset oneLine = "#oneLine##chr(9)##verbatimLatitude##chr(9)##verbatimLongitude#">
</cfif>
<cfif #detail_level# gte 4>
					<cfset oneLine = "#oneLine##chr(9)##dec_lat##chr(9)##dec_long##chr(9)##COORDINATEUNCERTAINTYINMETERS##chr(9)##datum##chr(9)##orig_lat_long_units##chr(9)##lat_long_determiner##chr(9)##lat_long_ref_source##chr(9)##lat_long_remarks#">	
</cfif>
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##CONTINENT_OCEAN#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)##Country##chr(9)##State_Prov#">
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##sea#">
</cfif>
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##quad##chr(9)##feature##chr(9)##county##chr(9)##island_group##chr(9)##island##chr(9)##Associated_Species##chr(9)##habitat##chr(9)##MIN_ELEV_IN_M#-#MAX_ELEV_IN_M#">
</cfif> 
<cfset oneLine = "#oneLine##chr(9)##spec_locality##chr(9)##verbatim_date#">
<cfif #detail_level# gte 3>
	<cfif #began_date# is #ended_date# AND len(#began_date#) gt 0>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")#">
	<cfelseif len(#ended_date#) is 0 AND len(#began_date#) is 0>
		<cfset collDate = "Not recorded.">
	<cfelse>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#">
	</cfif>
	<cfset oneLine = "#oneLine##chr(9)##collDate#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)##parts##chr(9)##sex#">
<cfif #detail_level# gte 3>
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #thisName# is not "sex">
				<Cfset thisVal =#evaluate("getBasic." &  thisName)#>
				<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			</cfif>
		</cfloop>
	</cfif>
	
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##remarks##chr(9)##coll_obj_disposition#">
</cfif>
<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	
	</cfoutput>
	<cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	<cflocation url="download_agree.cfm?cnt=#getBasic.recordcount#&downloadFile=#downloadFile#">
	</cfoutput>
</cfif>
	
	<!------------------------------------- end download ----------------------------------->
<cfif #Action# is "labels">

<cfset dlPath = "#Application.DownloadPath#">
<cfset dlFile = "#session.DownloadFileName#">
	<cfset header = "CatalogNumber#chr(9)#ScientificName#chr(9)#AfNumber#chr(9)#LatLong#chr(9)#Geog#chr(9)#VerbatimDate#chr(9)#Sex#chr(9)#Collectors#chr(9)#Parts#chr(9)#FieldNumber#chr(9)#Measurements#chr(9)#Accn#chr(9)#">

<cfset header=#trim(header)#>
	<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">

 <cfoutput query="getBasic" group="collection_object_id">
 	<cfset af = "">
	<cfif len(#af#) gt 0>
		<cfset af = "AF #af#">
	</cfif>
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	<cfset geog = "">
		<cfif #state_prov# is "Alaska">
			<cfset geog = "Alaska">
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfif len(#quad#) is 0>
					<cfset geog = "#geog#, #sea#">
				</cfif>
			</cfif>
			<cfif len(#quad#) gt 0>
					<cfif not #geog# contains " Quad">
						<cfset geog = "#geog#, #quad# Quad">
					</cfif>
			</cfif>
			
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		<cfelse>
		  	<cfif len(#country#) gt 0>
				<cfset geog = "#country#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfset geog = "#geog#, #sea#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#quad#) gt 0>
				<cfset geog = "#geog#, #quad# Quad">
			</cfif>
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		</cfif>
		<cfset sexcode = "">
		<cfif len(#trim(sex)#) gt 0>
			<cfif #trim(sex)# is "male">
				<cfset sexcode = "M">
			<cfelseif #trim(sex)# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfset FieldNum = "">
		<cfloop list="#OIDlist#" index="val">
			<cfif #val# contains "original field number">
				<cfset FieldNum = "#val#">
			</cfif>
		</cfloop>
		<!---
		<cfif len(#sex#) gt 0>
			<cfif #sex# is "male">
				<cfset sexcode = "M">
			<cfelseif #sex# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		--->
		<cfif #collectors# contains ";">
			<Cfset spacePos = find(";",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		<cfset totlen = "">
		<cfset taillen = "">
		<cfset hf = "">
		<cfset efn = "">
		<cfset weight = "">
		<cfset totlen_val = "">
		<cfset taillen_val = "">
		<cfset hf_val = "">
		<cfset efn_val = "">
		<cfset weight_val = "">
		<cfset totlen_units = "">
		<cfset taillen_units = "">
		<cfset hf_units = "">
		<cfset efn_units = "">
		<cfset weight_units = "">
				
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #val# is "total length">
				<cfset totlen = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "tail length">
				<cfset taillen = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "hind foot with claw">
				<cfset hf = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "ear from notch">
				<cfset efn = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "weight">
				<cfset weight = "#evaluate("getBasic." &  thisName)#">
			</cfif>
		</cfloop>
		<cfif len(#totlen#) gt 0>
			<cfif #trim(totlen)# contains " ">
				<cfset spacePos = find(" ",totlen)>
				<cfset totlen_val = trim(left(totlen,#spacePos#))>
				<cfset totlen_Units = trim(right(totlen,len(totlen) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#taillen#) gt 0>
			<cfif #trim(taillen)# contains " ">
				<cfset spacePos = find(" ",taillen)>
				<cfset taillen_val = trim(left(taillen,#spacePos#))>
				<cfset taillen_Units = trim(right(taillen,len(taillen) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#hf#) gt 0>
			<cfif #trim(hf)# contains " ">
				<cfset spacePos = find(" ",hf)>
				<cfset hf_val = trim(left(hf,#spacePos#))>
				<cfset hf_Units = trim(right(hf,len(hf) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#efn#) gt 0>
			<cfif trim(#efn#) contains " ">
				<cfset spacePos = find(" ",efn)>
				<cfset efn_val = trim(left(efn,#spacePos#))>
				<cfset efn_Units = trim(right(efn,len(efn) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#weight#) gt 0>
			<cfif trim(#weight#) contains " ">
				<cfset spacePos = find(" ",weight)>
				<cfset weight_val = trim(left(weight,#spacePos#))>
				<cfset weight_Units = trim(right(weight,len(weight) - #spacePos#))>
			</cfif>		
		</cfif>
		
			<cfif len(#totlen#) gt 0>
				<cfif #totlen_Units# is "mm">
					<cfset meas = "#totlen_val#-">
				<cfelse>
					<cfset meas = "#totlen_val# #totlen_units#-">
				</cfif>
			<cfelse>
				<cfset meas="X-">
			</cfif>
			
			<cfif len(#taillen#) gt 0>
				<cfif #taillen_Units# is "mm">
					<cfset meas = "#meas##taillen_val#-">
				<cfelse>
					<cfset meas = "#meas##taillen_val# #taillen_Units#-">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X-">
			</cfif>
			
			<cfif len(#hf#) gt 0>
				<cfif #hf_Units# is "mm">
					<cfset meas = "#meas##hf_val#-">
				<cfelse>
					<cfset meas = "#meas##hf_val# #hf_Units#-">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X-">
			</cfif>
	
			<cfif len(#efn#) gt 0>
				<cfif #efn_Units# is "mm">
					<cfset meas = "#meas##efn_val#-">
				<cfelse>
					<cfset meas = "#meas##efn_val# #efn_Units#=">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X=">
			</cfif>
			
			<cfif len(#weight#) gt 0>
				<cfif #weight_Units# is "g">
					<cfset meas = "#meas##weight_val#">
				<cfelse>
					<cfset meas = "#meas##weight_val# #weight_Units#">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X">
			</cfif>
 	<cfset oneLine = "#cat_num##chr(9)##Scientific_Name##chr(9)##af##chr(9)##coordinates##chr(9)##geog##chr(9)##verbatim_date##chr(9)##sexcode##chr(9)##thisColl##chr(9)##parts##chr(9)##FieldNum##chr(9)##meas##chr(9)##Accession#">

	<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	</cfoutput>
	<cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	<cflocation url="download_agree.cfm?cnt=#getBasic.recordcount#&downloadFile=#downloadFile#">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">