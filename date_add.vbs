Option Explicit

' Function to validate if a string is numeric
Function IsNumericValue(str)
    IsNumericValue = IsNumeric(str)
End Function

' Function to retrieve a specific part of the date or time
Function GetDateTimePart(dt, part)
    Select Case LCase(part)
        Case "date"
            GetDateTimePart = Year(dt) & "-" & _
                              Right("00" & Month(dt), 2) & "-" & _
                              Right("00" & Day(dt), 2)
        Case "time"
            GetDateTimePart = Right("00" & Hour(dt), 2) & ":" & _
                              Right("00" & Minute(dt), 2) & ":" & _
                              Right("00" & Second(dt), 2)
        Case "both"
            GetDateTimePart = GetDateTimePart(dt, "date") & "T" & GetDateTimePart(dt, "time")
        Case Else
            GetDateTimePart = ""
    End Select
End Function

Dim currentDate, secondsToAdd, newDate, outputType, outputValue

' Check if the correct number of arguments is provided (1 or 2)
If WScript.Arguments.Count < 1 Or WScript.Arguments.Count > 2 Then
    WScript.Echo "Usage: cscript date_add.vbs <secondsToAdd> [outputType]"
    WScript.Echo "       <secondsToAdd> : Numeric value representing seconds to add."
    WScript.Echo "       [outputType]   : Optional. Specify 'date', 'time', or 'both'. Default is 'both'."
    WScript.Quit 1
End If

' Get the number of seconds to add from the first command-line argument
If IsNumericValue(WScript.Arguments(0)) Then
    secondsToAdd = CLng(WScript.Arguments(0))
Else
    WScript.Echo "Error: The first argument must be a numeric value representing seconds."
    WScript.Quit 1
End If

' Determine the output type from the second command-line argument, if provided
If WScript.Arguments.Count = 2 Then
    outputType = LCase(Trim(WScript.Arguments(1)))
    If outputType <> "date" And outputType <> "time" And outputType <> "both" Then
        WScript.Echo "Error: The second argument must be 'date', 'time', or 'both'."
        WScript.Quit 1
    End If
Else
    outputType = "both" ' Default value
End If

' Get the current date and time
currentDate = Now

' Ensure currentDate is a Date type
If Not IsDate(currentDate) Then
    WScript.Echo "Error: Unable to retrieve the current date and time."
    WScript.Quit 1
End If

' Add the seconds to the current date and time
On Error Resume Next
newDate = DateAdd("s", secondsToAdd, currentDate)
If Err.Number <> 0 Then
    WScript.Echo "Error adding seconds: " & Err.Description
    WScript.Quit 1
End If
On Error GoTo 0

' Determine what to output based on outputType
outputValue = GetDateTimePart(newDate, outputType)

' Display the results based on outputType
WScript.Echo outputValue
