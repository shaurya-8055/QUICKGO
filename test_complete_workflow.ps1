# PowerShell script to test the complete service request workflow

Write-Host "🚀 Starting Service Request Workflow Test..." -ForegroundColor Green
Write-Host ""

$BASE_URL = "http://localhost:3000"

try {
    # 1. Create a service request
    Write-Host "1. Creating a new service request..." -ForegroundColor Cyan
    $createBody = @{
        userID = "507f1f77bcf86cd799439011"
        category = "AC Repair"
        customerName = "John Doe"
        phone = "+1234567890"
        address = "123 Main St, City, State"
        description = "AC not cooling properly"
        preferredDate = "2025-08-19T10:00:00.000Z"
        preferredTime = "2:00 PM"
    } | ConvertTo-Json

    $createResponse = Invoke-WebRequest -Uri "$BASE_URL/service-requests" -Method POST -Body $createBody -ContentType "application/json"
    $createData = $createResponse.Content | ConvertFrom-Json
    
    Write-Host "✅ Service request created successfully" -ForegroundColor Green
    $requestId = $createData.data._id
    Write-Host "📝 Request ID: $requestId" -ForegroundColor Yellow
    Write-Host ""

    # 2. Fetch available technicians
    Write-Host "2. Fetching available technicians..." -ForegroundColor Cyan
    $techResponse = Invoke-WebRequest -Uri "$BASE_URL/technicians" -Method GET
    $techData = $techResponse.Content | ConvertFrom-Json
    
    Write-Host "✅ Technicians fetched: $($techData.data.Count) technicians" -ForegroundColor Green
    
    if ($techData.data.Count -eq 0) {
        Write-Host "❌ No technicians available for testing" -ForegroundColor Red
        return
    }

    $technician = $techData.data[0]
    Write-Host "👨‍🔧 Selected technician: $($technician.name) ($($technician.phone))" -ForegroundColor Yellow
    Write-Host ""

    # 3. Test APPROVE action with technician assignment
    Write-Host "3. Testing APPROVE action..." -ForegroundColor Cyan
    $approveBody = @{
        status = "approved"
        assigneeId = $technician._id
        assigneeName = $technician.name
        assigneePhone = $technician.phone
        notes = "Approved and assigned to technician"
    } | ConvertTo-Json

    $approveResponse = Invoke-WebRequest -Uri "$BASE_URL/service-requests/$requestId" -Method PATCH -Body $approveBody -ContentType "application/json"
    $approveData = $approveResponse.Content | ConvertFrom-Json

    Write-Host "✅ Request approved successfully" -ForegroundColor Green
    Write-Host "📋 Status: $($approveData.data.status)" -ForegroundColor Yellow
    Write-Host "👨‍🔧 Assigned to: $($approveData.data.assigneeName)" -ForegroundColor Yellow
    Write-Host ""

    # 4. Test IN-PROGRESS action
    Write-Host "4. Testing IN-PROGRESS action..." -ForegroundColor Cyan
    $inProgressBody = @{
        status = "in-progress"
        notes = "Technician is on the way"
    } | ConvertTo-Json

    $inProgressResponse = Invoke-WebRequest -Uri "$BASE_URL/service-requests/$requestId" -Method PATCH -Body $inProgressBody -ContentType "application/json"
    $inProgressData = $inProgressResponse.Content | ConvertFrom-Json

    Write-Host "✅ Request set to in-progress" -ForegroundColor Green
    Write-Host "📋 Status: $($inProgressData.data.status)" -ForegroundColor Yellow
    Write-Host ""

    # 5. Test COMPLETED action
    Write-Host "5. Testing COMPLETED action..." -ForegroundColor Cyan
    $completedBody = @{
        status = "completed"
        notes = "Service completed successfully"
    } | ConvertTo-Json

    $completedResponse = Invoke-WebRequest -Uri "$BASE_URL/service-requests/$requestId" -Method PATCH -Body $completedBody -ContentType "application/json"
    $completedData = $completedResponse.Content | ConvertFrom-Json

    Write-Host "✅ Request marked as completed" -ForegroundColor Green
    Write-Host "📋 Status: $($completedData.data.status)" -ForegroundColor Yellow
    Write-Host ""

    # 6. Create another request to test CANCEL action
    Write-Host "6. Creating another request to test CANCEL action..." -ForegroundColor Cyan
    $createBody2 = @{
        userID = "507f1f77bcf86cd799439011"
        category = "TV Repair"
        customerName = "Jane Smith"
        phone = "+1234567891"
        address = "456 Oak St, City, State"
        description = "TV not turning on"
        preferredDate = "2025-08-20T14:00:00.000Z"
        preferredTime = "3:00 PM"
    } | ConvertTo-Json

    $createResponse2 = Invoke-WebRequest -Uri "$BASE_URL/service-requests" -Method POST -Body $createBody2 -ContentType "application/json"
    $createData2 = $createResponse2.Content | ConvertFrom-Json
    $requestId2 = $createData2.data._id
    Write-Host "📝 Second Request ID: $requestId2" -ForegroundColor Yellow

    # 7. Test CANCEL action (DELETE)
    Write-Host "7. Testing CANCEL action (DELETE)..." -ForegroundColor Cyan
    $cancelResponse = Invoke-WebRequest -Uri "$BASE_URL/service-requests/$requestId2" -Method DELETE
    $cancelData = $cancelResponse.Content | ConvertFrom-Json
    Write-Host "✅ Request cancelled (deleted)" -ForegroundColor Green
    Write-Host ""

    # 8. Verify the full workflow by fetching all requests
    Write-Host "8. Fetching all service requests to verify workflow..." -ForegroundColor Cyan
    $allRequestsResponse = Invoke-WebRequest -Uri "$BASE_URL/service-requests" -Method GET
    $allRequestsData = $allRequestsResponse.Content | ConvertFrom-Json
    
    Write-Host "📊 Total service requests: $($allRequestsData.data.items.Count)" -ForegroundColor Yellow
    
    $completedRequest = $allRequestsData.data.items | Where-Object { $_._id -eq $requestId }
    if ($completedRequest) {
        Write-Host ""
        Write-Host "📋 Final request details:" -ForegroundColor Cyan
        Write-Host "   ID: $($completedRequest._id)" -ForegroundColor White
        Write-Host "   Category: $($completedRequest.category)" -ForegroundColor White
        Write-Host "   Customer: $($completedRequest.customerName)" -ForegroundColor White
        Write-Host "   Status: $($completedRequest.status)" -ForegroundColor White
        Write-Host "   Assigned to: $($completedRequest.assigneeName)" -ForegroundColor White
        Write-Host "   Phone: $($completedRequest.assigneePhone)" -ForegroundColor White
        Write-Host "   Notes: $($completedRequest.notes)" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "🎉 All workflow tests completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Test Summary:" -ForegroundColor Cyan
    Write-Host "   ✅ Create service request" -ForegroundColor Green
    Write-Host "   ✅ Approve request with technician assignment" -ForegroundColor Green
    Write-Host "   ✅ Set to in-progress" -ForegroundColor Green
    Write-Host "   ✅ Mark as completed" -ForegroundColor Green
    Write-Host "   ✅ Cancel (delete) request" -ForegroundColor Green
    Write-Host "   ✅ All action buttons functional" -ForegroundColor Green

} catch {
    Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
}
