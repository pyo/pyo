$(document).ready(function(){ 
 
	/// top right menus
	$("ul.subnav").parent().append("<span></span>");
 
	$("ul.topnav li").click(function() {
 
		$(this).parent().find("ul.subnav").slideDown('fast').show();
 
		$(this).parent().hover(function() {  
		}, function(){
			$(this).parent().find("ul.subnav").slideUp('slow');
		});
 
		}).hover(function() {
			$(this).addClass("subhover"); 
		}, function(){	//On Hover Out
			$(this).removeClass("subhover");
	});
 
});
// call this in body onload to set value again to 0
function clear(){$('#flag').val(0);}