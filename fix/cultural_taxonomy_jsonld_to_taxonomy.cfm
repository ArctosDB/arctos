<cfoutput>

<!----

For https://github.com/ArctosDB/arctos/issues/1732

Turn JSON-LD from

http://www.nomenclature.info/apropos-about.app?lang=en

into Arctos taxonomy


create table temp_c_t (
	id varchar2(255),
	p_id varchar2(255),
	e_trm varchar2(255),
	f_trm varchar2(255),
	alt_trm varchar2(255)
);



delete from temp_c_t;

select e_trm,alt_trm,f_trm from temp_c_t where rownum<10;

select p_id from temp_c_t group by p_id order by p_id;


SELECT SYS_CONNECT_BY_PATH(e_trm, '/') "p1",SYS_CONNECT_BY_PATH(alt_trm, '/') "p2",SYS_CONNECT_BY_PATH(f_trm, '/') "p3" FROM temp_c_t START WITH p_id is null CONNECT BY NOCYCLE PRIOR id = p_id;




SELECT SYS_CONNECT_BY_PATH(e_trm, '/') "Path" FROM temp_c_t START WITH p_id is null CONNECT BY NOCYCLE PRIOR id = p_id;




---->
<cffile action = "read" file = "/usr/local/httpd/htdocs/wwwarctos/temp/ctax.jsonld" variable = "x">

<cfset j=DeserializeJSON(x)>

<!--- outer array and struct are meaningless --->
<cfset ar=j[1]["@graph"]>

<!----
<cfdump var=#ar#>
---->
<cftransaction>
<cfloop from ="1" to="#ArrayLen(ar)#" index="i">
	<cfset thisrec=ar[i]>
<!---
	<cfdump var=#thisrec#>
	---->
	<cfset thisID=thisrec["@id"]>
	<!---
	<br>thisID::#thisID#
	--->

	<cfif structkeyexists(thisrec,"http://www.w3.org/2004/02/skos/core##broader")>
		<cfset thisPID=thisrec["http://www.w3.org/2004/02/skos/core##broader"][1]["@id"]>
	<cfelse>
		<cfset thisPID=''>
	</cfif>

	<cfif structkeyexists(thisrec,"http://www.w3.org/2004/02/skos/core##altLabel")>
		<cfset thisAL=thisrec["http://www.w3.org/2004/02/skos/core##altLabel"][1]["@value"]>
		<!---
		<br>thisAL::#thisAL#
		--->
	<cfelse>
		<cfset thisAL=''>
	</cfif>
	<cfset thisET="">
	<cfset thisFT="">
	<cfif structkeyexists(thisrec,"http://www.w3.org/2004/02/skos/core##prefLabel")>
		<cfset tary=thisrec["http://www.w3.org/2004/02/skos/core##prefLabel"]>
		<!----
		<cfdump var=#tary#>
		---->
		<cfloop from="1" to="#ArrayLen(tary)#" index="idx">
			<cfset thisLG=tary[idx]["@language"]>
			<!----
			<br>thisLG::#thisLG#
			---->
			<cfif thisLG is 'en'>
				<cfset thisET=tary[idx]["@value"]>
			<cfelseif thisLG is 'fr'>
				<cfset thisFT=tary[idx]["@value"]>
			</cfif>
		</cfloop>
	</cfif>
<!---
	<br>thisET::#thisET#
	<br>thisFT::#thisFT#


	<br>thisPID::#thisPID#
--->



	<cfquery name="ist" datasource="uam_god">
		insert into temp_c_t (id,p_id,e_trm ,f_trm ,alt_trm) values ('#thisID#','#thisPID#','#thisET#','#thisFT#','#thisAL#')
	</cfquery>

</cfloop>
</cftransaction>
</cfoutput>
