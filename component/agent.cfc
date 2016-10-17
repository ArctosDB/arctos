<cfcomponent>
<cffunction name="jsonEscape" access="remote">
	<cfargument name="inpstr" required="yes">
	<cfset inpstr=replace(inpstr,'\','\\',"all")>
	<cfset inpstr=replace(inpstr,'"','\"',"all")>
	<cfset inpstr=replace(inpstr,chr(10),'<br>',"all")>
	<cfset inpstr=replacenocase(inpstr,chr(9),'<br>',"all")>
	<cfset inpstr=replace(inpstr,chr(13),'<br>',"all")>
	<cfset inpstr=replace(inpstr,'  ',' ',"all")>
	<cfset inpstr=rereplacenocase(inpstr,'(<br>){2,}','<br>',"all")>
	<cfreturn inpstr>
</cffunction>

<!-------------------------------------------------------------------------------->
<cffunction name="checkAgent" access="remote" returnformat="json">
    <cfargument name="preferred_name" required="true" type="string">
    <cfargument name="agent_type" required="true" type="string">
    <cfargument name="first_name" required="false" type="string" default="">
    <cfargument name="middle_name" required="false" type="string" default="">
    <cfargument name="last_name" required="false" type="string" default="">
    <cfif not isdefined("escapeQuotes")>
        <cfinclude template="/includes/functionLib.cfm">
    </cfif>

    <!--- shared rules --->
    <cfset regexStripJunk='[ .,-]'>
    <cfset problems='UUID: ' & CreateUUID()>
	<cfset problems=''>
    <cfset thisProb="">
    <cfset sql="">
	<cfset varPNsql="">
	<cfset strippedNamePermutations="">
	<cfset schFormattedName="">






    <cfset disallowCharacters="/,\,&">
    <cfif preferred_name neq trim(preferred_name)>
        <cfset problems=listappend(problems,'FATAL ERROR: leading and trailing spaces are prohibited.',';')>
    </cfif>
    <cfif len(trim(preferred_name)) is 0>
        <cfreturn "FATAL ERROR: Preferred_name is required.">
    </cfif>
    <cfloop list="#disallowCharacters#" index="i">
        <cfif preferred_name contains i>
            <cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of `unknown.`',';')>
        </cfif>
    </cfloop>

    <cfif agent_type is "person">
        <cfif (first_name neq trim(first_name)) or (middle_name neq trim(middle_name)) or (last_name neq trim(last_name))>
            <cfset problems=listappend(problems,'FATAL ERROR: leading and trailing spaces are prohibited.',';')>
        </cfif>
		<cfquery name="ds_ct_notperson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select term from ds_ct_notperson
		</cfquery>
		<cfset disallowPersons=valuelist(ds_ct_notperson.term)>


        <!----
            random lists of things may be indicitave of garbage.
                disallowWords are " me AND you" but not "ANDy"
                disallowCharacters are just that "me/you" and me /  you" and ....
            Expect some false positives - sorray!
        ---->
        <cfset disallowWords="and,or,cat">
        <cfset strippedUpperFML=ucase(rereplace(first_name & middle_name & last_name,regexStripJunk,"","all"))>
        <cfset strippedUpperFL=ucase(rereplace(first_name & last_name,regexStripJunk,"","all"))>
        <cfset strippedUpperLF=ucase(rereplace(last_name & first_name,regexStripJunk,"","all"))>
        <cfset strippedUpperLFM=ucase(rereplace(last_name & first_name & middle_name,regexStripJunk,"","all"))>
        <cfset strippedP=ucase(rereplace(preferred_name,regexStripJunk,"","all"))>
        <cfset strippedNamePermutations=strippedP>
        <cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperFML)>
        <cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperFL)>
        <cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperLF)>
        <cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperLFM)>
        <cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedP)>
        <cfif len(strippedNamePermutations) is 0>
            <cfset problems=listappend(problems,'Check apostrophy/single-quote. "O&apos;Neil" is fine. "Jim&apos;s Cat" should be entered as "unknown".',';')>
        </cfif>
        <cfloop list="#disallowWords#" index="i">
            <cfif listfindnocase(preferred_name,i," ;,.")>
                <cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of `unknown.`',';')>
            </cfif>
        </cfloop>
        <cfloop list="#disallowPersons#" index="i">
            <cfif listfindnocase(preferred_name,i,"() ;,.")>
                <cfset problems=listappend(problems,'Check name for #i#: do not create non-person agents as persons.',';')>
            </cfif>
        </cfloop>
        <!--- try to avoid unnecessary acronyms --->
        <cfif refind('[A-Z]{3,}',preferred_name) gt 0>
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif Compare(ucase(preferred_name), preferred_name) is 0 or Compare(lcase(preferred_name), preferred_name) is 0>
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif preferred_name does not contain " ">
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif preferred_name contains ".">
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif len(first_name) is 0 and len(middle_name) is 0 and len(last_name) is 0>
            <cfset problems=listappend(problems,'FATAL ERROR: Person agents must have at least one of first, middle, last name.',';')>
        </cfif>
        <cfif len(first_name) is 1 or len(middle_name) is 1 or len(last_name) is 1>
            <cfset problems=listappend(problems,'FATAL ERROR: One-character names are disallowed. Abbreviations must be followed by a period.',';')>
        </cfif>
        <!---
            period MUST be
                1) followed by a space, or
                2) The last character in the preferred name (eg, bla dood Jr.)
        ---->
        <cfif preferred_name contains "." and refind('^.*\.[^ ].*$',preferred_name)>
            <cfset problems=listappend(problems,'FATAL ERROR: Periods (except ending) must be followed by a space.',';')>
        </cfif>

        <cfset strippedNamePermutations=trim(escapeQuotes(strippedNamePermutations))>
        <cfset strippedNamePermutations=ListQualify(strippedNamePermutations,"'")>
        <!--- if we did not get a first or last name passed in, try to guess from the preferred name string ---->
        <cfset srchFirstName=first_name>
        <cfset srchMiddleName=middle_name>
        <cfset srchLastName=last_name>
        <cfif len(first_name) is 0 or len(last_name) is 0 or len(middle_name) is 0>
            <cfset x=splitAgentName(preferred_name)>
            <cfif len(first_name) is 0 and len(x.first) gt 0>
                <cfset srchFirstName=x.first>
            </cfif>
            <cfif len(middle_name) is 0 and len(x.middle) gt 0>
                <cfset srchMiddleName=x.middle>
            </cfif>
            <cfif len(last_name) is 0 and len(x.last) gt 0>
                <cfset srchLastName=x.last>
            </cfif>
            <cfif len(x.formatted_name) gt 0>
                <cfset schFormattedName=trim(escapeQuotes(x.formatted_name))>
            </cfif>
        </cfif>
        <cfset srchFirstName=trim(escapeQuotes(srchFirstName))>
        <cfset srchMiddleName=trim(escapeQuotes(srchMiddleName))>
        <cfset srchLastName=trim(escapeQuotes(srchLastName))>
        <cfset srchPrefName=trim(escapeQuotes(preferred_name))>

        <cfset nvars=ArrayNew(1)>


		<cfquery name="ds_ct_namesynonyms" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select names from ds_ct_namesynonyms
		</cfquery>

		<cfloop query="ds_ct_namesynonyms">
			<cfset ArrayAppend(nvars, names)>
		</cfloop>



        <!--- make any changes here to info/dupAgent as well ---->


        <cfset sqlinlist="">

        <!--- try to find name variants in preferred name ---->
        <cfset fnOPN=listgetat(srchPrefName,1,' ,;')>
        <cfset restOPN=trim(replace(srchPrefName,fnOPN,''))>

        <cfloop array="#nvars#" index="p">
            <cfif listfindnocase(p,fnopn)>
                <cfset varnts=p>
                <cfset varnts=listdeleteat(varnts,listfindnocase(p,fnopn))>
                <cfset sqlinlist=listappend(sqlinlist,varnts)>
            </cfif>
        </cfloop>
        <cfif len(sqlinlist) gt 0>
            <cfset sqlinlist=ucase(sqlinlist)>
            <cfloop list="#sqlinlist#" index="f">
                <cfset varPNsql=listappend(varPNsql,"replace(upper(agent_name.agent_name),'#ucase(f)#','#ucase(fnOPN)#') = '#ucase(srchPrefName)#'",'|')>
            </cfloop>
            <cfset varPNsql=replace(varPNsql,'|',' OR ','all')>
        </cfif>
        <!---- now do the same thing for first name ---->
        <cfif len(first_name) gt 0 and len(last_name) gt 0>
            <cfset varFNsql="">
            <cfloop array="#nvars#" index="p">
                <cfif listfindnocase(p,first_name)>
                    <cfset varnts=p>
                    <cfset varnts=listdeleteat(varnts,listfindnocase(p,first_name))>
                    <cfset varFNsql=listappend(varFNsql,varnts)>
                </cfif>
            </cfloop>
        </cfif>

        <!--- nocase preferred name match ---->
        <cfset sql="select
                        'nocase preferred name match' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent
                    where
                        trim(upper(agent.preferred_agent_name))=trim(upper('#srchPrefName#'))">
        <cfset sql="select
                        'exact preferred name match' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent
                    where
                        agent.preferred_agent_name='#srchPrefName#'">
        <cfif isdefined("schFormattedName") and len(schFormattedName) gt 0>
            <cfset sql=sql & "
                 union select
                    'nodots-nospaces match on agent name' reason,
                     agent.agent_id,
                     agent.preferred_agent_name
                from
                    agent,
                    agent_name
                where
                    agent.agent_id=agent_name.agent_id and
                    upper(agent_name.agent_name) like '%#ucase(schFormattedName)#%'">
        </cfif>
        <cfif isdefined("varFNsql") and len(varFNsql) gt 0 >
            <cfset sql=sql & "
                union select
                        'nocase first name variant+last name match' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent,
                        agent_name firstname,
                        agent_name lastname
                    where
                        agent.agent_id=firstname.agent_id and
                        agent.agent_id=lastname.agent_id and
                        lastname.agent_name_type='last name' and
                        firstname.agent_name_type='first name' and
                        upper(lastname.agent_name)='#ucase(escapeQuotes(last_name))#' and
                        upper(firstname.agent_name) IN
                        (
                            #listqualify(ucase(varFNsql),chr(39))#
                        )
                    ">
        </cfif>
        <cfif isdefined("varPNsql") and len(varPNsql) gt 0 >
            <cfset sql=sql & "
                union select
                        'nocase preferred name variant match' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent,
                        agent_name
                    where
                        agent.agent_id=agent_name.agent_id and
                        (
                            #varPNsql#
                        )
                    ">
        </cfif>

        <cfset sql=sql & "
                union
                  select
                        'nodots-nospaces match on first last' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent,
                        (select agent_id,agent_name from agent_name where agent_name_type='first name') first_name,
                        (select agent_id,agent_name from agent_name where agent_name_type='last name') last_name
                    where
                        agent.agent_id=first_name.agent_id and
                        agent.agent_id=last_name.agent_id and
                        trim(upper(first_name.agent_name)) = trim(upper('#srchFirstName#')) and
                        trim(upper(last_name.agent_name)) = trim(upper('#srchLastName#')) and
                          upper(regexp_replace(first_name.agent_name || last_name.agent_name ,'#regexStripJunk#', '')) in (
                            #preserveSingleQuotes(strippedNamePermutations)#
                         )">
        <cfset sql=sql & "
             union select
                'nodots-nospaces match on agent name' reason,
                 agent.agent_id,
                 agent.preferred_agent_name
            from
                agent,
                agent_name
            where
                agent.agent_id=agent_name.agent_id and
                upper(regexp_replace(agent_name.agent_name,'#regexStripJunk#', '')) in (#preserveSingleQuotes(strippedNamePermutations)#)">
        <cfif len(srchFirstName) gt 0 and len(srchLastName) gt 0>
            <cfset sql=sql & "
                        union
                        select
                            'nocase first and last name match' reason,
                            agent.agent_id,
                            agent.preferred_agent_name
                        from
                            agent,
                            (select agent_id,agent_name from agent_name where agent_name_type='first name') first_name,
                            (select agent_id,agent_name from agent_name where agent_name_type='last name') last_name
                        where
                            agent.agent_id=first_name.agent_id and
                            agent.agent_id=last_name.agent_id and
                            trim(upper(first_name.agent_name)) = trim(upper('#srchFirstName#')) and
                            trim(upper(last_name.agent_name)) = trim(upper('#srchLastName#'))">
        </cfif>
        <cfif len(srchFirstName) gt 0 and len(srchMiddleName) gt 0 and len(srchLastName) gt 0>
            <cfset sql=sql & "
                         union
                        select
                            'nodots-nospaces-nocase match on first middle last' reason,
                            agent.agent_id,
                            agent.preferred_agent_name
                        from
                            agent,
                            (select agent_id,agent_name from agent_name where agent_name_type='first name') first_name,
                            (select agent_id,agent_name from agent_name where agent_name_type='middle name') middle_name,
                            (select agent_id,agent_name from agent_name where agent_name_type='last name') last_name
                        where
                            agent.agent_id=first_name.agent_id and
                            agent.agent_id=middle_name.agent_id and
                            agent.agent_id=last_name.agent_id and
                            upper(regexp_replace(first_name.agent_name || middle_name.agent_name || last_name.agent_name ,'#regexStripJunk#', '')) in (
                                #preserveSingleQuotes(strippedNamePermutations)#
                             )">
        </cfif>
    <cfelse><!--- not a person --->
        <!----
            random lists of things may be indicitave of garbage.
                disallowWords are " me AND you" but not "ANDy"
                disallowCharacters are just that "me/you" and me /  you" and ....
            Expect some false positives - sorray!
        ---->
        <cfif (isdefined("first_name") and len(first_name) gt 0) or
            (isdefined("middle_name") and len(middle_name) gt 0) or
            (isdefined("last_name") and len(last_name) gt 0)>
            <cfset problems=listappend(problems,'FATAL ERROR: Non-person agents may not have first, middle, or last names.',';')>
        </cfif>



        <cfset disallowWords="or,cat,biol,boat,co,Corp,et,illegible,inc,other,uaf,ua,NY,AK,CA,various,Mfg">

        <cfset strippedNamePermutations=ucase(rereplace(preferred_name,regexStripJunk,"","all"))>
        <cfset srchPrefName=trim(escapeQuotes(preferred_name))>

        <cfif len(strippedNamePermutations) is 0>
            <cfset problems=listappend(problems,'Check apostrophy/single-quote. "O&apos;Neil" is fine. "Jim&apos;s Cat" should be entered as "unknown".',';')>
        </cfif>

        <cfif compare(ucase(preferred_name),preferred_name) eq 0 or compare(lcase(preferred_name),preferred_name) eq 0>
            <cfset problems=listappend(problems,'Check case: Most agents should be Proper Case.',';')>
        </cfif>

        <cfloop list="#disallowWords#" index="i">
            <cfif listfindnocase(preferred_name,i," ;,.")>
                <cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of `unknown.`',';')>
            </cfif>
        </cfloop>

        <!--- try to avoid unnecessary acronyms --->
        <cfif refind('[A-Z]{3,}',preferred_name) gt 0>
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif Compare(ucase(preferred_name), preferred_name) is 0 or Compare(lcase(preferred_name), preferred_name) is 0>
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif preferred_name does not contain " ">
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfif preferred_name contains ".">
            <cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of `unknown.`',';')>
        </cfif>
        <cfset strippedNamePermutations=trim(escapeQuotes(strippedNamePermutations))>
        <cfset strippedNamePermutations=ListQualify(strippedNamePermutations,"'")>
        <!--- if we did not get a first or last name passed in, try to guess from the preferred name string ---->
        <!--- nocase preferred name match ---->
        <cfset sql="select
                        'nocase preferred name match' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent
                    where
                        trim(upper(agent.preferred_agent_name))=trim(upper('#srchPrefName#'))">
        <cfset sql="select
                        'exact preferred name match' reason,
                        agent.agent_id,
                        agent.preferred_agent_name
                    from
                        agent
                    where
                        agent.preferred_agent_name='#srchPrefName#'">
        <cfset sql=sql & "
             union select
                'nodots-nospaces match on agent name' reason,
                 agent.agent_id,
                 agent.preferred_agent_name
            from
                agent,
                cf_agent_isitadup
            where
                agent.agent_id=cf_agent_isitadup.agent_id and
                strippeduppername in (#preserveSingleQuotes(strippedNamePermutations)#) ">

        <!---
            common "shortcuts"

            new: national park service
            old: U. S. National Park service
         ---->

        <cfset agencystrip=strippedNamePermutations>
        <cfset agencystrip=replace(agencystrip,'US','','all')>
        <cfset agencystrip=replace(agencystrip,'UNITEDSTATES','','all')>
        <cfset agencystrip=replace(agencystrip,'THE','','all')>
        <cfset agencystrip=replace(agencystrip,'THE','','all')>
        <cfset sql=sql & "
             union select
                'manipulated match on agent name' reason,
                 agent.agent_id,
                 agent.preferred_agent_name
            from
                agent,
                cf_agent_isitadup
            where
                agent.agent_id=cf_agent_isitadup.agent_id and
                upperstrippedagencyname  in (#preserveSingleQuotes(agencystrip)#)
                ">

    </cfif><!--- end agent type check ---->

    <cfquery name="isdup" datasource="uam_god">
        select
            agent_id,
            preferred_agent_name,
            reason
        from (
            #preservesinglequotes(sql)#
        )  group by
            reason,
            agent_id,
            preferred_agent_name
        order by
            preferred_agent_name
    </cfquery>

	<cfset problems=problems & '<br><br>:::::sql:' & sql & '<br><br>'>


    <cfquery name="daid" dbtype="query">
        select preferred_agent_name,agent_id from isdup group by preferred_agent_name,agent_id
    </cfquery>

    <cfset d = querynew("preferred_agent_name,agent_id,reasons,rcount")>
    <cfset i=1>
    <cfloop query="daid">
        <!--- some really craptacular agents return thousands of "matches"
        <cfif i lt 20>

		 --->
                <cfquery name="thisReasons" dbtype="query">
                    select * from isdup where agent_id=#agent_id#
                </cfquery>
                <cfset temp = queryaddrow(d,1)>
                <cfset temp = QuerySetCell(d, "preferred_agent_name", daid.preferred_agent_name, i)>
                <cfset temp = QuerySetCell(d, "agent_id", daid.agent_id, i)>
                <cfset temp = QuerySetCell(d, "reasons", valuelist(thisReasons.reason), i)>
                <cfset temp = QuerySetCell(d, "rcount", thisReasons.recordcount, i)>
                <cfset i=i+1>
				<!----
        </cfif>
		---->
    </cfloop>
    <cfquery name="ff" dbtype="query">
        select * from d order by rcount desc,preferred_agent_name
    </cfquery>

    <cfloop query="ff">
        <cfif reasons contains "exact preferred name match">
            <cfset thisProb='FATAL ERROR: duplicate of <a href="/agents.cfm?agent_id=#agent_id#" target="_blank">#preferred_agent_name#</a> (#reasons#)'>
        <cfelse>
            <cfset thisProb='possible duplicate of <a href="/agents.cfm?agent_id=#agent_id#" target="_blank">#preferred_agent_name#</a> (#reasons#)'>
        </cfif>
        <cfset problems=listappend(problems,thisProb,';')>
    </cfloop>
    <cfreturn problems>
</cffunction>

































<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="updateAgentPreload" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="KEY" type="numeric" required="true">
	<cfargument name="PREFERRED_NAME" type="string" required="true">
	<cfargument name="AGENT_TYPE" type="string" required="false">
	<cfargument name="STATUS" type="string" required="false">
	<cfargument name="OTHER_NAME_1" type="string" required="false">
	<cfargument name="OTHER_NAME_2" type="string" required="false">
	<cfargument name="OTHER_NAME_3" type="string" required="false">
	<cfargument name="OTHER_NAME_4" type="string" required="false">
	<cfargument name="OTHER_NAME_5" type="string" required="false">
	<cfargument name="OTHER_NAME_6" type="string" required="false">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cftry>
		<cfset status=replace(status,'<br>',';','all')>
		<cfset status=replace(status,'<span class="red">FATAL ERROR</span>','FATAL ERROR','all')>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_agent_sort
			set
				PREFERRED_NAME = '#escapeQuotes(PREFERRED_NAME)#',
				AGENT_TYPE = '#escapeQuotes(AGENT_TYPE)#',
				STATUS = '#escapeQuotes(STATUS)#',
				OTHER_NAME_1 = '#escapeQuotes(OTHER_NAME_1)#',
				OTHER_NAME_2 = '#escapeQuotes(OTHER_NAME_2)#',
				OTHER_NAME_3 = '#escapeQuotes(OTHER_NAME_3)#',
				OTHER_NAME_4 = '#escapeQuotes(OTHER_NAME_4)#',
				OTHER_NAME_5 = '#escapeQuotes(OTHER_NAME_5)#',
				OTHER_NAME_6 = '#escapeQuotes(OTHER_NAME_6)#'
			where
				KEY=#KEY#
		</cfquery>
		<cfset result='{"Result":"OK","Message":"success"}'>
		<cfcatch>
			<cfset msg=cfcatch.message>
			<cfif isdefined("cfcatch.detail") and len(cfcatch.detail) gt 0>
				<cfset msg=msg & ': ' & cfcatch.detail>
			</cfif>
			<cfif isdefined("cfcatch.sql") and len(cfcatch.sql) gt 0>
				<cfset msg=msg & ': ' & cfcatch.sql>
			</cfif>
			<cfset msg=jsonEscape(msg)>
			<cfset result='{"Result":"ERROR","Message":"#msg#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="deleteAgentPreload" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="KEY" type="numeric" required="true">
	<cftry>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from
				cf_temp_agent_sort
			where
				KEY=#KEY#
		</cfquery>
		<cfset result='{"Result":"OK","Message":"success"}'>
		<cfcatch>
			<cfset msg=cfcatch.message>
			<cfif isdefined("cfcatch.detail") and len(cfcatch.detail) gt 0>
				<cfset msg=msg & ': ' & cfcatch.detail>
			</cfif>
			<cfif isdefined("cfcatch.sql") and len(cfcatch.sql) gt 0>
				<cfset msg=msg & ': ' & cfcatch.sql>
			</cfif>
			<cfset msg=jsonEscape(msg)>
			<cfset result='{"Result":"ERROR","Message":"#msg#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="listAgentPreload" access="remote" returnformat="plain" queryFormat="column">
	<cfparam name="jtStartIndex" type="integer" default="0">
	<cfparam name="jtPageSize" type="integer" default="100">
	<cfparam name="jtSorting" type="string" default="PREFERRED_NAME ASC">
			<cfset jtStopIndex=jtStartIndex+jtPageSize>

	<!--- jtables likes to start at 0, which confuses CF, so.... ---->
	<cfset theFirstRow=jtStartIndex+1>
	<cfset theLastRow=theFirstRow+jtPageSize>
	<cftry>
		<cfquery name="d" datasource="uam_god">
			Select * from (
					Select a.*, rownum rnum From (
						select
							KEY,
							PREFERRED_NAME,
							AGENT_TYPE,
							replace(replace(STATUS,';','<br>'),'FATAL ERROR','<span class="red">FATAL ERROR</span>') STATUS,
							OTHER_NAME_1,
							OTHER_NAME_2,
							OTHER_NAME_3,
							OTHER_NAME_4,
							OTHER_NAME_5,
							OTHER_NAME_6
						from cf_temp_agent_sort order by #jtSorting#
					) a where rownum <= #jtStopIndex#
				) where rnum >= #jtStartIndex#
		</cfquery>
		<cfquery name="trc"  datasource="uam_god">
			Select count(*) c from cf_temp_agent_sort
		</cfquery>
		<cfoutput>
			<cfset coredata=''>
			<cfloop query="d">
				<cfset trow="">
				<cfloop list="#d.columnlist#" index="i">
					<cfset theData=evaluate("d." & i)>
					<cfset theData=jsonEscape(theData)>
					<cfset t = '"#i#":"' & theData  & '"'>
					<cfset trow=listappend(trow,t)>
				</cfloop>
				<cfset trow="{" & trow & "}">
				<cfset coredata=listappend(coredata,trow)>
			</cfloop>
		</cfoutput>
		<cfset result='{"Result":"OK","Records":[' & coredata & '],"TotalRecordCount":#trc.c#}'>
		<cfcatch>
			<cfset msg=cfcatch.message>
			<cfif isdefined("cfcatch.detail") and len(cfcatch.detail) gt 0>
				<cfset msg=msg & ': ' & cfcatch.detail>
			</cfif>
			<cfif isdefined("cfcatch.sql") and len(cfcatch.sql) gt 0>
				<cfset msg=msg & ': ' & cfcatch.sql>
			</cfif>
			<cfset msg=jsonEscape(msg)>
			<cfset result='{"Result":"ERROR","Message":"#msg#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!---------------------------------------------------------------->
<cffunction name="saveAgent" access="remote">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cfoutput>
		<cftry>

			<cftransaction>
				<!--- agent --->
				<cfquery name="updateAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE agent SET
						agent_remarks = '#escapeQuotes(agent_remarks)#',
						agent_type='#agent_type#',
						preferred_agent_name='#escapeQuotes(preferred_agent_name)#'
					WHERE
						agent_id = #agent_id#
				</cfquery>
				<!---- agent names --->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,16) is "agent_name_type_">
						<cfset thisAgentNameID=listlast(key,"_")>
						<cfset thisAgentNameType=url["agent_name_type_#thisAgentNameID#"]>
						<cfset thisAgentName=url["agent_name_#thisAgentNameID#"]>
						<cfif thisAgentNameID contains "new">
							<cfif len(thisAgentName) gt 0>
								<cfquery name="nan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO agent_name (
										agent_name_id,
										agent_id,
										agent_name_type,
										agent_name
									) VALUES (
										sq_agent_name_id.nextval,
										<cfqueryparam value = "#agent_ID#" CFSQLType = "CF_SQL_INTEGER">,
										'#thisAgentNameType#',
										'#escapeQuotes(thisAgentName)#'
									)
								</cfquery>
							</cfif>
						<cfelseif thisAgentNameType is "DELETE">
							<cfquery name="nan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from agent_name where agent_name_id=<cfqueryparam value = "#thisAgentNameID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="nan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update
									agent_name
								set
									agent_name='#escapeQuotes(thisAgentName)#',
									agent_name_type='#thisAgentNameType#'
								where agent_name_id=<cfqueryparam value = "#thisAgentNameID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
				<!---- relationships ---->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,19) is "agent_relationship_">
						<cfset thisAgentRelationsID=listlast(key,"_")>
						<cfset thisAgentRelationship=url["agent_relationship_#thisAgentRelationsID#"]>
						<cfset thisRelatedAgentName=url["related_agent_#thisAgentRelationsID#"]>
						<cfset thisRelatedAgentID=url["related_agent_id_#thisAgentRelationsID#"]>
						<cfif thisAgentRelationsID contains "new">
							<cfif len(thisAgentRelationship) gt 0>
								<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO agent_relations (
										AGENT_ID,
										RELATED_AGENT_ID,
										AGENT_RELATIONSHIP)
									VALUES (
										<cfqueryparam value = "#agent_id#" CFSQLType = "CF_SQL_INTEGER">,
										<cfqueryparam value = "#thisRelatedAgentID#" CFSQLType = "CF_SQL_INTEGER">,
										'#thisAgentRelationship#')
								</cfquery>
							</cfif>
						<cfelseif thisAgentRelationship is "DELETE">
							<cfquery name="killRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from agent_relations where agent_relations_id=<cfqueryparam value = "#thisAgentRelationsID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="changeRelated" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								UPDATE agent_relations SET
									related_agent_id = <cfqueryparam value = "#thisRelatedAgentID#" CFSQLType = "CF_SQL_INTEGER">,
									agent_relationship='#thisAgentRelationship#'
								WHERE AGENT_RELATIONS_ID=<cfqueryparam value = "#thisAgentRelationsID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>

				<!---- group members ---->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,16) is "member_agent_id_">
						<cfset thisGroupMemberID=listlast(key,"_")>
						<cfset thisMemberAgentID=url["member_agent_id_#thisGroupMemberID#"]>
						<cfset thisMemberAgentName=url["group_member_#thisGroupMemberID#"]>
						<cfif thisGroupMemberID contains "new">
							<cfif len(thisMemberAgentID) gt 0>
								<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO group_member (
										GROUP_AGENT_ID,
										MEMBER_AGENT_ID)
									VALUES (
										<cfqueryparam value = "#agent_id#" CFSQLType = "CF_SQL_INTEGER">,
										<cfqueryparam value = "#thisMemberAgentID#" CFSQLType = "CF_SQL_INTEGER">
									)
								</cfquery>
							</cfif>
						<cfelseif thisMemberAgentName is "DELETE">
							<cfquery name="killRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from group_member where GROUP_MEMBER_ID=<cfqueryparam value = "#thisGroupMemberID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="changeRelated" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								UPDATE group_member SET
									MEMBER_AGENT_ID = <cfqueryparam value = "#thisMemberAgentID#" CFSQLType = "CF_SQL_INTEGER">
								WHERE GROUP_MEMBER_ID=<cfqueryparam value = "#thisGroupMemberID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
				<!---- status ---->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,13) is "agent_status_">
						<cfset thisAgentStatusID=listlast(key,"_")>
						<cfset thisAgentStatus=url["agent_status_#thisAgentStatusID#"]>
						<cfset thisAgentStatusDate=url["status_date_#thisAgentStatusID#"]>
						<cfset thisAgentStatusRemark=url["status_remark_#thisAgentStatusID#"]>
						<cfif thisAgentStatusID contains "new">
							<cfif len(thisAgentStatus) gt 0>
								<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									insert into agent_status (
										AGENT_STATUS_ID,
										AGENT_ID,
										AGENT_STATUS,
										STATUS_DATE,
										STATUS_REMARK
									) values (
										sq_AGENT_STATUS_ID.nextval,
										#agent_id#,
										'#thisAgentStatus#',
										'#thisAgentStatusDate#',
										'#escapequotes(thisAgentStatusRemark)#'
									)
								</cfquery>
							</cfif>
						<cfelseif thisAgentStatus is "DELETE">
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from  agent_status where agent_status_id=<cfqueryparam value = "#thisAgentStatusID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update agent_status
								set
									AGENT_STATUS='#thisAgentStatus#',
									STATUS_DATE='#thisAgentStatusDate#',
									STATUS_REMARK='#escapequotes(thisAgentStatusRemark)#'
								where AGENT_STATUS_ID=<cfqueryparam value = "#thisAgentStatusID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,13) is "address_type_">
						<cfset thisAddressID=listlast(key,"_")>
						<cfset thisAddressType=url["address_type_#thisAddressID#"]>
						<cfset thisAddress=url["address_#thisAddressID#"]>
						<cfset thisAddressValidFg=url["valid_addr_fg_#thisAddressID#"]>
						<cfset thisAddressRemark=url["address_remark_#thisAddressID#"]>
						<cfif thisAddressID contains "new">
							<cfif len(thisAddressType) gt 0>
								<cfquery name="elecaddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO address (
										AGENT_ID
										,address_type
									 	,address
									 	,VALID_ADDR_FG
									 	,ADDRESS_REMARK
									 ) VALUES (
										<cfqueryparam value = "#agent_ID#" CFSQLType = "CF_SQL_INTEGER">
										,'#thisAddressType#'
									 	,'#thisAddress#'
									 	,#thisAddressValidFg#
									 	,'#escapeQuotes(thisAddressRemark)#'
									)
								</cfquery>
							</cfif>
						<cfelseif thisAddressType is "DELETE">
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from  address where address_id=<cfqueryparam value = "#thisAddressID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update address
								set
									address_type='#thisAddressType#',
									address='#thisAddress#',
									VALID_ADDR_FG=#thisAddressValidFg#,
									ADDRESS_REMARK='#escapeQuotes(thisAddressRemark)#'
								where
									address_id=<cfqueryparam value = "#thisAddressID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			</cftransaction>
		<cfreturn "success">
		<cfcatch>
			<cf_logError subject="error caught: saveAgent" attributeCollection=#cfcatch#>
			<cfset m=cfcatch.message & ': ' & cfcatch.detail>
			<cfif isdefined("cfcatch.sql")>
				<cfset m= m & ' SQL:' & cfcatch.sql>
			</cfif>
			<cfreturn m>
		</cfcatch>
		</cftry>
	</cfoutput>
