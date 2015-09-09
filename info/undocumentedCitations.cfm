<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Undocumented Citations">
<a href="undocumentedCitations.cfm?action=nothing">splash</a>

<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from collection order by guid_prefix
</cfquery>

<cfparam name="collectionid" default="">


<cfoutput>
	<cfif action is "nothing">
		<p>
			This form provides links to various things which may contain undocumented specimen usage.
		</p>

		<ul>
			<li>
				<a href="undocumentedCitations.cfm?action=projpub">Project Publications lacking Citations</a>
			</li>
			<li>
				<a href="undocumentedCitations.cfm?action=projpubdoi">Project Publications lacking DOI</a>
			</li>
			<li>
				<a href="undocumentedCitations.cfm?action=genbanknocite">Specimens with GenBank IDs and no citations</a>
			</li>
			<li>
				<a href="undocumentedCitations.cfm?action=genbanknoloan">Specimens with GenBank IDs and no loans</a>
			</li>
			<li>
				<a href="undocumentedCitations.cfm?action=citsnoloan">Specimens with Citations and no loans</a>
			</li>
		</ul>
	</cfif>





	<cfif action is "citsnoloan">
		<p>
			Find specimens which have Citations and do not have loan history.
		</p>
		<form name="f" method="get" action="undocumentedCitations.cfm">
			<input type="hidden" name="action" value="citsnoloan">
			<label for="collectionid">Collection</label>
			<select name="collectionid" size="1" id="collectionid">
				<option value=""></option>
					<cfloop query="ctcollection">
						<option <cfif collectionid is ctcollection.collection_id> selected="selected" </cfif>
							value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
					</cfloop>
				</select>
				<br><input type="submit" value="go">
		</form>
		<cfif len(collectionid) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct
				  guid
				from
				  flat,
				  citation
				where
				  flat.collection_object_id=citation.collection_object_id and
				  flat.COLLECTION_ID in (#collectionid#) and
				  flat.collection_object_id not in (
				      -- data loans
				      select collection_object_id from loan_item
				      -- real loans
				      union
				      select derived_from_cat_item from specimen_part,loan_item where specimen_part.collection_object_id=loan_item.collection_object_id
				    )
			</cfquery>
			<cfif d.recordcount is 0>
				<p>
					Nothing Found (yay!)
				</p>
			<cfelse>
				<table border id="t" class="sortable">
					<tr>
						<th>Specimen</th>
					</tr>
					<cfloop query="d">
						<tr>
							<td><a href="/guid/#guid#">#guid#</a></td>
						</tr>
					</cfloop>
				</table>
			</cfif>
		</cfif>
	</cfif>
	<!-------------------------------------------------------------------------------------------------->
	<cfif action is "genbanknocite">
		<p>
			Find specimens which have GenBank numbers and do not have citations.
		</p>
		<form name="f" method="get" action="undocumentedCitations.cfm">
			<input type="hidden" name="action" value="genbanknocite">
			<label for="collectionid">Collection</label>
			<select name="collectionid" size="1" id="collectionid">
				<option value=""></option>
					<cfloop query="ctcollection">
						<option <cfif collectionid is ctcollection.collection_id> selected="selected" </cfif>
							value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
					</cfloop>
				</select>
				<br><input type="submit" value="go">
		</form>
		<cfif len(collectionid) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct
				  guid
				from
				  flat,
				  coll_obj_other_id_num
				where
				  flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
				  other_id_type='GenBank' and
				  flat.COLLECTION_ID in (#collectionid#) and
				  flat.collection_object_id not in (select collection_object_id from citation)
				 order by
				 	guid
			</cfquery>
			<cfif d.recordcount is 0>
				<p>
					Nothing Found (yay!)
				</p>
			<cfelse>
				<table border id="t" class="sortable">
					<tr>
						<th>Specimen</th>
					</tr>
					<cfloop query="d">
						<tr>
							<td><a href="/guid/#guid#">#guid#</a></td>
						</tr>
					</cfloop>
				</table>
			</cfif>
		</cfif>
	</cfif>
	<!-------------------------------------------------------------------------------------------------->
	<cfif action is "projpubdoi">
		<p>
			Find publications which are associated with a project which is associated with a collection
			and which do not include DOI.
		</p>
		<form name="f" method="get" action="undocumentedCitations.cfm">
			<input type="hidden" name="action" value="projpubdoi">
			<label for="collectionid">Collection</label>
			<select name="collectionid" size="1" id="collectionid">
				<option value=""></option>
					<cfloop query="ctcollection">
						<option <cfif collectionid is ctcollection.collection_id> selected="selected" </cfif>
							value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
					</cfloop>
				</select>
				<br><input type="submit" value="go">
		</form>
		<cfif len(collectionid) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct
				  publication.publication_id,
				  publication.SHORT_CITATION
				from
				  publication,
				  project_publication,
				  project_trans,
				  trans,
				  collection
				where
				  publication.publication_id=project_publication.publication_id and
				  project_publication.project_id=project_trans.project_id and
				  project_trans.TRANSACTION_ID=trans.TRANSACTION_ID and
				  trans.COLLECTION_ID=collection.COLLECTION_ID and
				  collection.COLLECTION_ID in (#collectionid#) and
				  publication.doi is null
				order by
					short_citation
			</cfquery>
			<cfif d.recordcount is 0>
				<p>
					Nothing Found (yay!)
				</p>
			<cfelse>
				<table border id="t" class="sortable">
					<tr>
						<th>Publication</th>
					</tr>
					<cfloop query="d">
						<tr>
							<td><a href="/publication/#publication_id#">#SHORT_CITATION#</a></td>
						</tr>
					</cfloop>
				</table>
			</cfif>
		</cfif>
	</cfif>
	<!-------------------------------------------------------------------------------------------------->
	<cfif action is "projpub">
		<p>
			Find publications which are associated with a project which is associated with a collection
			and which do not contain citations.
		</p>
		<form name="f" method="get" action="undocumentedCitations.cfm">
			<input type="hidden" name="action" value="projpub">
			<label for="collectionid">Collection</label>
			<select name="collectionid" size="1" id="collectionid">
				<option value=""></option>
					<cfloop query="ctcollection">
						<option <cfif collectionid is ctcollection.collection_id> selected="selected" </cfif>
							value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
					</cfloop>
				</select>
				<br><input type="submit" value="go">
		</form>
		<cfif len(collectionid) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct
				  publication.publication_id,
				  publication.SHORT_CITATION
				from
				  publication,
				  project_publication,
				  project_trans,
				  trans,
				  collection,
				  citation
				where
				  publication.publication_id=project_publication.publication_id and
				  project_publication.project_id=project_trans.project_id and
				  project_trans.TRANSACTION_ID=trans.TRANSACTION_ID and
				  trans.COLLECTION_ID=collection.COLLECTION_ID and
				  collection.COLLECTION_ID in (#collectionid#) and
				  publication.publication_id=citation.publication_id (+) and
				  citation.PUBLICATION_ID is null
				order by
					short_citation
			</cfquery>
			<cfif d.recordcount is 0>
				<p>
					Nothing Found (yay!)
				</p>
			<cfelse>
				<table border id="t" class="sortable">
					<tr>
						<th>Publication</th>
					</tr>
					<cfloop query="d">
						<tr>
							<td><a href="/publication/#publication_id#">#SHORT_CITATION#</a></td>
						</tr>
					</cfloop>
				</table>
			</cfif>

		</cfif>
	</cfif>

</cfoutput>

<!-----------
<cfparam name="loanto" default="">
<cfparam name="loantype" default="">
<cfparam name="loanstatus" default="">
<cfparam name="citations" default="">
<cfparam name="itemsloaned" default="">








<cfquery name="ctLoanStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select loan_status from ctloan_status order by loan_status
</cfquery>
<cfquery name="ctLoanType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select loan_type from ctloan_type order by loan_type
</cfquery>
<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select loan_status from ctloan_status order by loan_status
</cfquery>


<cfoutput>
<form name="f" method="get" action="loanStats.cfm">
	<input type="hidden" name="action" value="srch">
	<label for="collectionid">Collection
						</label>
						<select name="collectionid" size="1" id="collectionid">
			<option value=""></option>
							<cfloop query="ctcollection">
								<option <cfif collectionid is ctcollection.collection_id> selected="selected" </cfif> value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
							</cfloop>
						</select>

	<label for="loanto">Loaned To Person</label>
	<input type="text" name="loanto" id="loanto" value="#loanto#">

		<label for="loantype">Loan Type</label>
		<select name="loantype" id="loantype" class="reqdClr">
			<option value=""></option>
			<cfloop query="ctLoanType">
				<option <cfif loantype is ctLoanType.loan_type> selected="selected" </cfif>value="#ctLoanType.loan_type#">#ctLoanType.loan_type#</option>
			</cfloop>
		</select>
		<label for="loanstatus">Loan Status</label>
		<select name="loanstatus" id="loanstatus" class="reqdClr">
			<option value=""></option>
			<cfloop query="ctLoanStatus">
				<option  <cfif loanstatus is ctLoanStatus.loan_status> selected="selected" </cfif> value="#ctLoanStatus.loan_status#">#ctLoanStatus.loan_status#</option>
			</cfloop>
		</select>
		<label for="citations">Citations</label>

		<select name="citations" id="citations" class="reqdClr">
			<option value="">whatever</option>
			<option <cfif citations is 0> selected="selected" </cfif> value="0">has none</option>
			<option <cfif citations is 1> selected="selected" </cfif> value="1">has some</option>
		</select>
			<label for="itemsloaned">Items Loaned</label>

		<select name="itemsloaned" id="itemsloaned" class="reqdClr">
			<option value="">whatever</option>
			<option <cfif itemsloaned is 0> selected="selected" </cfif> value="0">has none</option>
			<option <cfif itemsloaned is 1> selected="selected" </cfif> value="1">has some</option>
		</select>


</form>
<cfif action is "srch">
<cfquery name="loanData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
	guid_prefix,
	collection_id,
	TRANSACTION_ID,
	loan_number,
	loan_type,
	loaned_to,
	LOAN_STATUS,
	RETURN_DUE_DATE,
	TRANS_DATE,
	count(distinct(derived_from_cat_item)) CntCatNum,
	count(distinct(citationID)) cntCited,
	trans_remarks
	from (
		select
			guid_prefix,
			collection.collection_id,
			loan.TRANSACTION_ID,
			loan.loan_number,
			loan_type,
			concattransagent(loan.TRANSACTION_ID,'received by') loaned_to,
			LOAN_STATUS,
			RETURN_DUE_DATE,
			TRANS_DATE,
			specimen_part.derived_from_cat_item,
			citation.collection_object_id citationID,
			trans_remarks
		from
			loan,
			trans,
			loan_item,
			specimen_part,
			citation,
			collection
		where
			loan.transaction_id = trans.transaction_id and
			trans.collection_id=collection.collection_id and
			loan.transaction_id=loan_item.transaction_id (+) and
			loan_item.collection_object_id=specimen_part.collection_object_id (+) and
			specimen_part.derived_from_cat_item=citation.collection_object_id (+)	union
		select
			guid_prefix,
			collection.collection_id,
			loan.TRANSACTION_ID,
			loan.loan_number,
		loan_type,
			concattransagent(loan.TRANSACTION_ID,'received by') loaned_to,
			LOAN_STATUS,
			RETURN_DUE_DATE,
			TRANS_DATE,
			specimen_part.derived_from_cat_item,
			citation.collection_object_id citationID,
			trans_remarks
		from
			loan,
			trans,
			loan_item,
			specimen_part,
			citation,
			collection
		where
			loan.transaction_id = trans.transaction_id and
			trans.collection_id=collection.collection_id and
			loan.transaction_id=loan_item.transaction_id (+) and
			loan_item.collection_object_id=specimen_part.derived_from_cat_item (+) and
			loan_item.collection_object_id=citation.collection_object_id (+)
	)
	where 1=1
	<cfif len(loanto) gt 0>
		and upper(loaned_to) like '%#ucase(loanto)#%'
	</cfif>
	<cfif len(loantype) gt 0>
		and loan_type='#loantype#'
	</cfif>
	<cfif len(loanstatus) gt 0>
		and loan_status='#loanstatus#'
	</cfif>
	<cfif len(collectionid) gt 0>
		and collection_id=#collectionid#
	</cfif>
	<cfif len(citations) gt 0>
		<cfif citations is 0>
			and citationID is null
		<cfelse>
			and citationID is not null
		</cfif>
	</cfif>
	<cfif len(itemsloaned) gt 0>
		<cfif itemsloaned is 0>
			and derived_from_cat_item is null
		<cfelse>
			and derived_from_cat_item is not null
		</cfif>
	</cfif>
	group by
		guid_prefix,
		collection_id,
		TRANSACTION_ID,
		loan_number,
		loan_type,
		loaned_to,
		LOAN_STATUS,
		RETURN_DUE_DATE,
		TRANS_DATE,
		trans_remarks
</cfquery>


	<cfset clist="Collection,Loan,Type,LoanedTo,Status,TransDate,DueDate,ItemsLoaned,Citations,TransRemarks">

	<cfset fileDir = "#Application.webDirectory#">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "loan-citation-stats.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(ListQualify(clist,'"'));
	</cfscript>

	<h2>Loan Statistics</h2>
<div style="background-color:lightgray;font-size:small;padding:1em; width:50%; align:center;margin-left:3em;margin:1em;">
	Citations apply to cataloged items and do not reflect activity resulting from any particular loan.
	<p>
		Each line is one loan/collection/citation combination; information may be repeated. Showing #loanData.recordcount# rows.
	</p>
	<p>
		Click headers to sort.
	</p>
</div>
<p><a href="/download/#fname#">CSV</a></p>

<table border id="t" class="sortable">
	<tr>
		<th>Collection</th>
		<th>Loan</th>
		<th>Type</th>
		<th>Loaned To</th>
		<th>Status</th>
		<th>Trans Date</th>
		<th>Due Date</th>
		<th>Items Loaned</th>
		<th>Citations</th>
		<th>TransRemarks</th>
	</tr>
	<cfloop query="loanData">
		<cfset oneLine = '"#guid_prefix#","#loan_number#","#loan_type#","#loaned_to#","#LOAN_STATUS#","#dateformat(TRANS_DATE,"yyyy-mm-dd")#","#dateformat(RETURN_DUE_DATE,"yyyy-mm-dd")#","#CntCatNum#","#cntCited#","#trans_remarks#"'>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
		<tr>
			<td nowrap="nowrap">#guid_prefix#</td>
			<td nowrap="nowrap"><a href="/Loan.cfm?action=editLoan&TRANSACTION_ID=#TRANSACTION_ID#">#loan_number#</a></td>
			<td nowrap="nowrap">#loan_type#</td>
			<td nowrap="nowrap">#loaned_to#</td>
			<td>#LOAN_STATUS#</td>
			<td nowrap="nowrap">#dateformat(TRANS_DATE,"yyyy-mm-dd")#&nbsp;</td>
			<td nowrap="nowrap">#dateformat(RETURN_DUE_DATE,"yyyy-mm-dd")#&nbsp;</td>
			<td>
				<a href="/SpecimenResults.cfm?loan_trans_id=#loanData.TRANSACTION_ID#&collection_id=#loanData.collection_id#">#CntCatNum#</a>
			</td>
			<td><a href="/SpecimenResults.cfm?loan_trans_id=#loanData.TRANSACTION_ID#&collection_id=#loanData.collection_id#&type_status=any">
					#cntCited#</a>&nbsp;
			</td>
			<td>#trans_remarks#</td>
		</tr>
	</cfloop>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>
</table>


</cfif>

</cfoutput>
----------->
<cfinclude template="/includes/_footer.cfm">