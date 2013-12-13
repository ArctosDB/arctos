
<cfinclude template="/includes/_header.cfm">


<!----


<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>jQuery Popup Overlay</title>
    <meta name="description" content="jQuery plugin for responsive and accessible modal windows and tooltips." />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- Bootstrap styles -->
    <link rel="stylesheet" href="http://getbootstrap.com/dist/css/bootstrap.min.css" />

    <!-- Font Awesome icons -->
    <link rel="stylesheet" href="http://weloveiconfonts.com/api/?family=fontawesome">
    <style>
        [class*="fontawesome-"]:before {
          font-family: 'FontAwesome', sans-serif;
        }
    </style>

    <!-- jQuery -->
    <script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>





</head>
<body>

------------->


    <!-- jQuery Popup Overlay -->
    <script src="/includes/jquery.popupoverlay.js"></script>



<div class="container">

    <section class="col-md-10 col-md-offset-1">

        <div class="page-header">
            <h1>jQuery Popup Overlay</h1>
            <p>jQuery plugin for responsive and accessible modal windows and tooltips.</p>
        </div>

        <h2>Demo</h2>

        <p>
            <a class="basic_open btn btn-success" href="#basic">Basic</a>
            <a class="fade_open btn btn-success" href="#fade">Fade</a>
            <a class="fadeandscale_open btn btn-success" href="#fadeandscale">Fade &amp; scale</a>
            <button class="slidein_open btn btn-success">Slide in</button>
            <button class="standalone_open btn btn-success">Stand alone</button>
            <a href="#my_tooltip" class="my_tooltip_open btn btn-success">Tooltip</a>
            <button class="fall_open btn btn-success">Callback events</button>
        </p>

        <h2>Features</h2>

        <ul>
            <li><b>Positioned with CSS:</b>
                Overlays are horizontally and vertically centered with CSS, without any JavaScript offset calculations,
                therefore remain centered even if their height change.</li>
            <li><b>Suitable for responsive web design: </b>
                Overlays are fully customizable with CSS and will adapt to any screen size and orientation.
                You can set a flexible minimum and maximum width and height to the overlay, as well as media queries.</li>
            <li><b>Always visible: </b>
                If the height of the overlay exceeds the visible area, vertical scrolling
                 will be automatically enabled to prevent the off-screen content from being unreachable.</li>
            <li><b>Accessible: </b>
                Keyboard navigable using <kbd>Tab</kbd> key. <abbr title="Web Accessibility Initiative - Accessible Rich Internet Applications">WAI-ARIA</abbr> roles are added automatically if missing. Text resizing or zooming will not break the layout, visibility, or position of the popup.</li>
            <li><b>Device independent: </b>
                Works well on desktops, tablets, most modern phones and other devices. Optimized and tested in all modern browsers including <abbr title="Internet Explorer 7 and later">IE7+</abbr>, and in new versions of popular screen readers including JAWS, NVDA, and VoiceOver.</li>
        </ul>

        <h2>Usage</h2>

<pre class="prettyprint">
<code>&lt;!doctype html&gt;
&lt;html lang="en"&gt;
&lt;head&gt;
  &lt;meta charset="utf-8"&gt;
  &lt;title&gt;Site Title&lt;/title&gt;
&lt;/head&gt;
&lt;body&gt;

  &lt;!-- Add an optional button to open the popup --&gt;
  &lt;button class="my_popup_open"&gt;Open popup&lt;/button&gt;

  &lt;!-- Add content to the popup --&gt;
  &lt;div id="my_popup"&gt;
    ...popup content...

    &lt;!-- Add an optional button to close the popup --&gt;
    &lt;button class="my_popup_close"&gt;Close&lt;/button&gt;

  &lt;/div&gt;

  &lt;!-- Include jQuery --&gt;
  &lt;script src="http://code.jquery.com/jquery-1.8.2.min.js"&gt;&lt;/script&gt;

  &lt;!-- Include jQuery Popup Overlay --&gt;
  &lt;script src="http://vast-eng.github.io/jquery-popup-overlay/jquery.popupoverlay.js"&gt;&lt;/script&gt;

  &lt;script&gt;
    $(document).ready(function() {

      // Initialize the plugin
      $('#my_popup').popup();

    });
  &lt;/script&gt;

