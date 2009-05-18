﻿;(function($){
/**
 * jqGrid Swedish Translation
 * Anders Nyberg anders.nyberg@alecta.com
 * http://wwww.alecta.com 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/
$.jgrid = {};

$.jgrid.defaults = {
	recordtext: "post(er)",
	loadtext: "Laddar...",
	pgtext : "/"
};
$.jgrid.search = {
    caption: "Sök...",
    Find: "Hitta",
    Reset: "Återställ",
    odata : ['lika', 'ej lika', 'mindre', 'mindre eller lika','större','större eller lika', 'börjar med','slutar med','innehåller' ]
};
$.jgrid.edit = {
    addCaption: "Skapa post",
    editCaption: "Ändra post",
    bSubmit: "Utför",
    bCancel: "Avbryt",
	bClose: "Stäng",
    processData: "Processar...",
    msg: {
        required:"Fält är obligatoriskt",
        number:"Välj korrekt nummer",
        minValue:"värdet måste vara större än eller lika med",
        maxValue:"värdet måste vara mindre än eller lika med",
        email: "är inte korrekt e-mail adress",
        integer: "Var god ange korrekt heltal",
	date: "Var god att ange korrekt datum"
    }
};
$.jgrid.del = {
    caption: "Ta bort",
    msg: "Ta bort vald post(er)?",
    bSubmit: "Utför",
    bCancel: "Avbryt",
    processData: "Processing..."
};
$.jgrid.nav = {
	edittext: " ",
	edittitle: "Ändra vald rad",  
	addtext:" ",
    addtitle: "Skapa ny rad",
    deltext: " ",
    deltitle: "Ta bort vald rad",
    searchtext: " ",
    searchtitle: "Hitta poster",
    refreshtext: "",
    refreshtitle: "Ladda om Grid",
    alertcap: "Varning",
    alerttext: "Var god välj rad"
};
// setcolumns module
$.jgrid.col ={
    caption: "Visa/Göm kolumner",
    bSubmit: "Utför",
    bCancel: "Avbryt"	
};
$.jgrid.errors = {
	errcap : "Fel",
	nourl : "Ingen URL är definierad",
	norecords: "Inga poster att processa",
    model : "Längden av colNames <> colModel!"
};
$.jgrid.formatter = {
	integer : {thousandsSeparator: " ", defaulValue: 0},
	number : {decimalSeparator:",", thousandsSeparator: " ", decimalPlaces: 2, defaulValue: 0},
	currency : {decimalSeparator:",", thousandsSeparator: " ", decimalPlaces: 2, prefix: "", suffix:"", defaulValue: 0},
	date : {
		dayNames:   [
			"Sön", "Mån", "Tis", "Ons", "Tor", "Fre", "Lör",
			"Söndag", "Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag"
		],
		monthNames: [
			"Jan", "Feb", "Mar", "Apr", "Maj", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dec",
			"Januari", "Februari", "Mars", "April", "Maj", "Juni", "Juli", "Augusti", "September", "Oktober", "November", "December"
		],
		AmPm : ["fm","em","FM","EM"],
		S: function (j) {return j < 11 || j > 13 ? ['st', 'nd', 'rd', 'th'][Math.min((j - 1) % 10, 3)] : 'th'},
		srcformat: 'Y-m-d',
		newformat: 'Y-m-d',
		masks : {
            ISO8601Long:"Y-m-d H:i:s",
            ISO8601Short:"Y-m-d",
            ShortDate:  "n/j/Y",
            LongDate: "l, F d, Y",
            FullDateTime: "l, F d, Y g:i:s A",
            MonthDay: "F d",
            ShortTime: "g:i A",
            LongTime: "g:i:s A",
            SortableDateTime: "Y-m-d\\TH:i:s",
            UniversalSortableDateTime: "Y-m-d H:i:sO",
            YearMonth: "F, Y"
        },
        reformatAfterEdit : false
	},
	baseLinkUrl: '',
	showAction: 'show',
	addParam : ''
};
// SV
})(jQuery);
