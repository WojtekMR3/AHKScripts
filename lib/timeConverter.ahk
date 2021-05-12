;==================================================

;Differences between the 1900 and the 1904 date system in Excel
;https://support.microsoft.com/en-us/help/214330/differences-between-the-1900-and-the-1904-date-system-in-excel
;a serial number that represents the number of elapsed days since January 1, 1900

;vNum: blank value means now
JEE_DateExcelToAhk(vNum:="", vFormat:="yyyyMMddHHmmss")
{
	if !(vNum = "")
		vDate := DateAdd(18991230, vNum*86400, "Seconds")
	if (vNum = "") || !(vFormat == "yyyyMMddHHmmss")
		return FormatTime(vDate, vFormat)
	return vDate
}

;==================================================

;vDate: blank value means now
JEE_DateAhkToExcel(vDate:="")
{
	return DateDiff(vDate, 18991230, "Seconds") / 86400
}

;==================================================

;FILETIME structure (Windows)
;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724284(v=vs.85).aspx
;number of 100-nanosecond intervals since January 1, 1601 (UTC)

;vNum: blank value means now
JEE_DateFileTimeToAhk(vNum:="", vFormat:="yyyyMMddHHmmss")
{
	if !(vNum = "")
		vDate := DateAdd(1601, vNum//10000000, "Seconds")
	if (vNum = "") || !(vFormat == "yyyyMMddHHmmss")
		return FormatTime(vDate, vFormat)
	return vDate
}

;==================================================

;vDate: blank value means now
JEE_DateAhkToFileTime(vDate:="")
{
	return DateDiff(vDate, 1601, "Seconds") * 10000000
}

;==================================================

;Unix time - Wikipedia
;https://en.wikipedia.org/wiki/Unix_time
;the number of seconds that have elapsed since 00:00:00 Coordinated Universal Time (UTC), Thursday, 1 January 1970, minus the number of leap seconds that have taken place since then

JEE_DateUnixToAhk(vNum:="", vFormat:="yyyyMMddHHmmss")
{
	if !(vNum = "")
		vDate := DateAdd(1970, vNum, "Seconds")
	if (vNum = "") || !(vFormat == "yyyyMMddHHmmss")
		return FormatTime(vDate, vFormat)
	return vDate
}

;==================================================

;vDate: blank value means now
JEE_DateAhkToUnix(vDate:="")
{
	return DateDiff(vDate, 1970, "Seconds")
}

;==================================================

;commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

DateAdd(DateTime, Time, TimeUnits)
{
    EnvAdd DateTime, %Time%, %TimeUnits%
    return DateTime
}
DateDiff(DateTime1, DateTime2, TimeUnits)
{
    EnvSub DateTime1, %DateTime2%, %TimeUnits%
    return DateTime1
}
FormatTime(YYYYMMDDHH24MISS:="", Format:="")
{
    local OutputVar
    FormatTime OutputVar, %YYYYMMDDHH24MISS%, %Format%
    return OutputVar
}

;==================================================