&lt;/body&gt;
&lt;/html&gt;</code>
</pre>

        <h3>Options</h3>

        <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Default</th>
            <th>Description</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td>type</td>
            <td>'overlay'<br />'tooltip'</td>
            <td>'overlay'</td>
            <td>Sets popup type to overlay or tooltip.</td>
        </tr>
        <tr>
            <td>autoopen</td>
            <td>boolean</td>
            <td>false</td>
            <td>Shows the popup when initialized.</td>
        </tr>
        <tr>
            <td>scrolllock</td>
            <td>boolean</td>
            <td>false</td>
            <td>Disables scrolling of background content while the popup is visible.</td>
        </tr>
        <tr>
            <td>background</td>
            <td>boolean</td>
            <td>true</td>
            <td>Enables background cover.<br />
                <small  class="text-muted">Disabled for tooltips.</small></td>
        </tr>
        <tr>
            <td>color</td>
            <td>string <small class="text-muted"><i>(CSS&nbsp;color)</i></small></td>
            <td>'#000'</td>
            <td>Sets background color.</td>
        </tr>
        <tr>
            <td>opacity</td>
            <td>float</td>
            <td>0.5</td>
            <td>Sets background opacity.</td>
        </tr>
        <tr>
            <td>horizontal</td>
            <td>'center'<br />'left'<br />'right'<br /><span class="text-muted">'leftedge'</span><br /><span class="text-muted">'rightedge'</span></td>
            <td>'center'</td>
            <td><p>Sets horizontal position.</p>
                <p class="text-muted"><small>Options `leftedge` and `rightedge` can be used only for tooltips, and will align the tooltip to the left or right edge of the opening element (`openelement`).</small></p></td>
        </tr>
        <tr>
            <td>vertical</td>
            <td>'center'<br />'top'<br />'bottom'<br /><span class="text-muted">'topedge'</span><br /><span class="text-muted">'bottomedge'</span></td>
            <td>'center'</td>
            <td><p>Sets vertical position.</p>
                <p class="text-muted"><small>Options `topedge` and `bottomedge` can be used only for tooltips, and will align the tooltip to the top or bottom edge of the opening element (`openelement`).</small></p></td>
        </tr>
        <tr>
            <td>offsettop</td>
            <td>number</td>
            <td>0</td>
            <td><p>Sets top offset to tooltip.</p></td>
        </tr>
        <tr>
            <td>offsetleft</td>
            <td>number</td>
            <td>0</td>
            <td><p>Sets left offset to tooltip.</p></td>
        </tr>
        <tr>
            <td>escape</td>
            <td>boolean</td>
            <td>true</td>
            <td>Closes the popup when <kbd>Escape</kbd> key is pressed.</td>
        </tr>
        <tr>
            <td>blur</td>
            <td>boolean</td>
            <td>true</td>
            <td>Closes the popup when clicked outside of it.</td>
        </tr>
        <tr>
            <td>setzindex</td>
            <td>boolean</td>
            <td>true</td>
            <td>Sets default z-index to the popup (2001) and to the background (2000).</td>
        </tr>
        <tr>
            <td>autozindex</td>
            <td>boolean</td>
            <td>false</td>
            <td><p>Sets highest z-index on the page to the popup.</p></td>
        </tr>
        <tr>
            <td>keepfocus</td>
            <td>boolean</td>
            <td>true</td>
            <td>Lock keyboard focus inside of popup. Recommended to be enabled.</td>
        </tr>
        <tr>
            <td>focuselement</td>
            <td>boolean</td>
            <td>'#<i>{popup_id}</i>'</td>
            <td>Enables you to specify the element which will be focused upon showing the popup. By default, the popup element <code>#my_popup</code> will recieve the initial focus.</td>
        </tr>
        <tr>
            <td>focusdelay</td>
            <td>number</td>
            <td>50</td>
            <td>Sets a delay in milliseconds before focusing an element. This is to prevent page scrolling during opening transition, as browsers will try to move the viewport to an element which received the focus.</td>
        </tr>
        <tr>
            <td>pagecontainer</td>
            <td>string <small class="text-muted"><i>(CSS&nbsp;selector)</i></small></td>
            <td></td>
            <td><p>Sets a page container (to help screen reader users). Page container should be the element that surrounds all the content on the page (e.g. '.container' in the case of this very page).</p>
                <p class="text-muted"><small>It's highly recommended that you set the page container to help some screen readers read the modal dialog correctly. When the popup is visible, <code>aria-hidden="true"</code> is set to the page container and <code>aria-hidden="false"</code> to the popup, and vice-versa when the popup closes. You can set `pagecontainer` once per website (e.g. <code>$.fn.popup.defaults.pagecontainer = '.container'</code>).</small></p></td>
        </tr>
        <tr>
            <td>outline</td>
            <td>boolean</td>
            <td>false</td>
            <td><p>Shows a default browser outline on popup element when focused.</p>
                <p class="text-muted"><small>Setting to <code>false</code> is equivalent to <code>#my_popup{outline: none;}</code>.</small></p></td>
        </tr>
        <tr>
            <td>detach</td>
            <td>boolean</td>
            <td>false</td>
            <td>
                <p>Removes popup element from the DOM after closing transition.</p>
                <p class="text-muted"><small>If you are not using transitions but want to remove popup from DOM after closing, as a temporary solution you can use `notransitiondetach` instead of `detach`.</small></p>
            </td>
        </tr>
        <tr>
            <td>openelement</td>
            <td>string <small class="text-muted"><i>(CSS&nbsp;selector)</i></small></td>
            <td>'.<i>{popup_id}</i>_open'</td>
            <td>Enables you to define custom element which will open the popup on click. By default, in our case it's set to <code>.my_popup_open</code>.</td>
        </tr>
        <tr>
            <td>closeelement</td>
            <td>string <small class="text-muted"><i>(CSS&nbsp;selector)</i></small></td>
            <td>'.<i>{popup_id}</i>_close'</td>
            <td>Enables you to define custom element which will close the popup on click. By default, in our case it's set to <code>.my_popup_close</code>.</td>
        </tr>
        <tr>
            <td>transition</td>
            <td>string <small class="text-muted"><i>(CSS&nbsp;transition)</i></small></td>
            <td></td>
            <td>
                <p>Sets CSS transition when showing and hiding a popup.</p>
                <p class="text-muted"><small>Use this if you don't need different transition for background, and if you don't need to transition only selected properties. Otherwise set transitions in CSS.</small></p>
                <p class="text-muted"><small>Simple fade effect <code>$('#my_popup').popup({transition: 'all 0.3s'})</code> is equivalent to <code>#my_popup, #my_popup_wrapper, #my_popup_background {transition: all 0.3s;}</code></small></p>
                <p class="text-muted"><small>Setting fade effect for all popups on the site: <code>$.fn.popup.defaults.transition = 'all 0.3s';</code> is equivalent to <code>.popup_content, .popup_wrapper, .popup_background {transition: all 0.3s;}</code></small></p>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                <p>Example:</p>
