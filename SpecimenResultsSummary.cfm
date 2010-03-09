<cfinclude template = "/includes/_header.cfm">
<cfset title="Specimen Results">
<cfif not isdefined("displayrows")>
	<cfset displayrows = session.displayrows>
</cfif>
<cfif not isdefined("SearchParams")>
	<cfset SearchParams = "">
</cfif>
<cfif not isdefined("groupBy")>
	<cfset groupBy = "">
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


<!--- set up the basic SQL, tack qualifiers on below ><cfset thisUserCols = "#thisUserCols#,attribute_detail">--->


<!--- The progress bar --->
<cfif #newQuery# is 1>
 <cfset basSelect = "SELECT COUNT(distinct(#session.flatTableName#.collection_object_id)) CountOfCatalogedItem,#session.flatTableName#.scientific_name">
 <cfset basJoin = "INNER JOIN cataloged_item ON (#session.flatTableName#.collection_object_id = cataloged_item.collection_object_id)">
 <cfset basFrom = " FROM #session.flatTableName#">
  <cfset basWhere = " WHERE #session.flatTableName#.collection_object_id > 0">
<cfset basGroup = "GROUP BY #session.flatTableName#.scientific_name">

<cfif #groupBy# contains "continent_ocean">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.continent_ocean">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.continent_ocean">		
</cfif>
<cfif #groupBy# contains "country">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.country">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.country">		
</cfif>
<cfif #groupBy# contains "state_prov">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.state_prov">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.state_prov">		
</cfif>
<cfif #groupBy# contains "county">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.county">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.county">		
</cfif>
<cfif #groupBy# contains "quad">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.quad">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.quad">		
</cfif>
<cfif #groupBy# contains "feature">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.feature">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.feature">		
</cfif>
<cfif #groupBy# contains "island_group">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.island_group">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.island_group">		
	<!---
	<cfset groupBy = #replace(groupBy,"flat.island_group","isl_group","all")#>
	--->
</cfif>
<cfif #groupBy# contains "island">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.island">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.island">		
</cfif>
<cfif #groupBy# contains "isl_group">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.island_group">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.island_group">		
</cfif>
<cfif #groupBy# contains "sea">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.sea">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.sea">		
</cfif>
<cfif #groupBy# contains "spec_locality">
	 <cfset basSelect = "#basSelect#,#session.flatTableName#.spec_locality">
	 <cfset basGroup = "#basGroup#,#session.flatTableName#.spec_locality">		
</cfif>
<cfif #groupBy# contains "yr">
	 <cfset basSelect = "#basSelect#,to_char(#session.flatTableName#.began_date,'yyyy') yr">
	 <cfset basGroup = "#basGroup#,to_char(#session.flatTableName#.began_date,'yyyy')">		
</cfif>
	
	
	
