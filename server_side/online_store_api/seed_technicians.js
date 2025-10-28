/**
 * Script to populate sample technician data with realistic locations in major Indian cities
 * Run this script once to add sample data to your MongoDB database
 * 
 * Usage: node seed_technicians.js
 */

const mongoose = require('mongoose');
require('dotenv').config();

// Import the Technician model
const Technician = require('./model/technician');

// Sample technician data with locations in Delhi NCR area
const sampleTechnicians = [
  // AC Repair Specialists - Delhi/Gurgaon area
  {
    name: "Rajesh Kumar",
    phone: "+91-9876543210",
    skills: ["ac", "refrigeration"],
    active: true,
    latitude: 28.7041,  // Connaught Place, Delhi
    longitude: 77.1025,
    rating: 4.8,
    totalJobs: 156,
    yearsExperience: 8,
    profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
    certifications: ["HVAC Certified", "Blue Star Authorized"],
    verified: true,
    bio: "Specialized in all types of AC repair and maintenance. 8 years of experience with brands like Blue Star, Voltas, and Daikin.",
    pricePerHour: 500,
    currentlyAvailable: true
  },
  {
    name: "Amit Sharma",
    phone: "+91-9876543211",
    skills: ["ac", "appliance"],
    active: true,
    latitude: 28.4595,  // Gurgaon
    longitude: 77.0266,
    rating: 4.5,
    totalJobs: 89,
    yearsExperience: 5,
    profileImage: "https://randomuser.me/api/portraits/men/2.jpg",
    certifications: ["LG Service Partner"],
    verified: true,
    bio: "Expert in AC and refrigerator repairs. Quick service with genuine parts.",
    pricePerHour: 450,
    currentlyAvailable: true
  },

  // Plumbers - Delhi/Noida area
  {
    name: "Suresh Singh",
    phone: "+91-9876543212",
    skills: ["plumbing", "sanitary"],
    active: true,
    latitude: 28.5355,  // South Delhi
    longitude: 77.3910,
    rating: 4.9,
    totalJobs: 234,
    yearsExperience: 12,
    profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
    certifications: ["Master Plumber Certified", "Gas Line Specialist"],
    verified: true,
    bio: "Senior plumber with 12 years of experience. Expert in bathroom fittings, pipe repairs, and water heater installation.",
    pricePerHour: 600,
    currentlyAvailable: true
  },
  {
    name: "Vijay Yadav",
    phone: "+91-9876543213",
    skills: ["plumbing"],
    active: true,
    latitude: 28.5706,  // Noida
    longitude: 77.3272,
    rating: 4.3,
    totalJobs: 67,
    yearsExperience: 4,
    profileImage: "https://randomuser.me/api/portraits/men/4.jpg",
    certifications: ["Plumbing Basics"],
    verified: false,
    bio: "Affordable plumbing services for all your home needs.",
    pricePerHour: 350,
    currentlyAvailable: true
  },

  // Electricians - Delhi area
  {
    name: "Ramesh Verma",
    phone: "+91-9876543214",
    skills: ["electrical", "wiring"],
    active: true,
    latitude: 28.6692,  // North Delhi
    longitude: 77.4538,
    rating: 4.7,
    totalJobs: 178,
    yearsExperience: 10,
    profileImage: "https://randomuser.me/api/portraits/men/5.jpg",
    certifications: ["Licensed Electrician", "Safety Certified"],
    verified: true,
    bio: "Licensed electrician specializing in home wiring, MCB installation, and electrical troubleshooting.",
    pricePerHour: 550,
    currentlyAvailable: false
  },
  {
    name: "Dinesh Patel",
    phone: "+91-9876543215",
    skills: ["electrical"],
    active: true,
    latitude: 28.6448,  // East Delhi
    longitude: 77.2167,
    rating: 4.4,
    totalJobs: 92,
    yearsExperience: 6,
    profileImage: "https://randomuser.me/api/portraits/men/6.jpg",
    certifications: ["Electrical Safety"],
    verified: true,
    bio: "Quick and reliable electrical services. Available for emergencies.",
    pricePerHour: 400,
    currentlyAvailable: true
  },

  // Mobile Repair Specialists
  {
    name: "Arjun Malhotra",
    phone: "+91-9876543216",
    skills: ["mobile", "electronics"],
    active: true,
    latitude: 28.4089,  // Gurgaon Sector 29
    longitude: 77.0719,
    rating: 4.6,
    totalJobs: 312,
    yearsExperience: 7,
    profileImage: "https://randomuser.me/api/portraits/men/7.jpg",
    certifications: ["Apple Certified", "Samsung Authorized"],
    verified: true,
    bio: "Certified mobile technician for all brands. Screen replacement, battery change, software issues.",
    pricePerHour: 700,
    currentlyAvailable: true
  },
  {
    name: "Karan Singh",
    phone: "+91-9876543217",
    skills: ["mobile"],
    active: true,
    latitude: 28.6304,  // Rohini, Delhi
    longitude: 77.1122,
    rating: 4.2,
    totalJobs: 145,
    yearsExperience: 3,
    profileImage: "https://randomuser.me/api/portraits/men/8.jpg",
    certifications: [],
    verified: false,
    bio: "Affordable mobile repairs with warranty on parts.",
    pricePerHour: 300,
    currentlyAvailable: true
  },

  // Appliance Repair
  {
    name: "Manoj Tiwari",
    phone: "+91-9876543218",
    skills: ["appliance", "washing machine", "refrigerator"],
    active: true,
    latitude: 28.6139,  // Central Delhi
    longitude: 77.2090,
    rating: 4.8,
    totalJobs: 201,
    yearsExperience: 9,
    profileImage: "https://randomuser.me/api/portraits/men/9.jpg",
    certifications: ["IFB Certified", "Whirlpool Partner"],
    verified: true,
    bio: "Expert in washing machine, refrigerator, and microwave repairs. Authorized service partner.",
    pricePerHour: 650,
    currentlyAvailable: true
  },
  {
    name: "Sanjay Gupta",
    phone: "+91-9876543219",
    skills: ["appliance"],
    active: true,
    latitude: 28.4595,  // Gurgaon
    longitude: 77.0725,
    rating: 4.1,
    totalJobs: 58,
    yearsExperience: 4,
    profileImage: "https://randomuser.me/api/portraits/men/10.jpg",
    certifications: [],
    verified: false,
    bio: "Home appliance repair services at affordable rates.",
    pricePerHour: 400,
    currentlyAvailable: true
  },

  // Painters
  {
    name: "Rakesh Chauhan",
    phone: "+91-9876543220",
    skills: ["painting", "wall finishing"],
    active: true,
    latitude: 28.5494,  // Dwarka, Delhi
    longitude: 77.0558,
    rating: 4.7,
    totalJobs: 87,
    yearsExperience: 11,
    profileImage: "https://randomuser.me/api/portraits/men/11.jpg",
    certifications: ["Asian Paints Certified"],
    verified: true,
    bio: "Professional painter with 11 years experience. Interior and exterior painting.",
    pricePerHour: 500,
    currentlyAvailable: true
  },
  {
    name: "Pankaj Kumar",
    phone: "+91-9876543221",
    skills: ["painting"],
    active: true,
    latitude: 28.5273,  // Faridabad
    longitude: 77.3158,
    rating: 4.3,
    totalJobs: 43,
    yearsExperience: 5,
    profileImage: "https://randomuser.me/api/portraits/men/12.jpg",
    certifications: [],
    verified: false,
    bio: "Quality painting services for homes and offices.",
    pricePerHour: 350,
    currentlyAvailable: false
  },

  // Additional workers spread across Delhi NCR
  {
    name: "Anil Rao",
    phone: "+91-9876543222",
    skills: ["ac", "electrical"],
    active: true,
    latitude: 28.6823,  // Shahdara
    longitude: 77.2898,
    rating: 4.6,
    totalJobs: 112,
    yearsExperience: 7,
    profileImage: "https://randomuser.me/api/portraits/men/13.jpg",
    certifications: ["Multi-skilled Technician"],
    verified: true,
    bio: "Multi-skilled technician for AC and electrical work.",
    pricePerHour: 550,
    currentlyAvailable: true
  },
  {
    name: "Deepak Mishra",
    phone: "+91-9876543223",
    skills: ["plumbing", "electrical"],
    active: true,
    latitude: 28.4817,  // Faridabad
    longitude: 77.3194,
    rating: 4.4,
    totalJobs: 134,
    yearsExperience: 8,
    profileImage: "https://randomuser.me/api/portraits/men/14.jpg",
    certifications: ["Certified Technician"],
    verified: true,
    bio: "Reliable services for plumbing and electrical needs.",
    pricePerHour: 480,
    currentlyAvailable: true
  },
  {
    name: "Mohit Jain",
    phone: "+91-9876543224",
    skills: ["mobile", "appliance"],
    active: true,
    latitude: 28.5672,  // Greater Noida
    longitude: 77.3581,
    rating: 4.5,
    totalJobs: 98,
    yearsExperience: 5,
    profileImage: "https://randomuser.me/api/portraits/men/15.jpg",
    certifications: ["Electronics Specialist"],
    verified: true,
    bio: "Expert in mobile and small appliance repairs.",
    pricePerHour: 450,
    currentlyAvailable: true
  }
];

