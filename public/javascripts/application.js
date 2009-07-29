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
	
	$('.change_admin').click(function(e){
		e.preventDefault();
		var link = $(this);
		var url = $(this).attr("href");
		var promote = /admin%5D=1/.test(url);
		var newUrl =  promote ? url.replace(/admin%5D=1/,'admin%5D=0') : url.replace(/admin%5D=0/,'admin%5D=1');
		$.post(url,{
			_method:'put'
		},function(data){
			link.attr('href',newUrl);
			link.html(promote ? "Demote Admin" : "Make Admin");
		});
	});
	
	$('.change_featured').click(function(e){
		e.preventDefault();
		var link = $(this);
		var url = $(this).attr("href");
		var promote = /featured%5D=1/.test(url);
		var newUrl =  promote ? url.replace(/featured%5D=1/,'featured%5D=0') : url.replace(/featured%5D=0/,'featured%5D=1');
		$.post(url,{
			_method:'put'
		},function(data){
			link.attr('href',newUrl);
			link.html(promote ? "Unfeature" : "Feature");
		});
	});
	
});