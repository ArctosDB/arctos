<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("media_id")>
	<cfset media_id=10273014>
</cfif>



<link type="text/css" href="/development/js/skin/jplayer.blue.monday.css" rel="stylesheet">


<script type='text/javascript' language="javascript" src='/development/js/jquery.jplayer.min.js'></script>


http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6229_Cicero_26Jun2006_Pmaculatus1_CC3215.mp3

<cfoutput>
<br><a href="mediatest.cfm?media_id=10242699">10242699</a>
<br><a href="mediatest.cfm?media_id=10242701">10242701</a>
<br><a href="mediatest.cfm?media_id=10242701,10242699">10242701,10242699</a>
	
	
<cfquery name="m" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from media where media_id in (#media_id#)
</cfquery>

<cfset thingsWeCanPlay="audio/mpeg3">
<cfset i=1>
<cfset theJS=''>
<cfloop query="m">
	<cfif mime_type is 'audio/mpeg3'>
		<cfset thisType='mp3'>
	</cfif>
<cfset theJS=theJS & '
		$("##jquery_jplayer_#i#").jPlayer({
		ready: function () {
			$(this).jPlayer("setMedia", {
				#thisType#:"#m.media_uri#"
			});
		},
		swfPath: "/development/js",
		supplied: "#thisType#",
		wmode: "window"
	});
		'>
	
	
	
	
	
	
	
	
	
	<cfset i=i+1>
	</cfloop>
<cfdump var=#m#>


<hr>

#theJS#

<hr>
<script>
	
	
$(document).ready(function(){
	#theJS# 
});
	
</script>
<cfset i=1>

<cfloop query="m">
	<cfif mime_type is 'audio/mpeg3'>
		<div id="jquery_jplayer_#I#" class="jp-jplayer"></div>
		<div id="jp_container_#I#" class="jp-audio">
			<div class="jp-type-single">
				<div class="jp-gui jp-interface">
					<ul class="jp-controls">
						<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
						<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
						<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
						<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>
						<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>
						<li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>
					</ul>
					<div class="jp-progress">
						<div class="jp-seek-bar">
							<div class="jp-play-bar"></div>
						</div>
					</div>
					<div class="jp-volume-bar">
						<div class="jp-volume-bar-value"></div>
					</div>
					<div class="jp-time-holder">
						<div class="jp-current-time"></div>
						<div class="jp-duration"></div>

						<ul class="jp-toggles">
							<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
							<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
						</ul>
					</div>
				</div>
				<div class="jp-title">
					<ul>
						<li>#m.media_uri#</li>
					</ul>
				</div>
				<div class="jp-no-solution">
					<span>Update Required</span>
					To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
				</div>
			</div>
		</div>
	<cfelse>
		<!--- not something we can play ---->
		<br>this is a normal media thingee, whatever that means.
	</cfif>

	<cfset i=i+1>
	</cfloop>


		
		
	</cfoutput>	
<!-------
	$("#jquery_jplayer_1").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", {
				mp3:"http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6229_Cicero_26Jun2006_Pmaculatus1_CC3215.mp3"
			});
		},
		swfPath: "/development/js",
		supplied: "mp3"
	});
	
	
	
	
	$("##jquery_jplayer_#i#").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", {
				#thisType#:"#m.media_uri#"
			});
		},
		swfPath: "/development/js",
		supplied: "#thisType#"
	});
	

$(document).ready(function(){

	$("#jquery_jplayer_1").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", {
				m4a:"http://www.jplayer.org/audio/m4a/TSP-01-Cro_magnon_man.m4a",
				oga:"http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg"
			});
		},
		swfPath: "/development/js",
		supplied: "m4a, oga",
		wmode: "window"
	});
});



  <div id="jquery_jplayer_1" class="jp-jplayer"></div>
  <div id="jp_container_1" class="jp-audio">
    <div class="jp-type-single">
      <div class="jp-gui jp-interface">
        <ul class="jp-controls">
          <li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
          <li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
          <li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
          <li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>
          <li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>
          <li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>
        </ul>
        <div class="jp-progress">
          <div class="jp-seek-bar">
            <div class="jp-play-bar"></div>
          </div>
        </div>
        <div class="jp-volume-bar">
          <div class="jp-volume-bar-value"></div>
        </div>
        <div class="jp-time-holder">
          <div class="jp-current-time"></div>
          <div class="jp-duration"></div>
          <ul class="jp-toggles">
            <li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
            <li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
          </ul>
        </div>
      </div>
      <div class="jp-title">
        <ul>
          <li>Bubble</li>
        </ul>
      </div>
      <div class="jp-no-solution">
        <span>Update Required</span>
        To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
      </div>
    </div>
  </div>


-------------->
<cfinclude template="/includes/_footer.cfm">
