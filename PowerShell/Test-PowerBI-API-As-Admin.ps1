# Test-PowerBI-API-As-Admin.ps1
# atwork.at, Toni Pohl, 01.10.2024
# See the corresponding article at https://blog.atwork.at/post/Grant-permissions-to-PowerBI-REST-API-as-Admin

# Fill in your app data
$tenantId = "<your-tenant-id>"
$clientId = "<your-app-id>"
$clientSecret = "<your-app-secret>"

# Create a token for this resource
$scope = "https://analysis.windows.net/powerbi/api/.default"
$authority = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Get the access token
$body = @{
  client_id = $clientId
  scope = $scope
  client_secret = $clientSecret
  grant_type = "client_credentials"
}

$response = Invoke-RestMethod -Method Post -Uri $authority -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $response.access_token

# Use the access token to call the Power BI REST API
$headers = @{
  Authorization = "Bearer $accessToken"
}

# Continue getting data with the access token $headers
$apiUrl = "https://api.powerbi.com/v1.0/myorg/admin/groups?%24top=10&%24skip=0"
# Note:
# If this error occurs: "Response status code does not indicate success: 404 (Not Found) OR "This API expects $top query option to be provided."
# This is the solution: Use %24 instead of $ in the query string as above.
# See https://stackoverflow.com/questions/75857169/powerbi-rest-api-request-getgroupsasadmin-returns-aggregateexception-an-attempt
$response = Invoke-RestMethod -Method Get -Uri $apiUrl -Headers $headers

# Show result
$response.value | ft
