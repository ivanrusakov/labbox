Option Explicit

' Function to validate if a string is numeric
Function IsNumericValue(str)
    IsNumericValue = IsNumeric(str)
End Function

' Function to retrieve a specific part of the date or time
Function GetDateTimePart(dateTime, partType, timeFormat)
    Select case LCase(timeFormat)
            Case "utc"
                Select Case LCase(partType)
                Case "date"
                    GetDateTimePart = Year(dateTime) & "-" & _
                                    Right("00" & Month(dateTime), 2) & "-" & _
                                    Right("00" & Day(dateTime), 2)
                Case "time"
                    GetDateTimePart = Right("00" & Hour(dateTime), 2) & ":" & _
                                    Right("00" & Minute(dateTime), 2) & ":" & _
                                    Right("00" & Second(dateTime), 2)
                Case "both"
                    GetDateTimePart = GetDateTimePart(dateTime, "date", timeFormat) & "T" & GetDateTimePart(dateTime, "time", timeFormat)
                Case Else
                    GetDateTimePart = ""
                End Select
        Case "local"            
            Select Case LCase(partType)
                Case "date"
                    GetDateTimePart = FormatDateTime(dateTime, vbShortDate)
                Case "time"
                    GetDateTimePart = FormatDateTime(dateTime, vbLongTime)
                Case "both"
                    GetDateTimePart = FormatDateTime(dateTime, vbShortDate) & " " & FormatDateTime(dateTime, vbLongTime)
                Case Else
                    GetDateTimePart = ""
            End Select
            
    End Select
End Function

Dim currentDate, secondsToAdd, newDate, outputType, outputValue, timeFormat

' Check if the correct arguments are provided
Function ParseAndValidateArgs()
    Dim i, arg, key, value
    
    ' Initialize default values
    secondsToAdd = 0
    outputType = "both"
    timeFormat = "local"
    
    ' Iterate through each argument
    For i = 0 To WScript.Arguments.Count - 1
        arg = WScript.Arguments(i)
        
        ' Check if argument contains '='
        If InStr(arg, "=") > 0 Then
            key = LCase(Left(arg, InStr(arg, "=") - 1))
            value = Mid(arg, InStr(arg, "=") + 1)
            
            Select Case key
                Case "/seconds"
                    If IsNumericValue(value) Then
                        secondsToAdd = CLng(value)
                    Else
                        WScript.Echo "Error: /seconds must be a numeric value."
                        WScript.Quit 1
                    End If
                Case "/outputtype"
                    value = LCase(Trim(value))
                    If value = "date" Or value = "time" Or value = "both" Then
                        outputType = value
                    Else
                        WScript.Echo "Error: /outputType must be 'date', 'time', or 'both'. Default is " & outputType & "."
                        WScript.Quit 1
                    End If
                Case "/timeformat"
                    value = LCase(Trim(value))
                    If value = "utc" Or value = "local" Then
                        timeFormat = value
                    Else
                        WScript.Echo "Error: /timeFormat must be 'UTC' or 'local'. Default is " & timeFormat & "."
                        WScript.Quit 1
                    End If
                Case Else
                    WScript.Echo "Error: Unknown parameter '" & key & "'."
                    WScript.Quit 1
            End Select
        Else
            WScript.Echo "Error: Invalid parameter format '" & arg & "'. Expected /key=value."
            WScript.Quit 1
        End If
    Next
    
    ' Validate required parameter
    If IsEmpty(secondsToAdd) Then
        WScript.Echo "Error: /seconds parameter is required."
        WScript.Echo "Usage: cscript date_add.vbs /seconds=<value> [/outputType=<date|time|both>] [/timeFormat=<UTC|local>]"
        WScript.Quit 1
    End If
End Function

ParseAndValidateArgs

' Get the current date and time
currentDate = Now

' Add the seconds to the current date and time
newDate = DateAdd("s", secondsToAdd, currentDate)

' Determine what to output based on outputType
outputValue = GetDateTimePart(newDate, outputType, timeFormat)

' Display the results based on outputType
WScript.Echo outputValue
