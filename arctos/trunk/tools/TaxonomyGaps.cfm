<cfinclude template="/includes/_header.cfm">
<cfset title="Taxonomy is a mess">
<cfif not isdefined("limit")>
	<cfset limit=1000>
</cfif>
<cfif not isdefined("lterm")>
	<cfset lterm="GENUS">
</cfif>
<cfif not isdefined("hterm")>
	<cfset hterm="FAMILY">
</cfif>
<cfif not isdefined("collection_id")>
	<cfset collection_id=''>
</cfif>
<cfif not isdefined("nullstuff")>
	<cfset nullstuff='phylclass,phylorder,family'>
</cfif>
<cfset taxaFields="phylclass,phylorder,family,nomenclatural_code,kingdom">
<cfif not isdefined("taxaReturns")>
	<cfset taxaReturns=taxaFields>
</cfif>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_id,collection from collection order by collection
</cfquery>
<cfset taxaRanks="PHYLCLASS,PHYLORDER,SUBORDER,FAMILY,SUBFAMILY,GENUS,SUBGENUS,SPECIES,SUBSPECIES,SCIENTIFIC_NAME,TRIBE,INFRASPECIFIC_RANK,PHYLUM,KINGDOM,SUBCLASS,SUPERFAMILY">
<script>
	function showOptions(v) {
		document.getElementById('gap').style.display='none';
		document.getElementById('higherCrash').style.display='none';
		if(v=='gap'){
			document.getElementById('gap').style.display='block';
		}
		if(v=='higherCrash'){
			document.getElementById('higherCrash').style.display='block';
		}	
	}
</script>
<cfoutput>	
	<form name="cf" method="get" action="TaxonomyGaps.cfm">
		<label for="action">Action</label>
		<select name="action" id="action" onchange="showOptions(this.value);";>
			<option value=""></option>
			<option <cfif action is "gap"> selected="selected" </cfif> 
				value="gap">Missing values</option>
			<option <cfif action is "funkyChar"> selected="selected" </cfif> 
				value="funkyChar">scientific name contains funky characters</option>
			<option <cfif action is "higherCrash"> selected="selected" </cfif> 
				value="higherCrash">Higher Taxonomy crash</option>
		</select>
		<div id="higherCrash" style="display:none;">
			<label for="lterm">Term....</label>
			<select name="lterm" id="lterm">
				<cfloop list="#taxaRanks#" index="i">
					<option value="#i#" <cfif lterm is i>selected="selected"</cfif>>#i#</option>
				</cfloop>
			</select>
			<label for="hterm">has multiple values under....</label>
			<select name="hterm" id="hterm">
				<cfloop list="#taxaRanks#" index="i">
					<option value="#i#" <cfif hterm is i>selected="selected"</cfif>>#i#</option>
				</cfloop>
			</select>
		</div>
		<div id="gap" style="display:none;">
			<table border>
				<tr>
					<td>Require one of to be NULL</td>
					<td>Return</td>
				</tr>
				<cfloop list="#taxaFields#" index="i">
					<tr>
						<td>
							#i#:<input <cfif listfindnocase(nullstuff,i)> checked="checked"</cfif>
								type="checkbox" name="nullstuff" value="#i#">
						</td>
						<td>
							#i#:<input <cfif listfindnocase(taxaReturns,i)> checked="checked"</cfif>
								type="checkbox" name="taxaReturns" value="#i#">
						</td>
					</tr>
				</cfloop>
			</table>			
		</div>
		<label for="limit">Row Limit</label>
		<select name="limit" id="limit">
			<option <cfif limit is 100> selected="selected" </cfif> 
				value="1000">100</option>
			<option <cfif limit is 1000> selected="selected" </cfif> 
				value="1000">1000</option>
			<option <cfif limit is 2000> selected="selected" </cfif> 
				value="2000">2000</option>
			<option <cfif limit is 5000> selected="selected" </cfif> 
				value="5000">5000</option>					
			<option <cfif limit is 10000> selected="selected" </cfif> 
				value="10000">10000</option>
		</select>
		<label for="collection_id">Collection</label>
		<select name="collection_id" id="limit">
			<option <cfif collection_id is ''> selected="selected" </cfif> 
				value="">Ignore</option>
			<option <cfif collection_id is '0'> selected="selected" </cfif> 
				value="0">Used by any collection</option>
			<option <cfif collection_id is '-1'> selected="selected" </cfif> 
				value="-1">Not used by any collection</option>
			<cfset thisCID=collection_id>
			<cfloop query="ctcollection">
				<option <cfif thisCID is ctcollection.collection_id> selected="selected" </cfif> 
					value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		<br><input type="submit" value="Go">
	</form>
	<script>
		showOptions('#action#');
	</script>