<pre class="prettyprint">
<code>$('#my_popup').popup({
  opacity: 0.3,
  transition: 'all 0.3s'
});</code>
</pre>
            </td>
        </tr>

        </tbody>
        </table>



        <h3>Callback events</h3>

        <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
        </thead>
        <tbody>
       <tr>
            <td>beforeopen</td>
            <td>function</td>
            <td>Callback function which will execute before the popup is opened.</td>
        </tr>
        <tr>
            <td>onopen</td>
            <td>function</td>
            <td>Callback function which will execute when the popup starts to open.</td>
        </tr>
        <tr>
            <td>onclose</td>
            <td>function</td>
            <td>Callback function which will execute when the popup starts to close.</td>
        </tr>
        <tr>
            <td>opentransitionend</td>
            <td>function</td>
            <td>Callback function which will execute after the opening CSS transition is over, only if transition actually occurs and if supported by the browser.</td>
        </tr>
        <tr>
            <td>closetransitionend</td>
            <td>function</td>
            <td>Callback function which will execute after the closing CSS transition is over, only if transition actually occurs and if supported by the browser.</td>
        </tr>
        <tr>
            <td colspan="3">
                <p>Example:</p>
<pre class="prettyprint">
<code>$('#my_popup').popup({
  onopen: function() {
    alert('Popup just opened!');
  }
});</code>
</pre>
            </td>
        </tr>
        </tbody>
        </table>

        <h3>Defaults</h3>
        <p>Default values for options and events can be modified:</p>
