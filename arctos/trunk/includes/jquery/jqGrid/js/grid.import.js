;(function($){
/*
 * jqGrid extension for constructing Grid Data from external file
 * Tony Tomov tony@trirand.com
 * http://trirand.com/blog/ 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/ 
    $.fn.extend({
        jqGridImport : function(o) {
            o = $.extend({
                imptype : "xml", // xml, json, xmlstring, jsonstring
                impstring: "",
                impurl: "",
                mtype: "GET",
                impData : {},
                xmlGrid :{
                    config : "roots>grid",
                    data: "roots>rows"
                },
                jsonGrid :{
                    config : "grid",
                    data: "data"
                }
            }, o || {});
            return this.each(function(){
                var $t = this;
                var XmlConvert = function (xml,o) {
                    var cnfg = $(o.xmlGrid.config,xml)[0];
                    var xmldata = $(o.xmlGrid.data,xml)[0];
                    if(xmlJsonClass.xml2json && JSON.parse) {
                        var jstr = xmlJsonClass.xml2json(cnfg," ");
                        var jstr = JSON.parse(jstr);
                        for(var key in jstr) { var jstr1=jstr[key];}
                        if(xmldata) {
                        // save the datatype
                            var svdatatype = jstr.grid.datatype;
                            jstr.grid.datatype = 'xmlstring';
                            jstr.grid.datastr = xml;
                            $($t).jqGrid( jstr1 ).setGridParam({datatype:svdatatype});
                        } else {
                            $($t).jqGrid( jstr1 );
                        }
                        jstr = null;jstr1=null;
                    } else {
                        alert("xml2json or json.parse are not present");
                    }
                };
                var JsonConvert = function (jsonstr,o){
                    if (jsonstr && typeof jsonstr == 'string' && JSON.parse) {
                        var json = JSON.parse(jsonstr);
                        var gprm = json[o.jsonGrid.config];
                        var jdata = json[o.jsonGrid.data];
                        if(jdata) {
                            var svdatatype = gprm.datatype;
                            gprm.datatype = 'jsonstring';
                            gprm.datastr = jdata;
                            $($t).jqGrid( gprm ).setGridParam({datatype:svdatatype});
                        } else {
                            $($t).jqGrid( gprm );
                        }
                    }
                };
                switch (o.imptype){
                    case 'xml':
                        $.ajax({
                            url:o.impurl,
                            type:o.mtype,
                            data: o.impData,
                            dataType:"xml",
                            complete: function(xml,stat) {
                                if(stat == 'success') {
                                    XmlConvert(xml.responseXML,o);
                                    xml=null;
                                }
                            }
                        });
                        break;
                    case 'xmlstring' :
                        // we need to make just the conversion and use the same code as xml
                        if(o.impstring && typeof o.impstring == 'string') {
                            var xmld = xmlJsonClass.parseXml(o.impstring);
                            if(xmld) {
                                XmlConvert(xmld,o);
                                xmld = null;
                            }
                        }
                        break;
                    case 'json':
                        $.ajax({
                            url:o.impurl,
                            type:o.mtype,
                            data: o.impData,
                            dataType:"json",
                            complete: function(json,stat) {
                                if(stat == 'success') {
                                    JsonConvert(json.responseText,o );
                                    json=null;
                                }
                            }
                        });
                        break;
                    case 'jsonstring' :
                        if(o.impstring && typeof o.impstring == 'string') {
                            JsonConvert(o.impstring,o );
                        }
                        break;
                }
            });
        },
        jqGridExport : function(o) {
            o = $.extend({
                exptype : "xmlstring"
            }, o || {});
            var ret = null;
            this.each(function () {
                if(!this.grid) { return;}
                var gprm = $(this).getGridParam();
                switch (o.exptype) {
                    case 'xmlstring' :
                        ret = xmlJsonClass.json2xml(gprm," ");
                        break;
                    case 'jsonstring' :
                        ret = JSON.stringify(gprm);
                        break;
                }
            });
            return ret;
        }
    });
})(jQuery);