/**
 * jqGrid extension
 * Paul Tiseo ptiseo@wasteconsultants.com
 * 
 */
;(function(c){c.fn.extend({getPostData:function(){var a=this[0];if(!a.grid){return}return a.p.postData},setPostData:function(a){var b=this[0];if(!b.grid){return}if(typeof(a)==='object'){b.p.postData=a}else{alert("Error: cannot add a non-object postData value. postData unchanged.")}},appendPostData:function(a){var b=this[0];if(!b.grid){return}if(typeof(a)==='object'){c.extend(b.p.postData,a)}else{alert("Error: cannot append a non-object postData value. postData unchanged.")}},setPostDataItem:function(a,b){var d=this[0];if(!d.grid){return}d.p.postData[a]=b},getPostDataItem:function(a){var b=this[0];if(!b.grid){return}return b.p.postData[a]},removePostDataItem:function(a){var b=this[0];if(!b.grid){return}delete b.p.postData[a]},getUserData:function(){var a=this[0];if(!a.grid){return}return a.p.userData},getUserDataItem:function(a){var b=this[0];if(!b.grid){return}return b.p.userData[a]}})})(jQuery);