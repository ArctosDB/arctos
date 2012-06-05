<cfinclude template="/includes/_header.cfm">
<style>
/*
 * -----------------------------------------------
 * www.jplayer.org
 * by Happyworm - www.happyworm.com
 * 
 * jPlayer.css
 * -----------------------------------------------
 */
 
 /* @group RESET */

/* 	css reset 
	by eric meyer http://meyerweb.com/eric/thoughts/2007/05/01/reset-reloaded/
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, font, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td {
	margin: 0;
	padding: 0;
	border: 0;
	outline: 0;
	font-weight: inherit;
	font-style: inherit;
	font-size: 100%;
	font-family: inherit;
	vertical-align: baseline;
}        


:focus {
	outline: none;
}
body {
	line-height: 1;
}
/*ol, ul {
	list-style: none;
}*/

/* @end */


body {
	background-color: #fff;
	color: #333;
	font: 1em/1.6 Verdana, Arial, sans-serif;
	margin:0;
	padding:0;
}

a {
	color:#009be3;
}

a:link {
	color:#009be3;
}

a:visited {
	color:#009be3;
}

a:hover {
	color:#009be3;
}

p {
	margin-bottom:1em;
}

ul {
	margin: 0;
	padding: 0 0 0 20px;
}

.dev_guide #content_main ul{
	list-style-type: disc;
}

h2 {
	color:#a0a600;
	margin: 0 0 20px 0;
	font-size:240%;
	line-height:140%;
	font-weight:normal;
}

h2 a{
	text-decoration:none;
	border-bottom: 1px solid #009be3;
}

h3 {
	color:#a0a600;
	font-size:200%;
	font-style:oblique;
	line-height:140%;
	margin-top:1.2em;
	margin-bottom:.6em;
}

h4 {
	color:#666;
	font-weight:bold;
	font-size:140%;
	margin-top:1em;
	margin-bottom:.5em;
}

h5 {
	color:#a0a600;
	font-weight:bold;
	font-size:120%;
	margin-top:1em;
	margin-bottom:.5em;
}


h6 {
	color:#666;
	font-size:120%;
	text-decoration:underline;
	margin-top:1em;
	margin-bottom:.5em;
}

strong {
	font-weight: bold;
}

a img {
	border: none;
	outline:none;	
}

nav {
	display:block;
}

#container {
	padding: 0 10px 20px 10px;
	margin: 0 auto;
	width: 978px;
	overflow: hidden;
}

header {
	position: relative;
	display:block;
	padding-top: 20px;
}

header > a {
	display: block;
	width: 300px;
}

header a{
	text-decoration:none;
}


header h1 {
	color:#a0a600;
	font-weight:normal;
	text-indent:28px;
	font-size:13.5px;
	margin-top:0;
}

header p a {
	display: block;
	position: absolute;
	top: 0;
	right: 0;
	width: 190px;
	height: 46px;
	background: url(../graphics/happyworm_logo.jpg) 0 0 no-repeat;
	text-indent:-9999px;
}

#content_main {
	width: 685px;
	float: left;
	font-size: 0.8em;
	margin-bottom: 40px;
	padding-top: 20px;
}

#content_main img.demo {
	float: right;
	margin: 0 0 20px 20px;
}

body.release_notes #content_main li {
	margin-bottom:8px;
}

aside {
	display: block;
	width: 264px;
	margin-left: 714px;
	margin-top: 4em;
	font-size:.7em;
}

aside a{
	color: #333;
}

aside .section {
	border: none;
	margin-bottom: 20px;
	padding: 0;
}

aside .highlight, aside .transbgr {
	padding: 10px 16px;
	margin: 0 0 20px 0;
	background-color: #f0f0f0;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
}

aside .transbgr {
	background-color: transparent;
}

.highlight h2, .transbgr h2 {
	color:#666;
	font-size:170%;
	line-height:160%;
}

aside .highlight h2 a, aside .transbgr h2 a{
	border-bottom:1px dotted #009be3;
	color: #009be3;
}

.highlight h3, .transbgr h3 {
	color:#a0a600;
	font-size:100%;
	font-weight:normal;
	line-height:160%;
	border-top: 1px solid #a0a600;
	margin: 16px -16px 0 -16px;
	padding:  0 16px 10px 16px;
}

aside .highlight h3 a, aside .transbgr h3 a {
	color:#a0a600;
	text-decoration:none;
}

aside form input {
	margin-bottom: 12px;
}

aside select,
input[type="text"] {
	border: 1px solid #999;
	padding: 6px 10px;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
}

/* placeholder: Used in Community email input. The HTML controls the color using onfocus/onblur code. Inital condition uses this value, so the code and this css need to match colors. */
input.placeholder {
	color:#999;
}

input.btn {
	background-color: #009be3;
	color: #fff;
	font-weight:bold;
	padding: 6px 14px;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
	border: 0;
}

input.btn:hover {
	cursor: pointer;
	background-color: #a0a600;
}


