<cfinclude template="/includes/_header.cfm">

<link rel="stylesheet" type="text/css" media="screen" href="/includes/jqModal.css"/>
<script src="/includes/jqModal.js" type="text/javascript"></script>


<style>

.jqmClose{ background:#FFDD00; border:1px solid #FFDD00; color:#000; clear:right; float:right; padding:0 5px; cursor:pointer; }
.jqmClose:hover{ background:#FFF; }
#jqmContent{ width:99%; height:99%; display: block; clear:both; margin:auto; margin-top:10px; background:#111; border:1px dotted #444; }


</style>




<script>


var loadInIframeModal = function(hash){
    var $trigger = $(hash.t);
    var $modal = $(hash.w);
    var myUrl = $trigger.attr('href');
    var myTitle= $trigger.attr('title');
    var $modalContent = $("iframe", $modal);
 
    $modalContent.html('').attr('src', myUrl);
    //let's use the anchor "title" attribute as modal window title
    $('#jqmTitleText').text(myTitle);
    $modal.jqmShow();
}
// initialise jqModal
$('#modalWindow').jqm({
modal: true,
trigger: 'a.thickbox',
target: '#jqmContent',
onShow:  loadInIframeModal
});
 
});



</script>


<span onclick="jqm():"> jqm() </span>
<div id="modalWindow" class="jqmWindow">
        <div id="jqmTitle">
            <button class="jqmClose">
                Close X
            </button>
            <span id="jqmTitleText">Title of modal window</span>
        </div>
        <iframe id="jqmContent" src="">
        </iframe>
    </div>

<cfinclude template="/includes/_footer.cfm">

