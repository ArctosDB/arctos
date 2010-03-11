<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		Enter a report title in the form below to get started.
		</p>
		<form name="a" method="post" action="SpecUsageReport.cfm">
			<input type="hidden" name="action" value="buildIt">
			<input type="hidden" name="project_id" value="#project_id#">
			<input type="hidden" name="publication_id" value="#publication_id#">
			<label for="reportTitle">Report Title</label>
			<input type="text" size="60" name="report_title" id="report_title">
			<br><input type="submit" value="Build Report Data" class="lnkBtn">
		</form>
	</cfif>
	<cfif action is "buildIt">
		<cfset session.projectReportTable="projTable#cfid##cftoken#">
		<cftry>
			<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				drop table #session.projectReportTable#
			</cfquery>
		<cfcatch><!--- not there, so what? ---></cfcatch>
		</cftry>
		<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			create table #session.projectReportTable# (
				report_title varchar2(4000),
				project_id number,
				project_name varchar2(4000),
				project_dates varchar2(4000),
				project_agents varchar2(4000),
				project_sponsors varchar2(4000),
				numberProjectAccnSpecimens number,
				numberProjectLoanSpecimens number,
				publication_id number,
				formatted_publication varchar2(4000),
				numberOfCitations number
			)
		</cfquery>
		<cfif len(project_id) gt 0>
			<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					project.project_id,
					project.project_name,
					to_char(project.start_date,'DD Mon YYYY') start_date,
					to_char(project.end_date,'DD Mon YYYY') end_date
				from
					project
				where
					project_id in (#project_id#)
			</cfquery>
			<cfloop query="p">
				<cfquery name="pa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						agent_name
					from
						project_agent,
						agent_name
					where
						project_agent.agent_name_id=agent_name.agent_name_id and
						project_id=#p.project_id#
					order by
						AGENT_POSITION
				</cfquery>
				<cfquery name="ps" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						agent_name,
						ACKNOWLEDGEMENT
					from
						project_sponsor,
						agent_name
					where
						project_sponsor.agent_name_id=agent_name.agent_name_id and
						project_id=#p.project_id#
				</cfquery>
				<cfquery name="pan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						count(distinct(cataloged_item.collection_object_id)) numSpec
					from
						project_trans,
						accn,
						cataloged_item
					where
						project_trans.TRANSACTION_ID=accn.TRANSACTION_ID and
						accn.TRANSACTION_ID=cataloged_item.accn_id and
						project_id=#p.project_id#
				</cfquery>
				<cfquery name="plo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						count(distinct(specimen_part.derived_from_cat_item)) numSpec
					from
						project_trans,
						loan,
						loan_item,
						specimen_part
					where
						project_trans.TRANSACTION_ID=loan.TRANSACTION_ID and
						loan.TRANSACTION_ID=loan_item.TRANSACTION_ID and
						loan_item.collection_object_id=specimen_part.collection_object_id and
						project_id=#p.project_id#
				</cfquery>
				<cfif pa.recordcount is 1>
					<cfset project_agents=pa.agent_name>
				<cfelseif pa.recordcount is 2>
					<cfset project_agents=valuelist(pa.agent_name," and ")>
				<cfelseif pa.recordcount gt 2>
					<cfset project_agents=valuelist(pa.agent_name,",")>
					<cfset lval = "and " & trim(ListLast(project_agents))>
					<cfset project_agents=listdeleteat(project_agents,listlen(project_agents))>
					<cfset project_agents=listappend(project_agents,lval)>
					<cfset project_agents=listchangedelims(project_agents,", ")>
				<cfelse>
					<cfset project_agents="">
				</cfif>
				<cfif ps.recordcount is 1>
					<cfset project_sponsors=ps.agent_name>
				<cfelseif ps.recordcount is 2>
					<cfset project_sponsors=valuelist(ps.agent_name," and ")>
				<cfelseif ps.recordcount gt 2>
					<cfset project_sponsors=valuelist(ps.agent_name,",")>
					<cfset lval = "and " & trim(ListLast(project_sponsors))>
					<cfset project_sponsors=listdeleteat(project_sponsors,listlen(project_sponsors))>
					<cfset project_sponsors=listappend(project_sponsors,lval)>
					<cfset project_sponsors=listchangedelims(project_sponsors,", ")>
				<cfelse>
					<cfset project_sponsors="">
				</cfif>
				<cfif p.start_date is p.end_date>
					<cfset project_dates=p.start_date>
				<cfelseif len(p.start_date) gt 0 and len(p.end_date) gt 0>
					<cfset project_dates=p.start_date & '-' & p.end_date>
				<cfelseif len(p.start_date) gt 0>
					<cfset project_dates=p.start_date>
				<cfelseif len(p.end_date) gt 0>
					<cfset project_dates=p.end_date>			
				</cfif>
				<cfquery name="insProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into #session.projectReportTable# (
						report_title,
						project_id,
						project_name,
						project_dates,
						project_agents,
						project_sponsors,
						numberProjectAccnSpecimens,
						numberProjectLoanSpecimens
					) values (
						'#report_title#',
						#p.project_id#,
						'#p.project_name#',
						'#project_dates#',
						'#project_agents#',
						'#project_sponsors#',
						#pan.numSpec#,
						#plo.numSpec#
					)
				</cfquery>
			</cfloop>
		</cfif>
		<cfif len(publication_id) gt 0>
			<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					formatted_publication.publication_id,
					formatted_publication,
					count(distinct(citation.collection_object_id)) numCits
				from
					formatted_publication,
					citation
				where
					formatted_publication.publication_id = citation.publication_id (+) and
					formatted_publication.format_style = 'long' and
					formatted_publication.publication_id in (#publication_id#)
				group by
					formatted_publication.publication_id,
					formatted_publication
			</cfquery>
			<cfloop query="p">
				<cfquery name="insPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into #session.projectReportTable# (
						report_title,
						publication_id,
						formatted_publication,
						numberOfCitations
					) values (
						'#report_title#',
						#publication_id#,
						'#formatted_publication#',
						#numCits#
					)
				</cfquery>
			</cfloop>		
		</cfif>
		
		You just created a table named #session.projectReportTable#.
	
	<p>
		Table structure is:
		<ul>
			<li>report_title</li>
			<li>project_id</li>
			<li>project_name</li>
			<li>project_dates</li>
			<li>project_agents</li>
			<li>project_sponsors</li>
			<li>numberProjectAccnSpecimens</li>
			<li>numberProjectLoanSpecimens</li>
			<li>publication_id</li>
			<li>formatted_publication</li>
			<li>numberOfCitations</li>
		</ul>
		Each row will contain either report or project data, never both.
	</p>
	<p>
		You may access this table in Reports as
		##session.projectReportTable##, or query #session.projectReportTable# in Write SQL.
	</p>
	<p>
	
		See Reports and handlers for
		<a href="http://arctos-test.arctos.database.museum/Reports/report_printer.cfm?report=ProjectTemplate">ProjectTemplate</a>
		 and 
		<a href="http://arctos-test.arctos.database.museum/Reports/report_printer.cfm?report=PublicationTemplate">PublicationTemplate</a>
		in the 
		<a href="http://arctos-test.arctos.database.museum/Reports/reporter.cfm">Reporter</a> and
		<a href="http://arctos-test.arctos.database.museum/Reports/report_printer.cfm">Report Printer</a>
		for example usage.
	</p>
	<p>
		#session.projectReportTable# is attached to your session, and will need rebuilt after you 
		log out, or after 2 hours.
	</p>
	</cfif>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">