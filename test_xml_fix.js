// Test the complete workflow: create service request → approve → in-progress
const API_BASE = 'http://localhost:3000';

async function testServiceRequestWorkflow() {
    console.log('🚀 Starting Service Request Workflow Test...\n');
    
    try {
        // Step 1: Create a service request
        console.log('📝 Step 1: Creating service request...');
        const createResponse = await fetch(`${API_BASE}/service-requests`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                userID: '689373c2607805e9de41acb5', // Valid existing user ID
                category: 'Electronics',
                customerName: 'Test Customer',
                phone: '1234567890',
                address: '123 Test Street',
                description: 'Test XMLHttpRequest fix',
                preferredDate: new Date().toISOString(),
                preferredTime: '10:00 AM',
                status: 'pending'
            })
        });
        
        if (!createResponse.ok) {
            throw new Error(`Create failed: ${createResponse.status} ${createResponse.statusText}`);
        }
        
        const createResult = await createResponse.json();
        console.log('✅ Service request created:', createResult.data);
        const serviceId = createResult.data._id;
        
        // Step 2: Get a technician for assignment
        console.log('\n👷 Step 2: Getting technicians...');
        const techResponse = await fetch(`${API_BASE}/technicians`);
        if (!techResponse.ok) {
            throw new Error(`Technicians fetch failed: ${techResponse.status}`);
        }
        
        const techResult = await techResponse.json();
        const technician = techResult.data[0]; // Direct array access
        console.log('✅ Technician found:', technician.name);
        
        // Step 3: Approve the request (this is where XMLHttpRequest error occurred)
        console.log('\n✅ Step 3: Approving service request...');
        const approveResponse = await fetch(`${API_BASE}/service-requests/${serviceId}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                status: 'approved',
                assigneeId: technician._id,
                assigneeName: technician.name,
                assigneePhone: technician.phone
            })
        });
        
        if (!approveResponse.ok) {
            throw new Error(`Approve failed: ${approveResponse.status} ${approveResponse.statusText}`);
        }
        
        const approveResult = await approveResponse.json();
        console.log('✅ Request approved:', approveResult.message);
        
        // Step 4: Set to in-progress
        console.log('\n🔄 Step 4: Setting to in-progress...');
        const progressResponse = await fetch(`${API_BASE}/service-requests/${serviceId}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                status: 'in-progress'
            })
        });
        
        if (!progressResponse.ok) {
            throw new Error(`In-progress failed: ${progressResponse.status} ${progressResponse.statusText}`);
        }
        
        const progressResult = await progressResponse.json();
        console.log('✅ Status updated to in-progress:', progressResult.message);
        
        // Step 5: Verify final state
        console.log('\n🔍 Step 5: Verifying final state...');
        const getResponse = await fetch(`${API_BASE}/service-requests/${serviceId}`);
        const getResult = await getResponse.json();
        const finalRequest = getResult.data;
        
        console.log('📊 Final State:');
        console.log(`   Status: ${finalRequest.status}`);
        console.log(`   Assigned to: ${finalRequest.assigneeName}`);
        console.log(`   Phone: ${finalRequest.assigneePhone}`);
        
        console.log('\n🎉 WORKFLOW TEST PASSED - XMLHttpRequest error is FIXED!');
        
    } catch (error) {
        console.error('❌ WORKFLOW TEST FAILED:', error.message);
        console.error('   This indicates XMLHttpRequest error still exists');
        return false;
    }
    
    return true;
}

// Run the test
testServiceRequestWorkflow().then(success => {
    if (success) {
        console.log('\n✅ ALL TESTS PASSED - Ready for UI testing!');
        console.log('🔗 Admin Portal: http://localhost:8080');
        console.log('🔗 User App: http://localhost:56632');
    } else {
        console.log('\n❌ TEST FAILED - Check server configuration');
    }
});
