<cfinclude template="/includes/_header.cfm">
<a href="compareEncumberedRecs.cfm?action=moveMedia">Move Media - do this before deleting</a>

<a href="compareEncumberedRecs.cfm?action=moveMediaISC">moveMediaISC - do this before deleting</a>


<script>
	function encumberThis(cid,eid){
		$.getJSON("/component/functions.cfc",
			{
				method : "encumberThis",
				cid : cid,
				eid : eid,
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				if (IsNumeric(r)) {
					var n=parseInt(r)
					$('#encbtn_' + n).addClass('red');
				} else {
					alert('An error occured! \n ' + r);
				}	
			}
		);		
	}
	function KeepTheFirst(lst){
		var lAry = lst.split(",");
		var eid=10000019;
		for (i = 0; i<lAry.length; i++) {
			var cid=lAry[i];
			encumberThis(cid,eid);
			$('#encbtn_' + cid).addClass('red');
		}
	}
	
	function FlagAll(lst){
		var lAry = lst.split(",");
		var eid=10000020;
		for (i = 0; i<lAry.length; i++) {
			var cid=lAry[i];
			encumberThis(cid,eid);
			$('#encbtn_' + cid).addClass('red');
		}	
	}
</script>

<cfif action is "nothing">

<cfset sql="
	SELECT distinct
		flat.collection,
		flat.cat_num,
		flat.collection_object_id as collection_object_id,
		flat.scientific_name,
		flat.higher_geog,
		flat.spec_locality,
		flat.verbatim_date,
		flat.BEGAN_DATE,
		flat.ended_date,
		concatotherid(flat.collection_object_id) other_ids,
		coll_obj_other_id_num.DISPLAY_VALUE alaac,
		flat.parts partString,
		flat.encumbrances encumbrances,
		flat.collectors,
		flat.dec_lat,
		flat.dec_long,
		getMediaBySpecimen ('cataloged_item',flat.collection_object_id) media
	FROM 
		flat,
		coll_obj_other_id_num
	WHERE 
		flat.collection_object_id = coll_obj_other_id_num.collection_object_id and
		OTHER_ID_TYPE='ALAAC' and				
		coll_obj_other_id_num.DISPLAY_VALUE in 
			(select 
				coll_obj_other_id_num.DISPLAY_VALUE
			from
				coll_obj_other_id_num
			where
				OTHER_ID_TYPE='ALAAC'
			having count(*) > 1
			group by 
				coll_obj_other_id_num.DISPLAY_VALUE
			)
			and flat.collection_object_id NOT IN (
				select collection_object_id from coll_object_encumbrance where encumbrance_id=10000020
			)			
	ORDER BY
		coll_obj_other_id_num.DISPLAY_VALUE
		">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfoutput>
	
<style>
	.match {
		color:green;
		}
	.nomatch {color:red;
		}
</style>
<cfquery name="dr" dbtype="query">
	select distinct(alaac) from data order by alaac
</cfquery>
	-dr.recordcount: #dr.recordcount#-#data.recordcount#
	<table border>
		<cfset i=1>
			<cfloop query="dr">
				<cfif i lt 101>
					<cfquery name="stoopid" dbtype='query'>
						select min(collection_object_id) collection_object_id from data where alaac='#alaac#'
					</cfquery>
					<cfquery name="recOne" dbtype="query">
						select * from data where
						collection_object_id=#stoopid.collection_object_id#
					</cfquery>
					
					<cfloop query="recOne">
						<cfquery name="recTwo" dbtype="query">
							select * from data where
							ALAAC='#ALAAC#'
							and collection_object_id <> #collection_object_id#
						</cfquery>
						<cfset allId=listappend(valuelist(recTwo.collection_object_id),recOne.collection_object_id)>
						<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
							<td>
								<div id="encbtn_#collection_object_id#">
									<span class="likeLink" 
										onclick="KeepTheFirst('#valuelist(recTwo.collection_object_id)#')">DeleteOthers</span>
									<br><span class="likeLink" onclick="FlagAll('#allId#')">FlagAndKeepAll</span>
									<br><span class="likeLink" onclick="encumberThis('#collection_object_id#','10000019')">DeleteThis</span>
								</div>
							</td>
							<td>
								<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#ALAAC#-#cat_num#</a>
							</td>
							<td>
								#media#
							</td>
							<td>#scientific_name#</td>
							<td>
								#higher_geog#
							</td>
							<td>#spec_locality#</td>
							<td>
								#verbatim_date# - 
								#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#
										- #dateformat(ended_date,"dd-mmm-yyyy")#
							</td>
							<td>#other_ids#</td>
							<td>#collectors#</td>
							<td>#encumbrances#</td>
						</tr>
						
						
		
						<cfloop query="recTwo">
							<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
								<td>
									<div id="encbtn_#collection_object_id#">
										<br><span class="likeLink" onclick="encumberThis('#collection_object_id#','10000019')">DeleteThis</span>
									</div>
								</td>
								<td>
									<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#ALAAC#-#cat_num#</a>
								</td> 
								<td>
									#media#
								</td>
								<td>
									<cfif scientific_name is recOne.scientific_name>
										<cfset c="match">
									<cfelse>
										<cfset c="nomatch">
									</cfif>
									<div class="#c#">#scientific_name#</div>
								</td>
								
								<td>
									<cfif higher_geog is recOne.higher_geog>
										<cfset c="match">
									<cfelse>
										<cfset c="nomatch">
									</cfif>
									<div class="#c#">#higher_geog#</div>
								</td>
								<td>#spec_locality#</td>
								<td>
									#verbatim_date# - 
									#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#
											- #dateformat(ended_date,"dd-mmm-yyyy")#
								</td>
								<td>#other_ids#</td>
								<td>#collectors#</td>
								<td>#encumbrances#</td>
							</tr>
						</cfloop>
					</cfloop>
					<cfset i=i+1>
							</cfif>

				</cfloop>
	</table>
