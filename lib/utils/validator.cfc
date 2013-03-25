component extends="_base"
{

	public boolean function hasHTML(required string str) {
		return REFindNoCase("<[^>]*>", arguments.str);
	}

	public boolean function isAlphaNumeric(required string str) {
		return ReFindNoCase("[^a-zA-Z0-9]", arguments.str);
	}

	public boolean function hasIllegalChars(required string str) {
		return ReFindNoCase("[\<\>]", arguments.str);
	}

	public boolean function isValidColor(required string str) {
		str = rereplace(str, "##", "");
		return isValid("regex", arguments.str, "[A-Fa-f0-9]{6}");
	}

	public boolean function isValidDatePattern(required string str) {
		return isDate(arguments.str) and isValid("regex", arguments.str, "[0-9]{4}-[0-9]{2}-[0-9]{2}");
	}

	public boolean function isValidIndex(required struct params, required string key) {
		if (NOT StructKeyExists(arguments.params, arguments.key)) {
			return false;
		}
		var val = arguments.params[arguments.key];
		return isNumeric(val) and val GT 0;
	}

	public boolean function checkValueIfExists(required struct params, required string key, required any value) {
		return StructKeyExists(arguments.params, arguments.key) and arguments.params[arguments.key] eq arguments.value;
	}

	public boolean function isValidLength(required string str, required numeric maxlength){
		return Len(arguments.str) LTE arguments.maxlength;
	}

	public boolean function isURL(required string str) {
		return isValid('url', arguments.str) OR Left(trim(arguments.str),4) is "www.";
	}


}
