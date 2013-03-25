component output="false"
{

	/**
	* @hint Returns a datetime in ISO 8601 format. Defaults to GMT but can return local time if GMT == false
	* @param {boolean} GMT Whether to return GMT (default) or local time
	*/
	public date function getISODateTime(boolean GMT = true)
	{
		var dateNow = (arguments.GMT) ? dateConvert("local2UTC", now()) : now();
		var isoDate = dateformat(dateNow, 'yyyy-mm-dd') & "T" & TimeFormat(dateNow, 'HH:mm:ss');
		var hourOffset = getTimeZoneInfo().utcHourOffset*-1;
		var minuteOffset = getTimeZoneInfo().utcMinuteOffset;

		if (arguments.GMT)
		{
			// GMT datetime (ie no timezone) add a trailing `Z`. Eg YYYY-MM-DDTHH:mm:ssZ
			isoDate &= "Z";
		}
		else
		{
			if (hourOffset > 0)
			{
				// Add the `+` sign as we need that for ISO 8601
				hourOffset = "+" & hourOffset;
			}
			if (len(minuteOffset) == 1)
			{
				// ColdFusion returns a single digit, not sure if this is a valid ISO 8601 format so we add a trailing 0
				minuteOffset = minuteOffset &= "0";
			}
			isoDate &= "#hourOffset#:#minuteOffset#"
		}

		return isoDate;
	}


	/**
	* @hint Returns a unit timestamp without the last 3 digits which represent milliseconds
	*/
	public numeric function getUnixTime()
	{
		return left(getTickCount(), 10);
	}

}