<!--------------------------------------------------------------->
	<cfset basQual = " where 1=1 ">
	
	<cfset mapurl="">
	<cfinclude template="includes/SearchSql.cfm">
	
	<!--- wrap everything up in a string --->

		<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basQual# #basGroup#">	

	
		<cfif len(#basQual#) is 0 AND basFrom does not contain "binary_object">
			<CFSETTING ENABLECFOUTPUTONLY=0>
			
			<font color="#FF0000" size="+2">You must enter some search criteria!</font>	  
			<cfabort>
		</cfif>
		<!-----
		
		<cfoutput>
	#preserveSingleQuotes(SqlString)#	</cfoutput>
	<cfflush>

		----->
		

	
	<!--- 
		get search parameters 
		There is soem goofy stuff that applies to thei form ONLY -
		be careful pasting this code!!
		-- REMOVE SCIENTIFIC NAME
		-- REMOVE sciNameOper
	---->
	
	<cfset searchParams = "">
	<cfoutput>
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
					and #key# is not "sciNameOper"
					and #key# is not "scientific_name">
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
					and #key# is not "sciNameOper"
					and #key# is not "scientific_name">
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
	
	
<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preserveSingleQuotes(SqlString)#
	</cfquery>
	<cfif getData.recordcount is 0>
	<CFSETTING ENABLECFOUTPUTONLY=0>
			<cfoutput>
		<font color="##FF0000" size="+2">Your search returned no results.</font>	  
		<p>Some possibilities include:</p>
		<ul>
			<li>
				If you searched by taxonomy, please consult <a href="/TaxonomySearch.cfm" class="novisit">Arctos Taxonomy</a>.			</li>
			<li>
				Try broadening your search criteria. Try the next-higher geographic element, remove criteria, etc.			</li>
			<li>
				Use dropdowns or partial word matches instead of text strings, which may be entered in unexpected ways. "Doe" is a good choice for a collector if "John P. Doe" didn't match anything.			</li>
			<li>
				Read the documentation for individual search fields (click the title of the field to see documentation). Arctos fields may not be what you expect them to be.			</li>
		</ul>
		</cfoutput>
		
		<cfabort>
	</cfif>
	
	<cfset newQuery=0>	
<cfset newSearch = 1>
</cfif>
<cfset order_by = "">
<cfif #groupBy# contains "continent_ocean">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "continent_ocean">
	 <cfelse>
	 	<cfset order_by = "#order_by#,continent_ocean">
	 </cfif>
</cfif>
<cfif #groupBy# contains "country">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "country">
	 <cfelse>
	 	<cfset order_by = "#order_by#,country">
	 </cfif>	
</cfif>
<cfif #groupBy# contains "state_prov">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "state_prov">
	 <cfelse>
	 	<cfset order_by = "#order_by#,state_prov">
	 </cfif>
</cfif>
<cfif #groupBy# contains "county">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "county">
	 <cfelse>
	 	<cfset order_by = "#order_by#,county">
	 </cfif>
</cfif>
<cfif #groupBy# contains "quad">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "quad">
	 <cfelse>
	 	<cfset order_by = "#order_by#,quad">
	 </cfif>
</cfif>
<cfif #groupBy# contains "feature">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "feature">
	 <cfelse>
	 	<cfset order_by = "#order_by#,feature">
	 </cfif>
</cfif>
<cfif #groupBy# contains "island_group">
	<cfset groupBy = #replace(groupBy,"island_group","isl_group","all")#>
</cfif>
<cfif #groupBy# contains "island">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "island">
	 <cfelse>
	 	<cfset order_by = "#order_by#,island">
	 </cfif>
</cfif>
<cfif #groupBy# contains "isl_group">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "island_group">
	 <cfelse>
	 	<cfset order_by = "#order_by#,island_group">
	 </cfif>
</cfif>
<cfif #groupBy# contains "sea">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "sea">
	 <cfelse>
	 	<cfset order_by = "#order_by#,sea">
	 </cfif>
</cfif>
<cfif #groupBy# contains "spec_locality">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "spec_locality">
	 <cfelse>
	 	<cfset order_by = "#order_by#,spec_locality">
	 </cfif>
</cfif>

<cfif #groupBy# contains "yr">
	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "yr">
	 <cfelse>
	 	<cfset order_by = "#order_by#,yr">
	 </cfif>
</cfif>

	 <cfif len(#order_by#) is 0>
	 	<cfset order_by = "scientific_name">
	 <cfelse>
	 	<cfset order_by = "#order_by#,scientific_name">
	 </cfif>

<cfif not isdefined("order_order") or len(#order_order#) is 0>
	<cfset order_order = "asc">
</cfif>

<cfif isdefined("newSearch") and #newSearch# is 1>
	<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,0,0)#">
		select * from getData
	</cfquery>
</cfif>
<cfquery name="SpecRes#cfid##cftoken#" dbtype="query" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from getData
</cfquery>


<cfoutput>
<cfquery name="getBasic" dbtype="query">
	select * from SpecRes#cfid##cftoken# order by #order_by#
</cfquery>

<cfquery name="s" dbtype="query">
	select sum(COUNTOFCATALOGEDITEM) c from getBasic
</cfquery>
Returned #s.c# specimens in #getBasic.recordcount# rows.
</cfoutput>

<cfquery name="cnt" dbtype="query">
	select CountOfCatalogedItem from getBasic
</cfquery>

<table border="1">
<tr>
 
	
				
		
	<!---- always on --->

	<td nowrap><strong>Count</strong>	</td>

	<td nowrap><strong>Scientific Name</strong></td>
	<cfif #groupBy# contains "continent_ocean">
		<td nowrap><strong>Continent</strong></td>
	</cfif>
	<cfif #groupBy# contains "yr">
		<td nowrap><strong>Year</strong></td>
	</cfif>
	<cfif #groupBy# contains "country">
		<td nowrap><strong>Country</strong></td>
	</cfif>
	<cfif #groupBy# contains "state_prov">
		<td nowrap><strong>State</strong></td>
	</cfif>
	<cfif #groupBy# contains "county">
		<td nowrap><strong>County</strong></td>
	</cfif>
	<cfif #groupBy# contains "quad">
		<td nowrap><strong>Map Name</strong></td>
	</cfif>
	<cfif #groupBy# contains "feature">
		<td nowrap><strong>Feature</strong></td>
	</cfif>
	<cfif #groupBy# contains "isl_group">
		<td nowrap><strong>Island Group</strong></td>
	</cfif>
	<cfif #groupBy# contains "island">
		<td nowrap><strong>Island</strong></td>
	</cfif>
	<cfif #groupBy# contains "sea">
		<td nowrap><strong>Sea</strong></td>
	</cfif>
	<cfif #groupBy# contains "spec_locality">
		<td nowrap><strong>Specific Locality</strong></td>
	</cfif>
	<cfset i=1>
<cfoutput query="getBasic">
    <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
	 <form name="theseSpecs#i#" method="post" action="/SpecimenResults.cfm">
	 #searchparams#
	  	<input type="hidden" name="Scientific_Name" value="#Scientific_Name#">
		<input type="hidden" name="sciNameOper" value="=">
		
		<cfif #groupBy# contains "yr" and searchparams does not contain 'name="yr"'>
			<cfif len(#yr#) gt 0>
				<input type="hidden" name="yr" value="#yr#">
			<cfelse>
				<input type="hidden" name="yr" value="NULL">
			</cfif>			
		</cfif>
		<cfif #groupBy# contains "continent_ocean" and searchparams does not contain 'name="continent_ocean"'>
			<cfif len(#continent_ocean#) gt 0>
				<input type="hidden" name="continent_ocean" value="#continent_ocean#">
			<cfelse>
				<input type="hidden" name="continent_ocean" value="NULL">
			</cfif>			
		</cfif>
		<cfif #groupBy# contains "country" and searchparams does not contain 'name="country"'>
			<cfif len(#country#) gt 0>
				<input type="hidden" name="country" value="#country#">
			<cfelse>
				<input type="hidden" name="country" value="NULL">
			</cfif>		
		</cfif>
		<cfif #groupBy# contains "state_prov" and searchparams does not contain 'name="state_prov"'>
			<cfif len(#state_prov#) gt 0>
				<input type="hidden" name="state_prov" value="#state_prov#">
			<cfelse>
				<input type="hidden" name="state_prov" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "county" and searchparams does not contain 'name="county"'>
			<cfif len(#county#) gt 0>
				<input type="hidden" name="county" value="#county#">
			<cfelse>
				<input type="hidden" name="county" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "quad" and searchparams does not contain 'name="quad"'>
			<cfif len(#quad#) gt 0>
				<input type="hidden" name="quad" value="#quad#">
			<cfelse>
				<input type="hidden" name="quad" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "feature" and searchparams does not contain 'name="feature"'>
			<cfif len(#feature#) gt 0>
				<input type="hidden" name="feature" value="#feature#">
			<cfelse>
				<input type="hidden" name="feature" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "isl_group" and searchparams does not contain 'name="island_group"'>
			<cfif len(#island_group#) gt 0>
				<input type="hidden" name="island_group" value="#island_group#">
			<cfelse>
				<input type="hidden" name="island_group" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "island" and searchparams does not contain 'name="island"'>
			<cfif len(#island#) gt 0>
				<input type="hidden" name="island" value="#island#">
			<cfelse>
				<input type="hidden" name="island" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "sea" and searchparams does not contain 'name="sea"'>
			<cfif len(#sea#) gt 0>
				<input type="hidden" name="sea" value="#sea#">
			<cfelse>
				<input type="hidden" name="sea" value="NULL">
			</cfif>
		</cfif>
		<cfif #groupBy# contains "spec_locality" and searchparams does not contain 'name="spec_locality"'>
			<cfif len(#spec_locality#) gt 0>
				<input type="hidden" name="spec_locality" value="#spec_locality#">
			<cfelse>
				<input type="hidden" name="spec_locality" value="NULL">
			</cfif>
		</cfif>
	  </form>
      <td nowrap>
	   <a href="javascript:void(0);"
	   	onClick="theseSpecs#i#.submit();"
		onMouseOver="self.status='Go to SpecimenRecords'"
		onMouseOut="self.status=''">
	 <div class="linkButton"
			onmouseover="this.className='linkButton btnhov'" 
			onmouseout="this.className='linkButton'"
			>#countOfCatalogedItem#</div></a>	 </td>
	
	<td nowrap><i>#Scientific_Name#</i></td>
	<cfif #groupBy# contains "continent_ocean">
		<td nowrap>#continent_ocean#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "yr">
		<td nowrap>#yr#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "country">
		<td nowrap>#country#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "state_prov">
		<td nowrap>#state_prov#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "county">
		<td nowrap>#county#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "quad">
		<td nowrap>#quad#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "feature">
		<td nowrap>#feature#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "isl_group">
		<td nowrap>#island_group#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "island">
		<td nowrap>#island#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "sea">
		<td nowrap>#sea#&nbsp;</td>
	</cfif>
	<cfif #groupBy# contains "spec_locality">
		<td nowrap>#spec_locality#&nbsp;</td>
	</cfif>
  </tr>
  <cfset i=#I#+1>
  </cfoutput>
</table>

<!------------------------------- download --------------------------------->


<cfset dlPath = "#Application.DownloadPath#">
<cfset dlFile = "#session.DownloadFileName#">
 <cfset header ="Count#chr(9)#Scientific_Name">
	<cfif #groupBy# contains "continent_ocean">
		 <cfset header = "#header##chr(9)#continent_ocean">
	</cfif>
	<cfif #groupBy# contains "country">
		<cfset header = "#header##chr(9)#country">
	</cfif>
	<cfif #groupBy# contains "state_prov">
		<cfset header = "#header##chr(9)#state_prov">
	</cfif>
	<cfif #groupBy# contains "county">
		<cfset header = "#header##chr(9)#county">
	</cfif>
	<cfif #groupBy# contains "quad">
		<cfset header = "#header##chr(9)#quad">
	</cfif>
	<cfif #groupBy# contains "feature">
		<cfset header = "#header##chr(9)#feature">
	</cfif>
	<cfif #groupBy# contains "isl_group">
		<cfset header = "#header##chr(9)#island_group">
	</cfif>
	<cfif #groupBy# contains "island">
		<cfset header = "#header##chr(9)#island">
	</cfif>
	<cfif #groupBy# contains "sea">
		<cfset header = "#header##chr(9)#sea">
	</cfif>
	<cfif #groupBy# contains "spec_locality">
		<cfset header = "#header##chr(9)#spec_locality">
	</cfif>

<cfset header=#trim(header)#>
	<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">


<cfoutput query="getBasic">
 	 <cfset oneLine ="#countOfCatalogedItem##chr(9)##Scientific_Name#">
	<cfif #groupBy# contains "continent_ocean">
		 <cfset oneLine = "#oneLine##chr(9)##continent_ocean#">
	</cfif>
	<cfif #groupBy# contains "country">
		<cfset oneLine = "#oneLine##chr(9)##country#">
	</cfif>
	<cfif #groupBy# contains "state_prov">
		<cfset oneLine = "#oneLine##chr(9)##state_prov#">
	</cfif>
	<cfif #groupBy# contains "county">
		<cfset oneLine = "#oneLine##chr(9)##county#">
	</cfif>
	<cfif #groupBy# contains "quad">
		<cfset oneLine = "#oneLine##chr(9)##quad#">
	</cfif>
	<cfif #groupBy# contains "feature">
		<cfset oneLine = "#oneLine##chr(9)##feature#">
	</cfif>
	<cfif #groupBy# contains "isl_group">
		<cfset oneLine = "#oneLine##chr(9)##island_group#">
	</cfif>
	<cfif #groupBy# contains "island">
		<cfset oneLine = "#oneLine##chr(9)##island#">
	</cfif>
	<cfif #groupBy# contains "sea">
		<cfset oneLine = "#oneLine##chr(9)##sea#">
	</cfif>
	<cfif #groupBy# contains "spec_locality">
		<cfset oneLine = "#oneLine##chr(9)##spec_locality#">
	</cfif>






<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
</cfoutput>
	<cfoutput>
		<cfset downloadFile = "/download/#dlFile#">
		<form name="download" method="post" action="/download_agree.cfm">
			<input type="hidden" name="cnt" value="#cnt.recordcount#">
			<input type="hidden" name="downloadFile" value="#downloadFile#">
			<input type="submit" value="Download" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'">
		</form>
	</cfoutput>
<cfinclude template = "includes/_footer.cfm">