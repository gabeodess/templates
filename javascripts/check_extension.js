function check_extension(element, extentions){
	var ext = element.val().split('.').pop().toLowerCase();
	var allow = extentions;
	if(jQuery.inArray(ext, allow) == -1) {
    alert('invalid extension!');
		element.val('');
	}
}