</cffunction>
<!---------------------------------------------------------------->
<cffunction name="findAgents" access="remote">
	<cfoutput>
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cfset sql = "SELECT
					agent.agent_id,
					agent.preferred_agent_name,
					agent.agent_type
				FROM
					agent,
					agent_name,
					agent_status
				WHERE
					agent.agent_id=agent_name.agent_id (+) and
					agent.agent_id=agent_status.agent_id (+) and
					agent.agent_id > -1
					">
	<cfset srch=false>
	<cfif isdefined("anyName") AND len(anyName) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#trim(ucase(escapeQuotes(anyName)))#%'">
	</cfif>
	<cfif isdefined("agent_id") AND isnumeric(agent_id)>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent.agent_id = #agent_id#">
	</cfif>
	<cfif isdefined("status_date") AND len(status_date) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND status_date #status_date_oper# '#status_date#'">
	</cfif>
	<cfif isdefined("agent_status") AND len(agent_status) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent_status='#agent_status#'">
	</cfif>
	<cfif isdefined("address") AND len(address) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent.agent_id IN (select agent_id from address where upper(address) like '%#ucase(address)#%')">
	</cfif>
	<cfif isdefined("agent_name_type") AND len(agent_name_type) gt 0>
		<cfset sql = "#sql# AND agent_name_type='#agent_name_type#'">
	</cfif>
	<cfif isdefined("agent_type") AND len(agent_type) gt 0>
		<cfset sql = "#sql# AND agent.agent_type='#agent_type#'">
	</cfif>
	<cfif isdefined("agent_name") AND len(agent_name) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(escapeQuotes(agent_name))#%'">
	</cfif>
	<cfif isdefined("created_by") AND len(created_by) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent.created_by_agent_id in (select agent_id from agent_name where upper(agent_name.agent_name) like '%#ucase(escapeQuotes(created_by))#%')">
	</cfif>

	<cfif isdefined("created_date") AND len(created_date) gt 0>
		<cfset srch=true>
		<cfif len(created_date) is 4>
			<cfset filter='YYYY'>
		<cfelseif len(created_date) is 7>
			<cfset filter='YYYY-MM'>
		<cfelseif len(created_date) is 10>
			<cfset filter='YYYY-MM-DD'>
		<cfelse>
			<cfreturn 'error: Search created date as YYYY, YYYY-MM, YYYY-MM-DD'>
		</cfif>
		<cfset sql = "#sql# AND to_char(CREATED_DATE,'#filter#') #create_date_oper# '#created_date#'">
	</cfif>
	<cfset sql = "#sql# GROUP BY  agent.agent_id,
						agent.preferred_agent_name,
						agent.agent_type">
	<cfset sql = "#sql# ORDER BY agent.preferred_agent_name">
	<cfif srch is false>
		<cfreturn 'error: You must provide criteria to search.'>
	</cfif>
	<cfquery name="getAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfreturn getAgents>
