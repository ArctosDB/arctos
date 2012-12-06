<cfinclude template="/includes/_header.cfm">


	 <link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />
	    <script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>



	<style>
		#container {
            border: 1px solid black;
            overflow: hidden;
            margin: auto;
        }
        #container .wrapper {
            width: 100%;
        }
        #container #left-col .item {
            margin: .5em .25em .5em .5em;
            border: 1px solid black;
        }
        #container #right-col .item {
            margin: .5em .5em .5em .25em;
            border: 1px solid black;
        }
        #left-col, #right-col { width: 50%;    }
        #left-col { float: left; }
        #right-col { float: right; }
        .item h2 { background: #ccc; }
	</style>

	<script>

jQuery(document).ready(function() {

			$(function() {
			    $("#left-col").sortable({
			        connectWith: '#right-col'
			    }).disableSelection();
			    $("#right-col").sortable({
			        handle: '.item h2',
			        connectWith: '#left-col'
			    }).disableSelection();
			});
		});

function r(){
	var newOrdering = $('#right-col').sortable('toArray');
	console.log('newOrderingR='+newOrdering);
	 var newOrdering = $('#left-col').sortable('toArray');
    						console.log('newOrderingL='+newOrdering);
	}
	function refreshPositions(){
			console.log('refreshPositions');

		$("#left-col").sortable("refreshPositions");
		$("#right-col").sortable("refreshPositions");
	}
	</script>
<span class="likeLink" onclick="r();">sort</span>
	<span class="likeLink" onclick="refreshPositions();">refreshPositions</span>

	<div id="container">
	    <div id="left-col">
	        <div class="wrapper" id="w1">
	            <div class="item" id="i1">
	                <h2>Row 1 Column 1</h2>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	        <div class="wrapper" id="w2">
	            <div class="item" id="i2">
	                <h2>Row 2 Column 1</h2>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	    </div><!-- end left-col -->
	    <div id="right-col">
	        <div class="wrapper" id="w3">
	            <div class="item">
	                <h2>Row 1 Column 2</h2>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	        <div class="wrapper" id="w4">
	            <div class="item">
	                <h2>Row 2 Column 2</h2>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	    </div><!-- end right-col -->
	</div>