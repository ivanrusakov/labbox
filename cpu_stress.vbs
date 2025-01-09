Option Explicit

Dim i, arg, DelayInSec, paramVal
' Setting the default value to -1 to indicate that the value has not been set. Required to ensure that the script will be able to execute all loops before system become unresponsive.
DelayInSec = -1

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

If DelayInSec < 1 Then
    WScript.Echo "The script will delay for the specified number of seconds before starting an infinite loop. The loop will consume CPU resources. number_of_seconds must be a positive integer more than zero."
    WScript.Echo "Usage: cscript /nologo cpu_stress.vbs /DelayInSec:<number_of_seconds>"
    WScript.Echo "Example: cscript /nologo cpu_stress.vbs /DelayInSec:10"
    WScript.Quit 1
End If

WScript.Echo "Delaying for " & DelayInSec & " second(s)..."
WScript.Sleep DelayInSec * 1000
WScript.Echo "Starting loop..."

' Infinite loop to consume CPU resources
While True

Wend