<cfif not isdefined("displayrows")>
	<cfset displayrows = client.displayrows>
</cfif>
<cfif not isdefined("maskedcolls")>
	<cfset maskedcolls = "">
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
<cfif not isdefined("basSelect")>
	<cfset basSelect = "">
</cfif>
<cfif not isdefined("basFrom")>
	<cfset basFrom = "">
</cfif>
<cfif not isdefined("basWhere")>
	<cfset basWhere = "">
</cfif>
<cfif not isdefined("basQual")>
	<cfset basQual = "">
</cfif>
<cfif not isdefined("mapurl")>
	<cfset mapurl="">
</cfif>
<cfif not isdefined("thisUserCols")>
	<cfset thisUserCols="">
</cfif>
<cfif not isdefined("inclDateSearch")>
	<cfset inclDateSearch="yes">
</cfif>

<!----
	CustomResults.cfm does NOT use this code and MUST be maintained independantly.
---->
<!--- start buildig SQL --->
		<cfif isdefined("catnum") AND isnumeric(#catnum#)><!--- will also fire if null ---->
			<cfset basQual = "#basQual#  AND cat_num = #catnum#" >
			<cfset mapurl = "#mapurl#&cat_num=#catnum#">
		</cfif>
		<cfif isdefined("entered_by") AND len(#entered_by#) gt 0><!--- will also fire if null ---->
			<cfif #basFrom# does not contain "CatItemCollObject">
				<cfset basFrom = " #basFrom#,coll_object CatItemCollObject">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = CatItemCollObject.collection_object_id">
				<cfquery name="enteredPersonID" datasource="#Application.web_user#">
					SELECT agent_id FROM agent_name WHERE upper(agent_name) LIKE '%#ucase(entered_by)#%'
				</cfquery>
				<cfif #enteredPersonID.recordcount# neq 1>
				 	<cfoutput>
						#enteredPersonID.recordcount# agents matched entered_by. Try narrowing or expanding to get one.
					</cfoutput>
					<cfabort>
				</cfif>
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.entered_person_id = #enteredPersonID.agent_id#" >
			<cfset mapurl = "#mapurl#&entered_by=#entered_by#">
		</cfif>
		<cfif isdefined("entered_by_id") AND len(#entered_by_id#) gt 0><!--- will also fire if null ---->
			<cfif #basFrom# does not contain "CatItemCollObject">
				<cfset basFrom = " #basFrom#,coll_object CatItemCollObject">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = CatItemCollObject.collection_object_id">
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.entered_person_id = #entered_by_id#" >
			<cfset mapurl = "#mapurl#&entered_by_id=#entered_by_id#">
		</cfif>
		<cfif isdefined("edited_by_id") AND len(#edited_by_id#) gt 0><!--- will also fire if null ---->
			<cfif #basFrom# does not contain "CatItemCollObject">
				<cfset basFrom = " #basFrom#,coll_object CatItemCollObject">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = CatItemCollObject.collection_object_id">
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.last_edited_person_id = #edited_by_id#" >
			<cfset mapurl = "#mapurl#&edited_by_id=#edited_by_id#">
		</cfif>
		<cfif isdefined("coll_obj_disposition") AND len(#coll_obj_disposition#) gt 0><!--- will also fire if null ---->
			<cfif #basFrom# does not contain "CatItemCollObject">
				<cfset basFrom = " #basFrom#,coll_object CatItemCollObject">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = CatItemCollObject.collection_object_id">
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.coll_obj_disposition = '#coll_obj_disposition#'" >
			<cfset mapurl = "#mapurl#&coll_obj_disposition=#coll_obj_disposition#">
		</cfif>
		<cfif isdefined("encumbrance_id") AND isnumeric(#encumbrance_id#)><!--- will also fire if null ---->
			<cfif #basFrom# does not contain "coll_object_encumbrance">
				<cfset basFrom = " #basFrom#,coll_object_encumbrance">
			</cfif>
			<cfif #basWhere# does not contain "encumbrance_id">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id">
			</cfif>
			<cfset basQual = "#basQual#  AND coll_object_encumbrance.encumbrance_id = #encumbrance_id#" >
			<cfset mapurl = "#mapurl#&encumbrance_id=#encumbrance_id#">
		</cfif>
		<cfif isdefined("encumbering_agent_id") AND isnumeric(#encumbering_agent_id#)><!--- will also fire if null ---->
			<cfif #basFrom# does not contain "coll_object_encumbrance">
				<cfset basFrom = " #basFrom#,coll_object_encumbrance,encumbrance">
			</cfif>
			<cfif #basWhere# does not contain "encumbrance_id">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id
									AND coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id">
			</cfif>
			<cfset basQual = "#basQual#  AND encumbering_agent_id = #encumbering_agent_id#" >
			<cfset mapurl = "#mapurl#&encumbering_agent_id=#encumbering_agent_id#">
		</cfif>
		<cfif isdefined("collection_id") AND isnumeric(#collection_id#)><!--- will also fire if null ---->
			<cfset basQual = "#basQual#  AND collection.collection_id = #collection_id#" >
			<cfset mapurl = "#mapurl#&collection_id=#collection_id#">
		</cfif>
		<cfif isdefined("listcatnum") and len(#listcatnum#) gt 0>
			<cfset mapurl = "#mapurl#&listcatnum=#listcatnum#">
		<!--- handle 'from-to' queries --->
		<cfif #listcatnum# contains "-">
			<cfset hyphenPosition=find("-",listcatnum)>
			<cfif #hyphenPosition# lt 2>
				<font color="#FF0000" size="+1">You've entered an invalid catalog number. Acceptable entries are:
				<ul>
					<li>An integer (9234)</li>
					<li>A comma-delimited list of integers (1,456,7689)</li>
					<li>A hyphen-separated range of integers (1-6)</li>
				</ul>
				</font>		
				<cfabort>
			</cfif>
			<cfset minCatNum=left(listcatnum,#hyphenPosition#-1)>
			<cfset maxCatNum=right(listcatnum,len(listcatnum)-#hyphenPosition#)>
			<cfif not isnumeric(#minCatNum#) OR not isnumeric(#maxCatNum#)>
				<font color="#FF0000" size="+1">You've entered an invalid catalog number. Acceptable entries are:
				<ul>
					<li>An integer (9234)</li>
					<li>A comma-delimited list of integers (1,456,7689)</li>
					<li>A hyphen-separated range of integers (1-6)</li>
				</ul>
				</font>		
				<cfabort>
			</cfif>
			<cfset basQual = " #basQual# AND cat_num >= #minCatNum# AND cat_num <= #maxCatNum#  " >
		<cfelse>
			<cfloop list="#listcatnum#" index="i">
				<cfif not isnumeric(#i#)>
					<font color="#FF0000" size="+1">Catalog Numbers must be numeric!</font>				  
					<cfabort>
				</cfif>
			</cfloop>
			<cfset basQual = " #basQual# AND cat_num IN ( #listcatnum# ) " >
		</cfif>
		</cfif>
		<cfif isdefined("Client.collection") and len(#Client.collection#) gt 0>
			<cfset collection_cde=#client.collection#>		
		</cfif>
		<cfif isdefined("collection_cde") and len(#collection_cde#) gt 0>
			<cfset collcde = "">
			<cfloop list="#collection_cde#" index="i">
				<cfif len(#collcde#) is 0>
					<cfset collcde = "'#i#'">
				<cfelse>
					<cfset collcde = "#collcde#,'#i#'">
				</cfif>
			</cfloop>
			
			<cfset basQual = "#basQual#  AND cataloged_item.collection_cde IN (#collcde#)" >
			<cfset mapurl = "#mapurl#&collection_cde=#collection_cde#">
		<!----
		<cfelseif isdefined("Client.collection") and len(#Client.collection#) gt 0>
			<cfset basQual = "#basQual#  AND cataloged_item.collection_cde IN (#client.collection#)" >
			<cfset mapurl = "#mapurl#&collection_cde=#client.collection#">
			---->
		</cfif>	
		<cfif isdefined("listafnum") and len(#listafnum#) gt 0>
			<cfset mapurl = "#mapurl#&listafnum=#listafnum#">
			<cfset aflist = "">
			<cfloop list="#listafnum#" index="i">
				<cfif len(#aflist#) is 0>
					<cfset aflist = "'#i#'">
				<cfelse>
					<cfset aflist = "#aflist#,'#i#'">
				</cfif>
			</cfloop>
			<cfif #basFrom# does not contain "af_num">
				<cfset basFrom = " #basFrom#,af_num">
			</cfif>
			<cfif #basSelect# does not contain "af_num">
				<cfset basSelect = "#basSelect#,to_number(af_num) as af_num">
			</cfif>
			<cfif #basSelect# does not contain "af_num">
				<cfset basSelect = "#basSelect#,to_number(af_num) as af_num">
			</cfif>
			<cfif #basWhere# does not contain "af_num">
				<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = af_num.collection_object_id">
			</cfif>
			<cfset basQual = " #basQual# AND af_num in (#aflist#) " >
		</cfif>
		
		<cfif isdefined("coll") AND #coll# IS NOT "">
			<cfif not isdefined("coll_role") or len(#coll_role#) is 0>
				<cfset coll_role="c">
			</cfif>
			<cfset mapurl = "#mapurl#&coll=#coll#">  
			<cfset basFrom = " #basFrom#, collector, agent, agent_name srchColl">
			<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = collector.collection_object_id
								AND collector.agent_id = agent.agent_id
								AND agent.agent_id = srchColl.agent_id AND collector.collector_role='#coll_role#'">
			<cfset basQual = " #basQual# AND UPPER(srchColl.Agent_Name) LIKE '%#UCASE(coll)#%'">
			<cfset mapurl = "#mapurl#&coll_role=#coll_role#">
		</cfif>
		<cfif isdefined("collector_agent_id") AND len(#collector_agent_id#) gt 0>
			<cfset mapurl = "#mapurl#&collector_agent_id=#collector_agent_id#"> 
			<cfset basFrom = " #basFrom#, collector, agent, agent_name srchColl">
			<cfSet basWhere = " #basWhere# AND cataloged_item.collection_object_id = collector.collection_object_id
								AND collector.agent_id = agent.agent_id
								AND agent.agent_id = srchColl.agent_id ">
			<cfset basQual = " #basQual# AND collector.agent_id = #collector_agent_id#">
			
		</cfif>
		<!---- old taxonomy.scientific_name --->
		<!----
		<cfif isdefined("scientific_name") AND #scientific_name# IS NOT "">
			<cfset mapurl = "#mapurl#&scientific_name=#scientific_name#">
			<cfif #basFrom# does not contain "taxonomy">
				<cfset basFrom = "#basFrom# ,identification, taxonomy">
			</cfif>
			<cfif #basWhere# does not contain "taxonomy">
				<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
				AND identification.accepted_id_fg=1
				AND identification.taxon_name_id = taxonomy.taxon_name_id">
			</cfif>
			<cfif #sciNameOper# is "LIKE" OR #sciNameOper# is "=">
				<cfif #sciNameOper# is "LIKE">
					<cfquery name="getTaxonId" datasource="#Application.web_user#">
						select taxon_name_id from taxonomy where 
						upper(scientific_name) #sciNameOper# '%#ucase(scientific_name)#%'
					</cfquery>
				<cfelseif #sciNameOper# is "=">
					<cfquery name="getTaxonId" datasource="#Application.web_user#">
						select taxon_name_id from taxonomy where 
						scientific_name #sciNameOper# '#scientific_name#'
					</cfquery>
				</cfif>
					<cfif #getTaxonId.recordcount# is 0>
						<cfoutput>
							<CFSETTING ENABLECFOUTPUTONLY=0>
						<SCRIPT>document.getElementById('progMeter').style.visibility = 'hidden';</SCRIPT>
						<font color="##FF0000" size="+2">Nothing matched scientific name "<i>#scientific_name#</i>"! 
							<br>Please check your spelling and try again or check
							<a href="/TaxonomySearch.cfm">Arctos Taxonomy</a> for synonyms, common names, and spelling.
							</font>	  
						<cfabort>
						</cfoutput>
					</cfif>
					<cfset taxonNameId = valuelist(getTaxonId.taxon_name_id)>
					<cfif #basFrom# does not contain "taxonomy">
						<cfset basFrom = "#basFrom# ,identification, taxonomy">
					</cfif>
					<cfif #basWhere# does not contain "taxonomy">
						<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
						AND identification.accepted_id_fg=1
						AND identification.taxon_name_id = taxonomy.taxon_name_id">
					</cfif>
					<cfset basQual = " #basQual# AND taxonomy.taxon_name_id IN (#taxonNameId#)">
			<cfelse><!--- slower, DOES NOT CONTAIN query --->
				<cfset mapurl = "#mapurl#&sciNameOper=#sciNameOper#">
				<cfset basQual = " #basQual# AND upper(scientific_name) NOT LIKE '%#ucase(scientific_name)#%'">
			</cfif>
		</cfif>
		---->
		<!---- end old taxonomy.scientific_name --->
		
		
		<!---- new identification.scientific_name --->
		
		<cfif #sciNameOper# is "was"><!--- duck out to any name --->
			<cfset AnySciName=#scientific_name#>
			<cfset scientific_name="">
		</cfif>
		<cfif isdefined("scientific_name") AND len(#scientific_name#) gt 0>
			<cfset mapurl = "#mapurl#&scientific_name=#scientific_name#">
			<cfif #basFrom# does not contain "identification">
				<cfset basFrom = "#basFrom# ,identification">
			</cfif>
			<cfif #basWhere# does not contain "identification">
				<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
						AND identification.accepted_id_fg=1">
			</cfif>
			<cfif #sciNameOper# is "LIKE">
				<cfset basQual = " #basQual# AND upper(identification.scientific_name) LIKE '%#ucase(scientific_name)#%'">					
			<cfelseif #sciNameOper# is "=">
				<cfset basQual = " #basQual# AND identification.scientific_name = '#scientific_name#'">
			<cfelseif #sciNameOper# is "NOT LIKE">
				<cfset basQual = " #basQual# AND upper(identification.scientific_name) NOT LIKE '%#ucase(scientific_name)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("identified_agent_id") AND len(#identified_agent_id#) gt 0>
			<cfset mapurl = "#mapurl#&identified_agent_id=#identified_agent_id#">
			<cfset basFrom = "#basFrom# ,identification all_identification">
			<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = all_identification.collection_object_id">
			<cfset basQual = " #basQual# AND all_identification.id_made_by_agent_id = #identified_agent_id#">			
		</cfif>
		<cfif isdefined("identified_agent") AND len(#identified_agent#) gt 0>
			<cfset mapurl = "#mapurl#&identified_agent=#identified_agent#">
			<cfset basFrom = "#basFrom# ,identification all_identification, agent_name identifier_name">
			<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = all_identification.collection_object_id
							AND all_identification.id_made_by_agent_id=identifier_name.agent_id">
			<cfset basQual = " #basQual# AND upper(identifier_name.agent_name) LIKE '%#ucase(identified_agent)#%'">			
		</cfif>
		<!---- end new identification.scientific_name --->
		
		
		<cfif isdefined("HighTaxa") AND #HighTaxa# IS NOT "">
			<cfset mapurl = "#mapurl#&HighTaxa=#HighTaxa#">
			<cfif #replace(basFrom,"identification_taxonomy","","all")# does not contain "identification">
				<cfset basFrom = "#basFrom# ,identification">
			</cfif>
			<cfif #replace(basFrom,"identification_taxonomy","","all")# does not contain "taxonomy">
				<cfset basFrom = "#basFrom# ,taxonomy">
			</cfif>
			<cfif #basFrom# does not contain "identification_taxonomy">
				<cfset basFrom = "#basFrom# ,identification_taxonomy">
			</cfif>
			
			<cfif #replace(basWhere,"identification_taxonomy","","all")# does not contain "identification">
				<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
				AND identification.accepted_id_fg=1">
			</cfif>
			<cfif #basWhere# does not contain "identification_taxonomy">
				<cfset basWhere = "#basWhere# AND identification.identification_id = identification_taxonomy.identification_id">
			</cfif>
			<cfif #replace(basWhere,"identification_taxonomy","","all")# does not contain "taxonomy">
				<cfset basWhere = "#basWhere# AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id">
			</cfif>
			
			<cfset basQual = " #basQual# AND UPPER(Full_Taxon_Name) LIKE '%#ucase(HighTaxa)#%'">
		</cfif>
		
		
		<cfif isdefined("AnySciName") AND #AnySciName# IS NOT "">
			<cfset mapurl = "#mapurl#&AnySciName=#AnySciName#">
				<cfset basQual = " #basQual# AND ( cataloged_item.collection_object_id IN
					(select collection_object_id FROM identification where 
						UPPER(scientific_name) LIKE '%#ucase(AnySciName)#%')
					OR cataloged_item.collection_object_id IN
						(select collection_object_id FROM
							citation,
							taxonomy
						WHERE
							citation.cited_taxon_name_id = taxonomy.taxon_name_id AND
							UPPER(scientific_name) LIKE '%#ucase(AnySciName)#%')
							)">
		</cfif>
		
		<cfif isdefined("Phylclass") AND len(#Phylclass#) gt 0>
			<cfset mapurl = "#mapurl#&Phylclass=#Phylclass#">
			<cfif #basFrom# does not contain "identification, identification_taxonomy, taxonomy">
				<cfset basFrom = "#basFrom# ,identification, identification_taxonomy, taxonomy">
			</cfif>
			<cfif #basWhere# does not contain "identification, identification_taxonomy, taxonomy">
				<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
				AND identification.accepted_id_fg=1
				AND identification.identification_id = identification_taxonomy.identification_id
				AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id">
			</cfif>
			<cfset basQual = " #basQual# AND Phylclass = '#Phylclass#'">
		</cfif>
		
		<cfif isdefined("begYear") AND len(#begYear#) gt 0>
			<cfif not isnumeric(#begYear#) OR len(#begYear#) neq 4>
				<b><font color="#FF0000" size="+1">Year must be entered as a 4-digit integer.</font></b>			  
				<cfabort>
			</cfif>
			<cfif not isdefined("endYear") OR len (#endYear#) is 0>
				<cfset endYear = #begYear#>
			</cfif>
			<cfif not isnumeric(#endYear#) OR len(#endYear#) neq 4>
				<b><font color="#FF0000" size="+1">Year must be entered as a 4-digit integer.</font></b>			  
				<cfabort>
			</cfif>
			<cfif #inclDateSearch# is "yes">
				<cfset basQual = " #basQual#
						AND ( 
					TO_NUMBER(TO_CHAR(began_date, 'yyyy')) >= #begYear#
					AND TO_NUMBER(TO_CHAR(ended_date, 'yyyy')) <= #endYear#
					)
					">			
			<cfelse>
				<cfset basQual = " #basQual#
						AND ( 
					TO_CHAR(began_date, 'yyyy') BETWEEN '#begYear#' AND '#endYear#'
					OR TO_CHAR(ended_date, 'yyyy') BETWEEN   '#begYear#' AND '#endYear#'
					OR ( '#begYear#' BETWEEN TO_CHAR(began_date, 'yyyy') AND TO_CHAR(ended_date, 'yyyy')
					AND '#endYear#' BETWEEN TO_CHAR(began_date, 'yyyy') AND TO_CHAR(ended_date, 'yyyy')
					))
					">			
			</cfif>
			
		</cfif>
		<cfif isdefined("begMon") AND len(#begMon#) gt 0>
			<cfif not isdefined("endMon") OR len (#endMon#) is 0>
				<cfset endMon = #begMon#>
			</cfif>
			<cfif #inclDateSearch# is "yes">
				<cfset basQual = " #basQual#
						AND ( 
					TO_NUMBER(TO_CHAR(began_date, 'mm')) >= #begMon#
					AND TO_NUMBER(TO_CHAR(ended_date, 'mm')) <= #endMon#
					)
					">			
			<cfelse>
				<cfset basQual = " #basQual# 
					AND ( 
					TO_CHAR(began_date, 'mm') BETWEEN '#begMon#' AND '#endMon#'
					OR TO_CHAR(ended_date, 'mm') BETWEEN   '#begMon#' AND '#endMon#'
					OR ( '#begMon#' BETWEEN TO_CHAR(began_date, 'mm') AND TO_CHAR(ended_date, 'mm')
					AND '#endMon#' BETWEEN TO_CHAR(began_date, 'mm') AND TO_CHAR(ended_date, 'mm')
					))">
				</cfif>
		</cfif>
		<cfif isdefined("begDay") AND len(#begDay#) gt 0>
			<cfif not isdefined("endDay") OR len (#endDay#) is 0>
				<cfset endDay = #begDay#>
			</cfif>
				<cfif #inclDateSearch# is "yes">
				<cfset basQual = " #basQual#
						AND ( 
					TO_NUMBER(TO_CHAR(began_date, 'dd')) >= #begDay#
					AND TO_NUMBER(TO_CHAR(ended_date, 'dd')) <= #endDay#
					)
					">			
			<cfelse>
				<cfset basQual = " #basQual# 
				AND ( 
					TO_CHAR(began_date, 'dd') BETWEEN '#begDay#' AND '#endDay#'
					OR TO_CHAR(ended_date, 'dd') BETWEEN   '#begDay#' AND '#endDay#'
					OR ( '#begDay#' BETWEEN TO_CHAR(began_date, 'dd') AND TO_CHAR(ended_date, 'dd')
					AND '#endDay#' BETWEEN TO_CHAR(began_date, 'dd') AND TO_CHAR(ended_date, 'dd')
					))">
				</cfif>
		</cfif>
<cfif isdefined("begDate") AND len(#begDate#) gt 0>
	<cfif not isdefined("endDate") OR len (#endDate#) is 0>
		<cfset endDate = #begDate#>
	</cfif>
	<cfif not isdate(begDate) OR not isdate(endDate)>
		<b><font color="#FF0000" size="+1">The date format you entered was not recognized as a valid date format.
		<br>
		<i>dd mm yyyy</i> is the preferred data format.</font></b>	  
		<cfabort>
	</cfif>
<cfscript>
/**
 * Calculates the Julian Day for any date in the Gregorian calendar.
 * 
 * @param TheDate 	 Date you want to return the Julian day for. 
 * @return Returns a numeric value. 
 * @author Beau A.C. Harbin (bharbin@figleaf.com) 
 * @version 1, September 4, 2001 
 */
 function GetJulianDay(){
        var date = Now();	
	var year = 0;
	var month = 0;
	var day = 0;
	var hour = 0;
	var minute = 0;
	var second = 0;
	var a = 0;
	var y = 0;
	var m = 0;
	var JulianDay =0;
        if(ArrayLen(Arguments)) 
          date = Arguments[1];	
	// The Julian Day begins at noon so in order to calculate the date properly, one must subtract 12 hours
	date = DateAdd("h", -12, date);
	year = DatePart("yyyy", date);
	month = DatePart("m", date);
	day = DatePart("d", date);
	hour = DatePart("h", date);
	minute = DatePart("n", date);
	second = DatePart("s", date);
	
	a = (14-month) \ 12;
	y = (year+4800) - a;
	m = (month + (12*a)) - 3;
	
	JD = (day + ((153*m+2) \ 5) + (y*365) + (y \ 4) - (y \ 100) + (y \ 400)) - 32045;
	JDTime = NumberFormat(CreateTime(hour, minute, second), ".99999999");
	
	JulianDay = JD + JDTime;
	
	return JulianDay;
}
</cfscript>
		
		
			<cfif #inclDateSearch# is "yes">
				<cfset basQual = " #basQual#
						AND ( 
					TO_NUMBER(TO_CHAR(began_date, 'j')) >= #round(GetJulianDay(begDate))#
					AND TO_NUMBER(TO_CHAR(ended_date, 'j')) <= #round(GetJulianDay(endDate))#
					)
					">			
			<cfelse>
			<cfset basQual = " #basQual# 
				AND ( 
					began_date BETWEEN '#dateformat(begDate,"dd-mmm-yyyy")#' AND '#dateformat(endDate,"dd-mmm-yyyy")#'
					OR ended_date BETWEEN  '#dateformat(begDate,"dd-mmm-yyyy")#' AND '#dateformat(endDate,"dd-mmm-yyyy")#'
					OR ( '#dateformat(begDate,"dd-mmm-yyyy")#' BETWEEN began_date AND ended_date
					AND '#dateformat(endDate,"dd-mmm-yyyy")#' BETWEEN began_date AND ended_date)
					)">
  </cfif>
		</cfif>
		
		<cfif isdefined("inMon") AND len(#inMon#) gt 0>
			<cfset basQual = " #basQual# AND TO_CHAR(began_date, 'mm') IN (#inMon#)">
		</cfif>
		
		<cfif isdefined("verbatim_date") AND len(#verbatim_date#) gt 0>
			<cfset basQual = " #basQual# AND upper(verbatim_date) LIKE '%#ucase(verbatim_date)#%'">
		</cfif>
		
			
		<cfif isdefined("Accn") AND #Accn# IS NOT "">
		<cfset mapurl = "#mapurl#&Accn=#accn#">
			<cfset basFrom = " #basFrom#, accn">
			<cfset basWhere = " #basWhere# AND accn.transaction_id = cataloged_item.accn_id">
			<cfset basQual = " #basQual# AND accn_num_prefix||'.'||LPAD(accn_num,3,'0') LIKE '#Accn#'">
		</cfif>
		
		<cfif isdefined("OIDType") AND #OIDType# IS NOT "">
			<cfset mapurl = "#mapurl#&OIDType=#OIDType#">	
			<cfset basSelect = "#basSelect#,other_id_num, other_id_type">
			<cfset basFrom = "#basFrom#, coll_obj_other_id_num">
			<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id">
			<cfset basQual = " #basQual# AND other_id_type = '#OIDType#'">
		</cfif>
		<cfif isdefined("OIDNum") AND #OIDNum# IS NOT "">
			<cfif not isdefined("OIDType") OR len(#OIDType#) is 0>
			<!--- only searching for the number, don't care what type 
				and can't have defined type above
			--->
					<cfset basSelect = "#basSelect#,other_id_num, other_id_type">
					<cfset basFrom = "#basFrom#, coll_obj_other_id_num">
					<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id =
						 coll_obj_other_id_num.collection_object_id">
					<cfif #oidOper# is "LIKE">
							<cfset basQual = " #basQual# AND UPPER(other_id_num) LIKE '%#UCASE(OIDNum)#%'">
						<cfelse>
							<cfset basQual = " #basQual# AND other_id_num = '#OIDNum#'">
			  </cfif>
					<cfset mapurl = "#mapurl#&OIDNum=#OIDNum#">
		  </cfif>
		   	  <cfif  isdefined ("OIDType") AND len(#OIDType#) gt 0>
			  <cfset mapurl = "#mapurl#&OIDType=#OIDType#">
				<!---- don't add to where and select if its already been done --->
					<cfif #oidOper# is "LIKE">
						<cfset basQual = " #basQual# AND UPPER(other_id_num) LIKE '%#UCASE(OIDNum)#%'">
					<cfelse>
						<cfset basQual = " #basQual# AND other_id_num = '#OIDNum#'">
					</cfif>
			  </cfif>
		</cfif>
		
		<cfif isdefined("continent_ocean") AND #continent_ocean# IS NOT "">
			<cfif #compare(continent_ocean,"NULL")# is 0>
				<cfset basQual = " #basQual# AND continent_ocean is null">
			<cfelse>
				<cfset basQual = " #basQual# AND continent_ocean LIKE '#continent_ocean#'">
			</cfif>					
			<cfset mapurl = "#mapurl#&continent_ocean=#continent_ocean#">			
		</cfif>
		<cfif isdefined("sea") AND #sea# IS NOT "">
			<cfif #compare(sea,"NULL")# is 0>
				<cfset basQual = " #basQual# AND sea is null">
			<cfelse>
				<cfset basQual = " #basQual# AND sea LIKE '#sea#'">
			</cfif>					
			<cfset mapurl = "#mapurl#&sea=#sea#">			
		</cfif>
		<cfif isdefined("Country") AND #Country# IS NOT "">
			<cfif #compare(country,"NULL")# is 0>
				<cfset basQual = " #basQual# AND country is null">
			<cfelse>
				<cfset basQual = " #basQual# AND country LIKE '#Country#'">
			</cfif>					
			<cfset mapurl = "#mapurl#&Country=#Country#">
		</cfif>
		<cfif isdefined("state_prov") AND #state_prov# IS NOT "">
			<cfif #compare(state_prov,"NULL")# is 0>
				<cfset basQual = " #basQual# AND state_prov is null">
			<cfelse>
				<cfset basQual = " #basQual# AND UPPER(state_prov) LIKE '%#UCASE(state_prov)#%'">
			</cfif>				
			<cfset mapurl = "#mapurl#&state_prov=#state_prov#">
		</cfif>
		<cfif isdefined("island_group") AND #island_group# IS NOT "">
			<cfif #compare(island_group,"NULL")# is 0>
				<cfset basQual = " #basQual# AND island_group is null">
			<cfelse>
				<cfset basQual = " #basQual# AND Island_Group LIKE '#island_group#'">
			</cfif>		
			
			<cfset mapurl = "#mapurl#&island_group=#island_group#">
		</cfif>
		<cfif isdefined("Island") AND #Island# IS NOT "">
			<cfif #compare(Island,"NULL")# is 0>
				<cfset basQual = " #basQual# AND Island is null">
			<cfelse>
				<cfset basQual = " #basQual# AND UPPER(Island) LIKE '%#UCASE(Island)#%'">
			</cfif>			
			<cfset mapurl = "#mapurl#&island=#island#">
		</cfif>
		<cfif isdefined("spec_locality") and len(#spec_locality#) gt 0>
			<cfif #compare(spec_locality,"NULL")# is 0>
				<cfset basQual = " #basQual# AND spec_locality is null">
			<cfelse>
				<cfset basQual = " #basQual# AND upper(spec_locality) like '%#ucase(spec_locality)#%' " >
			</cfif>			
			<cfset mapurl = "#mapurl#&spec_locality=#spec_locality#">
		</cfif>
		<cfif isdefined("Feature") AND #Feature# IS NOT "">
			<cfif #compare(Feature,"NULL")# is 0>
				<cfset basQual = " #basQual# AND Feature is null">
			<cfelse>
				<cfset basQual = " #basQual# AND Feature LIKE '#Feature#'">
			</cfif>		
			<cfset mapurl = "#mapurl#&feature=#feature#">
		</cfif>
		<cfif isdefined("higher_geog") AND #higher_geog# IS NOT "">
			<cfset basQual = " #basQual# AND upper(higher_geog) LIKE '%#ucase(higher_geog)#%'">
			<cfset mapurl = "#mapurl#&higher_geog=#higher_geog#">
		</cfif>
		<cfif isdefined("County") AND #County# IS NOT "">
			<cfif #compare(County,"NULL")# is 0>
				<cfset basQual = " #basQual# AND County is null">
			<cfelse>
				<cfset basQual = " #basQual# AND upper(County) LIKE '%#UCASE(County)#%'">
			</cfif>				
			<cfset mapurl = "#mapurl#&county=#county#">
		</cfif>
		<cfif isdefined("Quad") AND #Quad# IS NOT "">
			<cfif #compare(Quad,"NULL")# is 0>
				<cfset basQual = " #basQual# AND Quad is null">
			<cfelse>
				<cfset basQual = " #basQual# AND UPPER(Quad) LIKE '%#UCASE(Quad)#%'">
			</cfif>
			
		  <cfset mapurl = "#mapurl#&quad=#quad#">
		</cfif>
		<cfif #Action# is "dispCollObj">
			<cfif isdefined("part_name") AND len(#part_name#) gt 0>
				<cfset basFrom = " #basFrom#, specimen_part">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item">
				<cfset basQual = " #basQual# AND Part_Name LIKE '#part_name#'">
				<cfset mapurl = "#mapurl#&part_name=#part_name#">
				<cfif isdefined("preserv_method") AND len(#preserv_method#) gt 0>
					<cfset preserv_method=#replace(preserv_method,"'","''","all")#>
					<cfset basQual = " #basQual# AND preserve_method LIKE '#preserv_method#'">
					<cfset mapurl = "#mapurl#&preserv_method=#preserv_method#">
				</cfif>
			<cfelse>
			  	<cfif isdefined("preserv_method") AND len(#preserv_method#) gt 0>
					<cfset preserv_method=#replace(preserv_method,"'","''","all")#>
			  		<cfset basFrom = " #basFrom#, specimen_part">
					<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item">
					<cfset basQual = " #basQual# AND preserve_method LIKE '#preserv_method#'">
					<cfset mapurl = "#mapurl#&preserv_method=#preserv_method#">
				</cfif>
			</cfif>
		<cfelse>
			<cfif isdefined("part_name") AND len(#part_name#) gt 0>
				<cfset basSelect = "#basSelect#,part_name,part_modifier,preserve_method">
				<cfset basQual = " #basQual# AND Part_Name LIKE '#part_name#'">
				<cfset basFrom = " #basFrom#, specimen_part">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item">
				<cfset mapurl = "#mapurl#&part_name=#part_name#">
				<cfif isdefined("preserv_method") AND len(#preserv_method#) gt 0>
					<cfset basQual = " #basQual# AND preserve_method LIKE '#preserv_method#'">
					<cfset mapurl = "#mapurl#&preserv_method=#preserv_method#">
				</cfif>
  			  <cfelse>
			  	<cfif isdefined("preserv_method") AND len(#preserv_method#) gt 0>
				<cfset preserv_method=#replace(preserv_method,"'","''","all")#>
			  		<cfset basSelect = "#basSelect#,part_name, part_modifier, preserve_method">
					<cfset basFrom = " #basFrom#, specimen_part">
					<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item">
					<cfset basQual = " #basQual# AND preserve_method LIKE '#preserv_method#'">
					<cfset mapurl = "#mapurl#&preserv_method=#preserv_method#">
				</cfif>
			</cfif>
			<cfif isdefined("part_modifier") AND len(#part_modifier#) gt 0>
				<cfif #basSelect# does not contain "part_name">
					<cfset basSelect = "#basSelect#,part_name, part_modifier, preserve_method">
				</cfif>
				<cfif #basFrom# does not contain "specimen_part">
					<cfset basFrom = " #basFrom#, specimen_part">
				</cfif>
				<cfif #basWhere# does not contain "specimen_part.derived_from_cat_item">
					<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item">
				</cfif>
				<cfset basQual = " #basQual# AND part_modifier LIKE '#part_modifier#'">
				<cfset mapurl = "#mapurl#&part_modifier=#part_modifier#">
			</cfif>
		</cfif>
		<cfif isdefined("thisUserCols") AND #thisUserCols# contains "specimen_part">
			<cfif #basSelect# does not contain "part_name,part_modifier,preserve_method">
					<cfset basSelect = "#basSelect#,part_name,part_modifier,preserve_method">
		  </cfif>
				<cfif #basFrom# does not contain "specimen_part">
					<cfset basFrom = " #basFrom#, specimen_part">
				</cfif>
				<cfif #basWhere# does not contain "derived_from_cat_item">
					<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item (+)">
				</cfif>
		</cfif>
		<cfif isdefined("Common_Name") AND len(#Common_Name#) gt 0>
			<cfif #basFrom# does not contain "identification">
				<cfset basFrom = "#basFrom# ,identification">
			</cfif>
			<cfif #basFrom# does not contain "identification_taxonomy">
				<cfset basFrom = "#basFrom# ,identification_taxonomy">
			</cfif>
			<cfif #basFrom# does not contain "taxonomy">
				<cfset basFrom = "#basFrom# ,taxonomy">
			</cfif>
			<cfif #basWhere# does not contain "identification">
				<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
				AND identification.accepted_id_fg=1">
			</cfif>
			<cfif #basWhere# does not contain "identification_taxonomy">
				<cfset basWhere = "#basWhere# AND identification.identification_id = identification_taxonomy.identification_id ">
			</cfif>
			<cfif #basWhere# does not contain "taxonomy">
				<cfset basWhere = "#basWhere# AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id">
			</cfif>
			
			<cfset basFrom = " #basFrom#,common_name">
			<cfset basWhere = " #basWhere# AND taxonomy.taxon_name_id = common_name.taxon_name_id">
			<cfset basQual = " #basQual# AND UPPER(Common_Name) LIKE '%#ucase(Common_Name)#%'">
			<cfset mapurl = "#mapurl#&Common_Name=#Common_Name#">
		</cfif>
		<cfif isdefined("publication_id") AND #publication_id# is not "">
			<cfset basQual = " #basQual# AND publication_id LIKE '#publication_id#'">
			<cfset basFrom = " #basFrom#, citation">
			<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = citation.collection_object_id">
			<cfset mapurl = "#mapurl#&publication_id=#publication_id#">
		</cfif>
		<cfif isdefined("onlyCitation")>
			<cfif #basFrom# does not contain "citation">
				<cfset basFrom = " #basFrom#, citation">
			</cfif>
			<cfif #basWhere# does not contain "citation">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = citation.collection_object_id">
			</cfif>			
			<cfset mapurl = "#mapurl#&onlyCitation=t">
		</cfif>
		<cfif isdefined("type_status") and len(#type_status#) gt 0>
			<cfif #basFrom# does not contain "citation">
				<cfset basFrom = " #basFrom#, citation">
			</cfif>
			<cfif #basWhere# does not contain "citation">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = citation.collection_object_id">
			</cfif>
			<cfset basQual = " #basQual# AND type_status = '#type_status#'">			
			<cfset mapurl = "#mapurl#&onlyCitation=t">
		</cfif>
		<cfif isdefined("collection_object_id") AND len(#collection_object_id#) gt 0>
			<cfset basQual = " #basQual# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
			<cfset mapurl = "#mapurl#&collection_object_id=#collection_object_id#">
		</cfif>
		<cfif isdefined("taxon_name_id") AND len(#taxon_name_id#) gt 0>
			<cfif #basFrom# does not contain "identification">
				<cfset basFrom = "#basFrom# ,identification">
			</cfif>
			<cfif #basFrom# does not contain "identification_taxonomy">
				<cfset basFrom = "#basFrom# ,identification_taxonomy">
			</cfif>
			
			<cfif #basWhere# does not contain "identification">
				<cfset basWhere = "#basWhere# AND cataloged_item.collection_object_id = identification.collection_object_id
				AND identification.accepted_id_fg=1">
			</cfif>
			<cfif #basWhere# does not contain "identification_taxonomy">
				<cfset basWhere = "#basWhere# AND identification.identification_id = identification_taxonomy.identification_id ">
			</cfif>
			
			
			<cfset basQual = " #basQual# AND identification_taxonomy.taxon_name_id = #taxon_name_id#">
			<cfset mapurl = "#mapurl#&taxon_name_id=#taxon_name_id#">
		</cfif>
		<cfif isdefined("project_id") AND len(#project_id#) gt 0>
			<cfset basFrom = " #basFrom#, project,project_trans,accn projAccn">
			<cfset basWhere = " #basWhere# AND cataloged_item.accn_id = projAccn.transaction_id AND 
								projAccn.transaction_id = project_trans.transaction_id AND 
								project_trans.project_id = project.project_id">
			<cfset basQual = " #basQual# AND project.project_id = #project_id#">
			<cfset mapurl = "#mapurl#&project_id=#project_id#">
		</cfif>
		<cfif isdefined("project_name") AND len(#project_name#) gt 0>
			<cfset basFrom = " #basFrom#, project,project_trans,accn projAccn">
			<cfset basWhere = " #basWhere# AND cataloged_item.accn_id = projAccn.transaction_id AND 
								projAccn.transaction_id = project_trans.transaction_id AND 
								project_trans.project_id = project.project_id">
			<cfset basQual = " #basQual# AND upper(project_name) like '%#ucase(project_name)#%'">
			<cfset mapurl = "#mapurl#&project_name=#project_name#">
		</cfif>
		<cfif isdefined("collecting_event_id") AND len(#collecting_event_id#) gt 0>
			<cfset basQual = " #basQual# AND collecting_event.collecting_event_id = #collecting_event_id#">
			<cfset mapurl = "#mapurl#&collecting_event_id=#collecting_event_id#">
		</cfif>
		<cfif isdefined("locality_id") AND len(#locality_id#) gt 0>
			<cfset basQual = " #basQual# AND locality.locality_id = #locality_id#">
			<cfset mapurl = "#mapurl#&locality_id=#locality_id#">
		</cfif>
		<cfif isdefined("subject") AND len(#subject#) gt 0>
			<cfset basFrom = " #basFrom#, binary_object">
			<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = binary_object.derived_from_cat_item">
			<cfset basQual = " #basQual# AND binary_object.subject = '#subject#'">
			<cfset mapurl = "#mapurl#&subject=#subject#">
		</cfif>
		<cfif isdefined("imgDescription") AND len(#imgDescription#) gt 0>
			<cfif #basFrom# contains "binary_object">
				<cfset basQual = " #basQual# AND upper(binary_object.description) LIKE '%#ucase(description)#%'">
				<cfset mapurl = "#mapurl#&imgDescription=#imgDescription#">
			  <cfelse>
			  	<cfset basFrom = " #basFrom#, binary_object">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = binary_object.derived_from_cat_item">
				<cfset basQual = " #basQual# AND upper(binary_object.description) LIKE '%#ucase(imgDescription)#%'">
				<cfset mapurl = "#mapurl#&imgDescription=#imgDescription#">
			</cfif>
		</cfif>
		<cfif isdefined("binary_object_made_by_id") AND len(#binary_object_made_by_id#) gt 0>
			<cfif #basFrom# does not contain "binary_object">
				<cfset basFrom = " #basFrom#, binary_object">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = binary_object.derived_from_cat_item">
			</cfif>
				<cfset basQual = " #basQual# AND binary_object.made_agent_id = #binary_object_made_by_id#">
				<cfset mapurl = "#mapurl#&binary_object_made_by_id=#binary_object_made_by_id#">
		</cfif>
	<!--- this must be the last image criteria to run --->
		<cfif isdefined("onlyImages") AND not #basFrom# contains "binary_object">
			<cfset basFrom = " #basFrom#, binary_object">
			<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = binary_object.derived_from_cat_item">
			<cfset mapurl = "#mapurl#&onlyImages=t">
		</cfif>
			
		<cfif isdefined("permit_issued_by") AND len(#permit_issued_by#) gt 0
			OR isdefined("permit_issued_to") AND len(#permit_issued_to#) gt 0
			OR isdefined("permit_type") AND len(#permit_type#) gt 0
			OR isdefined("permit_num") AND len(#permit_num#) gt 0>
				<cfset mapurl = "#permit_issued_by#&permit_issued_by">
				<cfset basFrom = " #basFrom#, permit_trans, permit">
				<cfset basWhere = " #basWhere# AND cataloged_item.accn_id = permit_trans.transaction_id
					AND permit_trans.permit_id = permit.permit_id">
  </cfif>
		
		<cfif isdefined("permit_issued_by") AND len(#permit_issued_by#) gt 0>
		<cfset mapurl = "#permit_issued_by#&permit_issued_by">
			<cfset basFrom = " #basFrom#, agent_name permit_issued">
			<cfset basWhere = " #basWhere# AND permit.issued_by_agent_id = permit_issued.agent_id">
			<cfset basQual = " #basQual# AND upper(permit_issued.agent_name) like '%#ucase(permit_issued_by)#%'">
		</cfif>
		<cfif isdefined("permit_issued_to") AND len(#permit_issued_to#) gt 0>
		<cfset mapurl = "#permit_issued_to#&permit_issued_to">
			<cfset basFrom = " #basFrom#, agent_name permit_to">
			<cfset basWhere = " #basWhere# AND permit.issued_to_agent_id = permit_to.agent_id">
			<cfset basQual = " #basQual# AND upper(permit_to.agent_name) like '%#ucase(permit_issued_to)#%'">
		</cfif>
		<cfif isdefined("permit_type") AND len(#permit_type#) gt 0>
		<cfset mapurl = "#permit_type#&permit_type">
			<cfset basQual = " #basQual# AND permit_type='#replace(permit_type,"'","''","all")#'">
		</cfif>
		<cfif isdefined("permit_num") AND len(#permit_num#) gt 0>
		<cfset mapurl = "#permit_num#&permit_num">
			<cfset basQual = " #basQual# AND permit_num='#permit_num#'">
		</cfif>
			
		<!---- remarks for SB --->	
		<cfif isdefined("remark") AND len(#remark#) gt 0>
			<cfset mapurl = "#remark#&remark">
			<cfset basFrom = " #basFrom#, coll_object_remark">
			<cfset basWhere = " #basWhere# AND coll_object_remark.collection_object_id = cataloged_item.collection_object_id">
			<cfset basQual = " #basQual# AND upper(coll_object_remark.coll_object_remarks) LIKE '%#ucase(remark)#%'">
		</cfif>
		<!--- this is the custom form code - it MUST run AFTER the regular SQL for this particular attribute has run ---->
		<cfif isdefined("thisUserCols") AND #thisUserCols# contains "specimen_remarks">
			<cfif #basSelect# does not contain "coll_object_remarks">
				<cfset basSelect = "#basSelect#,coll_object_remarks">
			</cfif>
			<cfif #basFrom# does not contain "coll_object_remark">
				<cfset basFrom = "#basFrom#,coll_object_remark">
			</cfif>
			<cfif #basWhere# does not contain "coll_object_remark">
				<cfset basWhere = " #basWhere# AND cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+)">
			</cfif>
		</cfif>
		<cfif isdefined("attributed_determiner_agent_id") AND len(#attributed_determiner_agent_id#) gt 0>
			<cfset mapurl = "#mapurl#&attributed_determiner_agent_id=#attributed_determiner_agent_id#">
			<cfset basFrom = " #basFrom#, attributes">
			<cfset basWhere = " #basWhere# AND attributes.collection_object_id = cataloged_item.collection_object_id">
			<cfset basQual = " #basQual# AND attributes.determined_by_agent_id = #attributed_determiner_agent_id#">
		</cfif>
		<cfif isdefined("attribute_type_1") AND len(#attribute_type_1#) gt 0>
			<cfset mapurl = "#mapurl#&attribute_type_1=#attribute_type_1#">
			<cfset basFrom = " #basFrom#, attributes attributes_1">
			<cfset basWhere = " #basWhere# AND attributes_1.collection_object_id = cataloged_item.collection_object_id">
			<cfset basQual = " #basQual# AND attributes_1.attribute_type = '#attribute_type_1#'">
			
				<cfif not isdefined("attOper_1")>
					<cfset attOper_1 = "like">
				</cfif>
				<cfset mapurl = "#mapurl#&attOper_1=#attOper_1#">
				<cfif isdefined("attribute_value_1")>
					<cfset mapurl = "#mapurl#&attribute_value_1=#attribute_value_1#">
					<cfset attribute_value_1 = #replace(attribute_value_1,"'","''","all")#>
				</cfif>
				<cfif isdefined("attribute_units_1") AND len(#attribute_units_1#) gt 0>
						<cfset mapurl = "#mapurl#&attribute_units_1=#attribute_units_1#">
					</cfif>
				<cfif #attOper_1# is "like">
					<cfif isdefined("attribute_value_1") AND len(#attribute_value_1#) gt 0>
						<cfset basQual = " #basQual# AND upper(attributes_1.attribute_value) LIKE '%#ucase(attribute_value_1)#%'">
					</cfif>
					<cfif isdefined("attribute_units_1") AND len(#attribute_units_1#) gt 0>
						<cfset basQual = " #basQual# AND upper(attributes_1.attribute_units) LIKE '%#ucase(attribute_units_1)#%'">
					</cfif>
				  <cfelseif #attOper_1# is "equals" >
				  	<cfif isdefined("attribute_value_1") AND len(#attribute_value_1#) gt 0>
						<cfset basQual = " #basQual# AND attributes_1.attribute_value = '#attribute_value_1#'">
					</cfif>
					<cfif isdefined("attribute_units_1") AND len(#attribute_units_1#) gt 0>
						<cfset basQual = " #basQual# AND attributes_1.attribute_units = '#attribute_units_1#'">
					</cfif>
				<cfelseif #attOper_1# is "greater" >
				  	<cfif isdefined("attribute_value_1") AND len(#attribute_value_1#) gt 0>
						<cfif isnumeric(#attribute_value_1#)>
							<cfset basQual = " #basQual# AND to_number(attributes_1.attribute_value) > '#attribute_value_1#'">
						  <cfelse>
						  	<cfoutput>
				
							<CFSETTING ENABLECFOUTPUTONLY=0>
						<SCRIPT>document.getElementById('progMeter').style.visibility = 'hidden';</SCRIPT>
						<font color="##FF0000" size="+2">
							You tried to search for values greater than a non-numeric value (#attribute_value_1#).</font>	 
						<cfabort>
							</cfoutput>		  
						  	<cfabort>
						</cfif>
					</cfif>
				<cfelseif #attOper_1# is "less" >
				  	<cfif isdefined("attribute_value_1") AND len(#attribute_value_1#) gt 0>
						<cfif isnumeric(#attribute_value_1#)>
							<cfset basQual = " #basQual# AND attributes_1.attribute_value < '#attribute_value_1#'">
						  <cfelse>
						  	<cfoutput>
							<CFSETTING ENABLECFOUTPUTONLY=0>
						<SCRIPT>document.getElementById('progMeter').style.visibility = 'hidden';</SCRIPT>
						  	<font color="##FF0000" size="+2">You tried to search for values less than a non-numeric value (#attribute_value_1#).</font>				
							</cfoutput>		  
						  	<cfabort>
						</cfif>
					</cfif>
					<cfif isdefined("attribute_units_1") AND len(#attribute_units_1#) gt 0>
						<cfset basQual = " #basQual# AND attributes_1.attribute_units = '#attribute_units_1#'">
					</cfif>
				</cfif>
		</cfif>
		
		<cfif isdefined("attribute_type_2") AND len(#attribute_type_2#) gt 0>
			<cfset basFrom = " #basFrom#, attributes attributes_2">
			<cfset basWhere = " #basWhere# AND attributes_2.collection_object_id = cataloged_item.collection_object_id">
			<cfset basQual = " #basQual# AND attributes_2.attribute_type = '#attribute_type_2#'">
			<cfif not isdefined("attOper_2")>
				<cfset attOper_2 = "like">
			</cfif>
			<cfif isdefined("attribute_value_2")>
				<cfset attribute_value_2 = #replace(attribute_value_2,"'","''","all")#>
			</cfif>
			<cfif #attOper_2# is "like">
				<cfif isdefined("attribute_value_2") AND len(#attribute_value_2#) gt 0>
					<cfset basQual = " #basQual# AND upper(attributes_2.attribute_value) LIKE '%#ucase(attribute_value_2)#%'">
				</cfif>
				<cfif isdefined("attribute_units_2") AND len(#attribute_units_2#) gt 0>
					<cfset basQual = " #basQual# AND upper(attributes_2.attribute_units) LIKE '%#ucase(attribute_units_2)#%'">
				</cfif>
			<cfelseif #attOper_2# is "equals" >
				  	<cfif isdefined("attribute_value_2") AND len(#attribute_value_2#) gt 0>
						<cfset basQual = " #basQual# AND attributes_2.attribute_value = '#attribute_value_2#'">
					</cfif>
					<cfif isdefined("attribute_units_2") AND len(#attribute_units_2#) gt 0>
						<cfset basQual = " #basQual# AND attributes_2.attribute_units = '#attribute_units_2#'">
					</cfif>
			<cfelseif #attOper_2# is "greater" >
				  	<cfif isdefined("attribute_value_2") AND len(#attribute_value_2#) gt 0>
						<cfif isnumeric(#attribute_value_2#)>
							<cfset basQual = " #basQual# AND to_number(attributes_2.attribute_value) > '#attribute_value_2#'">
						<cfelse>
						  	<cfoutput>
							<CFSETTING ENABLECFOUTPUTONLY=0>
						<SCRIPT>document.getElementById('progMeter').style.visibility = 'hidden';</SCRIPT>
						  	<font color="##FF0000" size="+2">
								You tried to search for values greater than a non-numeric value (#attribute_value_2#).</font>				
							</cfoutput>		  
						  	<cfabort>
						</cfif>
					</cfif>
				<cfelseif #attOper_2# is "less" >
				  	<cfif isdefined("attribute_value_2") AND len(#attribute_value_2#) gt 0>
						<cfif isnumeric(#attribute_value_2#)>
							<cfset basQual = " #basQual# AND to_number(attributes_2.attribute_value) < '#attribute_value_2#'">
						<cfelse>
						  	<cfoutput>
							<CFSETTING ENABLECFOUTPUTONLY=0>
						<SCRIPT>document.getElementById('progMeter').style.visibility = 'hidden';</SCRIPT>
						  	<font color="##FF0000" size="+2">
							You tried to search for values less than a non-numeric value (#attribute_value_2#).</font>				
							</cfoutput>		  
						  	<cfabort>
						</cfif>
					</cfif>
		  </cfif>
		</cfif>
		
		<cfif isdefined("attribute_type_3") AND len(#attribute_type_3#) gt 0>
			<cfset basFrom = " #basFrom#, attributes attributes_3">
			<cfset basWhere = " #basWhere# AND attributes_3.collection_object_id = cataloged_item.collection_object_id">
			<cfset basQual = " #basQual# AND attributes_3.attribute_type = '#attribute_type_3#'">
			<cfif not isdefined("attOper_3")>
				<cfset attOper_3 = "like">
			</cfif>
			<cfif isdefined("attribute_value_3")>
				<cfset attribute_value_3 = #replace(attribute_value_3,"'","''","all")#>
			</cfif>
			<cfif #attOper_3# is "like">
				<cfif isdefined("attribute_value_3") AND len(#attribute_value_3#) gt 0>
					<cfset basQual = " #basQual# AND upper(attributes_3.attribute_value) LIKE '%#ucase(attribute_value_3)#%'">
				</cfif>
				<cfif isdefined("attribute_units_3") AND len(#attribute_units_2#) gt 0>
					<cfset basQual = " #basQual# AND upper(attributes_3.attribute_units) LIKE '%#ucase(attribute_units_3)#%'">
				</cfif>
			<cfelseif #attOper_3# is "equal" >
				  	<cfif isdefined("attribute_value_3") AND len(#attribute_value_3#) gt 0>
						<cfset basQual = " #basQual# AND attributes_3.attribute_value = '#attribute_value_3#'">
					</cfif>
					<cfif isdefined("attribute_units_3") AND len(#attribute_units_3#) gt 0>
						<cfset basQual = " #basQual# AND attributes_3.attribute_units = '#attribute_units_3#'">
					</cfif>
			<cfelseif #attOper_3# is "greater" >
				  	<cfif isdefined("attribute_value_3") AND len(#attribute_value_3#) gt 0>
						<cfif isnumeric(#attribute_value_3#)>
							<cfset basQual = " #basQual# AND to_number(attributes_3.attribute_value) > '#attribute_value_3#'">
						  <cfelse>
						  	<cfoutput>
						  	<font color="##FF0000" size="+2">
							You tried to search for values greater than a non-numeric value (#attribute_value_3#).</font>				
							</cfoutput>		  
						  	<cfabort>
						</cfif>
					</cfif>
				<cfelseif #attOper_3# is "less" >
				  	<cfif isdefined("attribute_value_3") AND len(#attribute_value_3#) gt 0>
						<cfif isnumeric(#attribute_value_3#)>
							<cfset basQual = " #basQual# AND to_number(attributes_3.attribute_value) < '#attribute_value_3#'">
						  <cfelse>
						  	<cfoutput>
							<CFSETTING ENABLECFOUTPUTONLY=0>
						<SCRIPT>document.getElementById('progMeter').style.visibility = 'hidden';</SCRIPT>
						  	<font color="##FF0000" size="+2">You tried to search for values less than a non-numeric value (#attribute_value_3#).</font>				
							</cfoutput>		  
						  	<cfabort>
						</cfif>
					</cfif>
		  </cfif>
  </cfif>
		<!---- special custom form building code for attributes --->
		
		<!----- end custom form code for this attribute ---->
		
	