</cfoutput>

</cfif>













<cfif action is "isc">

<cfset sql="
	SELECT distinct
		flat.collection,
		flat.cat_num,
		flat.collection_object_id as collection_object_id,
		flat.scientific_name,
		flat.higher_geog,
		flat.spec_locality,
		flat.verbatim_date,
		flat.BEGAN_DATE,
		flat.ended_date,
		concatotherid(flat.collection_object_id) other_ids,
		coll_obj_other_id_num.DISPLAY_VALUE alaac,
		flat.parts partString,
		flat.encumbrances encumbrances,
		flat.collectors,
		flat.dec_lat,
		flat.dec_long,
		getMediaBySpecimen ('cataloged_item',flat.collection_object_id) media
	FROM 
		flat,
		coll_obj_other_id_num
	WHERE 
		flat.collection_object_id = coll_obj_other_id_num.collection_object_id and
		OTHER_ID_TYPE='ISC: Ada Hayden Herbarium, Iowa State University' and				
		coll_obj_other_id_num.DISPLAY_VALUE in 
			(select 
				coll_obj_other_id_num.DISPLAY_VALUE
			from
				coll_obj_other_id_num
			where
				OTHER_ID_TYPE='ISC: Ada Hayden Herbarium, Iowa State University'
			having count(*) > 1
			group by 
				coll_obj_other_id_num.DISPLAY_VALUE
			)
			and flat.collection_object_id NOT IN (
				select collection_object_id from coll_object_encumbrance where encumbrance_id=10000020
			)			
	ORDER BY
		coll_obj_other_id_num.DISPLAY_VALUE
		">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfoutput>
	
<style>
	.match {
		color:green;
		}
	.nomatch {color:red;
		}
</style>
<cfquery name="dr" dbtype="query">
	select distinct(alaac) from data order by alaac
</cfquery>
	-dr.recordcount: #dr.recordcount#-#data.recordcount#
	<table border>
		<cfset i=1>
			<cfloop query="dr">
				<cfif i lt 101>
					<cfquery name="stoopid" dbtype='query'>
						select min(collection_object_id) collection_object_id from data where alaac='#alaac#'
					</cfquery>
					<cfquery name="recOne" dbtype="query">
						select * from data where
						collection_object_id=#stoopid.collection_object_id#
					</cfquery>
					
					<cfloop query="recOne">
						<cfquery name="recTwo" dbtype="query">
							select * from data where
							ALAAC='#ALAAC#'
							and collection_object_id <> #collection_object_id#
						</cfquery>
						<cfset allId=listappend(valuelist(recTwo.collection_object_id),recOne.collection_object_id)>
						<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
							<td>
								<div id="encbtn_#collection_object_id#">
									<span class="likeLink" 
										onclick="KeepTheFirst('#valuelist(recTwo.collection_object_id)#')">DeleteOthers</span>
									<br><span class="likeLink" onclick="FlagAll('#allId#')">FlagAndKeepAll</span>
									<br><span class="likeLink" onclick="encumberThis('#collection_object_id#','10000019')">DeleteThis</span>
								</div>
							</td>
							<td>
								<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#ALAAC#-#cat_num#</a>
							</td>
							<td>
								#media#
							</td>
							<td>#scientific_name#</td>
							<td>
								#higher_geog#
							</td>
							<td>#spec_locality#</td>
							<td>
								#verbatim_date# - 
								#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#
										- #dateformat(ended_date,"dd-mmm-yyyy")#
							</td>
							<td>#other_ids#</td>
							<td>#collectors#</td>
							<td>#encumbrances#</td>
						</tr>
						
						
		
						<cfloop query="recTwo">
							<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
								<td>
									<div id="encbtn_#collection_object_id#">
										<br><span class="likeLink" onclick="encumberThis('#collection_object_id#','10000019')">DeleteThis</span>
									</div>
								</td>
								<td>
									<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#ALAAC#-#cat_num#</a>
								</td> 
								<td>
									#media#
								</td>
								<td>
									<cfif scientific_name is recOne.scientific_name>
										<cfset c="match">
									<cfelse>
										<cfset c="nomatch">
									</cfif>
									<div class="#c#">#scientific_name#</div>
								</td>
								
								<td>
									<cfif higher_geog is recOne.higher_geog>
										<cfset c="match">
									<cfelse>
										<cfset c="nomatch">
									</cfif>
									<div class="#c#">#higher_geog#</div>
								</td>
								<td>#spec_locality#</td>
								<td>
									#verbatim_date# - 
									#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#
											- #dateformat(ended_date,"dd-mmm-yyyy")#
								</td>
								<td>#other_ids#</td>
								<td>#collectors#</td>
								<td>#encumbrances#</td>
							</tr>
						</cfloop>
					</cfloop>
					<cfset i=i+1>
							</cfif>

				</cfloop>
	</table>
