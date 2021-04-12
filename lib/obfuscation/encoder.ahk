#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;******************************************
;	PUT THESE FUNCTIONS IN YOUR ACTUAL AUTOHOTKEY SCRIPT FILE

hidestr(thisstr)
{
	return thisstr
}


decode_hidestr(startstr) 
{
	global	
;$OBFUSCATOR: $DEFGLOBVARS: hexdigits
	
	static newstr, startstrlen, charnum, hinibble, lownibble, mybinary
;$OBFUSCATOR: $DEFLOSVARS: newstr, startstrlen, charnum, hinibble, lownibble, mybinary

	hexdigits = % "0123456789abcdef"
		
	decode_hexshiftkeys(startstr)
	
	startstr = % substr(startstr, 1, 1) . substr(startstr, 6)
	startstrlen = % strlen(startstr)
		
	newstr = 
	loop, % strlen(startstr) 
		newstr = % substr(startstr, a_index, 1) . newstr
	
	startstr = % newstr
	newstr = 
	charnum = 1
	while true
	{
		if (charnum >startstrlen)
			break
			
		hinibble = % substr(startstr, charnum, 1)
		hinibble = % instr(hexdigits, hinibble) - 1
		
		lownibble = % substr(startstr, charnum + 1, 1)
		lownibble = % instr(hexdigits, lownibble) - 1
		
		hinibble := decode_shifthexdigit(hinibble)
		lownibble := decode_shifthexdigit(lownibble)
		
		mybinary = % hinibble * 16 + lownibble
		newstr .= chr(mybinary)
		
		charnum += 2		
	}
		
	newstr = % fixescapes(newstr)
		
	return, newstr	
}
decode_hexshiftkeys(startstr)
{
	global
;$OBFUSCATOR: $DEFGLOBVARS: decodekey, ishexchar, useshiftkey
	
	decodekey := "fff@kkf1ffkfkfkfff#k1fk@kf#@fffk@#kk"
	ishexchar := "fff@f1ff@kffkk#f1fffffkf"
	
	%decodekey%%ishexchar%1 = % substr(startstr, 2, 1)
	%decodekey%%ishexchar%2 = % substr(startstr, 3, 1)
	%decodekey%%ishexchar%3 = % substr(startstr, 4, 1)
	%decodekey%%ishexchar%4 = % substr(startstr, 5, 1)
	
	loop, 4
		%decodekey%%a_index% = % instr(hexdigits, %decodekey%%ishexchar%%a_index%) - 1
			
	useshiftkey = 0
}	

decode_shifthexdigit(hexvalue)
{
	global
	
	useshiftkey++
	if (useshiftkey > 4)
		useshiftkey = 1	
	
	hexvalue -= %decodekey%%useshiftkey%
	
	if (hexvalue < 0) 
		hexvalue += 16
		
	return hexvalue	
}

fixescapes(forstr)
{
	global
	
	StringReplace, forstr, forstr, % "````", % "``", all
	StringReplace, forstr, forstr, % "``n", % "`n", all
	StringReplace, forstr, forstr, % "``r", % "`r", all
	StringReplace, forstr, forstr, % "``,", % "`,", all
	StringReplace, forstr, forstr, % "``%", % "`%", all	
	StringReplace, forstr, forstr, % "``;", % "`;", all	
	StringReplace, forstr, forstr, % "``t", % "`t", all
	StringReplace, forstr, forstr, % "``b", % "`b", all
	StringReplace, forstr, forstr, % "``v", % "`v", all
	StringReplace, forstr, forstr, % "``a", % "`a", all
	
	StringReplace, forstr, forstr, % """""", % """", all
	
	return forstr
}