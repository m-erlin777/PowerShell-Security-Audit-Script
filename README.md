# PowerShell-Security-Audit-Script
PowerShell script that performs a basic Windows security audit tailored for a non-Active Directory home lab with Active Directory functionality showcased.

### Overview
Collects key system information, evaluates user accounts, checks last logon times, reviews password policies, and verifies password complexity settings from the Winodws registry.

The script automatically:
- Creates a timestamped log file in a dedicated (`Logs`) directory
- Performs multiple audit checks
- Records results with timestamps for review
- Handles missing features

## Features
- OS Information: Detects Windows version and build
- User Accounts: Lists all local accounts
- Last Logon Times: Shows recent login timestamps
- Password Policy: Displays minimum and maximum length, age, and history requirements
- Password Complexity Check: Reads (`HKLM\SYSTEM\CurrentControlSet\Control\Lsa`) registry to confirm complexity enforcement
- Logging Systems: All output is stored in a timestamped log file

## Script Behavior
### Logging Directory Auto-Creation
If (`Logs`) directory does not exist already, it is created automatically.

### Audit Functions
Each audit item is handled by a dedicated function for modularity and granularization.

### Non-AD Safe Defaults
AD-related variables can be commented out for portability to prevent errors in standalone systems

### Error Handling
If a value cannot be determined, a (`try-catch`) allows for graceful error handling and a descriptive message is logged.

## Requirements
- Windows PowerShell 5.1 or 7.x
- Local administrative privileges
- A writeable (`Logs`) directory

# Example Output
```
[2025-08-12 06:44:21] OS Version: Microsoft Windows 10 Pro 10.0.19045
[2025-08-12 06:44:21] User Accounts: Administrator, DefaultAccount, Guest, MyUser
[2025-08-12 06:44:21] Last Logon Times:
 - MyUser: 8/12/2025 06:40:15
 - Guest: Never logged on
[2025-08-12 06:44:21] Password Policy:
 - Minimum length: 12
 - Maximum age: 90 days
 - History length: 24
[2025-08-12 06:44:21] Password Complexity: Enabled
[2025-08-12 06:44:21] Security audit complete.
```







