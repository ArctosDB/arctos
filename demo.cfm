
<cfhttp method="head" url="http://web.corral.tacc.utexas.edu/MVZ/images/MVZ_img/images/jpg/img_15473.jpg">

</cfhttp>
<cfdump var=#cfhttp#>


<cfabort>


<cfinclude template="/includes/_header.cfm">

	<cfparam name="p" default="1">
	<cfparam name="pagesize" default="1000">
	<cfparam name="sort" default="temp_glus.COLLECTING_EVENT_ID">

	<cfset start=(p * pagesize)>
	<cfset stop=start+pagesize>
<cfoutput>


	<form id="f" method="get" action="demo.cfm">
		<label for="p">page</label>
		<input id="p" type="text" name="p" value="#p#">
		<label for="pagesize">pagesize</label>
		<input type="text" name="pagesize" value="#pagesize#">
		<label for="sort">sort</label>
		<select name="sort">
			<option value="temp_glus.COLLECTING_EVENT_ID" <cfif sort is "temp_glus.COLLECTING_EVENT_ID"> selected="selected" </cfif>>temp_glus.COLLECTING_EVENT_ID</option>
			<option value="orig_lat_long_units" <cfif sort is "orig_lat_long_units"> selected="selected" </cfif>>orig_lat_long_units</option>
			<option value="spec_locality" <cfif sort is "spec_locality"> selected="selected" </cfif>>spec_locality</option>
		</select>
		<input type="submit">
	</form>

	<cfset np=p+1>
	<cfset pp=p-1>
	<span class="likeLink" onclick="$('##p').val(parseInt($('##p').val())-1);$('##f').submit();">previous page</span>
	<span class="likeLink" onclick="$('##p').val(parseInt($('##p').val())+1);$('##f').submit();">next page</span>



	<cfquery name="f" datasource="uam_god">
		select blfld from temp_getMakeCE_flds where blfld not in
			('COLLECTING_EVENT_ID','WKT_POLYGON') order by ord
	</cfquery>

	<cfset fldlst=valuelist(f.blfld)>


		<cfquery name="d" datasource="uam_god">


				Select * from (
						Select a.*, rownum rnum From (
							select
				distinct
				temp_glus.COLLECTING_EVENT_ID,
				temp_glus.err,
				#fldlst#
			from
				temp_glus,
				bulkloader
			where
				temp_glus.collection_object_id=bulkloader.collection_object_id
				order by #sort#
						) a where rownum <= #stop#
					) where rnum >= #start#

		</cfquery>

		<table border>
			<tr>
				<th>EventOrError</th>
				<cfloop list="#fldlst#" index="i">
					<th>#i#</th>
				</cfloop>
			</tr>
			<cfloop query="d">
				<tr>
					<td>
						<cfif len(collecting_event_id) gt 0>
							<a href="/Locality.cfm?Action=findCollEvent&collecting_event_id=#collecting_event_id#" target="_blank">#collecting_event_id#</a>
						<cfelse>
							#err#
						</cfif>
					</td>
					<cfloop list="#fldlst#" index="i">
						<td>#evaluate("d." & i)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>




</cfoutput>




<cfabort>


























<!------------------------------------------------------------------------------------>

<hr>

rangesliderthingee
	<link href="/includes/jQRangeSlider-5.7.2/css/iThing.css" rel="stylesheet" media="screen">
  <script src="/includes/jQRangeSlider-5.7.2/jQDateRangeSlider-min.js"></script>
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">

<hr>---------- date range slider demo ----------<hr>
<style>
	#dateSlider{width:40%;}
