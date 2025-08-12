# ----------------------
# CONFIGURATION SECTION
# ----------------------

# Define where to save the audit log file with a timestamp
$logFile = "C:\Example\Filepath\Security_Audit_Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Create log folder if it doesn't exist
$logFolder = "C:\Example\Filepath"

if (-not (Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# Define where to save the audit log file with a timestamp
# --- Placeholder ---
# $logFile = Join-Path $logFolder "Security_Audit_Log$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# ----------------------
# LOGGING FUNCTION
# ----------------------

# Function to write output both to console and to log file
Function Write-Log {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $logFile -Value $Message
}

# ----------------------
# AUDIT FUNCTIONS
# ----------------------

Function Get-OSVersion {
    Write-Log "=== OS Version Check ==="
    $os = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber
    Write-Log ($os | Out-String)
}

Function Get-UserAccounts {
    Write-Log "=== Local User Accounts ==="
    $users = Get-LocalUser
    Write-Log ($users | Out-String)
}

Function Get-LastLogon {
    Write-Log "=== Last Logon Information ==="
    $lastLogon = Get-LocalUser | ForEach-Object {
        $_ | Select-Object Name, LastLogon
    }
    Write-Log ($lastLogon | Out-String)
}

Function Get-PasswordPolicy {
    Write-Log "=== Password Policy and Account Lockout Settings ==="

    # Try Active Directory
    try {
        if (Get-Module -ListAvailable -Name ActiveDirectory) {
            Import-Module ActiveDirectory -ErrorAction Stop

            # Retrieve AD domain password policy
            $adPolicy = Get-ADDefaultDomainPasswordPolicy

            Write-Log "=== Environment Detected: AD Domain Controller ==="
            Write-Log "Domain Name: $((Get-ADDomain).DNSRoot)"
            Write-Log "Minimum Password Length: $($adPolicy.MinPasswordLength)"
            Write-Log "Password History Count: $($adPolicy.PasswordHistoryCount)"
            Write-Log "Maximum Password Age (days): $($adPolicy.MaxPasswordAge.Days)"
            Write-Log "Minimum Password Age (days): $($adPolicy.MinPasswordAge.Days)"
            Write-Log "Lockout Threshold: $($adPolicy.LockoutThreshold)"
            Write-Log "Lockout Duration (minutes): $($adPolicy.LockoutDuration.TotalMinutes)"
            Write-Log "Reset Lockout Counter After (minutes): $($adPolicy.LockoutObservationWindow.TotalMinutes)"
        }
        else {
            throw "Active Directory module not found. Falling back to local policy."
        }
    }
    catch {
        # Fall back to local machine policy
        Write-Log "=== Local Machine Password Policy ==="

        # Run net accounts and capture output:
        $netAccountsOutput = net accounts
        Write-Log $netAccountsOutput
    
        # Parse key values from output for clear reporting
        if ($netAccountsOutput -match "Minimum password length\s+(\d+)") {
            $minPasswordLength = $matches[1]
            Write-Log "Minimum Password Length: $minPasswordLength"
        }

         # Parse password complexity
        # Check complexity setting via Security Policy, e.x. query registry or use secedit
        try {
            $passwordComplexity = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "PasswordComplexity" -ErrorAction Stop
            if ($passwordComplexity.PasswordComplexity -eq 1) {
                Write-Log "Password Complexity: Enabled"
            }
            else {
                Write-Log "Password Complexity: Disabled"
            }
        }
        catch {
            Write-Log "Password-Complexity: Unable to determine (error accessing registry)"
        }

        # Parse account lockout threshold
        if ($netAccountsOutput -match "Lockout threshold\s+(\d+)") {
            $lockoutThreshold = $matches[1]
            Write-Log "Account Lockout Threshold: $lockoutThreshold"
        }

        # Parse lockout duration
        if ($netAccountsOutput -match "Lockout duration\s+(\d+)") {
            $lockoutDuration = $matches[1]
            Write-Log "Account Lockout Duration (minutes): $lockoutDuration"
        }

        # Parse reset lockout counter after
        if ($netAccountsOutput -match "Lockout observation window\s+(\d+)") {
            $lockoutObservationWindow = $matches[1]
            Write-Log "Lockout Observation Window (minutes): $lockoutObservationWindow"
        }

    }
}

# ----------------------
# MAIN EXECUTION
# ----------------------

Write-Log "========== Security Audit Started: $(Get-Date) =========="

Get-OSVersion
Get-UserAccounts
Get-LastLogon
Get-PasswordPolicy

Write-Log "========== Security Audit Completed: $(Get-Date) =========="
