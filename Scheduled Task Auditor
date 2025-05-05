# Define a function to collect and audit scheduled tasks
function Invoke-ScheduledTaskAudit {

    # Create an empty list to store audit results
    $auditResults = @()

    # Get all scheduled tasks on the system
    Get-ScheduledTask | ForEach-Object {

        # Store the current task object
        $task = $_

        # Initialize an array to hold flags for suspicious indicators
        $flags = @()

        # Get basic properties of the task
        $taskName = $task.TaskName                       # Name of the scheduled task
        $taskPath = $task.TaskPath                       # Folder path of the task
        $author = $task.Principal.UserId                # User account under which the task runs
        $runLevel = $task.Principal.RunLevel            # Indicates if the task runs with highest privileges
        $hidden = $task.Settings.Hidden                 # Boolean indicating if the task is hidden
        $actions = ($task.Actions | ForEach-Object { $_.Execute + ' ' + $_.Arguments }) -join '; '  # Combined command(s) the task executes
        $triggers = ($task.Triggers | ForEach-Object { $_.StartBoundary }) -join '; '               # Start times for the task

        # === Detection Logic ===

        # Flag if task is hidden
        if ($hidden -eq $true) {
            $flags += "Hidden Task"
        }

        # Flag if the task uses base64 encoding (often seen in obfuscated PowerShell)
        if ($actions -match "(?i)base64") {
            $flags += "Encoded Payload"
        }

        # Flag if task uses known Living Off the Land Binaries (LOLBINs)
        if ($actions -match "(?i)powershell|cmd\.exe|wscript\.exe|mshta\.exe|cscript\.exe|rundll32\.exe") {
            $flags += "LOLBIN Usage"
        }

        # Flag if task runs under a non-standard or privileged user account
        if ($author -and ($author -notmatch "SYSTEM|LOCAL SERVICE|NETWORK SERVICE|Administrators|Users|^NT AUTHORITY\\")) {
            $flags += "Unusual User Context"
        }

        # Flag if task path indicates a user or public folder (possible persistence or evasion)
        if ($actions -match "C:\\Users\\|C:\\ProgramData\\|AppData\\|Temp\\|Public") {
            $flags += "Suspicious File Path"
        }

        # Create a custom object with all collected information
        $auditEntry = [PSCustomObject]@{
            TaskName       = $taskName
            TaskPath       = $taskPath
            User           = $author
            RunLevel       = $runLevel
            Hidden         = $hidden
            Triggers       = $triggers
            Actions        = $actions
            Flags          = ($flags -join ", ")
        }

        # Add the audit entry to the results array
        $auditResults += $auditEntry
    }

    # === Output Results in Full Block Format ===
    foreach ($entry in $auditResults) {
        Write-Output "TaskName      : $($entry.TaskName)"
        Write-Output "TaskPath      : $($entry.TaskPath)"
        Write-Output "User          : $($entry.User)"
        Write-Output "RunLevel      : $($entry.RunLevel)"
        Write-Output "Hidden        : $($entry.Hidden)"
        Write-Output "Triggers      : $($entry.Triggers)"
        Write-Output "Actions       : $($entry.Actions)"
        Write-Output "Flags         : $($entry.Flags)"
        Write-Output "`n" # New line between entries
    }

    # === Optional CSV Export ===
    $exportPath = "$env:USERPROFILE\Desktop\ScheduledTaskAudit_$(Get-Date -Format yyyyMMdd_HHmmss).csv"
    $auditResults | Export-Csv -NoTypeInformation -Path $exportPath
    Write-Host "`n[*] Audit complete. Results exported to:`n$exportPath" -ForegroundColor Cyan
}

# Run the audit function
Invoke-ScheduledTaskAudit
