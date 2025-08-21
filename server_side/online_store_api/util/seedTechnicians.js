const mongoose = require('mongoose');
const Technician = require('../model/technician');

// Default technicians data
const defaultTechnicians = [
  {
    name: 'John Smith',
    phone: '+1234567890',
    skills: ['AC Repair', 'HVAC', 'Cooling Systems'],
    active: true
  },
  {
    name: 'Mike Johnson',
    phone: '+1234567891',
    skills: ['Mobile Repair', 'Phone Repair', 'Electronics'],
    active: true
  },
  {
    name: 'Sarah Wilson',
    phone: '+1234567892',
    skills: ['TV Repair', 'Electronics', 'Display Systems'],
    active: true
  },
  {
    name: 'David Brown',
    phone: '+1234567893',
    skills: ['Washing Machine', 'Appliance Repair', 'Laundry Systems'],
    active: true
  },
  {
    name: 'Emily Davis',
    phone: '+1234567894',
    skills: ['Refrigerator', 'Fridge Repair', 'Cooling', 'Appliance'],
    active: true
  },
  {
    name: 'Robert Miller',
    phone: '+1234567895',
    skills: ['General Electronics', 'AC Repair', 'Mobile Repair'],
    active: true
  }
];

async function seedTechnicians() {
  try {
    // Check if technicians already exist
    const existingCount = await Technician.countDocuments();
    
    if (existingCount > 0) {
      console.log(`${existingCount} technicians already exist. Skipping seed.`);
      return;
    }

    // Insert default technicians
    await Technician.insertMany(defaultTechnicians);
    console.log(`Successfully seeded ${defaultTechnicians.length} technicians`);
    
    // Display created technicians
    const createdTechnicians = await Technician.find().sort({ name: 1 });
    console.log('\nCreated technicians:');
    createdTechnicians.forEach(tech => {
      console.log(`- ${tech.name} (${tech.phone}) - Skills: ${tech.skills.join(', ')}`);
    });
    
  } catch (error) {
    console.error('Error seeding technicians:', error);
  }
}

module.exports = { seedTechnicians, defaultTechnicians };
