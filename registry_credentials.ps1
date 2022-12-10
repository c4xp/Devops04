Param(
    [Parameter(Mandatory = $True, HelpMessage = 'Username')][string]$username,
    [Parameter(Mandatory = $True, HelpMessage = 'Password')][SecureString]$encoded
)

if ($encoded) {
    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($encoded))
}
else {
    Write-Host "Password not supplied"
    Start-Sleep -Seconds 2
    Exit
}

docker login --username $username --password $password
kubectl create secret docker-registry myapp-secret-registry --docker-username="$username" --docker-password="$password" --docker-server="index.docker.io" --namespace="myapp-namespace"