<pre class="prettyprint">
<code>$.fn.popup.defaults.transition = 'all 0.3s';
$.fn.popup.defaults.pagecontainer = '.container';
</code></pre>


        <h3>Methods</h3>

        <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <th>Name</th>
            <th>Description</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td>.popup(options)</td>
            <td><p>Activates your content as a popup. Accepts an optional options <code>object.</code></p>
<pre class="prettyprint">
<code>$('#my_popup').popup({
  background: false
});
</code>
</pre>
            </td>
        </tr>
        <tr>
            <td>.popup('show')</td>
            <td>
                <p>Manually opens a popup.</p>
                <pre class="prettyprint"><code>$('#my_popup').popup('show');</code></pre>
            </td>
        </tr>
        <tr>
            <td>.popup('hide')</td>
            <td>
                <p>Manually hides a popup.</p>
                <pre class="prettyprint"><code>$('#my_popup').popup('hide');</code></pre>
            </td>
        </tr>
        <tr>
            <td>.popup('toggle')</td>
            <td>
                <p>Manually toggles a popup.</p>
                <pre class="prettyprint"><code>$('#my_popup').popup('toggle');</code></pre>
            </td>
        </tr>
        </tbody>
        </table>

        <h2>Download</h2>
        <p>
            <a href="https://github.com/vast-eng/jquery-popup-overlay/archive/gh-pages.zip" class="btn btn-primary btn-success btn-lg"><span class="fontawesome-download-alt"></span> Download</a>
            <a href="https://github.com/vast-eng/jquery-popup-overlay" class="btn btn-lg btn-default"><span class="fontawesome-github"></span> View project on GitHub</a>
        </p>
        <p>&nbsp;</p>

    </section>

    <footer class="col-md-10 col-md-offset-1" role="contentinfo">

        <iframe src="http://ghbtns.com/github-btn.html?user=vast-eng&repo=jquery-popup-overlay&type=watch&size=small&count=true"
            allowtransparency="true" frameborder="0" scrolling="0" width="100" height="20"></iframe>

        <p class="text-muted"><small>Released under the <a href="http://opensource.org/licenses/MIT">MIT</a> license.</small></p>
    </footer>

</div>





<!-- Set defaults -->
<script>
$(document).ready(function () {
    $.fn.popup.defaults.pagecontainer = '.container'
});
</script>












<!-- Basic -->

<div id="basic" class="well" style="max-width:44em;">
    <h4>Basic example</h4>
    <p>Try to change the width and height of browser window, or to rotate your device, and also try to navigate with the <kbd>Tab</kbd> key.</p>
    <p>You can close the dialog by pressing the <kbd>Esc</kbd> key, or by clicking on the background outside the content area, or by clicking on the Close button.</p>
    <button class="basic_close btn btn-default">Close</button>
</div>

<script>
$(document).ready(function () {
    $('#basic').popup();
});
</script>










<!-- Fade -->

<div id="fade" class="well">
    <h4>Fade example</h4>
<pre class="prettyprint">
<code>$('#fade').popup({
  transition: 'all 0.3s'
});</code>
</pre>
    <p>Or you can set transitions directly in CSS:</p>
