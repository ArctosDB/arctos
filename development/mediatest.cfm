<cfinclude template="/includes/_header.cfm">

<link type="text/css" href="/development/js/skin/miniplayer.css" rel="stylesheet">



<script type='text/javascript' language="javascript" src='/development/js/jquery.jplayer.min.js'></script>


<script type='text/javascript' language="javascript" src='/development/js/jquery.mb.miniPlayer.js'></script>

http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6229_Cicero_26Jun2006_Pmaculatus1_CC3215.mp3
<style type="text/css">

    /*Generic page style*/

    body{
      font:normal 13px/16px 'trebuchet MS', sans-serif;
      margin:10px;
      background: #ffffff;
    }
    .wrapper{
      position:relative;
      padding-top:90px;
      padding-left:50px;
      width:80%;
      margin:auto
    }
    .wrapper h1{
      font-family:Arial, Helvetica, sans-serif;
      font-size:26px;
    }
    button{
      padding:3px;
      display:inline-block;
      cursor:pointer;
      font:12px/14px Arial, Helvetica, sans-serif;
      color:#fff;
      background-color:#ccc;
      -moz-border-radius:5px;
      -webkit-border-radius:5px;
      -moz-box-shadow:#999 1px 1px 3px;
      -webkit-box-shadow:#999 1px 1px 3px;
      border:1px solid white;
      text-shadow: 1px -1px 2px #aaa9a9 !important;
    }
    button:hover{
    /*background-color:#fff;*/
      color:#666;
    }
    hr{
      border:none;
      background-color:#ccc;
      height:1px;
    }

  </style>
<script>
	
	
$(document).ready(function(){


	 $(".audio").mb_miniPlayer({
        width:240,
        inLine:false
      });
      
      
});
	
</script>


<br>
<br>
<br>
<br>
<div class="wrapper">
  <h1>mb.miniAudioPlayer.demo</h1>
  <br>
  This is a GUI implementation of <a href="http://www.happyworm.com/jquery/jplayer/" target="_blank"><strong>Happyworm jPlayer plugin</strong></a>, an HTML5 audio engine, developed on jQuery framework, that let you listen mp3 and ogg file over the html5 audio tag where supported or using an invisible flash player where not supported.
  For more informations about html5 browsers' support go to <a href="http://www.happyworm.com/jquery/jplayer/latest/developer-guide.htm">jPlayer documentation site</a>.
<br>
<br>
<br>
  <a id="m1" class="audio {ogg:'http://www.miaowmusic.com/ogg/Miaow-07-Bubble.ogg'}" href="http://www.miaowmusic.com/mp3/Miaow-07-Bubble.mp3">miaowmusic - Bubble (mp3/ogg)</a>
  <span>param -> all features</span>
  <hr>
  <a id="m2" class="audio {skin:'orange', ogg:'http://www.miaowmusic.com/ogg/Miaow-02-Hidden.ogg', showTime:false}" href="http://www.miaowmusic.com/mp3/Miaow-02-Hidden.mp3">miaowmusic - Hidden (ogg/mp3)</a>
  <span> param -> showTime:false, ogg:'http://www.miaowmusic.com/ogg/Miaow-02-Hidden.ogg' (FF will play it as HTML5)</span>
  <hr>
  <a id="m3" class="audio {skin:'blue', autoPlay:false,showRew:false}" href="http://www.miaowmusic.com/mp3/Miaow-08-Stirring-of-a-fool.mp3">miaowmusic - Stirring of a Fool (mp3)</a>
  <span>param -> showRew:false</span>
  <hr>
  <a id="m4" class="audio {skin:'red', autoPlay:false,showRew:false, showTime:false}" href="http://www.miaowmusic.com/mp3/Miaow-04-Lismore.mp3">miaowmusic - Lismore (mp3)</a>
  <span>param -> showRew:false, showTime:false</span>
  <hr>
  <a id="m5" class="audio {skin:'green', autoPlay:false, addShadow:false}" href="http://www.miaowmusic.com/mp3/Miaow-08-Stirring-of-a-fool.mp3">miaowmusic - Stirring of a Fool (mp3)</a>
  <br>
  <div>change track:
    <br>
    <button onclick="$('#m5').mb_mAPchangeFile('http://www.miaowmusic.com/mp3/Miaow-04-Lismore.mp3',false,'Lismore (mp3)')">miaowmusic - Lismore</button>
    <button onclick="$('#m5').mb_mAPchangeFile('http://www.miaowmusic.com/mp3/Miaow-02-Hidden.mp3',false,'Hidden (mp3)')">miaowmusic - Hidden</button>
  </div>
  <br>
<hr>
  This is a gray player: <a  class="audio {skin:'gray', autoPlay:false, inLine:true, showVolumLevel:false, showRew:true, showTime:false, width:100, addShadow:false}" href="http://www.miaowmusic.com/mp3/Miaow-04-Lismore.mp3">miaowmusic - Lismore (mp3)</a>
  <span>and it is inline</span>

  <hr>
  <br>
  <b>jquery.mb.miniPlayer</b> is a GUI implementation of the <a href="http://www.jplayer.org" target="_blank">jquery.jPlayer</a> plug-in realized by © Happyworm LTD. (many thanks to <a href="http://happyworm.com/blog/" target="_blank">Mark Boas</a>)
  <br>
  All the music are provided by <a href="http://www.miaowmusic.com" target="_blank">© miaowmusic</a>.
</div>

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