async function seedTechnicians() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGO_URL || 'mongodb://localhost:27017/ecommerce_db';
    console.log('Connecting to MongoDB...');
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Clear existing technicians (optional - comment out if you want to keep existing data)
    console.log('\n⚠️  Clearing existing technician data...');
    await Technician.deleteMany({});
    console.log('✅ Cleared existing data');

    // Insert sample technicians
    console.log('\n📝 Inserting sample technician data...');
    const result = await Technician.insertMany(sampleTechnicians);
    console.log(`✅ Successfully inserted ${result.length} technicians`);

    // Display summary
    console.log('\n📊 Summary:');
    const bySkill = await Technician.aggregate([
      { $unwind: '$skills' },
      { $group: { _id: '$skills', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    console.log('\nTechnicians by skill:');
    bySkill.forEach(item => {
      console.log(`  - ${item._id}: ${item.count} technicians`);
    });

    const avgRating = await Technician.aggregate([
      { $group: { _id: null, avgRating: { $avg: '$rating' } } }
    ]);
    console.log(`\nAverage rating: ${avgRating[0]?.avgRating.toFixed(2)}`);

    const verified = await Technician.countDocuments({ verified: true });
    console.log(`Verified technicians: ${verified}/${result.length}`);

    console.log('\n✨ Sample data seeded successfully!');
    console.log('\n💡 You can now test the worker discovery feature in your app.');
    
  } catch (error) {
    console.error('❌ Error seeding data:', error.message);
    console.error(error);
  } finally {
    // Close database connection
    await mongoose.connection.close();
    console.log('\n👋 Database connection closed');
  }
}

// Run the seed function
seedTechnicians();