<pre class="prettyprint"><code>$('#fade').popup();</code></pre>
<pre class="prettyprint"><code>#fade,
#fade_wrapper,
#fade_background {
  -webkit-tranzition: all 0.3s;
     -moz-tranzition: all 0.3s;
          transition: all 0.3s;
}
</code>
</pre>
    <button class="fade_close fadeandscale_open btn btn-default">Next example</button>
    <button class="fade_close btn btn-default">Close</button>
</div>

<script>
$(document).ready(function () {

    $('#fade').popup({
      transition: 'all 0.3s'
    });

});
</script>









<!-- Fade & scale -->

<div id="fadeandscale" class="well">
    <h4>Fade &amp; scale example</h4>
<pre class="prettyprint">
<code>$('#fade').popup({
  transition: 'all 0.3s'
});</code>
</pre>
<pre class="prettyprint">
<code>#fadeandscale {
    -webkit-transform: scale(0.8);
       -moz-transform: scale(0.8);
        -ms-transform: scale(0.8);
            transform: scale(0.8);
}
.popup_visible #fadeandscale {
    -webkit-transform: scale(1);
       -moz-transform: scale(1);
        -ms-transform: scale(1);
            transform: scale(1);
}</code>
</pre>
    <button class="fadeandscale_close slidein_open btn btn-default">Next example</button>
    <button class="fadeandscale_close btn btn-default">Close</button>
</div>

<script>
$(document).ready(function () {

    $('#fadeandscale').popup({
        pagecontainer: '.container',
        transition: 'all 0.3s'
    });

});
</script>




<style>
#fadeandscale {
    -webkit-transform: scale(0.8);
       -moz-transform: scale(0.8);
        -ms-transform: scale(0.8);
            transform: scale(0.8);
}
.popup_visible #fadeandscale {
    -webkit-transform: scale(1);
       -moz-transform: scale(1);
        -ms-transform: scale(1);
            transform: scale(1);
}
</style>









<!-- Slide in -->

<div id="slidein" class="well">
<h4>Slide in example</h4>
<pre class="prettyprint">
<code>$('#slidein').popup({
    outline: true, // optional
    focusdelay: 300, // optional
});
</code>
</pre>
<pre class="prettyprint">
<code>#slidein_background {
    -webkit-transition: all 0.3s;
       -moz-transition: all 0.3s;
            transition: all 0.3s;
}
#slidein,
#slidein_wrapper {
    -webkit-transition: all 0.3s ease-out;
       -moz-transition: all 0.3s ease-out;
            transition: all 0.3s ease-out;
}
#slidein {
    -webkit-transform: translateX(0) translateY(-40%);
       -moz-transform: translateX(0) translateY(-40%);
        -ms-transform: translateX(0) translateY(-40%);
            transform: translateX(0) translateY(-40%);
}
.popup_visible #slidein {
    -webkit-transform: translateX(0) translateY(0);
       -moz-transform: translateX(0) translateY(0);
        -ms-transform: translateX(0) translateY(0);
            transform: translateX(0) translateY(0);
}
</code>
</pre>
    <button class="slidein_close btn btn-default">Close</button>
</div>

<script>
$(document).ready(function () {

    $('#slidein').popup({
        focusdelay: 300,
        outline: true
    });

});
</script>

<style>
#slidein_background {
    -webkit-transition: all 0.3s;
       -moz-transition: all 0.3s;
            transition: all 0.3s;
}
#slidein,
#slidein_wrapper {
    -webkit-transition: all 0.3s ease-out;
       -moz-transition: all 0.3s ease-out;
            transition: all 0.3s ease-out;
}
#slidein {
    -webkit-transform: translateX(0) translateY(-40%);
       -moz-transform: translateX(0) translateY(-40%);
        -ms-transform: translateX(0) translateY(-40%);
            transform: translateX(0) translateY(-40%);
}
.popup_visible #slidein {
    -webkit-transform: translateX(0) translateY(0);
       -moz-transform: translateX(0) translateY(0);
        -ms-transform: translateX(0) translateY(0);
            transform: translateX(0) translateY(0);
}
</style>









<!-- Stand alone -->

