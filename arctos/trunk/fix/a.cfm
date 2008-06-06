<cfquery name="d" datasource="#Application.web_user#">
select
			cataloged_item.collection_object_id,
			cat_num,
			scientific_name,
			state_prov,
			country,
			quad,
			county,
			island,
			sea,
			feature,
			spec_locality,
			'test' Coordinates,
			concatColl(cataloged_item.collection_object_id) as collectors,
			ConcatAttributeValue(cataloged_item.collection_object_id,'sex') as sex,
			concatotherid(cataloged_item.collection_object_id) as other_ids,
			concatparts(cataloged_item.collection_object_id) as parts,
			verbatim_date,
			accn_number,
			CONCATATTRIBUTE(cataloged_item.collection_object_id) attributes
		FROM
			cataloged_item,
			identification,
			collecting_event,
			locality,
			geog_auth_rec,
			accepted_lat_long,
			accn
		where
			cataloged_item.collection_object_id = identification.collection_object_id and
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
			collecting_event.locality_id = locality.locality_id and
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.locality_id = accepted_lat_long.locality_id (+) and
			cataloged_item.accn_id=accn.transaction_id and
			accepted_id_fg=1 AND 
			cataloged_item.collection_object_id IN (514750,514756,2318419,2627207,1757973,2291559,2274437,2279418,2591330,2494874,516404,2627199,537906,2420764,2291565,307533,1757986,279798,517436,1,537684,2279415,514768,307531,2279400,540778,65967,2274441,764386,2318423,2494864,2588314,2274439,2494868,531870,2274443,2593671,2627201,525396,514765,764396,2494856,539064,2291562,2593421,2588318,764355,540776,2275167,250477,517556,538348,540794,478388,517890,2494862,2593415,516396,540786,2318425,2275371,2291296,67022,6,517842,2291291,514753,2275173,764394,2279421,2627211,2591014,250510,764398,2292327,514759,2274435,2593412,519200,538128,2593418,2279427,56055,478400,2279424,2,67040,532350,2291571,60638,2275169,533288,2591010,4,2494872,516390,2279412,529780,2274445,478392,2494870,307524,478398,540788,2593409,5,2591182,764392,2591012,2275175,2588302,1757966,279719,521340,2591008,2627224,2798156,307529,2274429,1757969,2494860,514762,307535,2274447,516388,279758,518084,2494866,2627217,2376721,8,2591180,2588316,2588320,2593404,2588306,764388,478394,519202,2588308,514771,2588322,539066,2274433,1757971,2588312,2591388,516398,2279406,540790,2591404,2627209,518082,516402,2279409,540792,67041,2593674,534276,2279403,2318417,478390,65968,540780,540784,517832,538778,514777,478402,517766,66840,517870,279814,514774,516386,478406,1757963,523386,540782,7,2318427,2275163,764358,2591236,1757990,3,516394,2318415,2588304,2291556,1757977,2494858,2275373,2798154,536400,538562,2593335,2291293,2274431,478396,2627213,1757981,516400,2275165,2627203,764390,9,10,2593406,478404,532562,516392,1757984,2627222,2376723,517912,2318421,2291568,764400)
</cfquery>
<!---
		<cfdump var=#d#>

--->
<cfset gAr = ArrayNew(1)>
	<cfset sAr = ArrayNew(1)>
	<cfset idAr = ArrayNew(1)>
	<cfset cAr = ArrayNew(1)>	
	<cfset aAr = ArrayNew(1)>
	<cfset i=1>
	<cfloop query="d">
		<cfset geog = "">
		<cfif #state_prov# is "Alaska">
			<cfset geog = "USA: Alaska">
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
				<cfif #country# is "United States">
					<cfset geog = "USA: ">
				</cfif>
				<cfset geog = "#country#: ">
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
		<cfset geog=replace(geog,": , ",": ","all")>
		<cfset gAr[i] = #geog#>
	
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
		<cfset sAr[i] = #sexcode#>
		
		<cfset idNum = "">
		<cfset af = "">
		<cfloop list="#other_ids#" index="val" delimiters=";">
			<cfif #val# contains "Field Num=">
				<cfset idNum = "Field##: #replace(val,"Field Num=","")#">
			</cfif>
			<cfif #val# contains "AF=">
				<cfset af = "#replace(val,"="," ")#">
			</cfif>
		</cfloop>
		<cfset idAr[i] = #idNum#>
				
		
		<cfif #collectors# contains ",">
			<Cfset spacePos = find(",",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		<cfset cAr[i] = #collectors#>
		
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
			

		<cfloop list="#attributes#" index="attind" delimiters=";">
			attind: #attind#<br>
			<cfset sPos=find(attind,":")>
			<cfset att=left(attind,sPos)>
			<cfset aVal=right(attind,len(attind)-sPos)>
			
			<cfif #att# is "total length">
				<cfset totlen = "#aVal#">
			</cfif>
			<cfif #att# is "tail length">
				<cfset taillen = "#aVal#">
			</cfif>
			<cfif #att# is "hind foot with claw">
				<cfset hf = "#aVal#">
			</cfif>
			<cfif #att# is "ear from notch">

				<cfset efn = "#aVal#">
			</cfif>
			<cfif #att# is "weight">
				<cfset weight = "#aVal#">
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
					<cfset meas = "#meas##efn_val#=">
				<cfelse>
					<cfset meas = "#meas##efn_val# #efn_Units#=">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X=">
			</cfif>
			
			<cfif len(#weight#) gt 0>
				<cfset meas = "#meas##weight_val# #weight_Units#">
			<cfelse>
				<cfset meas="#meas#X">
			</cfif>
			<cfset aAr[i] = #meas#>
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		<cfset stripParts = "">
		<cfset tiss = "">
		<cfloop list="#parts#" delimiters=";" index="p">
			<cfif #p# contains "(frozen)">
				<cfset tiss="tissues (frozen)">
			<cfelseif #p# does not contain "ethanol">
				<cfif len(#stripParts#) is 0>
					<cfset stripParts = #p#>
				<cfelse>
					<cfset stripParts = "#stripParts#; #p#">
				</cfif>
			</cfif>
		</cfloop>
		<cfset accn = replace(accn_number,".Mamm","","all")>
		<cfif len(#tiss#) gt 0>
			<cfset stripParts = "#stripParts#; #tiss#">
		</cfif>
		<cfif left(stripParts,2) is "; ">
			<cfset stripParts = right(stripParts,len(stripParts) - 2)>
		</cfif>
		<cfset thisDate = "">
		<cftry>
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
			<cfset i=i+1>
		</cfloop>
		<cfset temp=queryAddColumn(d,"locality","VarChar",lAr)>
		<cfset temp=queryAddColumn(d,"sexcode","VarChar",sAr)>
		<cfset temp=queryAddColumn(d,"idNum","VarChar",idAr)>
		<cfset temp=queryAddColumn(d,"collectors","VarChar",cAr)>	
		
		<cfdump var=#d#>