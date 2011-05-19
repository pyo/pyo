$(document).ready(function(){
						   
	$('#comment_message').bind("blur focus keydown keypress keyup", function(){recount();});
	$('input.com-submit').attr('disabled','disabled');
	
	$('#new_comment').submit(function(e){
	
		tweet();
		e.preventDefault();
	
	});
	
});


function recount()
{
	var maxlen=400;
	var current = maxlen-$('#comment_message').val().length;
	$('#counter').html(current);
	
		
	if(current<0 || current==maxlen)
	{
		$('#counter').css('color','#D40D12');
		$('input.com-submit').attr('disabled','disabled').addClass('inact');
	}
	else
		$('input.com-submit').removeAttr('disabled').removeClass('inact');

	
	if(current<10)
		$('#counter').css('color','#D40D12');
	
	else if(current<20)
		$('#counter').css('color','#5C0002');
		
	else if(current<141)
		$('#counter').css('color','#bbb');

	else
		$('#counter').css('color','#eee');
	
}