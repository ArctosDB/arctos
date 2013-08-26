	<cfinclude template="/includes/_header.cfm">



		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select 
					source,
					PREFERRED_TAXONOMY_SOURCE
				from 
					taxon_term,
					collection
				where
					source=PREFERRED_TAXONOMY_SOURCE (+)
				group by source,PREFERRED_TAXONOMY_SOURCE order by source
			</cfquery>
			
			
			<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select 
					term_type
				from 
					taxon_term
				where
					term_type is not null and 
					POSITION_IN_CLASSIFICATION is not null
				group by term_type order by term_type
			</cfquery>
			
			
			<cfset colnterms="PHYLCLASS,KINGDOM,PHYLUM,PHYLORDER,FAMILY,GENUS,SPECIES,SUBSPECIES">

<label>
	Taxonomy and Identification
</label>
<input type="text" placeholder="type taxon term here">

	<label>Match Type (pick one)</label>
	<select>
		<option>contains</option>
		<option>is</option>
		<option>does not contain</option>
	</select>
<label>Scope (check one or more)</label>
<label>Current Identification</label> <input type="checkbox" checked="checked">
<label>Previous Identification</label> <input type="checkbox">
<label>Collection's Taxonomy</label><input type="checkbox">
<label>Related and webservice taxonomy (* prefix = preferred by at least one collection)</label>
<cfoutput>
<select>
	<option>ignore this</option>
	<option>include all sources</option>
	<cfloop query="d">
		<option>
		<cfif len(PREFERRED_TAXONOMY_SOURCE) gt 0>* </cfif>
		#source#</option>
	</cfloop>
	
</select>



<label>Term Rank (* prefix = available as collection's taxonomy)</label>
<select>
	<option>ignore this</option>
	<cfloop query="r">
		<option>
		<cfif listcontainsnocase(colnterms,term_type)>* </cfif>
		#term_type#</option>
	</cfloop>
	
</select>

</fieldset>
</cfoutput>

<cfabort>

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