</cfoutput>
<!------------------------------------------------------------------->
<cfif action is "higherCrash">
	<cfoutput>
		<cfquery name="termCrash" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from (
				select
					a.nomenclatural_code,a.#lterm# l,a.#hterm# h
				from
					(select nomenclatural_code,#lterm#,#hterm# from taxonomy group by nomenclatural_code,#lterm#,#hterm#) a,
					(select nomenclatural_code,#lterm#,#hterm# from taxonomy group by nomenclatural_code,#lterm#,#hterm#) b
				where
					a.#lterm#=b.#lterm# and
					a.#hterm#!=b.#hterm#
				group by
					a.nomenclatural_code,a.#lterm#,a.#hterm#
				order by 
					a.#lterm#,a.#hterm#,a.nomenclatural_code
			) where rownum<=#limit#
		</cfquery>
		<table border>
			<tr>
				<td>#lterm#</td>
				<td>#lterm#</td>
				<td>nomenclatural_code</td>
			</tr>
			<cfloop query="termCrash">
				<tr>
					<td>
						<a href="/TaxonomyResults.cfm?#lterm#==#l#">#l#</a>
					</td>
					<td>
						<a href="/TaxonomyResults.cfm?#hterm#==#h#">#h#</a>
					</td>
					<td>#nomenclatural_code#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif action is "funkyChar">
	<cfoutput>
		<cfquery name="ctINFRASPECIFIC_RANK" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select INFRASPECIFIC_RANK from ctINFRASPECIFIC_RANK
			where infraspecific_rank in ('forma','subsp.','var.')
		</cfquery>
		<hr> Showing the top #limit# records which have characters other than:
		<ul>
			<li>A-Za-z (upper or lower case Roman characters)</li>
			<li>[a-z]-[a-z] (lower-case character followed by a dash followed by another lower-case character)</li>
			<li>&##215; (hybrid or multiplication character)</li>
			<li>
				Unstoopidified values in ctinfraspecific_rank
				<ul>
					<cfloop query="ctINFRASPECIFIC_RANK">
						<li>#INFRASPECIFIC_RANK#</li>
					</cfloop>
				</ul>
			</li>
		</ul>
		Note: Combinations are goofy. Some records which have >1 excluded characters show up here anyway. 
		"Orchis &##215; semisaccata nothosubsp. murgiana" was valid as of this writing, but still makes the list. Ignore it.
		<cfset s="select 
				taxonomy.taxon_name_id,
				regexp_replace(taxonomy.scientific_name, '([^a-zA-Z ])','<b>\1</b>') craps,
				count(identification_taxonomy.identification_id) used">
		<cfset f="from 
				taxonomy,
				identification_taxonomy">
		<cfif len(collection_id) is 0 or collection_id is -1>
			<cfset w="where taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id (+) and">
		<cfelse>
			<cfset w="where taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id and">
		</cfif>
		
		<cfloop query="ctINFRASPECIFIC_RANK">
			<cfset w=w&" regexp_like(regexp_replace(regexp_replace(taxonomy.scientific_name, ' #INFRASPECIFIC_RANK# ', ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and"> 
		</cfloop>
		<cfset w=w&" regexp_like(regexp_replace(regexp_replace(taxonomy.scientific_name, chr(50071), ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') ">
		<cfif len(collection_id) gt 0 and collection_id gt 0>
			<cfset f= f & ",identification,cataloged_item">
			<cfset w=w & " and identification_taxonomy.identification_id=identification.identification_id and
					identification.collection_object_id=cataloged_item.collection_object_id and
					cataloged_item.collection_id=#collection_id#">
		<cfelseif collection_id is -1>
			<cfset w=w & " and identification_taxonomy.identification_id is null">
		</cfif>
		<cfset sql="select * from (" & s & ' ' & f & ' ' & w & ' group by
				taxonomy.taxon_name_id,
				taxonomy.scientific_name
			order by taxonomy.scientific_name) where rownum < #limit#'>
			
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#			
		</cfquery>
		<table border>
			<tr>
				<td>Scientific Name</td>
				<td>NumIds</td>
			</tr>
			<cfloop query="md">
				<tr>
					<td>
					<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#craps#</a>
					</td>
					<td>#used#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif action is "gap">
	<cfoutput>
		<cfset s="select taxonomy.taxon_name_id, taxonomy.scientific_name,#taxaReturns#">
		<cfset f=" from taxonomy ">
		<cfset w=" where (">
		<cfset i=1>
		<cfloop list="#nullstuff#" index="n">
			<cfset w=w & " #n# is null ">
			<cfif i lt listlen(nullstuff)>
				<cfset w=w & " OR ">
			</cfif>
			<cfset i=i+1>
		</cfloop>
		<cfset w=w & " ) ">
		<cfif collection_id is 0><!--- used by any collection --->
			<cfset f=f & ",identification_taxonomy">
			<cfset w=w & " AND taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id ">
		<cfelseif collection_id is -1>
			<cfset f=f & ",identification_taxonomy">
			<cfset w= w & " AND taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id (+) 
					and identification_taxonomy.identification_id is null ">
		<cfelseif len(collection_id) gt 0 and collection_id gt 0>
			<cfset f=f & ",identification_taxonomy,identification,cataloged_item">
			<cfset w=w & " and taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id and
					identification_taxonomy.identification_id=identification.identification_id and
					identification.collection_object_id=cataloged_item.collection_object_id and
					cataloged_item.collection_id=#collection_id#">
		</cfif>
		<cfset sql="select * from ( " & s & f & w & ' group by taxonomy.taxon_name_id, taxonomy.scientific_name,#taxaReturns#
				order by taxonomy.scientific_name) where rownum < #limit#'>
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#			
		</cfquery>
		
		<table border>
			<tr>
				<td>Scientific Name</td>
				<cfloop list="#taxaReturns#" index="n">
					<td>#n#</td>
				</cfloop>
			</tr>
			<cfloop query="md">
				<tr>
					<td>
					<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
					</td>
					<cfloop list="#taxaReturns#" index="n">
						<td>#evaluate("md." & n)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">