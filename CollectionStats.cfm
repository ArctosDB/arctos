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
			collection,
			loan,
			trans
		WHERE 
			trans.transaction_id = loan.transaction_id AND
			loan.transaction_id = loan_item.transaction_id AND
			loan_item.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id 
		group by 
			to_char(trans_date, 'yyyy'),
			collection
	</cfquery>
	<cfquery name="distColl" dbtype="query">
		select 
			collection,
			collection_id
		from 
			Loans
		group by
			collection.collection,
			collection.collection_id,
			tdate,
	</cfquery>
	<h2>Specimen Loans By Year and Collection</h2>
	
	<cfloop query="distColl">
		<cfquery name="thisData" dbtype="query">
			select * from Loans where collection_id=#collection_id#
		</cfquery>
		<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" title="#thisData.Collection# Loans" 
			xaxistitle="Year Accessioned" yaxistitle="Number Specimens" show3d="yes" 
			backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" showxgridlines="yes">
			<cfchartseries type="bar" query="thisData" itemcolumn="tdate" valuecolumn="cnt" />
		</cfchart>
	</cfloop>
	

	
	
	<!---- number of  loan ---->
<cfquery name="Loans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
	collection.institution_acronym||' '||collection.collection_cde as collection_cde,
to_char(trans_date, 'yyyy') tdate,
count(distinct(loan.transaction_id)) as cnt
 FROM
			cataloged_item,
			loan_item,
			collection,
			loan,
			trans
		WHERE 
			trans.transaction_id = loan.transaction_id AND
			loan.transaction_id = loan_item.transaction_id AND
			loan_item.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id 
		group by to_char(trans_date, 'yyyy'),
