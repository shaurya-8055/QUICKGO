// Quick test script for service booking endpoint using Node.js built-in modules
const http = require('http');

async function testServiceBooking() {
  const data = JSON.stringify({
    userID: '507f1f77bcf86cd799439011', // sample ObjectId
    category: 'AC Repair',
    customerName: 'Test User',
    phone: '1234567890',
    address: 'Test Address',
    description: 'Test Description',
    preferredDate: new Date().toISOString(),
    preferredTime: '2:30 PM'
  });

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/service-requests',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(data)
    }
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        console.log('Status Code:', res.statusCode);
        console.log('Response Headers:', res.headers);
        try {
          const parsedData = JSON.parse(responseData);
          console.log('Response Data:', JSON.stringify(parsedData, null, 2));
          resolve(parsedData);
        } catch (e) {
          console.log('Raw Response:', responseData);
          resolve(responseData);
        }
      });
    });

    req.on('error', (error) => {
      console.error('Request Error:', error.message);
      reject(error);
    });

    req.write(data);
    req.end();
  });
}

console.log('Testing service booking endpoint...');
testServiceBooking()
  .then(() => console.log('Test completed'))
  .catch(err => console.error('Test failed:', err));