aside ul{
	margin: 0;
	padding: 0;
	list-style-type:none;	
}


/* @group NAVIGATION */

.main {
	float: right;
	font-size: 0.8em;
	margin-top:-53px;
}

.main ul {
	margin: 0;
	padding: 0;
	list-style: none;
	overflow: hidden;
/*	width:100%;*/
}

.main li {
	float: left;
	margin: 0;
	margin-left: 6px;
}

.main li a, .main li a:link, .main li a:visited{
	display: block;
	overflow: hidden;
	background-color: #666;
	color: #fff;
	text-decoration:none;
	padding: 6px 14px;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
}

.main li a:hover{
	background-color: #009be3;
}

.main li a:focus{
	background-color: #009be3;
}

.main li a:active{
	margin-top: 1px;
	outline: none;
}

body.jplayer .main li#home a, body.demos .main li#demos a, body.download .main li#download a, body.dev_guide .main li#dev_guide a, body.support .main li#support a, body.sites .main li#sites a, body.about .main li#about a, body.skins .main li#skins a {
	background-color:#A0A600;
}

ul#usp {
	width: 100%;
	padding: 0;
	margin: 0 0 20px 0;
	overflow:hidden;
}

ul#usp li{
	list-style-type:none;
	float:left;
	width:25%;
}

ul#usp li a{
	display: block;
	text-align:center;
	width:100%;
}


#breadcrumbs {
	list-style-type:none;
	margin: 0 ;
	padding: 0;
	width: 100%;
	overflow: hidden;
	font-size:90%;
}

#breadcrumbs li{
	float: left;
	color: #666;
	padding-right: .5em;
}

#menu_download {
	float: right;
	width: 206px;
	overflow: hidden;
	margin: 0;
	padding: 0;
	list-style-type:none;
}

#menu_download li{
	float: left;
}

#menu_download a{
	display: block;
	width: 206px;
	height: 94px;
}

#menu_download a:active {
	top: 0px;
}

#menu_download #plugin a{
	background: url(../graphics/jplayer_download_sprites.jpg) 0 0 no-repeat;
}

#menu_download #plugin a:hover{
	background: url(../graphics/jplayer_download_sprites.jpg) 0 -94px no-repeat;
}

#menu_download a span{
	display: block;
	text-indent:-999px;
}

/*.forkit {
	display: block;
	width: 192px;
	height: 50px;
	line-height:50px;
	background-color:#fff;
	margin: 20px 10px;
	text-align:center;
	float: right;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
	color: #666;
}*/

.forkit {
	padding-top:40px;
}

.forkit a{
	display: block;
	float: right;
	width:206px;
	height: 65px;
	background: url(../graphics/jplayer_download_sprites.jpg) 0 -188px no-repeat;
	text-indent:-9999px;
	margin-bottom: 30px;
}

.forkit a:hover{
	background: url(../graphics/jplayer_download_sprites.jpg) 0 -253px no-repeat;
}


/* @end */    

/* For efficiency, put front page specific CSS in a separate file or in the front page itself -- mb */    


#slideshow {
	width: 460px;
	height: 260px;
	float: left;
	overflow:hidden;
	padding: 0;
	margin: 0 0 40px 0;
	list-style-type:none;
}

#slideshow .viewport {
	width: 360px;
	height: 260px;
	margin: 0 12px;  
	background-color:#f0f0f0;   
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;   
	 
	overflow: hidden;
	position: relative;
}  

#slideshow .overview {
	position: absolute;
	list-style-type:none;
	margin: 0;
	padding: 0 20px;
}

#slideshow li.right-button,
#slideshow li.left-button {
	float: left;
	margin-top:110px;
}

#slideshow li.carousel {
	float: left;
}

#slideshow .overview li.slide {
	float: left;
	width: 320px; /* 360 - (2 * 20) */
	height: 260px;
}

#slideshow a.slideshow_btn {
	display: block;
	width:10px;
	padding: 6px 14px;
	background-color: #666;
	color: #fff;
	text-decoration:none;
	text-align:center;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
}

#slideshow a.slideshow_btn:hover {
	background-color: #009be3;
}

#slideshow a.slideshow_btn:active {
	margin-top: 1px;
}

#slideshow li div.circleplayer  {
	position: relative;
	left: 60px;
	top: 30px;
	width:200px;
}

#slideshow li div.comingsoon {
	font-size: 170%;
	color:#009BE3;	
	text-align: center;
	padding-top:106px;
}

#steps{
	width: 100%;
	margin:0;
	padding: 0;
	overflow:hidden;
	clear: both;
} 

#steps li{
	list-style-type:none;
	margin: 0 0 0 -15px;
	padding: 0;
	float: left;
} 

#steps li a{
	position:relative;
	display:block;
	width:235px;
	height:49px;
	text-indent:-999px;
}

#steps li:first-child{
	margin-left:0;
}