collection.institution_acronym||' '||collection.collection_cde
  </cfquery>
	<cfquery name="distColl" dbtype="query">
		select distinct(collection_cde) from Loans
	</cfquery>
	<cfloop query="distColl">
		<cfset thisColl = #replace(collection_cde," ","_","all")#>
		<cfquery name="#thisColl#" dbtype="query">
			SELECT * from Loans where collection_cde='#collection_cde#'
		</cfquery>
	</cfloop>
	

	<hr>
	<div align="center">
    <font size="+2"><b>Loans By Year and Collection</b></font>
	<p>
  </div>


	<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" xaxistitle="Loan Year" yaxistitle="Number of Loans" show3d="yes" showlegend="yes" backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#">
		<cfloop query="distColl">
			<cfset thisColl = #replace(collection_cde," ","_","all")#>
			<cfchartseries type="bar" query="#thisColl#" itemcolumn="tdate" valuecolumn="cnt" serieslabel="#collection_cde#">
			</cfchartseries>
		</cfloop>
		
	</cfchart>	
	<!---------
	<!------------------------------->
	<hr>
	<div align="center">
    <font size="+2"><b>Specimens Loaned vs Specimens Cited</b></font>
	<p>
  </div>
	<!--- first, get all loans and their associated specimens --->
	<!--- legacy loan specimens --->
	<cfquery name="loanSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			loan_num_prefix||'.'||loan_num as loan
			, 
			coll_object.collection_object_id 
		FROM
			loan, 
			loan_item,
			coll_object
		where 
			loan.transaction_id = loan_item.transaction_id
			and loan_item.collection_object_id = coll_object.collection_object_id 
			and coll_object.coll_object_type = 'CI'
	</cfquery>
	<!--- loaned parts ---->
	<cfquery name="loanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			loan_num_prefix||'.'||loan_num as loan,
			 specimen_part.derived_from_cat_item AS collection_object_id 
		FROM
		loan, loan_item,
		coll_object,
		specimen_part
		where loan.transaction_id = loan_item.transaction_id
		and loan_item.collection_object_id = coll_object.collection_object_id and
		coll_object.coll_object_type <> 'CI' AND
		coll_object.collection_object_id = specimen_part.collection_object_id		
	</cfquery>
	<!---- combine these results sets --->
		<cfset allLoanSpec = querynew("loan,collection_object_id")>
		<cfset newrows = queryaddrow(allLoanSpec, 1)>
		<cfset i=1>
		<cfloop query="loanSpec">
			<cfset newrows = queryaddrow(allLoanSpec, 1)>
			<cfset temp = QuerySetCell(allLoanSpec, "collection_object_id", "#collection_object_id#", #i#)>
			<cfset temp = QuerySetCell(allLoanSpec, "loan", "#loan#", #i#)>
			<cfset i=#i#+1>
		</cfloop>
		<cfset i=1>
		<cfloop query="loanItem">
			<cfset newrows = queryaddrow(allLoanSpec, 1)>
			<cfset temp = QuerySetCell(allLoanSpec, "collection_object_id", "#collection_object_id#", #i#)>
			<cfset temp = QuerySetCell(allLoanSpec, "loan", "#loan#", #i#)>
			<cfset i=#i#+1>
		</cfloop>
	<!--- get citations --->
	<cfquery name="cit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT collection_object_id FROM citation
	</cfquery>
	<!--- combine the results sets ---->
	<cfquery name="LoanCit" dbtype="query">
		SELECT
			count(cit.collection_object_id) as cnt,
		 loan
		FROM
			allLoanSpec,
			cit
		WHERE
			allLoanSpec.collection_object_id = cit.collection_object_id
		GROUP BY
			loan
	</cfquery>
	<cfset loanList = ''>
	<cfloop query="LoanCit">
		<cfif len(#loanList#) is 0>
			<cfset loanList = "'#loan#'">
		  <cfelse>
		  	<cfset loanList = "#loanList#,'#loan#'">
		</cfif>
	</cfloop>
	<cfset sql="select 
			to_number(loan_num_prefix||'.'||loan_num) as loan, 
			count(loan_item.collection_object_id) as numLoaned
		FROM
			loan, loan_item
		WHERE
			loan.transaction_id = loan_item.transaction_id AND
			loan_num_prefix||'.'||loan_num IN (#loanList#)
		GROUP BY loan_num_prefix||'.'||loan_num">
	<cfquery name="numBorrowed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfquery name="allLoan" dbtype="query">
		SELECT LoanCit.loan as loan,
		cnt,
		numLoaned
		FROM
		LoanCit,
		numBorrowed
		WHERE
		LoanCit.loan = numBorrowed.loan
	</cfquery>
	<cfquery name="distLoanNumber" dbtype="query">
		select distinct(loan) as dLoan from allLoan
		order by loan
	</cfquery>
	<cfloop query="distLoanNumber">
		<cfset thisName = "q#replace(dloan,'.','_','all')#">
		<cfquery name="#thisName#" dbtype="query">
			select * from allLoan where loan = #dloan#
		</cfquery>
		
	</cfloop>
	<!---- new stuff ---->
	<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" xaxistitle="Specimens Loaned" yaxistitle="Number Citations" show3d="no" showlegend="yes" backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" seriesplacement="stacked" showxgridlines="yes" showygridlines="yes">
		
		<cfloop query="distLoanNumber">
		<cfset thisName = "q#replace(dloan,'.','_','all')#">
			<cfchartseries type="scatter" query="#thisName#" itemcolumn="numLoaned" valuecolumn="cnt" serieslabel="#dLoan#">
			</cfchartseries>
		</cfloop>
			
		
		
  </cfchart>	
	<!---------------------------->
	---->
	
	<cfquery name="Citation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
			count(citation.collection_object_id) as cnt, 
			collection.institution_acronym||' '||collection.collection_cde as collection_cde
		FROM
			cataloged_item,
			citation,
			collection
		WHERE 
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id 
		GROUP BY collection.institution_acronym||' '||collection.collection_cde	
	</cfquery>
	<cfquery name="distColl" dbtype="query">
		select distinct(collection_cde) from Citation
	</cfquery>
	<cfloop query="distColl">
		<cfset thisColl = #replace(collection_cde," ","_","all")#>
		<cfquery name="#thisColl#" dbtype="query">
			SELECT * from Citation where collection_cde='#collection_cde#'
		</cfquery>
	</cfloop>
	
<hr>
<div align="center">
    <font size="+2"><b>Specimen Citations by Collection</b></font>
	<p>
  </div>

<cfset chartType = "bar">
<p>Chart Type: #chartType#</p>
	<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" xaxistitle="Collection" yaxistitle="Citations" show3d="yes" showlegend="yes" backgroundcolor="#bgcolor#" databackgroundcolor="#databgcolor#" seriesplacement="stacked">
		<cfloop query="distcoll">
			<cfset thisColl = #replace(collection_cde," ","_","all")#>
			
			<cfchartseries type="#chartType#" query="#thisColl#" itemcolumn="collection_cde" valuecolumn="cnt" serieslabel="#collection_cde#">
			</cfchartseries>
		</cfloop>
		
  </cfchart>	

<hr>
<div align="center">
    <font size="+2"><b>Specimens with GenBank sequence accessions</b></font>
	<p>
  </div>

<cfquery name="genbank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
			count(coll_obj_other_id_num.collection_object_id) as cnt, 
			collection.institution_acronym||' '||collection.collection_cde as collection_cde
		FROM
			cataloged_item,
			coll_obj_other_id_num,
			collection
		WHERE 
			coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id AND
			coll_obj_other_id_num.other_id_type='GenBank' AND
			cataloged_item.collection_id = collection.collection_id 
		GROUP BY collection.institution_acronym||' '||collection.collection_cde	
</cfquery>
<cfset chartType = "bar">
	<cfchart chartwidth="800" chartheight="500" sortxaxis="yes" xaxistitle="Collection" yaxistitle="Genbank Sequence Accessions" show3d="yes" showlegend="yes" databackgroundcolor="#databgcolor#" backgroundcolor="#databgcolor#">
		<cfchartseries type="#chartType#" query="genbank" itemcolumn="collection_cde" valuecolumn="cnt">
			</cfchartseries>
  </cfchart>	
  
  
 
</cfoutput>
<cfinclude template="/includes/_footer.cfm">