</cfoutput>

</cfif>




<cfif action is "moveMedia">
	<cfoutput>
		<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				coll_object_encumbrance.collection_object_id,
				display_value
			from 
				coll_object_encumbrance,
				coll_obj_other_id_num
			where
				coll_object_encumbrance.collection_object_id=coll_obj_other_id_num.collection_object_id and
				other_id_type='ALAAC' and
				encumbrance_id=10000019
		</cfquery>
		<cftransaction>
		<cfloop query="b">
			<hr>
				badrec:#collection_object_id#==#display_value#
				<cfquery name="m" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select media_id from media_relations where media_relationship='shows cataloged_item' and
					related_primary_key=#collection_object_id#
				</cfquery>
				<cfif m.recordcount is 0>
					no media, just delete it
				<cfelse>
					<cfquery name="g" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select 
							collection_object_id 
						from 
							coll_obj_other_id_num
						where
							other_id_type='ALAAC' and
							collection_object_id!=#collection_object_id# and
							display_value='#display_value#'	and
							collection_object_id not in (
								select collection_object_id from coll_object_encumbrance where encumbrance_id=10000019
							)
					</cfquery>
					<cfif g.recordcount is 1>
						<cfquery name="mm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							update media_relations set related_primary_key=#g.collection_object_id# where
							media_relationship='shows cataloged_item' and
							related_primary_key=#collection_object_id#
						</cfquery>
						spiffy
					<cfelse>
						goddammit, something failed.
						<cfdump var=#g#>
					</cfif>
				</cfif>
				

			<hr>
			
		</cfloop>
		</cftransaction>
	</cfoutput>
</cfif>





<cfif action is "moveMediaISC">
	<cfoutput>
		<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				coll_object_encumbrance.collection_object_id,
				display_value
			from 
				coll_object_encumbrance,
				coll_obj_other_id_num
			where
				coll_object_encumbrance.collection_object_id=coll_obj_other_id_num.collection_object_id and
				other_id_type='ISC: Ada Hayden Herbarium, Iowa State University' and
				encumbrance_id=10000019
		</cfquery>
		<cftransaction>
		<cfloop query="b">
			<hr>
				badrec:#collection_object_id#==#display_value#
				<cfquery name="m" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select media_id from media_relations where media_relationship='shows cataloged_item' and
					related_primary_key=#collection_object_id#
				</cfquery>
				<cfif m.recordcount is 0>
					no media, just delete it
				<cfelse>
					<cfquery name="g" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select 
							collection_object_id 
						from 
							coll_obj_other_id_num
						where
							other_id_type='ISC: Ada Hayden Herbarium, Iowa State University' and
							collection_object_id!=#collection_object_id# and
							display_value='#display_value#'	and
							collection_object_id not in (
								select collection_object_id from coll_object_encumbrance where encumbrance_id=10000019
							)
					</cfquery>
					<cfif g.recordcount is 1>
						<cfquery name="mm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							update media_relations set related_primary_key=#g.collection_object_id# where
							media_relationship='shows cataloged_item' and
							related_primary_key=#collection_object_id#
						</cfquery>
						spiffy
					<cfelse>
						goddammit, something failed.
						<cfdump var=#g#>
					</cfif>
				</cfif>
				

			<hr>
			
		</cfloop>
		</cftransaction>
	</cfoutput>
</cfif>
