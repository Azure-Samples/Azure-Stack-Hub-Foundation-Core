$FQDN = "azurestack.external"
$RegionName = "local"


#Get Endpoints
$Endpoint=Invoke-WebRequest -Uri https://management.$RegionName.$FQDN/metadata/endpoints?api-version=2015-01-01
$endpoint.Content|fl *