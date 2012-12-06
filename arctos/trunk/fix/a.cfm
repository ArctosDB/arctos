<cfinclude template="/includes/_header.cfm">


	 <link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />
	    <script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>



	<style>
		
	</style>

	<script>

jQuery(document).ready(function() {








	</script>
<span class="likeLink" onclick="r();">sort</span>
	<span class="likeLink" onclick="refreshPositions();">refreshPositions</span>
	<span class="likeLink" onclick="reorder();">sortw1,w3,w4</span>

	<div id="container">
	    <div id="left-col">
	        <div class="wrapper" id="w1">
	            <div class="item" id="i1">
	                <p class="celltitle">w one</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	        <div class="wrapper" id="w2">
	            <div class="item" id="i2">
	<span class="celltitle">w two</span>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	    </div><!-- end left-col -->
	    <div id="right-col">
	        <div class="wrapper" id="w3">
	            <div class="item">
	                <p class="celltitle">w three</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	        <div class="wrapper" id="w4">
	            <div class="item">
					<p class="celltitle">w four</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	                <p>Lorem ipsum dolor sit amet</p>
	            </div>
	        </div>
	    </div><!-- end right-col -->
	</div>