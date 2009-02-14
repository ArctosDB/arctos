<cfoutput>
	<cfquery name="ed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
    count(cat_num) as cnt,
    to_char(COLL_OBJECT_ENTERED_DATE,'YYYY') as yr
from
        cataloged_item,
    coll_object
    where
    cataloged_item.collection_object_id = coll_object.collection_object_id
    and collection_id=1
   group by
   to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')
   order by
   to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')
	</cfquery>
	
	
	select
    count(cat_num) as cnt,
    to_char(COLL_OBJECT_ENTERED_DATE,'YYYY') as yr
from
        cataloged_item,
    coll_object
    where
    cataloged_item.collection_object_id = coll_object.collection_object_id
    and collection_id=1
   group by
   to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')
   order by
   to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')
   <p>
   Potential Issues:
	<ul>
		<li>Entered Date was recently added to the database model</li>
		<li>Entered Date is a poor indicator of when the specimen became property of the collection</li>
		<li>Entered Date is a really poor indicator of when the specimen was collected</li>
	</ul>
   </p>
<table border>
	<cfloop query="ed">
		<tr>
			<td>#yr#</td>
			<td>#cnt#</td>
		</tr>
	</cfloop>
</table>
<hr>


select 
count(cat_num) as cnt,
RECEIVED_DATE
from
cataloged_item,
accn
where 
cataloged_item.accn_id = accn.transaction_id
and collection_id=1
group by 
RECEIVED_DATE
order by 
RECEIVED_DATE
<p>
   	Potential Issues:
	<ul>
		<li>Received Date was recently added to the database model</li>
		<li>Received Date is a really poor indicator of when the specimen was collected</li>
		<li>Received Date is not a date-format field, so CF magic to produce data below dropped some specimens</li>
	</ul>
   </p>
<cfquery name="rd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
count(cat_num) as cnt,
RECEIVED_DATE
from
cataloged_item,
accn
where 
cataloged_item.accn_id = accn.transaction_id
and collection_id=1
group by 
RECEIVED_DATE
order by 
RECEIVED_DATE
</cfquery>
<cfset dq = QueryNew("cnt, yr")>
<cfset i=1>
<cfloop query="rd">
	<cfif isdate(RECEIVED_DATE)>
		<cfset newRow  = QueryAddRow(dq, 1)>
		<cfset temp = QuerySetCell(dq, "cnt", cnt, #i#)>
		<cfset temp = QuerySetCell(dq, "yr", dateformat(RECEIVED_DATE,'yyyy'), #i#)>
		<cfset i=#i#+1>
	</cfif>
</cfloop>

<cfquery name="aby" dbtype="query">
	select sum(cnt) as cnt,
	 yr 
	from dq 
	group by yr
	order by yr
</cfquery>

<table border>
<cfloop query="aby">
	<tr>
		<td>#yr#</td>
		<td>#cnt#</td>
	</tr>
</cfloop>
</table>

<cfquery name="cd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		count(cat_num) as cnt,
		to_char(began_date,'yyyy') as yr
	from
	cataloged_item,
	collecting_event
	where 
	cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
	collection_id=1
	and to_char(began_date,'yyyy') = to_char(ended_date,'yyyy')
	group by to_char(began_date,'yyyy')
	order by 
	to_char(began_date,'yyyy')
</cfquery>

select 
		count(cat_num) as cnt,
		to_char(began_date,'yyyy') as yr
	from
	cataloged_item,
	collecting_event
	where 
	cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
	collection_id=1
	and to_char(began_date,'yyyy') = to_char(ended_date,'yyyy')
	group by to_char(began_date,'yyyy')
	order by 
	to_char(began_date,'yyyy')
	
	<p>
   	Potential Issues:
	<ul>
		<li>This only gets specimens where began_date and ended_date are in the same year</li>
		<li>Coll Date is often a poor indicator of when the specimen entered the collection</li>
		<li>Coll Date is often a poor indicator of when the specimen was cataloged</li>
	</ul>
   </p>
   
   
	<table border>
	<cfloop query="cd">
		<tr>
			<td>#yr#</td>
			<td>#cnt#</td>			
		</tr>
	</cfloop>
	</table>
</cfoutput>