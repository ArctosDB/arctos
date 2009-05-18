;(function($){
/**
 * jqGrid Portuguese Translation
* Tradução da jqGrid em Portugues por Frederico Carvalho, http://www.eyeviewdesign.pt
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/
$.jgrid = {};

$.jgrid.defaults = {
	recordtext: "Registo(s)",
	loadtext: "A carregar...",
	pgtext : "/"
};
$.jgrid.search = {
    caption: "Busca...",
    Find: "Procurar",
    Reset: "Limpar",
    odata : ['igual', 'não igual', 'menor', 'menor ou igual', 'maior', 'maior ou igual', 'começa com', 'termina com','contém' ]
};
$.jgrid.edit = {
    addCaption: "Adicionar Registo",
    editCaption: "Modificar Registo",
    bSubmit: "Submeter",
    bCancel: "Cancelar",
	bClose: "Fechar",
    processData: "A processar...",
    msg: {
        required:"Campo obrigatório",
        number:"Por favor, introduza um numero",
        minValue:"O valor deve ser maior ou igual que",
        maxValue:"O valor deve ser menor ou igual a",
        email: "Não é um endereço de email válido",
        integer: "Por favor, introduza um numero inteiro",
		date: "Por favor, introduza uma data válida."
    }
};
$.jgrid.del = {
    caption: "Eliminar",
    msg: "Deseja eliminar o(s) registo(s) seleccionado(s)?",
    bSubmit: "Eliminar",
    bCancel: "Cancelar",
    processData: "A processar..."
};
$.jgrid.nav = {
	edittext: " ",
    edittitle: "Modificar registo seleccionado",
	addtext:" ",
    addtitle: "Adicionar novo registo",
    deltext: " ",
    deltitle: "Eliminar registo seleccionado",
    searchtext: " ",
    searchtitle: "Procurar",
    refreshtext: "",
    refreshtitle: "Actualizar",
    alertcap: "Aviso",
    alerttext: "Por favor, seleccione um registo"
};
// setcolumns module
$.jgrid.col ={
    caption: "Mostrar/Ocultar Colunas",
    bSubmit: "Enviar",
    bCancel: "Cancelar"	
};
$.jgrid.errors = {
	errcap : "Erro",
	nourl : "Não especificou um url",
	norecords: "Não existem dados para processar",
    model : "Tamanho do colNames <> colModel!"
};
$.jgrid.formatter = {
	integer : {thousandsSeparator: " ", defaulValue: 0},
	number : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, defaulValue: 0},
	currency : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, prefix: "", suffix:"", defaulValue: 0},
	date : {
		dayNames:   [
			"Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab",
			"Domingo", "Segunda-Feira", "Terça-Feira", "Quarta-Feira", "Quinta-Feira", "Sexta-Feira", "Sábado"
		],
		monthNames: [
			"Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez",
			"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
		],
		AmPm : ["am","pm","AM","PM"],
		S: function (j) {return j < 11 || j > 13 ? ['º', 'º', 'º', 'º'][Math.min((j - 1) % 10, 3)] : 'º'},
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
	showAction: 'show'
};
})(jQuery);
