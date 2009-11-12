<cfinclude template="/includes/_header.cfm">
	<cfset title="Collection Statistics">
	<cfset bgcolor="##FFFFFF">
	<cfset databgcolor="##FFFFFF">
	
<cfoutput>	
 	<h2>Specimen Holdings</h2>
 	<cfquery name="SpecColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			collection.institution_acronym||' '||collection.collection_cde as collection_cde,
			count(cataloged_item.collection_object_id) as cnt
		 from 
			cataloged_item,
			collection
		WHERE 
			cataloged_item.collection_id = collection.collection_id
		group by 
			collection.institution_acronym||' '||collection.collection_cde
		ORDER BY cnt
 	</cfquery>
	<cfchart chartwidth="800" chartheight="500"  sortxaxis="no" xaxistitle="Collection" yaxistitle="Number Specimens" show3d="yes" backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" >
		<cfchartseries type="bar" query="SpecColl" itemcolumn="collection_cde" valuecolumn="cnt" seriescolor="##A0B3C5" />
	</cfchart>
		
	<cfquery name="AccnByCollYear" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			collection.collection_id,
			collection.collection,
			to_char(trans_date, 'yyyy') tdate,
			count(cataloged_item.collection_object_id) as cnt
 		from 
			cataloged_item,
			accn,
			trans,
			collection
		WHERE 
			cataloged_item.accn_id = accn.transaction_id and
			accn.transaction_id = trans.transaction_id and
			cataloged_item.collection_id = collection.collection_id
		group by 
			to_char(trans_date, 'yyyy'),
			collection.collection,
			collection.collection_id
		order by 
			tdate
	</cfquery>
	<cfquery name="distColl" dbtype="query">
		select 
			collection_id, 
			collection 
		from 
			AccnByCollYear
		group by 
			collection_id,
			collection
	</cfquery>
	<h2>
		Specimens Accessioned by Collection and Year
	</h2>
	<cfloop query="distColl">
		<cfquery name="thisData" dbtype="query">
			select * from AccnByCollYear where collection_id=#collection_id#
		</cfquery>
		<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" title="#thisData.Collection# Accessions" 
			xaxistitle="Year Accessioned" yaxistitle="Number Specimens" show3d="yes" 
			backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" showxgridlines="yes">
			<cfchartseries type="bar" query="thisData" itemcolumn="tdate" valuecolumn="cnt" />
		</cfchart>
	</cfloop>
	
	
	<cfquery name="Loans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			collection.collection,
			collection.collection_id,
			to_char(trans_date, 'yyyy') tdate,
			count(loan_item.collection_object_id) as cnt
 		FROM
			cataloged_item,
			loan_item,
			specimen_part,
			collection,
			loan,
			trans
		WHERE 
			trans.transaction_id = loan.transaction_id AND
			loan.transaction_id = loan_item.transaction_id AND
			loan_item.collection_object_id = specimen_part.collection_object_id AND
			specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			cataloged_item.collection_id = collection.collection_id 
		group by 
			collection.collection,
			collection.collection_id,
			to_char(trans_date, 'yyyy')
	</cfquery>
	<cfquery name="distColl" dbtype="query">
		select 
			collection,
			collection_id
		from 
			Loans
		group by
			collection,
			collection_id
	</cfquery>
	<h2>Specimen Loans By Year and Collection</h2>
	
	<cfloop query="distColl">
		<cfquery name="thisData" dbtype="query">
			select * from Loans where collection_id=#collection_id#
		</cfquery>
		<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" title="#thisData.Collection# Loans" 
			xaxistitle="Year" yaxistitle="Number Specimens" show3d="yes" 
			backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" showxgridlines="yes">
			<cfchartseries type="bar" query="thisData" itemcolumn="tdate" valuecolumn="cnt" />
		</cfchart>
	</cfloop>
	

	
	<cfquery name="Citation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
			count(citation.collection_object_id) as cnt, 
			collection.collection
		FROM
			cataloged_item,
			citation,
			collection
		WHERE 
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id 
		GROUP BY collection
	</cfquery>
	
	<h2>Citations by Collection</h2>


	<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" xaxistitle="Collection" yaxistitle="Citations" show3d="yes" showlegend="yes" backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" seriesplacement="stacked">
		<cfchartseries type="bar" query="Citation" itemcolumn="collection" valuecolumn="cnt" serieslabel="collection" />
  </cfchart>	
<h2>Specimens with GenBank sequence accessions</h2>

<cfquery name="genbank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
			count(coll_obj_other_id_num.collection_object_id) as cnt, 
			collection.collection
		FROM
			cataloged_item,
			coll_obj_other_id_num,
			collection
		WHERE 
			coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id AND
			coll_obj_other_id_num.other_id_type='GenBank' AND
			cataloged_item.collection_id = collection.collection_id 
		GROUP BY collection	
</cfquery>
	<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" xaxistitle="Collection" yaxistitle="Citations" show3d="yes" showlegend="yes" backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" seriesplacement="stacked">
		<cfchartseries type="bar" query="genbank" itemcolumn="collection" valuecolumn="cnt" serieslabel="collection" />
  </cfchart>	
  
  
 
</cfoutput>
<cfinclude template="/includes/_footer.cfm">