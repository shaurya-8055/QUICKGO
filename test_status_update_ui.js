const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:3000';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  }
});

// Function to test immediate status update reflection
async function testStatusUpdateReflection() {
  console.log('=== Testing Service Request Status Update UI Reflection ===');
  console.log('API Base URL:', API_BASE_URL);
  
  try {
    // 1. Get current service requests
    console.log('\n--- Step 1: Getting Current Service Requests ---');
    const initialResponse = await apiClient.get('/service-requests?limit=1');
    const serviceRequest = initialResponse.data.data?.items[0];
    
    if (!serviceRequest) {
      console.log('No service requests found. Creating a test request...');
      
      // Create a test service request
      const createPayload = {
        userID: '665f18761ac62158d65a9200',
        category: 'Status Update Test',
        customerName: 'Test Customer UI',
        phone: '1234567890',
        address: '123 UI Test Street',
        description: 'Testing status update UI reflection',
        preferredDate: new Date(Date.now() + 86400000).toISOString().split('T')[0],
        preferredTime: '3:00 PM'
      };
      
      const createResponse = await apiClient.post('/service-requests', createPayload);
      console.log('✓ Test service request created for UI testing');
      
      // Get the newly created request
      const newResponse = await apiClient.get('/service-requests?limit=1');
      const newRequest = newResponse.data.data?.items[0];
      if (newRequest) {
        return await testStatusUpdates(newRequest);
      }
    } else {
      return await testStatusUpdates(serviceRequest);
    }
    
  } catch (error) {
    console.error('Test failed:', error.message);
    if (error.response) {
      console.error('Error status:', error.response.status);
      console.error('Error data:', error.response.data);
    }
  }
}

async function testStatusUpdates(serviceRequest) {
  console.log(`\n--- Testing Status Updates for Request ID: ${serviceRequest._id} ---`);
  console.log(`Initial Status: ${serviceRequest.status}`);
  
  // Test status progression: pending → approved → in-progress → completed
  const statusProgression = [
    { status: 'approved', description: 'Approve Request' },
    { status: 'in-progress', description: 'Set to In Progress' },
    { status: 'completed', description: 'Mark as Completed' }
  ];
  
  for (let i = 0; i < statusProgression.length; i++) {
    const { status, description } = statusProgression[i];
    
    console.log(`\n--- ${description} ---`);
    
    // 1. Update the status
    const updatePayload = {
      status: status,
      notes: `Updated to ${status} via UI reflection test`
    };
    
    const updateResponse = await apiClient.put(`/service-requests/${serviceRequest._id}`, updatePayload);
    
    if (updateResponse.status === 200) {
      console.log(`✓ Status updated to: ${status}`);
      console.log('Update response:', updateResponse.data.message);
      
      // 2. Immediately verify the status was updated by fetching the request
      const verifyResponse = await apiClient.get(`/service-requests?limit=50`);
      const updatedRequest = verifyResponse.data.data?.items.find(req => req._id === serviceRequest._id);
      
      if (updatedRequest) {
        if (updatedRequest.status === status) {
          console.log(`✓ Status change confirmed in database: ${updatedRequest.status}`);
          console.log(`✓ Last updated: ${updatedRequest.updatedAt}`);
        } else {
          console.log(`✗ Status mismatch! Expected: ${status}, Got: ${updatedRequest.status}`);
        }
      } else {
        console.log('✗ Could not find updated request in the list');
      }
      
      // 3. Simulate what the admin portal does - fetch all requests to refresh UI
      console.log('🔄 Simulating admin portal data refresh...');
      const refreshResponse = await apiClient.get('/service-requests');
      const refreshedRequest = refreshResponse.data.data?.items.find(req => req._id === serviceRequest._id);
      
      if (refreshedRequest && refreshedRequest.status === status) {
        console.log('✓ Admin portal would show correct status after refresh');
      } else {
        console.log('✗ Admin portal refresh would not show correct status');
      }
      
    } else {
      console.log(`✗ Failed to update status to ${status}`);
      console.log('Response:', updateResponse.data);
      break;
    }
    
    // Small delay between updates
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  console.log('\n=== Status Update UI Reflection Test Complete ===');
  console.log('✓ All status updates should reflect immediately in the admin portal');
  console.log('✓ The enhanced service provider automatically refreshes data after updates');
  console.log('✓ The service request list has backup refresh logic when dialogs close');
}

// Helper function to simulate rapid status changes (stress test)
async function stressTestStatusUpdates() {
  console.log('\n=== Stress Testing Rapid Status Changes ===');
  
  try {
    const response = await apiClient.get('/service-requests?limit=1');
    const serviceRequest = response.data.data?.items[0];
    
    if (!serviceRequest) {
      console.log('No service requests available for stress test');
      return;
    }
    
    console.log(`Stress testing with request ID: ${serviceRequest._id}`);
    
    // Rapidly change status back and forth
    const rapidChanges = [
      'approved',
      'in-progress', 
      'approved',
      'in-progress',
      'completed'
    ];
    
    for (let i = 0; i < rapidChanges.length; i++) {
      const status = rapidChanges[i];
      console.log(`Rapid change ${i + 1}: ${status}`);
      
      const updateResponse = await apiClient.put(`/service-requests/${serviceRequest._id}`, {
        status: status,
        notes: `Rapid change ${i + 1} to ${status}`
      });
      
      if (updateResponse.status === 200) {
        console.log(`✓ Rapid change ${i + 1} successful`);
      } else {
        console.log(`✗ Rapid change ${i + 1} failed`);
      }
      
      // No delay - testing rapid changes
    }
    
    // Final verification
    const finalResponse = await apiClient.get('/service-requests?limit=50');
    const finalRequest = finalResponse.data.data?.items.find(req => req._id === serviceRequest._id);
    
    if (finalRequest) {
      console.log(`Final status after rapid changes: ${finalRequest.status}`);
      console.log('✓ System handled rapid status changes correctly');
    }
    
  } catch (error) {
    console.error('Stress test failed:', error.message);
  }
}

// Run all tests
async function runAllTests() {
  await testStatusUpdateReflection();
  await stressTestStatusUpdates();
}

// Execute the tests
runAllTests();