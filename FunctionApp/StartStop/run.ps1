using namespace System.Net

param(
    $Request,
    [string] $VMName,
    [string] $Operator
    )
    
$WebhookSecret = Get-AzKeyVaultSecret -VaultName BHBTesting -Name "$VMName-$Operator"
$BSTRWebhook = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($WebhookSecret.secretvalue)
$WebhookPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTRWebhook)

$uri = $WebhookPlain
$headerMessage = @{ message = "AutomatedStop"}
$data = @(
    @{ Alert="Webhook to stop server implemented on $Date"}
)
$body = ConvertTo-Json -InputObject $data

# Trigger the webhook
try {
    $response = invoke-webrequest -method Post -uri $uri -header $headerMessage -Body $body -UseBasicParsing 
    }
catch {
    if ($_.ErrorDetails.Message) {
        $errorObject = $_.ErrorDetails.Message | ConvertFrom-Json
        foreach ($validationError in $errorObject.customProperties.ValidationResults) {
            Write-Warning $validationError.message
        }
        Write-Error $errorObject.message
    }
    throw $_.Exception
}