</cfoutput>
</cffunction>
<!--------------------------------------------------------------------------------------->
<cffunction name="splitAgentName" access="remote" returnformat="json">
   	<cfargument name="name" required="true" type="string">
   	<cfargument name="agent_type" required="false" type="string" default="person">
	<cfif isdefined("agent_type") and len(agent_type) gt 0 and agent_type neq 'person'>
		<cfset d = querynew("name,nametype,first,middle,last,formatted_name")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "name", name, 1)>
		<cfreturn d>
	</cfif>

	<cfquery name="CTPREFIX" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select prefix from CTPREFIX
	</cfquery>
	<cfquery name="CTsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select suffix from CTsuffix
	</cfquery>
	<cfset temp=name>
	<cfset removedPrefix="">
	<cfset removedSuffix="">
	<cfloop query="CTPREFIX">
		<cfif listfind(temp,prefix," ,")>
			<cfset removedPrefix=prefix>
			<cfset temp=listdeleteat(temp,listfind(temp,prefix," ,")," ,")>
		</cfif>
	</cfloop>
	<cfloop query="CTsuffix">
		<cfif listfind(temp,suffix," ,")>
			<cfset removedSuffix=suffix>
			<cfset temp=listdeleteat(temp,listfind(temp,suffix," ,")," ,")>
		</cfif>
	</cfloop>
	<cfset temp=trim(replace(temp,'  ',' ','all'))>
	<cfset snp="Von,Van,La,Do,Del,De,St,Der">
	<cfloop list="#snp#" index="x">
		<cfset temp=replace(temp, "#x# ","#x#|","all")>
	</cfloop>
	<cfset nametype="">
	<cfset first="">
	<cfset middle="">
	<cfset last="">
	<cfif REFind("^[^, ]+ [^, ]+$",temp)>
		<cfset nametype="first_last">
		<cfset first=listgetat(temp,1," ")>
		<cfset last=listlast(temp," ")>
	<cfelseif REFind("^[^,]+ [^,]+ .+$",temp)>
		<cfset nametype="first_middle_last">
		<cfset first=listgetat(temp,1," ")>
		<cfset last=listlast(temp," ")>
		<cfset middle=replace(replace(temp,first,"","first"),last,"","all")>
	<cfelseif REFind("^.+, .+ .+$",temp)>
		<cfset nametype="last_comma_first_middle">
		<cfset last=listfirst(temp," ")>
		<cfset first=listgetat(temp,2," ")>
		<cfset middle=replace(replace(temp,first,"","all"),last,"","all")>
	<cfelseif REFind("^.+, .+$",temp)>
		<cfset nametype="last_comma_first">
		<cfset last=listgetat(temp,1," ")>
		<cfset first=listgetat(temp,2," ")>
	<cfelse>
		<cfset nametype="nonstandard">
	</cfif>
	<cfset last=replace(last, "|"," ","all")>
	<cfset middle=replace(middle, "|"," ","all")>
	<cfset first=replace(first, "|"," ","all")>
	<cfset first=trim(replace(first, ',','','all'))>
	<cfset middle=trim(replace(middle, ',','','all'))>
	<cfset last=trim(replace(last, ',','','all'))>
	<cfset formatted_name=trim(replace(removedPrefix & ' ' & 	first & ' ' & middle & ' ' & last & ' ' & removedSuffix, ',','','all'))>
	<cfset formatted_name=replace(formatted_name, '  ',' ','all')>
	<cfif nametype is "nonstandard">
		<cfset formatted_name="">
	</cfif>
	<cfset d = querynew("name,nametype,first,middle,last, formatted_name")>
	<cfset temp = queryaddrow(d,1)>
	<cfset temp = QuerySetCell(d, "name", name, 1)>
	<cfset temp = QuerySetCell(d, "nametype", nametype, 1)>
	<cfset temp = QuerySetCell(d, "first", trim(first), 1)>
	<cfset temp = QuerySetCell(d, "middle", trim(middle), 1)>
	<cfset temp = QuerySetCell(d, "last", trim(last), 1)>
	<cfset temp = QuerySetCell(d, "formatted_name", trim(formatted_name), 1)>
	<cfreturn d>
</cffunction>
<!--------------------------------------------------------------------------------------->
</cfcomponent>