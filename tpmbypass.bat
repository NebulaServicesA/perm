reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI" /v "WindowsAIKHash" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI" /v "TaskManufacturerId" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI" /v "TaskInformationFlags" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\TaskStates" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\PlatformQuoteKeys" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement\EKCertStoreECC\Certificates" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EkRetryLast" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EKPub" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EkNoFetch" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /v "EkTries" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\Parameters\Wdf" /v "TimeOfLastTelemetry" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\Admin" /v "SRKPub" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\WMI\User" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\KeyAttestationKeys" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\Enum" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TPM\ODUID" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\TPM\WMI\Endorsement" /f
reg delete "HKLM\SYSTEM\ControlSet001\Services\TPM\WMI\Endorsement" /f

powershell -Command "Disable-TPMAutoProvisioning"
powershell -Command "Clear-Tpm"


