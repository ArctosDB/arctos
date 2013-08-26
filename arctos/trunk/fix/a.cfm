<label>
	Taxonomy and Identification
</label><br>
<input type="text" value="type taxon term here">

<p>Include in taxonomy search





<label>
	Taxonomy and Identification
</label><br>
<input type="text" value="type taxon term here">
<p>
	Match Type (pick one)
	contains<input type="radio" checked="checked">
is<input type="radio">
does not contain<input type="radio">
</p>
<p>
Scope (check one or more)
<br>Current Identification <input type="checkbox" checked="checked">
<br>Previous Identification <input type="checkbox">
<br>Collection's Taxonomy<input type="checkbox" checked="checked">
<br>Related and webservice taxonomy
<select>
	<option>do not include</option>
	<option>include all sources</option>
	<option>Arctos classification</option>
	<option>NCBI classification</option>
	<option>ca. 60 more things</option>
	<option>you've probably never heard of most of them</option>
	<option>and most of them probably do not....</option>
	<option>... have any data for most specimens</option>
</select>


<br>Current Taxonomy (by globalnames) <input type="checkbox" checked="checked">
<br>Related Taxonomy  (by collection)<input type="checkbox" checked="checked">
<br>Related Taxonomy  (by globalnames)<input type="checkbox" checked="checked">
<br>common name <input type="checkbox" checked="checked">
</p>


<table border>
	<tr>
		<th></th>
		<th>check</th>
	</tr>
	<tr>
		<tr>
			<td></td>
			<td></td>
		</tr>
	</tr>
</table>


<cfabort>
<cfinclude template="/includes/_header.cfm">

	<script src="/includes/jQuery.jPlayer.2.4.0/jquery.jplayer.min.js"></script>


<script>
 $(document).ready(function(){

	$("#jquery_jplayer_1").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", {
				mp3:"http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6231_Cicero_26Jun2006_Pmaculatus3.mp3"
			});
		},
		swfPath: "/includes/jQuery.jPlayer.2.4.0/",
		supplied: "mp3",
		wmode: "window",
		smoothPlayBar: true,
		keyEnabled: true
	});

});


</script>

--------
<audio controls>
  <source src="http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6231_Cicero_26Jun2006_Pmaculatus3.mp3" type="audio/mpeg">
Your browser does not support the audio element.
</audio> 
--------------
<div id="jquery_jplayer_1" class="jp-jplayer"></div>

		<div id="jp_container_1" class="jp-audio">
			<div class="jp-type-single">
				<div class="jp-gui jp-interface">
					<ul class="jp-controls">
						<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
						<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
						<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
					</ul>
					<div class="jp-progress">
						<div class="jp-seek-bar">
							<div class="jp-play-bar"></div>
						</div>
					</div>
					<div class="jp-volume-bar">
						<div class="jp-volume-bar-value"></div>
					</div>
					<div class="jp-current-time"></div>
					<div class="jp-duration"></div>
					<ul class="jp-toggles">
						<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
						<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
					</ul>
				</div>
				<div class="jp-title">
					<ul>
						<li>Cro Magnon Man</li>
					</ul>
				</div>
				<div class="jp-no-solution">
					<span>Update Required</span>
					To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
				</div>
			</div>
		</div>
		<cfinclude template="/includes/_footer.cfm">