<div id="standalone">
<pre class="prettyprint">
<code>$('#standalone').popup({
  color: 'white',
  opacity: 1,
  transition: '0.3s',
  scrolllock: true
});
</code>
</pre>
<pre class="prettyprint">
<code>#standalone {
    -webkit-transform: scale(0.8);
       -moz-transform: scale(0.8);
        -ms-transform: scale(0.8);
            transform: scale(0.8);
}
.popup_visible #standalone {
    -webkit-transform: scale(1);
       -moz-transform: scale(1);
        -ms-transform: scale(1);
            transform: scale(1);
}
</code>
</pre>
</div>



<script>
$(document).ready(function () {

    $('#standalone').popup({
      color: 'white',
      opacity: 1,
      transition: '0.3s',
      scrolllock: true
    });

});
</script>

<style>
#standalone {
    -webkit-transform: scale(0.8);
       -moz-transform: scale(0.8);
        -ms-transform: scale(0.8);
            transform: scale(0.8);
}
.popup_visible #standalone {
    -webkit-transform: scale(1);
       -moz-transform: scale(1);
        -ms-transform: scale(1);
            transform: scale(1);
}
</style>













<!-- Tooltip -->

<div id="my_tooltip" class="well">
    <a href="#" class="my_tooltip_close" style="float:right;padding:0 0.4em;">x</a>
    <h4>Tooltip example</h4>
    <p>Tooltip content will be positioned relative to the opening link.</p>
</div>

<script>
$(document).ready(function () {

    $('#my_tooltip').popup({
        type: 'tooltip',
        vertical: 'top'
    });

});
</script>









<!-- Callback events -->

<div id="fall" class="well" style="max-width: 45em;">
    <h4>Callback events</h4>
<pre class="prettyprint">
<code>$('#fall').popup({
        beforeopen: function () {
            alert('beforeopen');
        },
        onopen: function () {
            alert('onopen');
        },
        onclose: function () {
            alert('onclose');
        },
        opentransitionend: function () {
            alert('opentransitionend');
        },
        closetransitionend: function () {
            alert('closetransitionend');
        }
    });
</code>
</pre>
    <button class="fall_close btn btn-default">Close</button>
</div>

<script>
$(document).ready(function () {

    $('#fall').popup({
        beforeopen: function () {
            alert('beforeopen');
        },
        onopen: function () {
            alert('onopen');
        },
        onclose: function () {
            alert('onclose');
        },
        opentransitionend: function () {
            alert('opentransitionend');
        },
        closetransitionend: function () {
            alert('closetransitionend');
        }
    });

});
</script>

<style>
    #fall_background {
        -webkit-transition: all 3s;
           -moz-transition: all 3s;
                transition: all 3s;
    }
    #fall_wrapper {
        -webkit-transition: all 3s;
           -moz-transition: all 3s;
                transition: all 3s;
        -webkit-perspective: 1300px;
        -moz-perspective: 1300px;
        perspective: 1300px;
    }
    #fall {
        -webkit-transition: all 3s ease-in;
        -moz-transition: all 3s ease-in;
        transition: all 3s ease-in;
        -webkit-transform-style: preserve-3d;
        -moz-transform-style: preserve-3d;
        transform-style: preserve-3d;
        -webkit-transform: translateZ(600px) rotateX(20deg);
        -moz-transform: translateZ(600px) rotateX(20deg);
        -ms-transform: translateZ(600px) rotateX(20deg);
        transform: translateZ(600px) rotateX(20deg);
    }
    .popup_visible #fall {
        -webkit-transform: translateZ(0px) rotateX(0deg);
        -moz-transform: translateZ(0px) rotateX(0deg);
        -ms-transform: translateZ(0px) rotateX(0deg);
        transform: translateZ(0px) rotateX(0deg);
    }
</style>














<style>
/* Quick overrides for the demo */
.well {
    box-shadow: 0 0 10px rgba(0,0,0,0.3);
    display:none;
    margin:1em;
}
pre.prettyprint {
    padding: 9px 14px;
}
</style>



</body>
</html>


