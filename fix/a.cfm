<cfinclude template="/includes/_header.cfm">


  <script src="http://code.jquery.com/jquery-latest.js"></script>
  
  <script>
  $(document).ready(function(){
    
    $(document.body).click(function () {
      $("div:hidden:first").fadeIn("slow");
    });

  });
  </script>
  <style>
  span { color:red; cursor:pointer; }
  div { margin:3px; width:80px; display:none;
        height:80px; float:left; }
  div#one { background:#f00; }
  div#two { background:#0f0; }
  div#three { background:#00f; }
  </style>


<hr>
  <span>Click here...</span>
  <div id="one"></div>
  <div id="two"></div>
  <div id="three"></div>