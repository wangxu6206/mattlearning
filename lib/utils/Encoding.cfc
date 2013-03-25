component output="false"
{

	/**
	* @hint Decodes a URL modified base64 encoded string
	* Replaces `-`, `_` and `,` with `+`, `/` and `=` respectively
	*/
	public string function modifiedBase64Decode(required string data)
	{
		var s = arguments.data;

		s = replaceNoCase(s, "-", "+", "all");
		s = replaceNoCase(s, "_", "/", "all");
		s = replaceNoCase(s, ",", "=", "all");

		return toString(binaryDecode(s, "base64"));
	}


	/**
	* @hint Encodes a string in base64 encoding modifed for use over a HTTP `GET` request
	* Replaces `+`, `/` and `=` with `-`, `_` and `,` respectively
	*/
	public string function modifiedBase64Encode(required string data)
	{
		var s = toBase64(arguments.data, "utf-8");

		s = replaceNoCase(s, "+", "-", "all");
		s = replaceNoCase(s, "/", "_", "all");
		s = replaceNoCase(s, "=", ",", "all");

		return s;
	}


	/**
	* @hint Prepares XML data to send to a SAML endpoint. Must be:
	*  - DEFLATE compressed
	*  - base64 encoded
	*  - URL encoded
	* @param {string} data XML metadata for an authentication request
	*/
	public string function samlPack(required string data)
	{
		var compressionLevel = 9;
		var noWrap = true;
		var emptyByteArray = createObject("java", "java.io.ByteArrayOutputStream").init().toByteArray();
		var byteClass = emptyByteArray.getClass().getComponentType();
		var output = createObject("java","java.lang.reflect.Array").newInstance(byteClass, 500);
		var saml = arguments.data;
		var deflater = createObject("java", "java.util.zip.Deflater");

		deflater.init(compressionLevel, noWrap);
		deflater.setInput(saml.getBytes("UTF-8"));
		deflater.finish();
		deflater.deflate(output);

		return URLEncodedFormat(toBase64(output, "UTF-8"));
	}


	/**
	* @hint Decodes a base64 encoded XML response from a SAML IdP
	* @param {string} data XML metadata returned from an IdP
	*/
	public string function samlUnpack(required string data)
	{
		var xmlData = toString(binaryDecode(arguments.data, "base64"));
		if (!isXML(xmlData))
		{
			throw(type="encoding.samlUnpack.invalidXml", message="Data isn't XML");
		}
		return xmlData;
	}

}
