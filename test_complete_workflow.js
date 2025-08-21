const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

// Test service request workflow
async function testServiceRequestWorkflow() {
  console.log('🚀 Starting Service Request Workflow Test...\n');

  try {
    // 1. Create a service request
    console.log('1. Creating a new service request...');
    const createResponse = await axios.post(`${BASE_URL}/service-requests`, {
      userID: '507f1f77bcf86cd799439011', // Dummy user ID
      category: 'AC Repair',
      customerName: 'John Doe',
      phone: '+1234567890',
      address: '123 Main St, City, State',
      description: 'AC not cooling properly',
      preferredDate: '2025-08-19T10:00:00.000Z',
      preferredTime: '2:00 PM'
    });

    console.log('✅ Service request created:', createResponse.data);
    const requestId = createResponse.data.data._id;
    console.log(`📝 Request ID: ${requestId}\n`);

    // 2. Fetch available technicians
    console.log('2. Fetching available technicians...');
    const techResponse = await axios.get(`${BASE_URL}/technicians`);
    console.log('✅ Technicians fetched:', techResponse.data.data.length, 'technicians');
    
    if (techResponse.data.data.length === 0) {
      console.log('❌ No technicians available for testing');
      return;
    }

    const technician = techResponse.data.data[0];
    console.log(`👨‍🔧 Selected technician: ${technician.name} (${technician.phone})\n`);

    // 3. Test APPROVE action with technician assignment
    console.log('3. Testing APPROVE action...');
    const approveResponse = await axios.patch(`${BASE_URL}/service-requests/${requestId}`, {
      status: 'approved',
      assigneeId: technician._id,
      assigneeName: technician.name,
      assigneePhone: technician.phone,
      notes: 'Approved and assigned to technician'
    });

    console.log('✅ Request approved:', approveResponse.data);
    console.log(`📋 Status: ${approveResponse.data.data.status}`);
    console.log(`👨‍🔧 Assigned to: ${approveResponse.data.data.assigneeName}\n`);

    // 4. Test IN-PROGRESS action
    console.log('4. Testing IN-PROGRESS action...');
    const inProgressResponse = await axios.patch(`${BASE_URL}/service-requests/${requestId}`, {
      status: 'in-progress',
      notes: 'Technician is on the way'
    });

    console.log('✅ Request set to in-progress:', inProgressResponse.data);
    console.log(`📋 Status: ${inProgressResponse.data.data.status}\n`);

    // 5. Test COMPLETED action
    console.log('5. Testing COMPLETED action...');
    const completedResponse = await axios.patch(`${BASE_URL}/service-requests/${requestId}`, {
      status: 'completed',
      notes: 'Service completed successfully'
    });

    console.log('✅ Request marked as completed:', completedResponse.data);
    console.log(`📋 Status: ${completedResponse.data.data.status}\n`);

    // 6. Create another request to test CANCEL action
    console.log('6. Creating another request to test CANCEL action...');
    const createResponse2 = await axios.post(`${BASE_URL}/service-requests`, {
      userID: '507f1f77bcf86cd799439011',
      category: 'TV Repair',
      customerName: 'Jane Smith',
      phone: '+1234567891',
      address: '456 Oak St, City, State',
      description: 'TV not turning on',
      preferredDate: '2025-08-20T14:00:00.000Z',
      preferredTime: '3:00 PM'
    });

    const requestId2 = createResponse2.data.data._id;
    console.log(`📝 Second Request ID: ${requestId2}`);

    // 7. Test CANCEL action (DELETE)
    console.log('7. Testing CANCEL action (DELETE)...');
    const cancelResponse = await axios.delete(`${BASE_URL}/service-requests/${requestId2}`);
    console.log('✅ Request cancelled (deleted):', cancelResponse.data);

    // 8. Verify the full workflow by fetching all requests
    console.log('\n8. Fetching all service requests to verify workflow...');
    const allRequestsResponse = await axios.get(`${BASE_URL}/service-requests`);
    console.log('📊 Total service requests:', allRequestsResponse.data.data.items.length);
    
    const completedRequest = allRequestsResponse.data.data.items.find(req => req._id === requestId);
    if (completedRequest) {
      console.log('\n📋 Final request details:');
      console.log(`   ID: ${completedRequest._id}`);
      console.log(`   Category: ${completedRequest.category}`);
      console.log(`   Customer: ${completedRequest.customerName}`);
      console.log(`   Status: ${completedRequest.status}`);
      console.log(`   Assigned to: ${completedRequest.assigneeName || 'Not assigned'}`);
      console.log(`   Phone: ${completedRequest.assigneePhone || 'N/A'}`);
      console.log(`   Notes: ${completedRequest.notes || 'No notes'}`);
    }

    console.log('\n🎉 All workflow tests completed successfully!');
    console.log('\n📋 Test Summary:');
    console.log('   ✅ Create service request');
    console.log('   ✅ Approve request with technician assignment');
    console.log('   ✅ Set to in-progress');
    console.log('   ✅ Mark as completed');
    console.log('   ✅ Cancel (delete) request');
    console.log('   ✅ All action buttons functional');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the test
testServiceRequestWorkflow();
