// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});


$(function(){
	
	/* star rating */
	$('input.star').rating({
		callback: function(value, link){ 
			var path = $(link).parents("form").attr('action')+'.json';
			$.post(path,{
				rate_value:value
			},function(data){
				
			});
		}
	});
	
	/* commenting */
	$(".reply_btn").click(function(){
		$(this).parents(".comment:first").find(".reply").slideToggle('fast');
		return false;
	}); 
});