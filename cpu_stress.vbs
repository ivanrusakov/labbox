Option Explicit

Dim i, arg, DelayInSec, paramVal
DelayInSec = -1 ' Default to invalid until found

For i = 0 To WScript.Arguments.Count - 1
    arg = WScript.Arguments(i)
    If InStr(LCase(arg), "/delayinsec:") = 1 Then
        ' Extract the value after the colon
        paramVal = Mid(arg, Len("/delayinsec:") + 1)
        If IsNumeric(paramVal) Then
            DelayInSec = CInt(paramVal)
            Exit For
        End If                
    End If
Next

If DelayInSec < 0 Then
    WScript.Echo "Usage: cscript /nologo cpu_stress.vbs /DelayInSec:<number_of_seconds>"
    WScript.Quit 1
End If

WScript.Echo "Delaying for " & DelayInSec & " second(s)..."
WScript.Sleep DelayInSec * 1000
WScript.Echo "Starting loop..."
While True

Wend