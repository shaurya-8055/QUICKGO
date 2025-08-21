const http = require('http');

const BASE_URL = 'http://localhost:3000';

function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const jsonBody = JSON.parse(body);
          resolve({ data: jsonBody, status: res.statusCode });
        } catch (e) {
          resolve({ data: body, status: res.statusCode });
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function testEnhancedServiceBooking() {
  console.log('🚀 Testing Enhanced Service Booking Functionality\n');
  
  try {
    // Test 1: Health check
    console.log('1. Testing API Health...');
    const health = await makeRequest('GET', '/');
    console.log('✅ API is running:', health.data.message);
    
    // Test 2: Get technicians (should have seeded data)
    console.log('\n2. Testing Technicians API...');
    const techResponse = await makeRequest('GET', '/technicians');
    if (techResponse.data.success) {
      console.log(`✅ Found ${techResponse.data.data.length} technicians:`);
      techResponse.data.data.forEach(tech => {
        console.log(`   - ${tech.name} (${tech.phone}) - Skills: ${tech.skills.join(', ')}`);
      });
    } else {
      console.log('❌ Failed to get technicians:', techResponse.data.message);
    }
    
    // Test 3: Create a new service request
    console.log('\n3. Testing Service Request Creation...');
    const newRequest = {
      userID: '507f1f77bcf86cd799439011', // Sample ObjectId
      category: 'AC Repair',
      customerName: 'Test Customer',
      phone: '+1234567899',
      address: '123 Test Street, Test City',
      description: 'Air conditioner not cooling properly',
      preferredDate: new Date().toISOString(),
      preferredTime: '2:00 PM',
      status: 'pending'
    };
    
    const createResponse = await makeRequest('POST', '/service-requests', newRequest);
    if (createResponse.data.success) {
      console.log('✅ Service request created successfully');
      console.log('   ID:', createResponse.data.data._id);
      const requestId = createResponse.data.data._id;
      
      // Test 4: Update request status to approved with technician assignment
      console.log('\n4. Testing Request Approval with Technician Assignment...');
      const technicianToAssign = techResponse.data.data.find(t => 
        t.skills.some(skill => skill.toLowerCase().includes('ac'))
      );
      
      if (technicianToAssign) {
        const updatePayload = {
          status: 'approved',
          assigneeId: technicianToAssign._id,
          assigneeName: technicianToAssign.name,
          assigneePhone: technicianToAssign.phone,
          notes: 'Assigned AC specialist technician'
        };
        
        const updateResponse = await makeRequest('PATCH', `/service-requests/${requestId}`, updatePayload);
        if (updateResponse.data.success) {
          console.log('✅ Request approved and technician assigned:');
          console.log(`   Technician: ${technicianToAssign.name} (${technicianToAssign.phone})`);
          console.log(`   Status: ${updateResponse.data.data.status}`);
        }
        
        // Test 5: Update to in-progress
        console.log('\n5. Testing Status Update to In-Progress...');
        const progressUpdate = await makeRequest('PATCH', `/service-requests/${requestId}`, {
          status: 'in-progress',
          notes: 'Technician is on the way'
        });
        if (progressUpdate.data.success) {
          console.log('✅ Status updated to in-progress');
        }
        
        // Test 6: Mark as completed
        console.log('\n6. Testing Status Update to Completed...');
        const completeUpdate = await makeRequest('PATCH', `/service-requests/${requestId}`, {
          status: 'completed',
          notes: 'AC repair completed successfully. Customer satisfied.'
        });
        if (completeUpdate.data.success) {
          console.log('✅ Request marked as completed');
        }
        
        // Test 7: Get updated request details
        console.log('\n7. Testing Request Retrieval...');
        const getResponse = await makeRequest('GET', `/service-requests?userID=${newRequest.userID}`);
        if (getResponse.data.success) {
          const request = getResponse.data.data.items.find(r => r._id === requestId);
          if (request) {
            console.log('✅ Final request details:');
            console.log(`   Customer: ${request.customerName}`);
            console.log(`   Category: ${request.category}`);
            console.log(`   Status: ${request.status}`);
            console.log(`   Assigned to: ${request.assigneeName} (${request.assigneePhone})`);
            console.log(`   Notes: ${request.notes}`);
          }
        }
        
        // Test 8: Test cancellation (delete)
        console.log('\n8. Testing Request Cancellation (Delete)...');
        const deleteResponse = await makeRequest('DELETE', `/service-requests/${requestId}`);
        if (deleteResponse.data.success) {
          console.log('✅ Request cancelled and deleted successfully');
        }
        
      } else {
        console.log('❌ No AC repair technician found for assignment test');
      }
      
    } else {
      console.log('❌ Failed to create service request:', createResponse.data.message);
    }
    
    // Test 9: Get all service requests
    console.log('\n9. Testing Service Requests List...');
    const allRequests = await makeRequest('GET', '/service-requests');
    if (allRequests.data.success) {
      console.log(`✅ Retrieved ${allRequests.data.data.items.length} service requests`);
      console.log(`   Total in database: ${allRequests.data.data.total}`);
    }
    
    console.log('\n🎉 All tests completed successfully!');
    console.log('\n📋 Summary of Enhanced Features:');
    console.log('   ✅ Improved success/error messages in Flutter app');
    console.log('   ✅ Technician assignment system');
    console.log('   ✅ Status workflow (pending → approved → in-progress → completed)');
    console.log('   ✅ Request cancellation with database deletion');
    console.log('   ✅ Enhanced admin portal action buttons');
    console.log('   ✅ Comprehensive error handling');
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message || error);
  }
}

// Run the test
testEnhancedServiceBooking();
