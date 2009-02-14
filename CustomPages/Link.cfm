<cfif not isdefined("detail_level") OR len(#detail_level#) is 0>
	<cfif isdefined("session.detailLevel") AND #session.detailLevel# gt 0>
		<cfset detail_level = #session.detailLevel#>
	<cfelse>
		<cfset detail_level = 1>
	</cfif>	
</cfif>
<cfset detail_level = 4>
<cfinclude template = "/includes/_header.cfm">
<cfset title="Specimen Results">
<cfif not isdefined("displayrows")>
	<cfset displayrows = session.displayrows>
</cfif>
<cfif not isdefined("SearchParams")>
	<cfset SearchParams = "">
</cfif>
<cfif not isdefined("maskThis")>
	<cfset maskThis = "">
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

<!---- set it to default if we didn't get anything from a form OR from the above query ---->
<cfif not isdefined("thisUserCols")>
	<!--- default results --->
	<cfset thisUserCols="scientific_name,country,state_prov,specific_locality">
</cfif>

<!--- set up the basic SQL, tack qualifiers on below ><cfset thisUserCols = "#thisUserCols#,attribute_detail">--->
<cfif #newQuery# is 1>	<!--- build and send the query--->

<!--- The progress bar --->

	<cfset basSelect = " SELECT 
		cataloged_item.collection_object_id as collection_object_id,
		cat_num,
		institution_acronym,
		collection.collection_cde,
		concatEncumbrances(cataloged_item.collection_object_id) encumbrance_action,
		concatparts(cataloged_item.collection_object_id) parts
		,ConcatAttributeValue(cataloged_item.collection_object_id,'sex') sex
		,scientific_name,
		spec_locality,
		concatColls('collection_object_id', cataloged_item.collection_object_id, 'agent_name','coll_names') collectors
		,specCollObj.coll_obj_disposition
		,began_date, ended_date
		,dec_lat decimalLatitude,dec_long decimalLongitude
	">
	<!----
	
	
	,concatEncumbrances(cataloged_item.collection_object_id)
	
	--->
	<cfset basFrom = " FROM 
		cataloged_item,
		collection,
		identification
		,geog_auth_rec,
		locality,
		collecting_event
		,accepted_lat_long,preferred_agent_name lat_long_determiner
		,coll_object specCollObj">

	<cfset basWhere = " WHERE 
	 cataloged_item.collection_id = collection.collection_id
								AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id
								AND collecting_event.locality_id = locality.locality_id
								AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id
								AND locality.locality_id = accepted_lat_long.locality_id (+) AND accepted_lat_long.determined_by_agent_id = lat_long_determiner.agent_id (+)
								AND cataloged_item.collection_object_id = specCollObj.collection_object_id">	
<!--------------------------------------------------------------->
	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="/includes/SearchSql.cfm">
	<cfoutput>
	
		
			

		<cfset SqlString = "#basSelect# #basFrom# #basWhere# #basQual# ORDER BY cataloged_item.collection_object_id">	

	
	<!--- define the list of search paramaters that we need to get back here --->

	<cfset searchParams = "">
	<!--- set up hidden form variables to use when customizing.
			Explicitly exclude things we don't want --->
		<cfset searchParams = "">
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
					and #key# is not "STARTROW"
					and #key# is not "detail_level">
					<cfif len(#searchParams#) is 0>
						<cfset searchParams='<input type="hidden" name="#key#" value="#form[key]#">'>
					<cfelse>
						<cfset searchParams='#searchParams#<input type="hidden" name="#key#" value="#form[key]#">'>
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
					<cfif len(#searchParams#) is 0>
						<cfset searchParams='<input type="hidden" name="#key#" value="#url[key]#">'>
					<cfelse>
						<cfset searchParams='#searchParams#<input type="hidden" name="#key#" value="#url[key]#">'>
					</cfif>
				</cfif>
			 </cfif>
		</cfloop>
		
		<cfset searchParams = #replace(searchParams,"'","","all")#>
		
	</cfoutput>
		<cfif len(#basQual#) is 0 AND basFrom does not contain "binary_object">
			<CFSETTING ENABLECFOUTPUTONLY=0>
			
			<font color="#FF0000" size="+2">You must enter some search criteria!</font>	  
			<cfabort>
		</cfif>
		<!-----
		
		<cfabort>
	
				
		<hr>#searchParams#
	
<cfoutput>
	#preserveSingleQuotes(SqlString)#
	</cfoutput>
		----->
	
	
	<cfquery name="getData" datasource = "#Application.web_user#" >
		#preserveSingleQuotes(SqlString)#
	</cfquery>
	
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
				Try broadening your search criteria. Try the next-higher geographic element, remove criteria, etc.
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
	
<cfset maskThis = "">
<cfif #session.rights# does not contain "student0">
<!--- find records that we should have masked collector for --->
	<cfif isdefined("coll") AND len(#coll#) gt 0 AND #coll_role# is "c">
		<cfloop query="getData">
			<cfif #getData.encumbrance_action# contains "mask collector">
				<cfif len(#maskThis#) is 0>
					<cfset maskThis = "#getData.collection_object_id#">
				  <cfelse>
				   <cfset maskThis = "#maskThis#, #getData.collection_object_id#">
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isdefined("coll") AND len(#coll#) gt 0 AND #coll_role# is "p">
		<cfloop query="getData">
			<cfif #getData.encumbrance_action# contains "mask preparator">
				<cfif len(#maskThis#) is 0>
					<cfset maskThis = "#getData.collection_object_id#">
				  <cfelse>
				   <cfset maskThis = "#maskThis#, #getData.collection_object_id#">
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isdefined("OIDNum") AND len(#OIDNum#) gt 0>
		<cfloop query="getData">
			<cfif #getData.encumbrance_action# contains "mask original field number">
				<cfif len(#maskThis#) is 0>
					<cfset maskThis = "#getData.collection_object_id#">
				  <cfelse>
				   <cfset maskThis = "#maskThis#, #getData.collection_object_id#">
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<!---- mask data for users who aren't at least student0 rated ---->
<cfset basicSql = "select * from getData">
<cfif #session.rights# does not contain "student0">
	<cfset basicSql = "#basicSql# where encumbrance_action not in ('mask record')">
	<cfif len(#maskThis#) gt 0>
		<cfset basicSql = "#basicSql# AND collection_object_id NOT IN (#maskThis#)">
	</cfif>
</cfif>
<cfset basicSql = "#basicSql# ORDER BY cat_num">
<!---- kill the cached query since we're in the newquery loop
<cfquery name="SpecRes#cfid##cftoken#" dbtype="query">
	#preservesinglequotes(basicSql)#
</cfquery> ---->
<!---- build a new query and cache it ---->
<cfquery name="filteredData" dbtype="query"><!--- cache this AFTER we build the flat table ---->
	#preservesinglequotes(basicSql)#
</cfquery>
<cfquery name="uCollObj" dbtype="query">
	select distinct(collection_object_id) as collection_object_id from filteredData
</cfquery>

	<CFSETTING ENABLECFOUTPUTONLY=0>
	

<!---- clear old queries from cache and cache flatquery ---->
	<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,0,0)#">
		select * from filtereddata
	</cfquery>
	<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from filtereddata
	</cfquery>

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
<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from SpecRes#cfid##cftoken#
</cfquery>


<cfoutput>
<cfquery name="getBasic" dbtype="query">
	select * from SpecRes#cfid##cftoken# order by #order_by# #order_order#
</cfquery>
</cfoutput>

<cfquery name="cnt" dbtype="query">
	select distinct(collection_object_id) from getBasic
</cfquery>
<cfif cnt.recordcount lt 1000>
	<cfif cnt.recordcount is 0>
		<cfset mapcount = 0>
	</cfif>
	<cfset mapIds = "">
	<cfloop query="cnt">
		<cfif len(#mapIds#) is 0>
			<cfset mapIds = "#collection_object_id#">
		  <cfelse>
			<cfset mapIds = "#mapIds#,#collection_object_id#">
		</cfif>
	</cfloop>
	<cfif len(#mapIds#) gt 0>
	<cfquery name="mapCount#cfid##cftoken#" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT collection_object_id FROM
			cataloged_item,
			collecting_event,
			accepted_lat_long
		WHERE
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
			collecting_event.locality_id = accepted_lat_long.locality_id AND
			dec_lat is not null AND
			dec_long is not null AND
			cataloged_item.collection_object_id IN (#mapIds#)	
	</cfquery>
	<cfset collobjidlist = #mapIds#>
	<cfquery name="mapCount" dbtype="query">
		select count(collection_object_id) as mapCount from mapCount#cfid##cftoken#
	</cfquery>
	<cfset mapCount = mapCount.mapCount>
	</cfif>
  
  
  
  <cfelse>
  <!--- split it up into however many lists we need --->
    <cfset theseLists = "">
  <cfset numLoops = #int(cnt.recordcount / 1000)# + 1>
  <cfset NumberOfLoops = #numloops#>
  <cfset thisLoopNumber = 1>
  <cfset CollObjListNumber = 1>
  <!--- set our startrows at 1, 1001, ---->

	<cfloop index ="loopnum" from = "1" to = "#numLoops#">
		<cfoutput>
			<cfif #loopnum# gt 1>
	
				<cfset theseRecs = (#loopnum# -1) * 1000 + 1>
	  		  <cfelse>
	  			<cfset theseRecs = #loopnum#>
	 		</cfif>
	<cfif len(#theseLists#) is 0>
		<cfset theseLists = "#theseRecs#">
	<cfelse>
		<cfset theseLists = "#theseLists#,#theseRecs#">
	</cfif>
	</cfoutput>
<cfset #loopnum# = "">
		  <cfoutput query="cnt" startrow="#theseRecs#" maxrows="1000">
		  		<cfif len(#loopnum#) is 0>
				<cfset #loopnum# = "#collection_object_id#">
				<cfelse>
				<cfset #loopnum# = "#loopnum#,#collection_object_id#">
				</cfif>
				
		  </cfoutput>
		
		 <cfoutput> 
<cfquery name="#theseRecs#" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT collection_object_id FROM
			cataloged_item,
			collecting_event,
			accepted_lat_long
		WHERE
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
			collecting_event.locality_id = accepted_lat_long.locality_id AND
			dec_lat is not null AND
			dec_long is not null AND
			cataloged_item.collection_object_id IN (#loopnum#)	
</cfquery>
		</cfoutput>
		<!--- assign lists of collection object ids to lists, 
		--->
 </cfloop>
  

   <cfoutput>
 
	<cfset mapCount = 0>
		<cfloop list="#theseLists#" index="i">
			<cfloop query="#i#">
				<cfset mapCount = #mapCount# + 1>
			</cfloop>
		</cfloop>
	
  </cfoutput>
		
		
	
</cfif>






<P>
<CFOUTPUT>
<cfparam name="StartRow" default="1">
<CFSET ToRow = #StartRow# + (#DisplayRows# - 1)>
<CFIF ToRow GT cnt.RecordCount>
    <CFSET ToRow = cnt.RecordCount>
</CFIF>
<div align="left">
  <H4>Displaying records #StartRow# - #ToRow# from the 
#cnt.RecordCount# total records that matched your criteria.
<cfif len(#mapCount#) is 0>
	<cfset mapCount = 0>
</cfif>
<cfset cbifurl="/cbifMap.cfm?#mapurl#">
<cfset berkUrl = "http://elib.cs.berkeley.edu:8080/cgi-bin/uam_query?#session.mapSize##mapurl#">
<br><a href="#berkUrl#" class="novisit">Map #mapCount# of these #cnt.RecordCount# records at DLP</a>

<br><a href="#cbifurl#" class="novisit">Map #mapCount# of these #cnt.RecordCount# records at CBIF</a>
<br><a href="javascript:void(0);"
												onClick="getHelp('map'); return false;"
												onMouseOver="self.status='Click for Map help.';return true;"
												onmouseout="self.status='';return true;"><img src="/images/info.gif" border="0"></a>

<cfif #Action# is "dispCollObj">
<br><a href="Loan.cfm?transaction_id=#transaction_id#&Action=editLoan">Back to Loan</a>
</cfif>
</div>
</H4>
</CFOUTPUT>
</P>


<table>
	<CFOUTPUT>
	
	<!--- update the values for the next and previous rows to be returned --->
	<CFSET Next = StartRow + session.DisplayRows>
	<CFSET Previous = StartRow - session.DisplayRows>
	<cfif  #cnt.RecordCount# - #toRow#  lt #session.DisplayRows#>
		<cfset nextRows = #cnt.RecordCount# - #torow#>
	  <cfelse>
		<cfset nextRows = #session.DisplayRows#>
	</cfif>

	  <tr>
		<td><CFIF Previous GTE 1>
				<form name="form3" action="Link.cfm" method="post">
				#searchparams#
				<input type="submit" value="Previous #session.DisplayRows# Records" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
				
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="maskThis" type="hidden" value="#maskThis#">
				<input name="StartRow" type="hidden" value="#Previous#">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="detail_level" value="#detail_level#">
				
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				</form>
	</CFIF></td>
		<td><!--- Create a next records link if there are more records in the record set 
		  that haven't yet been displayed. --->
	<CFIF Next LTE getBasic.RecordCount>
				<form name="form4" action="Link.cfm" method="post">
				#searchParams#
				<input type="submit" value="Next #nextrows# Records" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	

				
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="maskThis" type="hidden" value="#maskThis#">
				<input name="StartRow" type="hidden" value="#Next#">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<input name="thisUserCols" type="hidden" value="#thisUserCols#">
				
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				</form>
	</CFIF>
	</td>
	  </tr>
  </CFOUTPUT>
</table>
	
	
<table width="95%" border="1">
<tr>
 
	
	<cfoutput>
	
				
				
<form name="reorder" action="Link.cfm" method="post">
				#searchParams#
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="maskThis" type="hidden" value="#maskThis#">
				<input name="StartRow" type="hidden" value="1">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<input name="thisUserCols" type="hidden" value="#thisUserCols#">
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
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
<cfif isdefined("session.active_loan_id") and #session.active_loan_id# gt 0>
	<td><b>Request</b></td>
</cfif>
	<td nowrap><strong>Catalog Number</strong>
	<a href="javascript: void(0);" 
		onClick="reorder.order_by.value='cat_num';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';catup.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';catup.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="catup"></a>
	<a href="javascript: void(0);" 
		onClick="reorder.order_by.value='cat_num';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';catdn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';catdn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="catdn"></a>
	</td>

	<td nowrap><strong>Scientific Name</strong>
		<a href="javascript: void(0);" 
		onClick="reorder.order_by.value='scientific_name';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';sciup.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';sciup.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="sciup"></a>
	<a href="javascript: void(0);" 
		onClick="reorder.order_by.value='scientific_name';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';scidn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';scidn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="scidn"></a>	
	</td>
</cfif>
<cfif #detail_level# gte 2>
	

		
	
		
	
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
	
</cfif>
<cfif #detail_level# gte 4>
				<td nowrap>
					<strong>Decimal Latitude</strong>
					<cfset thisTerm = "decimallatitude">
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
					<cfset thisTerm = "decimallongitude">
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
<cfif #detail_level# gte 1>
		
	
</cfif>
<cfif #detail_level# gte 2>
		

</cfif>
<cfif #detail_level# gte 1>
	<td nowrap>
		<strong>Specific Locality</strong>
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
	
</cfif>
<cfif #detail_level# gte 4>
	
</cfif>
<cfif #detail_level# gte 2>
	
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

<cfoutput query="getBasic" StartRow="#StartRow#" MaxRows="#session.DisplayRows#" group="collection_object_id">
 
    <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
	<cfif isdefined("session.active_loan_id") and #session.active_loan_id# gt 0>
	<td>
	<cfquery name="isLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select part_name from specimen_part, 
		cf_loan_item
		where specimen_part.collection_object_id = cf_loan_item.collection_object_id and
		cf_loan_item.loan_id = #active_loan_id# and
		derived_from_cat_item=#collection_object_id#
	</cfquery>
	
	<a href="javascript:void(0);" onClick="addLoanItem(#collection_object_id#)"><img src="/images/shoppingcart.gif" border="0" width="30"></a>
	<cfif #isLoanItem.recordcount# gt 0>
		<img src="images/check.gif" border="0">
	</cfif>
	
	</td>
</cfif>

      <td nowrap>
	 
  	    <a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
			#institution_acronym#&nbsp;#collection_cde#&nbsp;#cat_num#</a>
      	</td>
		
		<td nowrap>
			<i>#Scientific_Name#</i>
		</td>
<cfif #detail_level# gte 2> 
			
		
	
	
			
		<td nowrap>
			<cfset c = #replace(Collectors,";","<br>","all")#>
			<cfset c = #replace(c," ","&nbsp;","all")#>
			<cfset c = #replace(c,"<br>&nbsp;","<br>","all")#>
			<cfif #encumbrance_action# is not "mask collector">
				#c#
			<cfelse>
				Anonymous
			</cfif>
		</td>
		</cfif>
	<cfif #detail_level# gte 2>
		
			
	</cfif>
<cfif #detail_level# gte 4>
				<td nowrap>
					#decimallatitude#&nbsp;
				</td>
				<td nowrap>
					#decimallongitude#&nbsp;
				</td>
				
</cfif>
			
			
<cfif #detail_level# gte 2>
		
	
		
</cfif>  
	<td>
			#spec_locality#&nbsp;
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
		
	</cfif>
	<cfif #detail_level# gte 4>
		
	</cfif>
	<cfif #detail_level# gte 2>
		
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
	  <cfquery name="getParts" datasource="#uam_dbo#">
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
  
		
				  
				<input type="button" value="Add subsample" onClick="window.open('/picks/internalAddLoanItem.cfm?collection_object_id=#getParts.partID#&transaction_id=#transaction_id#&item=#getParts.part_name#&Action=AddItem&selfClose=y&isSubsample=y','_AddLoanItem');parts#getParts.partID#.#thisName#.checked=1;" #instClr#>
				  
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
</table>
<P>

	
	 
	<!--- Create a previous records link if the records being displayed aren't the
		  first set --->
<table>
	<CFOUTPUT>

	  <tr>
		<td><CFIF Previous GTE 1>
				<form name="form3" action="Link.cfm" method="post">
				#searchParams#
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input type="submit" value="Previous #session.DisplayRows# Records" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="maskThis" type="hidden" value="#maskThis#">				
				<input name="StartRow" type="hidden" value="#Previous#">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				</form>
	</CFIF></td>
		<td><!--- Create a next records link if there are more records in the record set 
		  that haven't yet been displayed. --->
	<CFIF Next LTE getBasic.RecordCount>
				<form name="form4" action="Link.cfm" method="post">
				#searchParams#
				<input type="hidden" name="searchParams" value='#searchParams#'>
				 <input type="submit" value="Next #nextrows# Records" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="maskThis" type="hidden" value="#maskThis#">
				<input name="StartRow" type="hidden" value="#Next#">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="NewSearch" type="hidden" value="0">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				</form>
	</CFIF>
	</td>
	  </tr>
  </CFOUTPUT>
</table>

</P>
<cfoutput>
<div align="left">
<form name="level" action="Link.cfm" method="post">
#searchParams#
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input type="hidden" name="searchParams" value='#searchParams#'>
				<input name="maskThis" type="hidden" value="#maskThis#">
				<input name="StartRow" type="hidden" value="1">
				<input type="hidden" name="Action" value="#Action#">
				<input name="NewQuery" type="hidden" value="1">
				<input type="hidden" name="detail_level">
				<input name="NewSearch" type="hidden" value="0">
				
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				<table border>
					<tr>
						<td colspan="6" align="center">
							Detail Level&nbsp;&nbsp;<a href="javascipt: void(0);" onClick="getHelp('detail_level'); return false;"><img src="images/info.gif" border="0"></a>
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
<cfoutput>
<form name="dlData" action="Link.cfm" method="post">
			<input type="hidden" name="searchParams" value='#searchParams#'>
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input name="mapurl" type="hidden" value="#mapurl#">
				<input name="maskThis" type="hidden" value="#maskThis#">
				<input type="hidden" name="cnt" value="#cnt.recordcount#">
				<input type="hidden" name="Action" value="Download">
				<input name="NewQuery" type="hidden" value="0">
				<input name="NewSearch" type="hidden" value="0">
				<input name="thisUserCols" type="hidden" value="#thisUserCols#">
				<input type="hidden" name="detail_level" value="#detail_level#">
				<input type="hidden" name="order_by" value="#order_by#">
				<input type="hidden" name="order_order" value="#order_order#">
				<!----
				<cfif isdefined("transaction_id")>
					<input type="hidden" name="transaction_id" value="#transaction_id#">
				</cfif>
				---->
				<input type="submit" value="Download" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
				</form>
</cfoutput>



<!-----------------------------------------------------------------------------------------
					End Accns
---------------------------------------------------------------------->


</div>

<!------------------------- make download ----------------------------------------------------------->
<!---- end action not download ---->
<cfif #Action# is "download">

<cfset dlPath = "#application.webDirectory#/download/">
<cfset dlFile = "UAMData_#cfid##cftoken#.txt">
<cfif #detail_level# gte 1>
	<cfset header = "Catalog_Number#chr(9)#Scientific_Name">
</cfif>
<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Collectors">
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Decimal_Latitude#chr(9)#Decimal_Longitude">
				
</cfif>
<cfif #detail_level# gte 1>
	
</cfif>
<cfif #detail_level# gte 2>
	
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Specific_Locality">
</cfif>
<cfif #detail_level# gte 3>
	<cfset header = "#header##chr(9)#Coll_Date">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Parts#chr(9)#Sex">
</cfif>


	<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Specimen_Disposition">
		
	</cfif>
<cfset header=#trim(header)#>
	<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">

 <cfoutput query="getBasic" group="collection_object_id">
 	<cfset oneLine = "#institution_acronym# #collection_cde# #cat_num##chr(9)##Scientific_Name#">

<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##Collectors#">
</cfif>
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##decimallatitude##chr(9)##decimallongitude#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)##spec_locality#">
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

	
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##coll_obj_disposition#">
</cfif>
<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	
	</cfoutput>
	<cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	<cflocation url="/download_agree.cfm?cnt=#cnt.recordcount#&downloadFile=#downloadFile#">
	</cfoutput>
</cfif>
	
	
	
<!------------------------------------------------------------------------>
<cfinclude template = "/includes/_footer.cfm">