#step-download a{
	background: url(../graphics/3btns_sprites.gif) 0 0 no-repeat;
}
#step-download a:hover {
	background: url(../graphics/3btns_sprites.gif) 0 -49px no-repeat;
	z-index:1;
}

#step-create a{
	background: url(../graphics/3btns_sprites.gif) -235px 0 no-repeat;
}
#step-create a:hover {
	background: url(../graphics/3btns_sprites.gif) -235px -49px no-repeat;
	z-index:1;
}

#step-takepart a{
	background: url(../graphics/3btns_sprites.gif) -470px 0 no-repeat;
}
#step-takepart a:hover {
	background: url(../graphics/3btns_sprites.gif) -470px -49px no-repeat;
	z-index:1;
}


ul.thin {
	width: 380px;
	float: left;
	margin-right: 20px;
	list-style-type:disc;
}

ul.thin li{
	margin-bottom:.5em;
}

.centered {
	font-size:90%;
	text-align:center;
	margin: 0;
}


.float_right {
	clear: both;
	float: right;
}

footer {
	display:block;
	font-size: 0.6em;
	position: relative;
	overflow: hidden;
	margin-bottom: 20px;
	clear:both;
}

footer p{
	width: 540px;
	float: left;
	line-height:60px;
}

footer p a img{
	float: left;
}


#twitter {
	display: block;
	width: 100px;
	text-decoration:none;
	padding: 10px;
	overflow:hidden;
	text-align:right;
	float: right;
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
}

#twitter img {
	float: left;
}

#twitter:hover {
	background-color:#eee;
}


#content_main div.section, /* The rule for older than 2.0.0 parts of the site */
#content_main > section, #content_main > article  {
	display:block;
	padding:1em 0;
	margin-bottom: 20px;
	overflow: hidden;
	border-bottom:1px solid #f0f0f0;
}

#content_main div.section a:active, /* The rule for older than 2.0.0 parts of the site */
#content_main > section p a:active { /* Added p element to selector otherwise all the demo controls break */
	position: relative;
	top: 1px;
}

/* The demo rules for older than 2.0.0 parts of the site */
#content_main div.demo_section_top {
	border:none;
	padding-bottom:0;
}

#content_main div.demo_section_mid {
	border:none;
	padding:0;
}

#content_main div.demo_section_bot {
	padding-top:0;
}
/* End of: The demo rules for older than 2.0.0 parts of the site */



.date {
	margin: 0;
	padding: 0;
	font-style:oblique;
}

dt {
	font-weight: bold;
	color:#666;
	margin-top: 20px;
	border-left: 1px solid  #a0a600;
	padding-left: 8px;
}

dd {
	border-left: 1px solid  #a0a600;
	padding-left: 8px;
}


dl {
	margin-bottom:20px;
}

dl dl {
	margin-left: 20px;
}

dl dl dt{
	color: #000;
}


dl dl dl dt{
	font-style: oblique;
	text-decoration:underline;
}

code {
	font-family: monospace, "Courier New";
	font-size:1.1em;
	color: #000;
	background-color: #eee;
}

.explanation {
	font-size:.8em;
	font-style: oblique;
}

.explanation code {
	font-size:1.4em;
}

pre {
	font-family: monospace, "Courier New";
	padding: 10px;
	margin: 10px 0;
	border:  1px solid #ccc;
	background-color:#eee;
	overflow: auto;
	color: #000;
	font-size:.9em;
}

pre.snippet {
	height:200px;
	font-size:0.8em;
}

ul.thin+pre {
	width: 243px;
	float: right;
	margin: 0;
}

ul.thin+img {
	float: right;
	margin:-20px 0 20px 0;
}

.media-copyright,
.note,
.miaow {
	font-size:.8em;
	color:#999;
}

.FlattrButton {
	float: right;	
	padding-top:3px;
}

/*
.center {
	text-align: center;
}*/

/*.flattr,
.plegie {
	margin-top: 1em;
}*/

div.obsolete {
	background-color:#ffeeee;
	border: 1px dashed #ff3333;
	font-weight:bold;
	color:#ff0000;
	padding:1em 10px 0 10px;
	margin-bottom:10px;
}

.ralign {
	text-align:right;
}  


</style>
<link type="text/css" href="/development/js/skin/jplayer.blue.monday.css" rel="stylesheet">


<script type='text/javascript' language="javascript" src='/development/js/jquery.jplayer.min.js'></script>


http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6229_Cicero_26Jun2006_Pmaculatus1_CC3215.mp3
<script>
	
	
$(document).ready(function(){
	$("#jquery_jplayer_1").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", {
				mp3:"http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6229_Cicero_26Jun2006_Pmaculatus1_CC3215.mp3"
			});
		},
		swfPath: "/development/js",
		supplied: "mp3"
	});
      
      
});
	
</script>



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
						<li>Cro Magnon Man</li>
					</ul>
				</div>
				<div class="jp-no-solution">
					<span>Update Required</span>
					To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
				</div>
			</div>
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
