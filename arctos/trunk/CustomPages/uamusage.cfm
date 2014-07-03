<cfinclude template="/includes/_header.cfm">
	<cfquery name="d" datasource="uam_god">
		select 
			collection,month,
			sum(numberQueries) totalQueries,
			sum(numberRecordViews) totalRecordViews
		from (
		    select 
		  		collection.collection,
				to_char(qs.create_date, 'YYYY-MM') month,
		  		count(qsc.query_id) numberQueries,
		  		sum(qsc.rec_count) numberRecordViews
			from 
		  		uam_query.query_stats qs, 
		  		uam_query.query_stats_coll qsc,
				collection
			where 
		  		qs.query_id = qsc.query_id
		  		and qsc.collection_id = collection.collection_id 
			group by 
				to_char(qs.create_date, 'YYYY-MM'),
				collection
			order by 
				to_char(qs.create_date, 'YYYY-MM'),
				collection
		  )
		group by collection,month
	</cfquery>



<cfchart format="flash" 
    xaxistitle="collection" 
    yaxistitle="Salary Average"> 

<cfchartseries type="bar" 
    query="d" 
    itemcolumn="collection" 
    valuecolumn="month">

<cfchartdata item="Facilities" value="35000">

</cfchartseries>
</cfchart> 



<cfinclude template="/includes/_footer.cfm">



select 
	collection.collection,
	sum(numberQueries) totalQueries,
	sum(numberRecordViews) totalRecordViews
from (
    select 
  		to_char(qs.create_date, 'YYYY-MM') month,
  		count(qsc.query_id) numberQueries,
  		sum(qsc.rec_count) numberRecordViews
	from 
  		uam_query.query_stats qs, 
  		uam_query.query_stats_coll qsc
	where 
  		qs.query_id = qsc.query_id
  		and qsc.collection_id = 20
  		and to_char(qs.create_date, 'YYYY')='2013'
group by to_char(qs.create_date, 'YYYY-MM')
order by to_char(qs.create_date, 'YYYY-MM')
  )
  ;


select 
	collection,month,
	sum(numberQueries) totalQueries,
	sum(numberRecordViews) totalRecordViews
from (
    select 
  		collection.collection,
		to_char(qs.create_date, 'YYYY-MM') month,
  		count(qsc.query_id) numberQueries,
  		sum(qsc.rec_count) numberRecordViews
	from 
  		uam_query.query_stats qs, 
  		uam_query.query_stats_coll qsc,
		collection
	where 
  		qs.query_id = qsc.query_id
  		and qsc.collection_id = collection.collection_id 
	group by 
		to_char(qs.create_date, 'YYYY-MM'),
		collection
	order by 
		to_char(qs.create_date, 'YYYY-MM'),
		collection
  )
group by collection,month
  ;