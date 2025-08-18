const https = require('https');
const http = require('http');

// Test configuration
const BASE_URL = 'https://quickgo-tpum.onrender.com'; // Testing production server
const testPhone = '+919026508435'; // Test phone number

// Helper function to make HTTP requests
function makeRequest(url, method = 'GET', data = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const isHttps = url.startsWith('https');
    const urlObj = new URL(url);
    
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };

    if (data) {
      const postData = JSON.stringify(data);
      options.headers['Content-Length'] = Buffer.byteLength(postData);
    }

    const req = (isHttps ? https : http).request(options, (res) => {
      let responseBody = '';
      res.on('data', (chunk) => {
        responseBody += chunk;
      });
      res.on('end', () => {
        try {
          const parsedBody = JSON.parse(responseBody);
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: parsedBody
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: responseBody
          });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

// Test functions
async function testServerConnection() {
  console.log('🔍 Testing server connection...');
  try {
    const response = await makeRequest(`${BASE_URL}/`);
    console.log('✅ Server connection:', response.status === 200 ? 'SUCCESS' : 'FAILED');
    return response.status === 200;
  } catch (error) {
    console.log('❌ Server connection: FAILED -', error.message);
    return false;
  }
}

async function testPhoneVerification() {
  console.log('\n🔍 Testing phone verification...');
  try {
    const response = await makeRequest(`${BASE_URL}/auth/verify-phone`, 'POST', {
      phone: testPhone
    });
    
    console.log('📱 Phone verification response status:', response.status);
    console.log('📱 Phone verification response:', response.body);
    
    if (response.status === 200) {
      console.log('✅ Phone verification: SUCCESS');
      return true;
    } else {
      console.log('❌ Phone verification: FAILED');
      return false;
    }
  } catch (error) {
    console.log('❌ Phone verification: ERROR -', error.message);
    return false;
  }
}

async function testOTPVerification() {
  console.log('\n🔍 Testing OTP verification with dummy code...');
  try {
    const response = await makeRequest(`${BASE_URL}/auth/verify-otp`, 'POST', {
      phone: testPhone,
      code: '123456' // This will likely fail, but tests the endpoint
    });
    
    console.log('🔐 OTP verification response status:', response.status);
    console.log('🔐 OTP verification response:', response.body);
    
    // We expect this to fail with invalid OTP, but endpoint should respond
    if (response.status === 400 && response.body.message) {
      console.log('✅ OTP verification endpoint: SUCCESS (responds correctly to invalid OTP)');
      return true;
    } else {
      console.log('❌ OTP verification endpoint: UNEXPECTED RESPONSE');
      return false;
    }
  } catch (error) {
    console.log('❌ OTP verification: ERROR -', error.message);
    return false;
  }
}

async function testRateLimiting() {
  console.log('\n🔍 Testing rate limiting...');
  try {
    const promises = [];
    // Make 6 rapid requests to trigger rate limiting (limit is 5)
    for (let i = 0; i < 6; i++) {
      promises.push(makeRequest(`${BASE_URL}/auth/verify-phone`, 'POST', {
        phone: testPhone
      }));
    }
    
    const responses = await Promise.all(promises);
    const rateLimitedResponses = responses.filter(r => r.status === 429);
    
    if (rateLimitedResponses.length > 0) {
      console.log('✅ Rate limiting: SUCCESS (blocked excessive requests)');
      return true;
    } else {
      console.log('⚠️ Rate limiting: NOT TRIGGERED (may need more requests)');
      return false;
    }
  } catch (error) {
    console.log('❌ Rate limiting test: ERROR -', error.message);
    return false;
  }
}

async function testAuthenticationEndpoints() {
  console.log('\n🔍 Testing authentication endpoints structure...');
  
  const endpoints = [
    '/auth/verify-phone',
    '/auth/verify-otp',
    '/auth/logout',
    '/auth/refresh-token'
  ];
  
  let successCount = 0;
  
  for (const endpoint of endpoints) {
    try {
      const response = await makeRequest(`${BASE_URL}${endpoint}`, 'POST', {});
      console.log(`📍 ${endpoint}: Status ${response.status}`);
      
      // We expect 400 (bad request) or 401 (unauthorized) for most endpoints
      // This means the endpoint exists and is responding
      if (response.status >= 400 && response.status < 500) {
        successCount++;
      }
    } catch (error) {
      console.log(`❌ ${endpoint}: ERROR -`, error.message);
    }
  }
  
  console.log(`✅ Authentication endpoints: ${successCount}/${endpoints.length} responding`);
  return successCount === endpoints.length;
}

// Main test runner
async function runAllTests() {
  console.log('🚀 Starting Authentication System Tests');
  console.log('=' .repeat(50));
  
  const results = {
    serverConnection: await testServerConnection(),
    authEndpoints: await testAuthenticationEndpoints(),
    phoneVerification: await testPhoneVerification(),
    otpVerification: await testOTPVerification(),
    rateLimiting: await testRateLimiting()
  };
  
  console.log('\n' + '=' .repeat(50));
  console.log('📊 TEST RESULTS SUMMARY:');
  console.log('=' .repeat(50));
  
  Object.entries(results).forEach(([test, passed]) => {
    console.log(`${passed ? '✅' : '❌'} ${test}: ${passed ? 'PASSED' : 'FAILED'}`);
  });
  
  const passedTests = Object.values(results).filter(Boolean).length;
  const totalTests = Object.keys(results).length;
  
  console.log(`\n🎯 Overall: ${passedTests}/${totalTests} tests passed`);
  
  if (passedTests === totalTests) {
    console.log('🎉 All tests passed! Authentication system is working.');
  } else {
    console.log('⚠️ Some tests failed. Check the issues above.');
  }
}

// Run the tests
runAllTests().catch(console.error);
