// This function checks if the username field
// is at least 6 characters long.
// If so, it attaches class="welldone" to the 
// containing fieldset.

// function checkUsernameForLength(whatYouTyped) {
//	var fieldset = whatYouTyped.parentNode;
//	var txt = whatYouTyped.value;
//	if (txt.length > 5) {
//		fieldset.className = "welldone";
//	}
//	else {
//		fieldset.className = "";
//	}
// }





// If the password is at least 4 characters long, the containing 
// fieldset is assigned class="kindagood".
// If it's at least 8 characters long, the containing
// fieldset is assigned class="welldone", to give the user
// the indication that they've selected a harder-to-crack
// password.

function checkPassword(child) {
  
	var parent = child.parentNode;
	var txt = $(child).val();
	if (txt.length > 3 && txt.length < 8) {
    parent.className = parent.className.replace(/(kindagood|welldone)/gi, "");
		parent.className += " kindagood";
	} else if (txt.length > 7) {
    parent.className = parent.className.replace(/(kindagood|welldone)/gi, "");
		parent.className += " welldone";
	} else {
		parent.className = parent.className.replace(/(kindagood|welldone)/gi, "");
	}
}

// This function checks the email address to be sure
// it follows a certain pattern:
// blah@blah.blah
// If so, it assigns class="welldone" to the containing
// fieldset.

function checkEmail(child) {
	var parent = child.parentNode;
	var txt = $(child).val();
	if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(txt)) {
	  parent.className = parent.className.replace(/welldone/gi, '');
		parent.className += " welldone";
	} else {
		parent.className = parent.className.replace(/welldone/gi, '');
	}
}




$(function() {
  var inputs = $("input");
  inputs.focus(function () {
    this.parentNode.getElementsByTagName("span")[0].style.display = "inline";
  });
  inputs.blur(function () {
    this.parentNode.getElementsByTagName("span")[0].style.display = "none";
  });
})