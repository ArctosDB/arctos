<!---- first, make a table of integers from 1 to the highest number we already have with
	create table numbers (num number);
	create public synonym numbers for numbers;
	grant select,insert,update,delete on numbers to uam_update;
---->
<!----
<cfquery name="highCat" datasource="#Application.uam_dbo#">
	select max(cat_num) cat_num from cataloged_item where collection_cde='Mamm'
</cfquery>
<cfquery name="whatWeGot" datasource="#Application.uam_dbo#">
	select max(num) num from numbers
</cfquery>
<cfloop from="#whatWeGot.num#" to="#highCat.cat_num#" index="i">
<cfquery name="moreNumbers" datasource="#Application.uam_dbo#">
	insert into numbers (num) values (#i#)
</cfquery>
</cfloop>	

<!---- now figure out what ain't there ---->
<cfquery name="notThere" datasource="#Application.uam_dbo#">
	select cat_num from cataloged_item 
	where 
	collection_cde='Mamm' and 
	cat_num < 80000 and
	not exists (select num from numbers)
	order by cat_num
</cfquery>
The following catalog numbers don't exist:
<p></p>
<cfoutput>
	<cfloop query="notThere">
		#cat_num#<br>
	</cfloop>
</cfoutput>

---->

<cfquery name="mcn" datasource="uam_god">
	select cat_num from mammalcatnums 
	where cat_num between 5000 and 5500
</cfquery>
1<cfflush>
<cfquery name="maxcat" datasource="uam_god">
	select max(cat_num) maxcatnum from mammalcatnums
</cfquery>
2<cfflush>
<cfquery name="numbers" datasource="uam_god">
	select rownum r from all_tab_columns where rownum <= 5501
</cfquery>
#maxcat.maxcatnum#
got numbers<cfflush>

<cfoutput>
<cfloop query="mcn">
	<cfquery name="notThere" dbtype="query">
		select r from numbers where r =#cat_num#
	</cfquery>
	<cfif #len(notThere.r)# is 0>
		#cat_num# is not there<br>
	<cfelse>
		#cat_num# - its there<br>
	</cfif>
	<cfflush>
</cfloop>
got it
</cfoutput>