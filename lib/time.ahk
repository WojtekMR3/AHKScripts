; @param string date "2021/05/05/15:35:10"
UnixTimeFromDate(date)
{
	date := StrReplace(date, "/")
	date := StrReplace(date, ":")
	FormatTime, TimeString, %date%, yyyyMMddHHmmss
	; Convert string to number.
	date := TimeString*1
	EnvSub, date, 19700101000000, Seconds
	return date  ; "Return" expects an expression.
}