;(function($){
/**
 * jqGrid Czech Translation
 * Pavel Jirak pavel.jirak@jipas.cz
 * http://trirand.com/blog/ 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/
$.jgrid = {};

$.jgrid.defaults = {
	recordtext: "Řádek(ů)",
	loadtext: "Načítám...",
	pgtext : "/"
};
$.jgrid.search = {
    caption: "Vyhledávám...",
    Find: "Hledat",
    Reset: "Reset",
    odata : ['rovno', 'není rovno', 'menší', 'menší nebo rovno', 'větší', 'větší nebo rovno', 'začíná na', 'končí na', 'obsahuje' ]
};
$.jgrid.edit = {
    addCaption: "Přidat záznam",
    editCaption: "Editace záznamu",
    bSubmit: "Uložit",
    bCancel: "Storno",
		bClose: "Zavřít",
    processData: "Zpracovávám...",
    msg: {
        required:"Pole je vyžadováno",
        number:"Prosím, vložte validní číslo",
        minValue:"hodnota musí být větší než nebo rovná ",
        maxValue:"hodnota musí být menší než nebo rovná ",
        email: "není validní e-mail",
        integer: "Prosím, vložte celé číslo",
		date: "Prosím, vložte validní datum"
    }
};
$.jgrid.del = {
    caption: "Smazat",
    msg: "Smazat vybraný(é) záznam(y)?",
    bSubmit: "Smazat",
    bCancel: "Storno",
    processData: "Zpracovávám..."
};
$.jgrid.nav = {
	  edittext: " ",
    edittitle: "Editovat vybraný řádek",
    addtext:" ",
    addtitle: "Přidat nový řádek",
    deltext: " ",
    deltitle: "Smazat vybraný záznam ",
    searchtext: " ",
    searchtitle: "Najít záznamy",
    refreshtext: "",
    refreshtitle: "Obnovit tabulku",
    alertcap: "Varování",
    alerttext: "Prosím, vyberte řádek"
};
// setcolumns module
$.jgrid.col ={
    caption: "Zobrazit/Skrýt sloupce",
    bSubmit: "Uložit",
    bCancel: "Storno"	
};
$.jgrid.errors = {
		errcap : "Chyba",
		nourl : "Není nastavena url",
		norecords: "Žádné záznamy ke zpracování",
		model : "Length colNames <> colModel!"
};
$.jgrid.formatter = {
	integer : {thousandsSeparator: " ", defaulValue: 0},
	number : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, defaulValue: 0},
	currency : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, prefix: "", suffix:"", defaulValue: 0},
	date : {
		dayNames:   [
			"Ne", "Po", "Út", "St", "Čt", "Pá", "So",
			"Neděle", "Pondělí", "Úterý", "Středa", "Čtvrtek", "Pátek", "Sobota"
		],
		monthNames: [
			"Led", "Úno", "Bře", "Dub", "Kvě", "Čer", "Čvc", "Srp", "Zář", "Říj", "Lis", "Pro",
			"Leden", "Únor", "Březen", "Duben", "Květen", "Červen", "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec"
		],
		AmPm : ["do","od","DO","OD"],
		S: function (j) {return j < 11 || j > 13 ? ['st', 'nd', 'rd', 'th'][Math.min((j - 1) % 10, 3)] : 'th'},
		srcformat: 'Y-m-d',
		newformat: 'd/m/Y',
		masks : {
            ISO8601Long:"Y-m-d H:i:s",
            ISO8601Short:"Y-m-d",
            ShortDate: "n/j/Y",
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
// US
// GB
// CA
// AU
})(jQuery);
