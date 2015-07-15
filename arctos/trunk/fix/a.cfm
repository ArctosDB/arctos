<cfoutput>

<cfinclude template="/includes/_header.cfm">

		<cfquery name="qry" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from publication where doi is null and rownum<100
		</cfquery>
		<cfloop query="qry">
			<p>
			#FULL_CITATION#



<br>#REFind("a+c+", "abcaaccdd")#
<cfset startttl=refind('[0-9]{4}\.',FULL_CITATION) + 5>

<br>startttl:#startttl#

<cfset noauths=mid(FULL_CITATION,startttl,len(FULL_CITATION))>

<br>noauths:#noauths#

<br>first #startttl# chrs: [#left(FULL_CITATION,startttl)#]

<br>now find position of next dot from startttl....

<cfset stopttl=refind('x',FULL_CITATION,#startttl#)>

<br>stopttl:#stopttl#

<cfdump var=#startttl#>


<cfdump var=#stopttl#>


<cfset ttl=Mid(FULL_CITATION, startttl, stopttl)>

<br>ttl:[#ttl#]
<!----

			<br>startttl: #startttl#

---->

			</p>
			<br>
		</cfloop>



<!-----

this part works yay!

<cfhttp url="http://search.crossref.org/dois?q=Phenotypic evolution in high-elevation populations of western fence lizards (Sceloporus occidentalis) in the Sierra Nevada Mountains"></cfhttp>


<cfdump var=#cfhttp#>



<cfset x=DeserializeJSON(cfhttp.filecontent)>


<cfdump var=#x#>


<cfset q=queryNew("doi,fullcitation,score")>


<cfloop array="#x#" index="data_index">

<p>
	looptyloop
</p>
<p>
	<cfdump var=#data_index#>

	<p>
		doi: #data_index['doi']#
	</p>
	<p>
		fullcitation: #data_index['fullcitation']#
	</p>

	<p>
		normalizedScore: #data_index['normalizedScore']#
	</p>

</cfloop>

------>






<!-----
http://search.crossref.org/?q=M.+Henrion%2C+D.+J.+Mortlock%2C+D.+J.+Hand%2C+and+A.+Gandy%2C+%22A+Bayesian+approach+to+star-galaxy+classification%2C%22+Monthly+Notices+of+the+Royal+Astronomical+Society%2C+vol.+412%2C+no.+4%2C+pp.+2286-2302%2C+Apr.+2011.

	<cfset rauths="">
	<cfset lPage=''>
	<cfset pubYear=''>
	<cfset jVol=''>
	<cfset jIssue=''>
	<cfset fPage=''>
	<cfset fail="">
	<cfset firstAuthLastName=''>
	<cfset secondAuthLastName=''>
	<cfoutput>
		<cftry>
		<cfif idtype is 'DOI'>
			<cfhttp url="http://www.crossref.org/openurl/?id=#identifier#&noredirect=true&pid=dlmcdonald@alaska.edu&format=unixref"></cfhttp>
			<cfset r=xmlParse(cfhttp.fileContent)>
			<cfif debug>
				<cfdump var=#r#>
			</cfif>
			<cfif left(cfhttp.statuscode,3) is not "200" or not structKeyExists(r.doi_records[1].doi_record[1].crossref[1],"journal")>
				<cfset fail="not found or not journal">
			</cfif>
			<cfif len(fail) is 0>
				<cfset numberOfAuthors=arraylen(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors.xmlchildren)>
				<cfloop from="1" to="#numberOfAuthors#" index="i">
					<cfset fName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[i].given_name.xmltext>
					<cfset lName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[i].surname.xmltext>
					<cfset thisName=fName & ' ' & lName>
					<cfset rauths=listappend(rauths,thisName,"|")>
				</cfloop>
				<cfset firstAuthLastName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[1].surname.xmltext>
				<cfif numberOfAuthors gt 1>
					<cfset secondAuthLastName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[2].surname.xmltext>
				</cfif>
				<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.publication_date,"year")>
					<cfset pubYear=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.publication_date.year.xmltext>
				<cfelseif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.publication_date,"year")>>
					<cfset pubYear=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.publication_date.year.xmltext>
				</cfif>
				<cfset pubTitle=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.titles.title.xmltext>
				<cfset jName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_metadata.full_title.xmltext>
				<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1],"journal_issue")>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.journal_volume,"volume")>
						<cfset jVol=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.journal_volume.volume.xmltext>
					</cfif>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue,"issue")>
						<cfset jIssue=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.issue.xmltext>
					</cfif>
				</cfif>
				<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article,"pages")>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages,"first_page")>
						<cfset fPage=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages.first_page.xmltext>
					</cfif>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages,"last_page")>
						<cfset lPage=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages.last_page.xmltext>
					</cfif>
				</cfif>
			</cfif><!--- end DOI --->
		<cfelseif idtype is "PMID">
			<cfhttp url="http://www.ncbi.nlm.nih.gov/pubmed/#identifier#?report=XML"></cfhttp>
			<cfset theData=replace(cfhttp.fileContent,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">','')>
			<cfset theData=replace(theData,"&gt;",">","all")>
			<cfset theData=replace(theData,"&lt;","<","all")>
			<cfset r=xmlParse(theData)>
			<cfif left(cfhttp.statuscode,3) is not "200" or not structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1],"Journal")>
				<cfset fail="not found or not journal">
			</cfif>
			<cfif len(fail) is 0>
				<cfif debug>
					<cfdump var=#r#>
				</cfif>
				<cfset numberOfAuthors=arraylen(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].xmlchildren)>
				<cfloop from="1" to="#numberOfAuthors#" index="i">
					<cfset fName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[i].ForeName.xmltext>
					<cfset lName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[i].LastName.xmltext>
					<cfset thisName=fName & ' ' & lName>
					<cfset rauths=listappend(rauths,thisName,"|")>
				</cfloop>
				<cfset firstAuthLastName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[1].LastName.xmltext>
				<cfif numberOfAuthors gt 1>
					<cfset secondAuthLastName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[2].LastName.xmltext>
				</cfif>
				<cfif structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal[1].JournalIssue[1].PubDate,"Year")>
					<cfset pubYear=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal[1].JournalIssue[1].PubDate.Year.xmltext>
				</cfif>
				<cfset pubTitle=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].ArticleTitle.xmltext>
				<cfif right(pubTitle,1) is ".">
					<cfset pubTitle=left(pubTitle,len(pubTitle)-1)>
				</cfif>
				<cfset jName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.Title.xmltext>
				<cfif structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue,"Issue")>
					<cfset jIssue=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue.Issue.xmltext>
				</cfif>
				<cfif structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue,"Volume")>
					<cfset jVol=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue.Volume.xmltext>
				</cfif>
				<cfset pages=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Pagination.MedlinePgn.xmltext>
				<cfif listlen(pages,"-") is 2>
					<cfset fPage=listgetat(pages,1,"-")>
					<cfset lPage=listgetat(pages,2,"-")>
				</cfif>
			</cfif><!--- PMID nofail --->
		</cfif><!---- end PMID --->
		<cfcatch>
			<cfset fail='error_getting_data: #cfcatch.message# #cfcatch.detail#'>
		</cfcatch>
		</cftry>

		<cfif len(fail) is 0>
			<cftry>
			<cfif listlen(rauths,"|") is 2>
				<cfset auths=replace(rauths,"|"," and ")>
			<cfelse>
				<cfset auths=listchangedelims(rauths,", ","|")>
			</cfif>
			<cfset longCit="#auths#.">
			<cfif len(pubYear) gt 0>
				<cfset longCit=longCit & " #pubYear#.">
			</cfif>
			<cfset longCit=longCit & " #pubTitle#. #jName#">
			<cfif len(jVol) gt 0>
				<cfset longCit=longCit & " #jVol#">
			</cfif>
			<cfif len(jIssue) gt 0>
				<cfset longCit=longCit & "(#jIssue#)">
			</cfif>
			<cfif len(fPage) gt 0>
				<cfset longCit=longCit & ":#fPage#">
			</cfif>
			<cfif len(lPage) gt 0>
				<cfset longCit=longCit & "-#lPage#">
			</cfif>
			<cfset longCit=longCit & ".">
			<cfif numberOfAuthors is 1>
				<cfset shortCit="#firstAuthLastName# #pubYear#">
			<cfelseif numberOfAuthors is 2>
				<cfset shortCit="#firstAuthLastName# and #secondAuthLastName# #pubYear#">
			<cfelse>
				<cfset shortCit="#firstAuthLastName# et al. #pubYear#">
			</cfif>
			<cfset d = querynew("STATUS,PUBLICATIONTYPE,LONGCITE,SHORTCITE,YEAR,AUTHOR1,AUTHOR2,AUTHOR3,AUTHOR4,AUTHOR5")>
			<cfset temp = queryaddrow(d,1)>
			<cfset temp = QuerySetCell(d, "STATUS", 'success', 1)>
			<cfset temp = QuerySetCell(d, "PUBLICATIONTYPE", 'journal article', 1)>
			<cfset temp = QuerySetCell(d, "LONGCITE", longCit, 1)>
			<cfset temp = QuerySetCell(d, "SHORTCITE", shortCit, 1)>
			<cfset temp = QuerySetCell(d, "YEAR", pubYear, 1)>
			<cfset l=1>
			<cfloop list="#rauths#" index="a" delimiters="|">
				<cfif l lte 5>
					<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select * from (
							select
								preferred_agent_name.agent_name,
								preferred_agent_name.agent_id
							from
								preferred_agent_name,
								agent_name
							where
								preferred_agent_name.agent_id=agent_name.agent_id and
								upper(agent_name.agent_name) like '%#ucase(a)#%'
						) where rownum<=5
					</cfquery>
					<cfif a.recordcount gt 0>
						<cfset thisAuthSugg="">
						<cfloop query="a">
							<cfset thisAuthSuggElem="#agent_name#@#agent_id#">
							<cfset thisAuthSugg=listappend(thisAuthSugg,thisAuthSuggElem,"|")>
						</cfloop>
					<cfelse>
						<cfif idtype is "DOI">
							<cfset thisLastName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[l].surname.xmltext>
						<cfelseif idtype is "PMID">
							<cfset thisLastName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[l].LastName.xmltext>
						</cfif>

						<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select * from (
								select
									preferred_agent_name.agent_name,
									preferred_agent_name.agent_id
								from
									preferred_agent_name,
									agent_name
								where
									preferred_agent_name.agent_id=agent_name.agent_id and
									upper(agent_name.agent_name) like '%#ucase(thisLastName)#%'
							) where rownum<=5
						</cfquery>
						<cfif a.recordcount gt 0>
							<cfset thisAuthSugg="">
							<cfloop query="a">
								<cfset thisAuthSuggElem="#agent_name#@#agent_id#">
								<cfset thisAuthSugg=listappend(thisAuthSugg,thisAuthSuggElem,"|")>
							</cfloop>
						<cfelse>
							<cfset thisAuthSugg="">
						</cfif>
					</cfif>
					<cfset temp = QuerySetCell(d, "AUTHOR#l#", thisAuthSugg, 1)>
				</cfif>
				<cfset l=l+1>
			</cfloop>
		<cfcatch>
			<cfset fail='error_getting_author: #cfcatch.message# #cfcatch.detail#'>
		</cfcatch>
		</cftry>
	</cfif>
	<cfif len(fail) gt 0>
		<cfset d = querynew("STATUS,PUBLICATIONTYPE,LONGCITE,SHORTCITE,YEAR,AUTHORS")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "STATUS", 'fail:#cfhttp.statuscode#:#fail#', 1)>
	</cfif>
	<cfreturn d>
</cfoutput>
</cffunction>


----->
<cfinclude template="/includes/_footer.cfm">
</cfoutput>

