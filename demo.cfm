<cfinclude template="/includes/_header.cfm">
	<link href="/includes/jQRangeSlider-5.7.2/css/classic.css" rel="stylesheet" media="screen">
  <script src="/includes/jQRangeSlider-5.7.2/jQDateRangeSlider-min.js"></script>

<hr>---------- date range slider demo ----------<hr>

<script>
$(document).ready(function(){
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
          }
        }]
      });

          $("#dateSlider").bind("valuesChanged", function(e, data){
      console.log("Values just changed. min: " + data.values.min + " max: " + data.values.max);
    });


    });
</script>




      <div class="sliderContainer"><div id="dateSlider"></div></div>








<hr>---------- possible "simple search" or default Arctos search page demo ----------<hr>

<h1>Search Arctos</h1>
<h2>Specimens</h2>
<p>
I'm a link click for full search
</p>

<blockquote>
<label for="">What</label>
<input type="text" placeholder="identification or common name">
<br>Try <a href="#">Marmot</a> or <a href="#">Arrowhead</a>

<label for="">Where</label>
<input type="text" placeholder="Place Name">
<br>Try <a href="#">Albuquerque</a>


<label for="">When (slide to pick year range)</label>
 <input id="test" type="range"/>

<br><input type="button" value="click to search">
</blockquote>

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