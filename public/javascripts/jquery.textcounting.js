/** jQuery textCounting plugin by Brian Swartzfager (http://www.swartzfager.org/blog)* */
(function($){$.fn.textCounting=function(parameters){var opts=$.extend({},$.fn.textCounting.defaults,parameters);if(opts.maxLengthSource=="list")
{if(opts.maxLengthList!="")
{var maxLengthArray=opts.maxLengthList.split(",");var lengthsCounter=0;}
else
{denoteError("The maxLengthSource parameter of the jQuery textCounting plugin was set to 'list', but the maxLengthList parameter is blank.");return false;}}
return this.each(function(){var $box=$(this);var options=$.metadata?$.extend({},opts,$box.metadata()):opts;var proceed=true;if(options.excludeIds!="")
{proceed=isObjectIncluded($box.attr("id"),options.excludeIds);}
if(proceed)
{switch(options.maxLengthSource)
{case"list":var maxCount=maxLengthArray[lengthsCounter];lengthsCounter++;break;case"attribute":if(options.maxLengthAttribute!="")
{var maxCount=$box.attr(options.maxLengthAttribute);}
else
{denoteError("The maxLengthSource parameter of the jQuery textCounting plugin was set to 'attribute', but the maxLengthAttribute parameter is blank.");return false;}
break;case"metadata":if(options.maxLengthAttribute!="")
{var maxCount=$box.metadata()[options.maxLengthAttribute];if(maxCount==undefined)
{denoteError("The maxLengthAttribute specified was not found in the metadata of element "+$box.attr("id"));return false;}}
else
{denoteError("The maxLengthSource parameter of the jQuery textCounting plugin was set to 'metadata', but the maxLengthAttribute parameter is blank.");return false;}
break;}
var directionArray=options.countDirection.split(",");var targetArray=options.targetModifier.split(",");for(var setting=0;setting<directionArray.length;setting++)
{var currentDirection=directionArray[setting];var textCount=$.fn.textCounting.calculateCount($box,options.countWhat,currentDirection,maxCount);var currentTarget=targetArray[setting];$.fn.textCounting.displayResult($box,options.targetModifierType,currentTarget,textCount,maxCount,currentDirection,options.lengthExceededClass);}
$box.keyup(function(){for(var setting=0;setting<directionArray.length;setting++)
{var currentDirection=directionArray[setting];var textCount=$.fn.textCounting.calculateCount($box,options.countWhat,currentDirection,maxCount);var currentTarget=targetArray[setting];$.fn.textCounting.displayResult($box,options.targetModifierType,currentTarget,textCount,maxCount,currentDirection,options.lengthExceededClass);}});}});};$.fn.textCounting.defaults={maxLengthSource:"attribute",maxLengthList:"",maxLengthAttribute:"maxLength",countWhat:"characters",countDirection:"down",targetModifierType:"suffix",targetModifier:"Down",lengthExceededClass:"",excludeIds:""};$.fn.textCounting.calculateCount=function(obj,countWhat,direction,maxCount){if(countWhat=="characters")
{if(direction=="down")
{var textCount=maxCount-obj.val().length;}
else
{var textCount=obj.val().length;}}
else if(countWhat=="words")
{var boxText=jQuery.trim(obj.val());if(boxText!="")
{var wordArray=boxText.split(/\s+/);if(direction=="down")
{var textCount=maxCount-wordArray.length;}
else
{var textCount=wordArray.length;}}
else
{if(direction=="down")
{var textCount=maxCount;}
else
{var textCount=0;}}}
return textCount;};$.fn.textCounting.displayResult=function(obj,modifierType,target,textCount,maxCount,direction,lengthExceededClass){switch(modifierType){case"id":var $targetElement=$("#"+target);break;case"prefix":var $targetElement=$("#"+target+obj.attr("id"));break;case"suffix":var $targetElement=$("#"+obj.attr("id")+target);break;}
$targetElement.text(textCount);if(lengthExceededClass!="")
{if((direction=='down'&&textCount<0)||(direction=='up'&&textCount>maxCount))
{$targetElement.addClass(lengthExceededClass);}
else
{$targetElement.removeClass(lengthExceededClass);}}};function isObjectIncluded(objId,excluded){var outcome=true;var exclusionArray=excluded.split(",");for(var c=0;c<exclusionArray.length;c++)
{if(objId==exclusionArray[c])
{outcome=false;}}
return outcome;};function denoteError(msg){if(window.console)
{console.debug(msg);}
else
{alert(msg);}};})(jQuery);