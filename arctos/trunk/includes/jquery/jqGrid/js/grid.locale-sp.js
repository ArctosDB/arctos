;(function($){
/**
 * jqGrid Spanish Translation
 * Traduccion jqGrid en Espa�ol por Yamil Bracho
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/
$.jgrid = {};

$.jgrid.defaults = {
	recordtext: "Fila(s)",
	loadtext: "Cargando...",
	pgtext : "/"
};
$.jgrid.search = {
    caption: "Busqueda...",
    Find: "Buscar",
    Reset: "Limpiar",
    odata : ['igual', 'no igual', 'menor', 'menor o igual', 'mayor', 'mayor o igual', 'comienza con', 'termina con','contiene' ]
};
$.jgrid.edit = {
    addCaption: "Agregar Registro",
    editCaption: "Modificar Registro",
    bSubmit: "Enviar",
    bCancel: "Cancelar",
	bClose: "Cerrar",
    processData: "Procesando...",
    msg: {
        required:"Campo es requerido",
        number:"Por favor, introduzca un numero",
        minValue:"El valor debe ser mayor o igual que ",
        maxValue:"El valor debe ser menor o igual a",
        email: "no es un direccion de correo valida",
        integer: "Por favor, introduzca un entero",
		date: "Please, enter valid date value"
    }
};
$.jgrid.del = {
    caption: "Eliminar",
    msg: "¿ Desea eliminar los registros seleccionados ?",
    bSubmit: "Eliminar",
    bCancel: "Cancelar",
    processData: "Procesando..."
};
$.jgrid.nav = {
	edittext: " ",
    edittitle: "Modificar fila seleccionada",
	addtext:" ",
    addtitle: "Agregar nueva fila",
    deltext: " ",
    deltitle: "Eliminar fila seleccionada",
    searchtext: " ",
    searchtitle: "Buscar información",
    refreshtext: "",
    refreshtitle: "Refrescar Rejilla",
    alertcap: "Aviso",
    alerttext: "Por favor, seleccione una fila"
};
// setcolumns module
$.jgrid.col ={
    caption: "Mostrar/Ocultar Columnas",
    bSubmit: "Enviar",
    bCancel: "Cancelar"	
};
$.jgrid.errors = {
	errcap : "Error",
	nourl : "No se ha especificado una url",
	norecords: "No hay datos para procesar",
    model : "Length of colNames <> colModel!"
};
$.jgrid.formatter = {
	integer : {thousandsSeparator: " ", defaulValue: 0},
	number : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, defaulValue: 0},
	currency : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, prefix: "", suffix:"", defaulValue: 0},
	date : {
		dayNames:   [
			"Sun", "Mon", "Tue", "Wed", "Thr", "Fri", "Sat",
			"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
		],
		monthNames: [
			"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
			"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
		],
		AmPm : ["am","pm","AM","PM"],
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
	showAction: 'show'
};
})(jQuery);
