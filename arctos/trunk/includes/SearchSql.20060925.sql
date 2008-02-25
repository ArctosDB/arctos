<cfif not isdefined("Request.GetJulianDay")>
	<cfinclude template="/includes/functionLib.cfm">
</cfif>

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
<cfif not isdefined("CustomOidOper")>
	<cfset CustomOidOper = "LIKE">
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
<cfif not isdefined("basGroup")>
	<cfset basGroup = "">
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
<cfset mapurl = "#mapurl#&inclDateSearch=#inclDateSearch#">

<!---- handle old stuff by aliasing it to new ---->
<cfif isdefined("catnum") AND isnumeric(#catnum#)><!--- will also fire if null ---->
	<cfset listcatnum = "#catnum#">
</cfif>
		
<!--- start buildig SQL --->
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
		<cfset basQual = " #basQual# AND flat.cat_num >= #minCatNum# AND flat.cat_num <= #maxCatNum#  " >
	<cfelse>
		<cfloop list="#listcatnum#" index="i">
			<cfif not isnumeric(#i#)>
				<font color="#FF0000" size="+1">Catalog Numbers must be numeric!</font>				  
				<cfabort>
			</cfif>
		</cfloop>
		<cfset basQual = " #basQual# AND flat.cat_num IN ( #listcatnum# ) " >
	</cfif>
</cfif>	
		
<cfif isdefined("entered_by") AND len(#entered_by#) gt 0>
	
		<cfquery name="enteredPersonID" datasource="#web_user#">
			SELECT agent_id FROM agent_name WHERE upper(agent_name) LIKE '%#ucase(entered_by)#%'
		</cfquery>
		<cfif #enteredPersonID.recordcount# neq 1>
			<cfoutput>
				#enteredPersonID.recordcount# agents matched entered_by. Try narrowing or expanding to get one.
			</cfoutput>
			<cfabort>
		</cfif>
	<cfset entered_by_id = #enteredPersonID.agent_id# >
</cfif>

<cfif isdefined("entered_by_id") AND len(#entered_by_id#) gt 0><!--- will also fire if null ---->
	<cfif #basJoin# does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
			(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.entered_person_id = #entered_by_id#" >
	<cfset mapurl = "#mapurl#&entered_by_id=#entered_by_id#">
</cfif>
		
<cfif isdefined("coll_obj_flags") AND len(#coll_obj_flags#) gt 0>
	<cfif #basJoin# does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
		(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.flags = '#coll_obj_flags#'" >
	<cfset mapurl = "#mapurl#&coll_obj_flags=#coll_obj_flags#">
</cfif>
		
		<cfif isdefined("beg_entered_date") AND len(#beg_entered_date#) gt 0>
			<cfif not isdefined("end_entered_date") or len(#end_entered_date#) is 0>
				<cfset end_entered_date = #beg_entered_date#>
			</cfif>
			<cfset beEntDate = dateformat(beg_entered_date,"dd-mmm-yyyy")>
			<cfset edEntDate = dateformat(end_entered_date,"dd-mmm-yyyy")>
			<cfif #basJoin# does not contain "CatItemCollObject">
				<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
				(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.COLL_OBJECT_ENTERED_DATE BETWEEN '#beEntDate#' and '#edEntDate#'" >
			<cfset mapurl = "#mapurl#&beg_entered_date=#beg_entered_date#">
			<cfset mapurl = "#mapurl#&end_entered_date=#end_entered_date#">
		</cfif>
<cfif isdefined("print_fg") AND len(#print_fg#) gt 0>
	<!---- get data for printing labels ---->
	<cfset basQual = "#basQual#  AND cataloged_item.collection_object_id IN (
		SELECT
			derived_from_cat_item
		FROM
			specimen_part,
			coll_obj_cont_hist,
			container coll_obj_container,
			container parent_container
		WHERE
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id AND
			coll_obj_cont_hist.container_id = coll_obj_container.container_id AND
			coll_obj_container.parent_container_id = parent_container.container_id AND
			parent_container.print_fg = #print_fg# )
		" >
	<cfset mapurl = "#mapurl#&print_fg=#print_fg#">
</cfif>
		
		<!---
		<cfif isdefined("ShowObservations") AND #ShowObservations# is "true">
			<cfset mapurl = "#mapurl#&ShowObservations=#ShowObservations#">
			<!--- 
				Kludgey manual filtering against observations
				Default is on; don't show them.
				At some point, we'll probably want to make
				cataloged_item.cataloged_item_type the filter here.
				For now, just catch it by Institution_Acronym and call
				it good.
			---->
		<cfelse>
			<!---- the default; hide observations ---->
			<cfset basQual = "#basQual#  AND collection_id <> 13" >
		</cfif>
		--->
		<cfif isdefined("edited_by_id") AND len(#edited_by_id#) gt 0>
			<cfif #basJoin# does not contain "CatItemCollObject">
				<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
				(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.last_edited_person_id = #edited_by_id#" >
			<cfset mapurl = "#mapurl#&edited_by_id=#edited_by_id#">
		</cfif>
		<cfif isdefined("coll_obj_disposition") AND len(#coll_obj_disposition#) gt 0>
			<cfif #basJoin# does not contain "CatItemCollObject">
				<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
				(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
			</cfif>
			<cfset basQual = "#basQual#  AND CatItemCollObject.coll_obj_disposition = '#coll_obj_disposition#'" >
			<cfset mapurl = "#mapurl#&coll_obj_disposition=#coll_obj_disposition#">
		</cfif>
		
		<cfif isdefined("encumbrance_id") AND isnumeric(#encumbrance_id#)>
			<cfif #basJoin# does not contain "coll_object_encumbrance">
				<cfset basJoin = " #basJoin# INNER JOIN coll_object_encumbrance ON 
				(cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id)">
			</cfif>
			<cfset basQual = "#basQual#  AND coll_object_encumbrance.encumbrance_id = #encumbrance_id#" >
			<cfset mapurl = "#mapurl#&encumbrance_id=#encumbrance_id#">
		</cfif>
		
		<cfif isdefined("encumbering_agent_id") AND isnumeric(#encumbering_agent_id#)>
			<cfif #basJoin# does not contain " coll_object_encumbrance ">
				<cfset basJoin = " #basJoin# INNER JOIN coll_object_encumbrance ON 
				(cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id)">
			</cfif>
			<cfif #basJoin# does not contain " encumbrance ">
				<cfset basJoin = " #basJoin# INNER JOIN encumbrance ON 
				(coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id)">
			</cfif>
			<cfset basQual = "#basQual#  AND encumbering_agent_id = #encumbering_agent_id#" >
			<cfset mapurl = "#mapurl#&encumbering_agent_id=#encumbering_agent_id#">
		</cfif>
		
		
		<cfif isdefined("collection_id") AND isnumeric(#collection_id#)>
			<cfset basQual = "#basQual#  AND flat.collection_id = #collection_id#" >
			<cfset mapurl = "#mapurl#&collection_id=#collection_id#">
		<cfelse>
			<!--- allow over-ride of collection in preferences if they specify a collection 
			at specimensearch --->
			<cfif isdefined("collection_ids") and len(#collection_ids#) gt 0>
				<cfset basQual = "#basQual#  AND cataloged_item.collection_id IN (#collection_ids#)" >
				<cfset mapurl = "#mapurl#&collection_ids=#collection_ids#">
			</cfif>	
			<cfif isdefined("exclusive_collection_id") and len(#exclusive_collection_id#) gt 0>
				<cfset basQual = "#basQual#  AND cataloged_item.collection_id = #exclusive_collection_id#" >
				<cfset mapurl = "#mapurl#&exclusive_collection_id=#exclusive_collection_id#">
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
		</cfif>	
		
		<cfif isdefined("coll") AND #coll# IS NOT "">
			<cfif not isdefined("coll_role") or len(#coll_role#) is 0>
				<cfset coll_role="c">
			</cfif>
			<cfif #coll_role# is "p">
				<cfset basJoin = " #basJoin# INNER JOIN collector ON 
					(cataloged_item.collection_object_id = collector.collection_object_id)
					INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
				<cfSet basQual = " #basQual# AND UPPER(srchColl.Agent_Name) LIKE '%#UCASE(coll)#%'
					AND collector_role = '#coll_role#'">
			<cfelse>
				<cfSet basQual = " #basQual# AND UPPER(flat.COLLECTORS) LIKE '%#UCASE(coll)#%'">
			</cfif>
			<cfset mapurl = "#mapurl#&coll=#coll#">  
			<cfset mapurl = "#mapurl#&coll_role LIKE #coll_role#">
		</cfif>
		<cfif isdefined("collector_agent_id") AND len(#collector_agent_id#) gt 0>
			<cfset mapurl = "#mapurl#&collector_agent_id=#collector_agent_id#"> 
			<cfif #basJoin# does not contain "srchColl">
				<cfset basJoin = " #basJoin# INNER JOIN collector ON 
					(cataloged_item.collection_object_id = collector.collection_object_id)
					INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
			</cfif>
			<cfset basQual = " #basQual# AND collector.agent_id = #collector_agent_id#">
		</cfif>
		
		
		<cfif #sciNameOper# is "was"><!--- duck out to any name --->
			<cfset AnySciName=#scientific_name#>
			<cfset scientific_name="">
		</cfif>
		<cfif isdefined("sciname") and len(#sciname#) gt 0>
			<cfset scientific_name=#sciname#>
		</cfif>
		<cfif isdefined("scientific_name") AND len(#scientific_name#) gt 0>
			<cfset mapurl = "#mapurl#&scientific_name=#scientific_name#">
			<cfif #sciNameOper# is "LIKE">
				<cfset basQual = " #basQual# AND upper(scientific_name) LIKE '%#ucase(scientific_name)#%'">					
			<cfelseif #sciNameOper# is "=">
				<cfset basQual = " #basQual# AND scientific_name = '#scientific_name#'">
			<cfelseif #sciNameOper# is "NOT LIKE">
				<cfset basQual = " #basQual# AND upper(scientific_name) NOT LIKE '%#ucase(scientific_name)#%'">
			</cfif>
		</cfif>
		
		<cfif isdefined("HighTaxa") AND len(#HighTaxa#) gt 0>
			<cfset mapurl = "#mapurl#&HighTaxa=#HighTaxa#">
			<cfif #basJoin# does not contain " identification ">
				<cfset basJoin = " #basJoin# INNER JOIN identification ON 
				(cataloged_item.collection_object_id = identification.collection_object_id)">
			</cfif>
			<cfif #basJoin# does not contain " identification_taxonomy ">
				<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
				(identification.identification_id = identification_taxonomy.identification_id)">
			</cfif>
			<cfif #basJoin# does not contain " taxonomy ">
				<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
				(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
			</cfif>
			<cfset basQual = "#basQual# AND identification.accepted_id_fg=1">
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
						OR cataloged_item.collection_object_id IN (
							select collection_object_id FROM
								identification,
								identification_taxonomy,
								taxonomy AccTax,
								taxonomy RelTax,
								taxon_relations
							WHERE
								identification.identification_id=identification_taxonomy.identification_id AND
								identification_taxonomy.taxon_name_id=AccTax.taxon_name_id AND
								AccTax.taxon_name_id=taxon_relations.taxon_name_id AND
								taxon_relations.related_taxon_name_id = RelTax.taxon_name_id AND
								UPPER(RelTax.scientific_name) LIKE '%#ucase(AnySciName)#%'
							)
							)">
		</cfif>
		
		<cfif isdefined("Phylclass") AND len(#Phylclass#) gt 0>
			<cfset mapurl = "#mapurl#&Phylclass=#Phylclass#">
			<cfif #basJoin# does not contain " identification ">
				<cfset basJoin = " #basJoin# INNER JOIN identification ON 
				(cataloged_item.collection_object_id = identification.collection_object_id)">
			</cfif>
			<cfif #basJoin# does not contain " identification_taxonomy ">
				<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
				(identification.identification_id = identification_taxonomy.identification_id)">
			</cfif>
			<cfif #basJoin# does not contain " taxonomy ">
				<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
				(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
			</cfif>
			<cfset basQual = " #basQual# AND Phylclass = '#Phylclass#'">
		</cfif>
		
		<cfif isdefined("identified_agent_id") AND len(#identified_agent_id#) gt 0>
			<cfset mapurl = "#mapurl#&identified_agent_id=#identified_agent_id#">
			<cfif #basJoin# does not contain " identification ">
				<cfset basJoin = " #basJoin# INNER JOIN identification ON 
				(cataloged_item.collection_object_id = identification.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND identification.id_made_by_agent_id = #identified_agent_id#">			
		</cfif>
		
		<cfif isdefined("identified_agent") AND len(#identified_agent#) gt 0>
			<cfset mapurl = "#mapurl#&identified_agent=#identified_agent#">
			<cfset basQual = " #basQual# AND upper(flat.IDENTIFIEDBY) LIKE '%#ucase(identified_agent)#%'">			
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
				<cfset mapurl = "#mapurl#&begYear=#begYear#">
				<cfset mapurl = "#mapurl#&endYear=#endYear#">
				<cfset basQual = " #basQual#
						AND ( 
					TO_NUMBER(TO_CHAR(flat.began_date, 'yyyy')) >= #begYear#
					AND TO_NUMBER(TO_CHAR(flat.ended_date, 'yyyy')) <= #endYear#
					)
					">			
			<cfelse>
				<cfset mapurl = "#mapurl#&begYear=#begYear#">
				<cfset mapurl = "#mapurl#&endYear=#endYear#">
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
			<cfset mapurl = "#mapurl#&endMon=#endMon#">
			<cfset mapurl = "#mapurl#&begMon=#begMon#">
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
			<cfset mapurl = "#mapurl#&begDay=#begDay#">
			<cfset mapurl = "#mapurl#&endDay=#endDay#">
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
	<cfset mapurl = "#mapurl#&endDate=#endDate#">
	<cfset mapurl = "#mapurl#&begDate=#begDate#">
	<cfif not isdate(begDate) OR not isdate(endDate)>
	<!--- see if we can use ddMonYYYY format ---->
	<cfif not isdate(begDate)>
		<cfif len(begDate) is 9>
			<cfset d = left(begDate,2)>
			<cfset m = mid(begDate,3,3)>
			<cfset y = right(begDate,4)>
			<cfset begDate = "#d#-#m#-#y#">
			<cfif not isdate(begDate)>
				<b><font color="#FF0000" size="+1">The date format you entered was not recognized as a valid date format.
		<br>
		<i>dd mm yyyy</i> is the preferred data format.</font></b>	
				<cfabort>
			</cfif>
		</cfif>
	</cfif>
	<cfif not isdate(endDate)>
		<cfif len(endDate) is 9>
			<cfset d = left(endDate,2)>
			<cfset m = mid(endDate,3,3)>
			<cfset y = right(endDate,4)>
			<cfset endDate = "#d#-#m#-#y#">
			<cfif not isdate(endDate)>
				<b><font color="#FF0000" size="+1">The date format you entered was not recognized as a valid date format.
		<br>
		<i>dd mm yyyy</i> is the preferred data format.</font></b>	
				<cfabort>
			</cfif>
		</cfif>
	</cfif>
		  
	</cfif>

		
		
			<cfif #inclDateSearch# is "yes">

				<cfset mapurl = "#mapurl#&inclDateSearch=#inclDateSearch#">
				<cfset basQual = " #basQual#
						AND ( 
					TO_NUMBER(TO_CHAR(began_date, 'j')) >= #round(Request.GetJulianDay(begDate))#
					AND TO_NUMBER(TO_CHAR(ended_date, 'j')) <= #round(Request.GetJulianDay(endDate))#
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
			<cfset mapurl = "#mapurl#&inMon=#inMon#">
			<cfset basQual = " #basQual# AND TO_CHAR(began_date, 'mm') IN (#inMon#)">
		</cfif>
		
		<cfif isdefined("verbatim_date") AND len(#verbatim_date#) gt 0>
			<cfset mapurl = "#mapurl#&verbatim_date=#verbatim_date#">
			<cfset basQual = " #basQual# AND upper(verbatim_date) LIKE '%#ucase(verbatim_date)#%'">
		</cfif>
		
		<cfif isdefined("Accn_trans_id") AND len(#Accn_trans_id#) gt 0>
			<cfset mapurl = "#mapurl#&Accn_trans_id=#Accn_trans_id#">
			<cfif #basJoin# does not contain " accn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn ON 
				(cataloged_item.accn_id = accn.transaction_id)">
			</cfif>
			<cfset basQual = " #basQual# AND accn.transaction_id = #Accn_trans_id#">
		</cfif>	
		
		<cfif isdefined("Accn") AND #Accn# IS NOT "">
			Accn is no longer a valid search term. Please submit a bug report.
			<cfabort>
			<!----
			<cfset mapurl = "#mapurl#&Accn=#accn#">
			<cfset basFrom = " #basFrom#, accn,trans">
			<cfset basWhere = " #basWhere# AND accn.transaction_id = cataloged_item.accn_id AND accn.transaction_id = trans.transaction_id">
			<!--- should have got an 8 (1234.567) or 13 (1234.567.Mamm) character string
				choke if not --->
			<cfif len(#accn#) is 8>
				<cfset basQual = " #basQual# AND accn_num_prefix||'.'||LPAD(accn_num,3,'0') LIKE '#Accn#'">
			<cfelseif len(#accn#) is 13>
				<cfset basQual = " #basQual# AND accn_num_prefix||'.'||LPAD(accn_num,3,'0')||'.'||accn_num_suffix LIKE '#Accn#'">
			<cfelse>
				<font color="#FF0000" size="+1"><strong>I was expecting an 8 or 13 character accn 
				number in one of the following formats:
				</strong></font>
				<ul>
					<li><strong><font color="#FF0000" size="+1">
					  1234.567
					</font></strong></li>
					<li><strong><font color="#FF0000" size="+1">
					  1234.567.Mamm
					</font></strong></li>
				</ul>
				<strong><font color="#FF0000" size="+1">but you searched for Accession 
				<cfoutput>#accn#</cfoutput>. I don't know what to do with that!
				</font>
			    </strong>
			  <p><strong><font color="#FF0000" size="+1">Please submit a <a href="/info/bugs.cfm">bug report</a>.</font></strong></p>
				<cfabort>
			</cfif>
			---->
		</cfif>
		<cfif isdefined("accn_inst") and len(#accn_inst#) gt 0>
			<cfset mapurl = "#mapurl#&accn_inst=#accn_inst#">
			<cfif #basJoin# does not contain " accn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn ON 
				(cataloged_item.accn_id = accn.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " trans ">
				<cfset basJoin = " #basJoin# INNER JOIN trans ON 
				(accn.transaction_id=trans.transaction_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(trans.institution_acronym) like '%#ucase(accn_inst)#%'">
		</cfif>
		<cfif isdefined("accn_prefix") and len(#accn_prefix#) gt 0>
			<cfset mapurl = "#mapurl#&accn_prefix=#accn_prefix#">
			<cfif #basJoin# does not contain " accn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn ON 
				(cataloged_item.accn_id = accn.transaction_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(ACCN_NUM_PREFIX) = '#ucase(accn_prefix)#'">
		</cfif>
		<cfif isdefined("accn_number") and len(#accn_number#) gt 0>
			<cfset mapurl = "#mapurl#&accn_number=#accn_number#">
			<cfif #basJoin# does not contain " accn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn ON 
				(cataloged_item.accn_id = accn.transaction_id)">
			</cfif>
			<cfset basQual = " #basQual# AND accn_num = #accn_number#">
		</cfif>
		<cfif isdefined("accn_suffix") and len(#accn_suffix#) gt 0>
			<cfset mapurl = "#mapurl#&accn_suffix=#accn_suffix#">
			<cfif #basJoin# does not contain " accn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn ON 
				(cataloged_item.accn_id = accn.transaction_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(ACCN_NUM_SUFFIX) LIKE '%#ucase(accn_suffix)#%'">
		</cfif>
		<cfif isdefined("accn_agency") and len(#accn_agency#) gt 0>
			<cfset mapurl = "#mapurl#&accn_agency=#accn_agency#">
			<cfif #basJoin# does not contain " accn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn ON 
				(cataloged_item.accn_id = accn.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " trans ">
				<cfset basJoin = " #basJoin# INNER JOIN trans ON 
				(accn.transaction_id=trans.transaction_id)">
			</cfif>
			
			<cfif #basJoin# does not contain " accn_agency ">
				<cfset basJoin = " #basJoin# INNER JOIN agent_name accn_agency ON 
				(trans.TRANS_AGENCY_ID = accn_agency.agent_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(accn_agency.agent_name) LIKE '%#ucase(accn_agency)#%'">
		</cfif>
		
		<cfif isdefined("CustomIdentifierValue") and len(#CustomIdentifierValue#) gt 0>
			<cfset mapurl = "#mapurl#&CustomIdentifierValue=#CustomIdentifierValue#">
			<cfif #basJoin# does not contain " customIdentifier ">
				<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON 
				(cataloged_item.collection_object_id = customIdentifier.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#customOtherIdentifier#'">
			<cfif #CustomOidOper# is "=">
				<cfset basQual = " #basQual# AND customIdentifier.other_id_num = '#CustomIdentifierValue#'">
			<cfelseif #CustomOidOper# is "LIST">
				<cfset CustOidList = "">
				<cfloop list="#CustomIdentifierValue#" delimiters="," index="v">
					<cfif len(#CustOidList#) is 0>
						<cfset CustOidList = "'#v#'">
					<cfelse>
						<cfset CustOidList = "#CustOidList#,'#v#'">
					</cfif>
				</cfloop>
				<cfset basQual = " #basQual# AND upper(customIdentifier.other_id_num) IN (#ucase(CustOidList)#)">
			<cfelseif #CustomOidOper# is "BETWEEN">
				<cfif #CustomIdentifierValue# does not contain "-">
					<strong><font color="#FF0000" size="+1">You must specify a range of values separated by ' - '
					to search for ranges of Your Identifier.
					</font>
					</strong>
					<cfabort>
				</cfif>
				<cfset dash = find("-",CustomIdentifierValue)>
				<cfset idFrom = left(CustomIdentifierValue,dash-1)>
				<cfset idTo = mid(CustomIdentifierValue,dash+1,len(CustomIdentifierValue))>
				<cfset basQual = " #basQual# AND to_number(customIdentifier.other_id_num) BETWEEN #idFrom# and #idTo#">
			<cfelse><!---- LIKE ---->
				<cfset basQual = " #basQual# AND upper(customIdentifier.other_id_num) LIKE '%#ucase(CustomIdentifierValue)#%'">
			</cfif>
		</cfif>
		
		<cfif isdefined("OIDType") AND #OIDType# IS NOT "">
			<cfset mapurl = "#mapurl#&OIDType=#OIDType#">	
			<cfif #basJoin# does not contain " otherIdSearch ">
				<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON 
				(cataloged_item.collection_object_id = otherIdSearch.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND otherIdSearch.other_id_type = '#OIDType#'">
		</cfif>
		
		<cfif isdefined("OIDNum") and len(#OIDNum#) gt 0>
			<cfset mapurl = "#mapurl#&OIDNum=#OIDNum#">	
			<cfset mapurl = "#mapurl#&oidOper=#oidOper#">	
			<cfif #basJoin# does not contain " otherIdSearch ">
				<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON 
				(cataloged_item.collection_object_id = otherIdSearch.collection_object_id)">
			</cfif>
			
			<cfset oidList="">
			<cfloop list="#OIDNum#" delimiters="," index="i">
				<cfif #oidOper# is "LIKE">
					<cfif len(#oidList#) is 0>
						<cfset oidList = "AND ( upper(otherIdSearch.other_id_num) LIKE '%#ucase(i)#%'">
					<cfelse>
						<cfset oidList = "#oidList# OR upper(otherIdSearch.other_id_num) LIKE '%#ucase(i)#%'">
					</cfif>
				<cfelse>
					<cfif len(#oidList#) is 0>
						<cfset oidList = "AND ( otherIdSearch.other_id_num = '#i#'">
					<cfelse>
						<cfset oidList = "#oidList# OR otherIdSearch.other_id_num = '#i#'">
					</cfif>
				</cfif>
			</cfloop>
			<cfset oidList = "#oidList# )">
			<cfset basQual = " #basQual# #oidList#">
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
		
		<cfif isdefined("max_error_in_meters") AND len(#max_error_in_meters#) gt 0>
			<cfif not isnumeric(#max_error_in_meters#)>
				<font color="#FF0000" size="+1">max_error_in_meters must be numeric.</font>			  
				<cfabort>
			</cfif>
		  	<cfset mapurl = "#mapurl#&max_error_in_meters=#max_error_in_meters#">
			<cfset basQual = " #basQual# AND coORDINATEUNCERTAINTYINMETERS <= #max_error_in_meters#">
			<!---- allow searches for max_error=0, but exclude 0 from the results otherwise ---->
			<cfif #max_error_in_meters# gt 0>
				<cfset basQual = " #basQual# AND coORDINATEUNCERTAINTYINMETERS > 0">
			</cfif>
		</cfif>
		
		<cfif isdefined("chronological_extent") AND len(#chronological_extent#) gt 0>
			<cfif not isnumeric(#chronological_extent#)>
				<font color="#FF0000" size="+1">chronological_extent must be numeric.</font>			  
				<cfabort>
			</cfif>
			<cfset mapurl = "#mapurl#&chronological_extent=#chronological_extent#">
			<cfset basQual = " #basQual# AND (
							to_number(to_char(ended_date,'J')) - to_number(to_char(began_date,'J')))
							<= #chronological_extent#">
		</cfif>
			
		<cfif (isdefined("NWLat") and len(#NWLat#) gt 0)
			OR (isdefined("NWLong") and len(#NWLong#) gt 0)
			OR (isdefined("SELat") and len(#SELat#) gt 0)
			OR (isdefined("SELong") and len(#SELong#) gt 0)>
			<!--- got at least one point, see if we got enough to run ---->
			<cfif (isdefined("NWLat") and isnumeric(#NWLat#))
				AND (isdefined("NWLong") and isnumeric(#NWLong#))
				AND (isdefined("SELat") and isnumeric(#SELat#))
				AND (isdefined("SELong") and isnumeric(#SELong#))>
				<!---- got enough data to run ---->
				
				
				<cfset basQual = " #basQual# AND dec_lat BETWEEN #SELat# AND #NWLat#
											AND dec_long BETWEEN #NWLong# AND #SELong#">
				<cfset mapurl = "#mapurl#&NWLat=#NWLat#">
				<cfset mapurl = "#mapurl#&NWLong=#NWLong#">
				<cfset mapurl = "#mapurl#&SELat=#SELat#">
				<cfset mapurl = "#mapurl#&SELong=#SELong#">
			<cfelse>
				You entered at least one bounding box point, but didn't enter sufficient
				information to finish the query. To search by bounding box, you must specify 2 coordinate sets
				in decimal latitude format.
				<cfabort>
			</cfif>
		</cfif>
		
		<cfif isdefined("spec_locality") and len(#spec_locality#) gt 0>
			<cfif #compare(spec_locality,"NULL")# is 0>
				<cfset basQual = " #basQual# AND spec_locality is null">
			<cfelse>
				<cfset basQual = " #basQual# AND upper(spec_locality) like '%#ucase(replace(spec_locality,"'","''","all"))#%' " >
			</cfif>			
			<cfset mapurl = "#mapurl#&spec_locality=#spec_locality#">
		</cfif>
		
		<cfif isdefined("minimum_elevation") and len(#minimum_elevation#) gt 0>
			<cfif not isdefined("orig_elev_units") OR len(#orig_elev_units#) is 0>
				<font color="#FF0000" size="+1">You must supply units to search by elevation.</font>
				<cfabort>
			</cfif>
			<cfif not isnumeric(#minimum_elevation#)>
				<font color="#FF0000" size="+1">Minimum Elevation must be numeric.</font>
				<cfabort>
			</cfif>
			<cfset basQual = " #basQual# AND MIN_ELEV_IN_M >= #getMeters(minimum_elevation,orig_elev_units)#" >
			<cfset mapurl = "#mapurl#&minimum_elevation=#minimum_elevation#">
		</cfif>
		<cfif isdefined("maximum_elevation") and len(#maximum_elevation#) gt 0>
			<cfif not isdefined("orig_elev_units") OR len(#orig_elev_units#) is 0>
				<font color="#FF0000" size="+1">You must supply units to search by elevation.</font>
				<cfabort>
			</cfif>
			<cfif not isnumeric(#maximum_elevation#)>
				<font color="#FF0000" size="+1">Maximum Elevation must be numeric.</font>
				<cfabort>
			</cfif>
			<cfset basQual = " #basQual# AND MAX_ELEV_IN_M <= #getMeters(maximum_elevation,orig_elev_units)#" >
			<cfset mapurl = "#mapurl#&maximum_elevation=#maximum_elevation#">
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
		<cfif isdefined("inCounty") AND #inCounty# IS NOT "">
			<cfset tCounty = "">
			<cfloop list="#inCounty#" delimiters="," index="i">
				<cfif len(#tCounty#) is 0>
					<cfset tCounty = "'#i#'">
				<cfelse>
					<cfset tCounty = "#tCounty#,'#i#'">
				</cfif>
			</cfloop>
			<cfset basQual = " #basQual# AND County IN (#tCounty#)">
			<cfset mapurl = "#mapurl#&inCounty=#inCounty#">
		</cfif>
		<cfif isdefined("Quad") AND #Quad# IS NOT "">
			<cfif #compare(Quad,"NULL")# is 0>
				<cfset basQual = " #basQual# AND Quad is null">
			<cfelse>
				<cfset basQual = " #basQual# AND UPPER(Quad) LIKE '%#UCASE(Quad)#%'">
			</cfif>
			
		  <cfset mapurl = "#mapurl#&quad=#quad#">
		</cfif>
		
		<cfif isdefined("part_name") AND len(#part_name#) gt 0>
			<cfset basQual = " #basQual# AND PARTS LIKE '%#part_name#%'">
			<cfset mapurl = "#mapurl#&part_name=#part_name#">
		</cfif>
		<cfif isdefined("srchParts") AND len(#srchParts#) gt 0>
			<cfif #basJoin# does not contain " specimen_part ">
				<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
				(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
			</cfif>
			<cfset basQual = " #basQual# 
				AND specimen_part.part_name in (
					SELECT part_name FROM
					part_hierarchy
					start with upper(part_name) LIKE '%#ucase(srchParts)#%'
					connect by prior parent_part_id = part_id)">
			<cfset mapurl = "#mapurl#&srchParts=#srchParts#">
		</cfif>
		
		<cfif isdefined("preserv_method") AND len(#preserv_method#) gt 0>
			<cfset preserv_method=#replace(preserv_method,"'","''","all")#>
			<cfif #basJoin# does not contain " specimen_part ">
				<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
				(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
			</cfif>
			<cfset basQual = " #basQual# AND preserve_method LIKE '#preserv_method#'">
			<cfset mapurl = "#mapurl#&preserv_method=#preserv_method#">
		</cfif>
		
		<cfif isdefined("part_modifier") AND len(#part_modifier#) gt 0>
			<cfif #basJoin# does not contain " specimen_part ">
				<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
				(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
			</cfif>
			<cfset basQual = " #basQual# AND part_modifier LIKE '#part_modifier#'">
			<cfset mapurl = "#mapurl#&part_modifier=#part_modifier#">
		</cfif>
			
		
		<cfif isdefined("Common_Name") AND len(#Common_Name#) gt 0>
			<cfif #basJoin# does not contain " identification ">
				<cfset basJoin = " #basJoin# INNER JOIN identification ON 
				(cataloged_item.collection_object_id = identification.collection_object_id)">
			</cfif>
			<cfif #basJoin# does not contain " identification_taxonomy ">
				<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
				(identification.identification_id = identification_taxonomy.identification_id)">
			</cfif>
			<cfif #basJoin# does not contain " common_name ">
				<cfset basJoin = " #basJoin# INNER JOIN common_name ON 
				(identification_taxonomy.taxon_name_id = common_name.taxon_name_id)">
			</cfif>
			<cfset basQual = " #basQual# AND identification.accepted_id_fg = 1 AND
				 UPPER(Common_Name) LIKE '%#ucase(replace(Common_Name,"'","''","all"))#%'">
			<cfset mapurl = "#mapurl#&Common_Name=#Common_Name#">
		</cfif>
		
		<cfif isdefined("publication_id") AND #publication_id# is not "">
			<cfif #basJoin# does not contain " citation ">
				<cfset basJoin = " #basJoin# INNER JOIN citation ON 
				(cataloged_item.collection_object_id = citation.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND publication_id = #publication_id#">
			<cfset mapurl = "#mapurl#&publication_id=#publication_id#">
		</cfif>
		<cfif isdefined("relationship") AND len(#relationship#) gt 0>
			<cfif #basJoin# does not contain " biol_indiv_relations ">
				<cfset basJoin = " #basJoin# INNER JOIN biol_indiv_relations ON 
				(cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND biol_indiv_relations.biol_indiv_relationship = '#relationship#'">
			<cfset mapurl = "#mapurl#&relationship=#relationship#">
		</cfif>
		<cfif isdefined("derived_relationship") AND len(#derived_relationship#) gt 0>
			<cfif #derived_relationship# is "offspring of">
				<cfset srchReln = "parent of">
				<cfif #basJoin# does not contain " invRelns ">
					<cfset basJoin = " #basJoin# INNER JOIN biol_indiv_relations invRelns ON 
					(cataloged_item.collection_object_id = invRelns.collection_object_id)">
				</cfif>
				<cfset basQual = " #basQual# AND invRelns.BIOL_INDIV_RELATIONSHIP = '#srchReln#'">
			<cfelse>
				<span style="font-size:large; color:#FF0000">
					I don't know how to handle relationship <cfoutput>"#derived_relationship#".</cfoutput>
					<br />
					Please submit a <a href="/info/bugs.cfm">bug report.</a>
				</span>
				<cfabort>
			</cfif>
			<cfset mapurl = "#mapurl#&derived_relationship=#derived_relationship#">
		</cfif>
		
		<cfif isdefined("type_status") and len(#type_status#) gt 0>
			<cfif #type_status# is "any">
				<cfset basQual = " #basQual# AND flat.TYPESTATUS IS NOT NULL">
			<cfelse>
				<cfset basQual = " #basQual# AND upper(flat.TYPESTATUS) LIKE '%#ucase(type_status)#%'">
			</cfif>
			<cfset mapurl = "#mapurl#&type_status=#type_status#">
		</cfif>
		
		<cfif isdefined("collection_object_id") AND len(#collection_object_id#) gt 0>
			<cfset basQual = " #basQual# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
			<cfset mapurl = "#mapurl#&collection_object_id=#collection_object_id#">
		</cfif>
		
		<cfif isdefined("taxon_name_id") AND len(#taxon_name_id#) gt 0>
			<cfif #basJoin# does not contain " identification ">
				<cfset basJoin = " #basJoin# INNER JOIN identification ON 
				(cataloged_item.collection_object_id = identification.collection_object_id)">
			</cfif>
			<cfif #basJoin# does not contain " identification_taxonomy ">
				<cfset basJoin = " #basJoin# INNER JOIN identification ON 
				(identification.identification_id = identification_taxonomy.identification_id)">
			</cfif>
			<cfset basQual = " #basQual# AND identification_taxonomy.taxon_name_id = #taxon_name_id#
				AND identification.accepted_id_fg=1">
			<cfset mapurl = "#mapurl#&taxon_name_id=#taxon_name_id#">
		</cfif>
		
		<cfif isdefined("project_id") AND len(#project_id#) gt 0>
			<cfif #basJoin# does not contain " projAccn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn projAccn ON 
				(cataloged_item.accn_id = projAccn.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " project_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN project_trans ON 
				(projAccn.transaction_id = project_trans.transaction_id)">
			</cfif>
			<cfset basQual = " #basQual# AND project_trans.project_id = #project_id#">
			<cfset mapurl = "#mapurl#&project_id=#project_id#">
		</cfif>
		
		<cfif isdefined("loan_project_name") AND len(#loan_project_name#) gt 0>
			<cfif #basJoin# does not contain " specimen_part ">
				<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
				(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
			</cfif>
			<cfif #basJoin# does not contain " loan_item ">
				<cfset basJoin = " #basJoin# INNER JOIN loan_item ON 
				(specimen_part.collection_object_id = loan_item.collection_object_id)">
			</cfif>
			<cfif #basJoin# does not contain " project_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN project_trans ON 
				(loan_item.transaction_id = project_trans.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " project ">
				<cfset basJoin = " #basJoin# INNER JOIN project ON 
				(project_trans.project_id = project.project_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(project_name) like '%#ucase(loan_project_name)#%'">
			<cfset mapurl = "#mapurl#&loan_project_name=#loan_project_name#">
		</cfif>
		
		<cfif isdefined("project_name") AND len(#project_name#) gt 0>
			<cfif #basJoin# does not contain " projAccn ">
				<cfset basJoin = " #basJoin# INNER JOIN accn projAccn ON 
				(cataloged_item.accn_id = projAccn.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " project_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN project_trans ON 
				(projAccn.transaction_id = project_trans.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " project ">
				<cfset basJoin = " #basJoin# INNER JOIN project ON 
				(project_trans.project_id = project.project_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(project_name) like '%#ucase(project_name)#%'">
			<cfset mapurl = "#mapurl#&project_name=#project_name#">
		</cfif>
		
		<cfif isdefined("collecting_event_id") AND len(#collecting_event_id#) gt 0>
			<cfset basQual = " #basQual# AND flat.collecting_event_id IN ( #collecting_event_id# )">
			<cfset mapurl = "#mapurl#&collecting_event_id=#collecting_event_id#">
		</cfif>
		
		<cfif isdefined("locality_id") AND len(#locality_id#) gt 0>
			<cfset basQual = " #basQual# AND flat.locality_id = #locality_id#">
			<cfset mapurl = "#mapurl#&locality_id=#locality_id#">
		</cfif>
		
		<cfif isdefined("subject") AND len(#subject#) gt 0>
			<cfif #basJoin# does not contain " binary_object ">
				<cfset basJoin = " #basJoin# INNER JOIN binary_object ON 
				(cataloged_item.collection_object_id = binary_object.derived_from_cat_item)">
			</cfif>
			<cfset basQual = " #basQual# AND binary_object.subject = '#subject#'">
			<cfset mapurl = "#mapurl#&subject=#subject#">
		</cfif>
		
		<cfif isdefined("imgDescription") AND len(#imgDescription#) gt 0>
			<cfif #basJoin# does not contain " binary_object ">
				<cfset basJoin = " #basJoin# INNER JOIN binary_object ON 
				(cataloged_item.collection_object_id = binary_object.derived_from_cat_item)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(binary_object.description) LIKE '%#ucase(description)#%'">
			<cfset mapurl = "#mapurl#&imgDescription=#imgDescription#">
		</cfif>
		
		<cfif isdefined("binary_object_made_by_id") AND len(#binary_object_made_by_id#) gt 0>
			<cfif #basJoin# does not contain " binary_object ">
				<cfset basJoin = " #basJoin# INNER JOIN binary_object ON 
				(cataloged_item.collection_object_id = binary_object.derived_from_cat_item)">
			</cfif>
			<cfset basQual = " #basQual# AND binary_object.made_agent_id = #binary_object_made_by_id#">
			<cfset mapurl = "#mapurl#&binary_object_made_by_id=#binary_object_made_by_id#">
		</cfif>
	
		<cfif isdefined("onlyImages") AND len(#onlyImages#) gt 0>
			<cfif #basJoin# does not contain " binary_object ">
				<cfset basJoin = " #basJoin# INNER JOIN binary_object ON 
				(cataloged_item.collection_object_id = binary_object.derived_from_cat_item)">
			</cfif>
		</cfif>
		<cfif isdefined("permit_issued_by") AND len(#permit_issued_by#) gt 0>
			<cfset mapurl = "#mapurl#&permit_issued_by=#permit_issued_by#">
			<cfif #basJoin# does not contain " permit_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
				(cataloged_item.accn_id = permit_trans.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " permit ">
				<cfset basJoin = " #basJoin# INNER JOIN permit ON 
				(permit_trans.permit_id = permit.permit_id)">
			</cfif>
			<cfif #basJoin# does not contain " permit_issued ">
				<cfset basJoin = " #basJoin# INNER JOIN agent_name permit_issued ON 
				(permit.issued_by_agent_id = permit_issued.agent_id)">
			</cfif>
			<cfset basQual = " #basQual# AND upper(permit_issued.agent_name) like '%#ucase(permit_issued_by)#%'">
		</cfif>
		<cfif isdefined("permit_issued_to") AND len(#permit_issued_to#) gt 0>
			<cfset mapurl = "#mapurl#&permit_issued_to=#permit_issued_to#">
			<cfif #basJoin# does not contain " permit_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
				(cataloged_item.accn_id = permit_trans.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " permit ">
				<cfset basJoin = " #basJoin# INNER JOIN permit ON 
				(permit_trans.permit_id = permit.permit_id)">
			</cfif>
			<cfif #basJoin# does not contain " permit_to ">
				<cfset basJoin = " #basJoin# INNER JOIN agent_name permit_to ON 
				(permit.issued_by_agent_id = permit_to.agent_id)">
			</cfif>
			<cfset basWhere = " #basWhere# AND permit.issued_to_agent_id = permit_to.agent_id">
			<cfset basQual = " #basQual# AND upper(permit_to.agent_name) like '%#ucase(permit_issued_to)#%'">
		</cfif>
		
		<cfif isdefined("permit_type") AND len(#permit_type#) gt 0>
		<cfset mapurl = "#mapurl#&permit_type=#permit_type#">
			<cfif #basJoin# does not contain " permit_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
				(cataloged_item.accn_id = permit_trans.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " permit ">
				<cfset basJoin = " #basJoin# INNER JOIN permit ON 
				(permit_trans.permit_id = permit.permit_id)">
			</cfif>
			<cfset basQual = " #basQual# AND permit_type='#replace(permit_type,"'","''","all")#'">
		</cfif>
		
		<cfif isdefined("permit_num") AND len(#permit_num#) gt 0>
			<cfset mapurl = "#mapurl#&permit_num=#permit_num#">
			<cfif #basJoin# does not contain " permit_trans ">
				<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
				(cataloged_item.accn_id = permit_trans.transaction_id)">
			</cfif>
			<cfif #basJoin# does not contain " permit ">
				<cfset basJoin = " #basJoin# INNER JOIN permit ON 
				(permit_trans.permit_id = permit.permit_id)">
			</cfif>
			<cfset basQual = " #basQual# AND permit_num='#permit_num#'">
		</cfif>
		
		<cfif isdefined("collecting_source") AND len(#collecting_source#) gt 0>
			<cfset mapurl = "#mapurl#&collecting_source=#collecting_source#">
			<cfset basQual = " #basQual# AND collecting_source='#collecting_source#'">
			<cfif #basJoin# does not contain " collecting_event ">
				<cfset basJoin = " #basJoin# INNER JOIN collecting_event ON 
				(cataloged_item.collecting_event_id = collecting_event.collecting_event_id)">
			</cfif>
		</cfif>
			
		<cfif isdefined("remark") AND len(#remark#) gt 0>
			<cfset mapurl = "#mapurl#&remark=#remark#">
			<cfset basQual = " #basQual# AND upper(flat.remarks) LIKE '%#ucase(remark)#%'">
		</cfif>
		
		<cfif isdefined("attributed_determiner_agent_id") AND len(#attributed_determiner_agent_id#) gt 0>
			<cfset mapurl = "#mapurl#&attributed_determiner_agent_id=#attributed_determiner_agent_id#">
			<cfif #basJoin# does not contain " attributes ">
				<cfset basJoin = " #basJoin# INNER JOIN attributes ON 
				(cataloged_item.collection_object_id = attributes.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND attributes.determined_by_agent_id = #attributed_determiner_agent_id#">
		</cfif>
		
		<cfif isdefined("attribute_type_1") AND len(#attribute_type_1#) gt 0>
			<cfset mapurl = "#mapurl#&attribute_type_1=#attribute_type_1#">
			<cfif #basJoin# does not contain " attributes_1 ">
				<cfset basJoin = " #basJoin# INNER JOIN attributes attributes_1 ON 
				(cataloged_item.collection_object_id = attributes_1.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND attributes_1.attribute_type = '#attribute_type_1#'">
			<cfif not isdefined("attOper_1")>
				<cfset attOper_1 = "like">
			</cfif>
			<cfset mapurl = "#mapurl#&attOper_1=#attOper_1#">
			<cfif isdefined("attribute_value_1") and len(#attribute_value_1#) gt 0>
				<cfset mapurl = "#mapurl#&attribute_value_1=#attribute_value_1#">
				<cfset attribute_value_1 = #replace(attribute_value_1,"'","''","all")#>
				<cfif #attOper_1# is "like">
					<cfset basQual = " #basQual# AND upper(attributes_1.attribute_value) LIKE '%#ucase(attribute_value_1)#%'">
				<cfelseif #attOper_1# is "equals" >
					<cfset basQual = " #basQual# AND attributes_1.attribute_value = '#attribute_value_1#'">
				<cfelseif #attOper_1# is "greater" >
					<cfif isnumeric(#attribute_value_1#)>
						<cfset basQual = " #basQual# AND to_number(attributes_1.attribute_value) > #attribute_value_1#">
					<cfelse>
					  	<font color="#FF0000" size="+2">
							You tried to search for attribute values greater than a non-numeric value.
						</font>	 
						<cfabort>
					</cfif>
				<cfelseif #attOper_1# is "less" >
					<cfif isnumeric(#attribute_value_1#)>
						<cfset basQual = " #basQual# AND attributes_1.attribute_value < #attribute_value_1#">
					<cfelse>
						<font color="#FF0000" size="+2">
							You tried to search for attribute values less than a non-numeric value.</font>
					</cfif>
				</cfif>
			</cfif>
			<cfif isdefined("attribute_units_1") AND len(#attribute_units_1#) gt 0>
				<cfset basQual = " #basQual# AND attributes_1.attribute_units = '#attribute_units_1#'">
			</cfif>
		</cfif>
		
		<cfif isdefined("attribute_type_2") AND len(#attribute_type_2#) gt 0>
			<cfset mapurl = "#mapurl#&attribute_type_2=#attribute_type_2#">
			<cfif #basJoin# does not contain " attributes_2 ">
				<cfset basJoin = " #basJoin# INNER JOIN attributes attributes_2 ON 
				(cataloged_item.collection_object_id = attributes_2.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND attributes_2.attribute_type = '#attribute_type_2#'">
			<cfif not isdefined("attOper_2")>
				<cfset attOper_2 = "like">
			</cfif>
			<cfset mapurl = "#mapurl#&attOper_2=#attOper_2#">
			<cfif isdefined("attribute_value_2") and len(#attribute_value_2#) gt 0>
				<cfset mapurl = "#mapurl#&attribute_value_2=#attribute_value_2#">
				<cfset attribute_value_2 = #replace(attribute_value_2,"'","''","all")#>
				<cfif #attOper_2# is "like">
					<cfset basQual = " #basQual# AND upper(attributes_2.attribute_value) LIKE '%#ucase(attribute_value_2)#%'">
				<cfelseif #attOper_2# is "equals" >
					<cfset basQual = " #basQual# AND attributes_2.attribute_value = '#attribute_value_2#'">
				<cfelseif #attOper_2# is "greater" >
					<cfif isnumeric(#attribute_value_2#)>
						<cfset basQual = " #basQual# AND to_number(attributes_2.attribute_value) > #attribute_value_2#">
					<cfelse>
					  	<font color="#FF0000" size="+2">
							You tried to search for attribute values greater than a non-numeric value.
						</font>	 
						<cfabort>
					</cfif>
				<cfelseif #attOper_2# is "less" >
					<cfif isnumeric(#attribute_value_2#)>
						<cfset basQual = " #basQual# AND attributes_2.attribute_value < #attribute_value_2#">
					<cfelse>
						<font color="#FF0000" size="+2">
							You tried to search for attribute values less than a non-numeric value.</font>
					</cfif>
				</cfif>
			</cfif>
			<cfif isdefined("attribute_units_2") AND len(#attribute_units_2#) gt 0>
				<cfset basQual = " #basQual# AND attributes_2.attribute_units = '#attribute_units_2#'">
			</cfif>
		</cfif>
		
		<cfif isdefined("attribute_type_3") AND len(#attribute_type_3#) gt 0>
			<cfset mapurl = "#mapurl#&attribute_type_3=#attribute_type_3#">
			<cfif #basJoin# does not contain " attributes_3 ">
				<cfset basJoin = " #basJoin# INNER JOIN attributes attributes_3 ON 
				(cataloged_item.collection_object_id = attributes_3.collection_object_id)">
			</cfif>
			<cfset basQual = " #basQual# AND attributes_3.attribute_type = '#attribute_type_3#'">
			<cfif not isdefined("attOper_3")>
				<cfset attOper_3 = "like">
			</cfif>
			<cfset mapurl = "#mapurl#&attOper_3=#attOper_3#">
			<cfif isdefined("attribute_value_3") and len(#attribute_value_3#) gt 0>
				<cfset mapurl = "#mapurl#&attribute_value_3=#attribute_value_3#">
				<cfset attribute_value_3 = #replace(attribute_value_3,"'","''","all")#>
				<cfif #attOper_3# is "like">
					<cfset basQual = " #basQual# AND upper(attributes_3.attribute_value) LIKE '%#ucase(attribute_value_3)#%'">
				<cfelseif #attOper_3# is "equals" >
					<cfset basQual = " #basQual# AND attributes_3.attribute_value = '#attribute_value_3#'">
				<cfelseif #attOper_3# is "greater" >
					<cfif isnumeric(#attribute_value_3#)>
						<cfset basQual = " #basQual# AND to_number(attributes_3.attribute_value) > #attribute_value_3#">
					<cfelse>
					  	<font color="#FF0000" size="+3">
							You tried to search for attribute values greater than a non-numeric value.
						</font>	 
						<cfabort>
					</cfif>
				<cfelseif #attOper_3# is "less" >
					<cfif isnumeric(#attribute_value_3#)>
						<cfset basQual = " #basQual# AND attributes_3.attribute_value < #attribute_value_3#">
					<cfelse>
						<font color="#FF0000" size="+3">
							You tried to search for attribute values less than a non-numeric value.</font>
					</cfif>
				</cfif>
			</cfif>
			<cfif isdefined("attribute_units_3") AND len(#attribute_units_3#) gt 0>
				<cfset basQual = " #basQual# AND attributes_3.attribute_units = '#attribute_units_3#'">
			</cfif>
		</cfif>
		
  <cfif isdefined("exclCollObjId") and len(#exclCollObjId#) gt 0>
  		<!---- need to strip out any extra commas before we do anything ---->
		<cfset exclCollObjId = trim(exclCollObjId)>
		<cfif left(exclCollObjId,1) is ",">
			<cfset exclCollObjId = right(exclCollObjId,len(exclCollObjId)-1)>
		</cfif>
		<cfif right(exclCollObjId,1) is ",">
			<cfset exclCollObjId = left(exclCollObjId,len(exclCollObjId)-1)>
		</cfif>
		<cfset brkPnt=1>
		<CFLOOP CONDITION="brkPnt LESS THAN OR EQUAL TO 5">
			<cfset exclCollObjId = replace(exclCollObjId,",,",",","all")>
			<cfif #exclCollObjId# does not contain ",,">
				<cfset brkPnt=999999>
			</cfif>			
		</CFLOOP>
		<cfset basQual = " #basQual# AND cataloged_item.collection_object_id NOT IN (#exclCollObjId#)">
  </cfif>
  
  <cfif isdefined("institution_appearance") AND len(#institution_appearance#) gt 0>
	<cfquery name="whatInst" datasource="#web_user#">
		select collection_id from collection where institution_acronym='#institution_appearance#'
	</cfquery>
	<cfset goodCollIds = valuelist(whatInst.collection_id,",")>
	<cfset basQual = " #basQual# AND cataloged_item.collection_id  IN (#goodCollIds#)">
</cfif>	
	