</style>
<script>
$(document).ready(function(){

/*
	 $('#specresults').jtable({
	            title: 'Specimen Results',
				paging: true, //Enable paging
	            pageSize: 10, //Set page size (default: 10)
	            sorting: true, //Enable sorting
	            //defaultSorting: 'GUID ASC', //Set default sorting
				columnResizable: true,
				//recordsLoaded: getPostLoadJunk,
				multiSorting: true,
				columnSelectable: false,
				multiselect: true,
				//selectingCheckboxes: true,
  				//selecting: true, //Enable selecting
          		//selectingCheckboxes: true, //Show checkboxes on first column
            	//selectOnRowClick: false, //Enable this to only select using checkboxes
				pageSizes: [10, 25, 50, 100, 250, 500,5000],
	            fields:  {
					 SCIENTIFIC_NAME:  {title: 'IDENTIFIEDAS'}
	            }
	        });
	       // $('#specresults').jtable('load');


*/
      $("#dateSlider").dateRangeSlider({
        bounds: {min: new Date(1800, 0, 1), max: new Date()},
        defaultValues: {min: new Date(1800, 1, 10), max: new Date()},
        scales: [{
          next: function(val){
            var next = new Date(val);
            return new Date(next.setMonth(next.getMonth() + 1));
          },
          label: function(val){
            return Months[val.getMonth()];
          },
           formatter:function(val){
                var days =  ("0" + (val.getDate()).slice(-2)),
                  month = val.getMonth() + 1,
                  year = val.getFullYear();
                return days + "/" + month + "/" + year;
              }

        }]
      });

          $("#dateSlider").bind("valuesChanged", function(e, data){
          	console.log(data);
          	var bd=("0" + (data.values.min.getDate())).slice(-2) ,
          		bm=("0" + (data.values.min.getMonth() + 1)).slice(-2),
          		by=data.values.min.getFullYear();
          	var ed=("0" + (data.values.max.getDate())).slice(-2) ,
          		em=("0" + (data.values.max.getMonth() + 1)).slice(-2),
          		ey=data.values.max.getFullYear();

          	$("#minDate").val(by + '-' + bm + '-' + bd );
          	$("#maxDate").val(ey + '-' + em + '-' + ed );

          	console.log('by: ' + by);
          	console.log('bm: ' + bm);
          	console.log('bd: ' + bd);
      console.log("Values just changed. min: " + data.values.min + " max: " + data.values.max);



    });

$("#sss").submit(function( event ) {
	$.ajax({
		url: "/component/simplesearch.cfc?queryformat=column&method=getSSSpecimens&returnformat=json",
		type: "GET",
		dataType: "json",
		data:  {
			what:  $("#what").val(),
			when:  $("#when").val(),
			where:  $("#where").val()
		},
		success: function(r) {
			alert(r);
			var t='<table id="srtbl">';
			for (i=0;i<r.ROWCOUNT;i++) {
				t+='<tr>';
					t+='<td>' + r.DATA.SCIENTIFIC_NAME[i] + '</td>';
				t+='</tr>';
			}
			t+='</table>';
			$("#specresults").html(t);
		},
		error: function (xhr, textStatus, errorThrown){

		    alert(errorThrown + ': ' + textStatus + ': ' + xhr);

		}
	});



  event.preventDefault();
});

    });
</script>
<!----

        $("#formatterExample").dateRangeSlider({
          formatter:function(val){
                var days = val.getDate(),
                  month = val.getMonth() + 1,
                  year = val.getFullYear();
                return days + "/" + month + "/" + year;
              }
        });

		---->











<hr>---------- possible "simple search" or default Arctos search page demo ----------<hr>

<h1>Search Arctos</h1>
<h2>Site Search</h2>

<div id="cse" style="width: 50%;">Loading</div>

<script src="http://www.google.com/jsapi" type="text/javascript"></script>
<script type="text/javascript">
  google.load('search', '1', {language : 'en'});
  google.setOnLoadCallback(function(){
    var customSearchControl = new google.search.CustomSearchControl('011384802149075345004:_xhrdehjm50');
    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
    customSearchControl.draw('cse');
  }, true);
</script>
<link rel="stylesheet" href="http://www.google.com/cse/style/look/default.css" type="text/css" />




<h2>Specimens</h2>
<p>
<a href="/SpecimenSearch.cfm">Click here for advanced specimen search</a>
</p>

<blockquote>
	<form name="sss" id="sss">
<label for="">What</label>
<input type="text" id="what" placeholder="identification or common name">
<br>Try <a href="#">Marmot</a> or <a href="#">Arrowhead</a>

<label for="">Where</label>
<input id="where" type="text" placeholder="Place Name">
<br>Try <a href="#">Albuquerque</a>


<label for="">When</label>
	     <div id="dateSlider"></div>


From <input id="minDate" placeholder="earliest date"> to <input id="maxDate" placeholder="latest date">

<br><input type="submit" value="find specimens">
</form>
</blockquote>
	<div id="specresults"></div>



<H2>
	Projects and Publications
</H2>

	<br>there's a box or 2 here....

<H2>
	Taxonomy
</H2>

	<br>there's a box or 2 here....


<H2>
	People and Agencies
</H2>

	<br>there's a box or 2 here....

<cfinclude template="/includes/_pickFooter.cfm">