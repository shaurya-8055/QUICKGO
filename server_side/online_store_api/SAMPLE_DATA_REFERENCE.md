# Sample Technician Data - Reference

## ✅ Successfully Added 15 Technicians to Database

### Location Coverage: Delhi NCR Area

- **Delhi**: Connaught Place, South Delhi, North Delhi, East Delhi, Shahdara, Rohini, Dwarka
- **Gurgaon**: Multiple sectors
- **Noida**: Greater Noida, Noida Sector 62
- **Faridabad**: Multiple locations

### Technicians by Category:

#### AC Repair (3 technicians)

1. **Rajesh Kumar** - ⭐ 4.8, 156 jobs, ₹500/hr, Connaught Place
2. **Amit Sharma** - ⭐ 4.5, 89 jobs, ₹450/hr, Gurgaon
3. **Anil Rao** (Multi-skilled) - ⭐ 4.6, 112 jobs, ₹550/hr, Shahdara

#### Plumbers (3 technicians)

1. **Suresh Singh** - ⭐ 4.9, 234 jobs, ₹600/hr, South Delhi (Master Plumber)
2. **Vijay Yadav** - ⭐ 4.3, 67 jobs, ₹350/hr, Noida
3. **Deepak Mishra** (Multi-skilled) - ⭐ 4.4, 134 jobs, ₹480/hr, Faridabad

#### Electricians (4 technicians)

1. **Ramesh Verma** - ⭐ 4.7, 178 jobs, ₹550/hr, North Delhi (Licensed)
2. **Dinesh Patel** - ⭐ 4.4, 92 jobs, ₹400/hr, East Delhi
3. **Anil Rao** (Multi-skilled) - ⭐ 4.6, 112 jobs, ₹550/hr, Shahdara
4. **Deepak Mishra** (Multi-skilled) - ⭐ 4.4, 134 jobs, ₹480/hr, Faridabad

#### Mobile Repair (3 technicians)

1. **Arjun Malhotra** - ⭐ 4.6, 312 jobs, ₹700/hr, Gurgaon (Apple/Samsung Certified)
2. **Karan Singh** - ⭐ 4.2, 145 jobs, ₹300/hr, Rohini
3. **Mohit Jain** (Multi-skilled) - ⭐ 4.5, 98 jobs, ₹450/hr, Greater Noida

#### Appliance Repair (4 technicians)

1. **Manoj Tiwari** - ⭐ 4.8, 201 jobs, ₹650/hr, Central Delhi (IFB/Whirlpool Partner)
2. **Sanjay Gupta** - ⭐ 4.1, 58 jobs, ₹400/hr, Gurgaon
3. **Amit Sharma** (Multi-skilled) - ⭐ 4.5, 89 jobs, ₹450/hr, Gurgaon
4. **Mohit Jain** (Multi-skilled) - ⭐ 4.5, 98 jobs, ₹450/hr, Greater Noida

#### Painters (2 technicians)

1. **Rakesh Chauhan** - ⭐ 4.7, 87 jobs, ₹500/hr, Dwarka (Asian Paints Certified)
2. **Pankaj Kumar** - ⭐ 4.3, 43 jobs, ₹350/hr, Faridabad

### Statistics:

- **Total Technicians**: 15
- **Verified**: 11 (73%)
- **Average Rating**: 4.52/5.0
- **Average Experience**: 7 years
- **Average Price**: ₹483/hr
- **Currently Available**: 14 (93%)

### Testing Locations (Use these coordinates):

#### To find technicians near Connaught Place, Delhi:

- Latitude: 28.7041
- Longitude: 77.1025
- **Expected Results**: Rajesh Kumar (AC), others within 10km

#### To find technicians near Gurgaon:

- Latitude: 28.4595
- Longitude: 77.0266
- **Expected Results**: Amit Sharma (AC), Sanjay Gupta (Appliance), Arjun Malhotra (Mobile)

#### To find technicians near South Delhi:

- Latitude: 28.5355
- Longitude: 77.3910
- **Expected Results**: Suresh Singh (Plumber), others nearby

### Test Filters:

#### High-Rated (≥4.8):

- Rajesh Kumar (AC) - 4.8
- Suresh Singh (Plumber) - 4.9
- Manoj Tiwari (Appliance) - 4.8

#### Budget-Friendly (≤₹400/hr):

- Vijay Yadav (Plumber) - ₹350
- Karan Singh (Mobile) - ₹300
- Pankaj Kumar (Painter) - ₹350
- Dinesh Patel (Electrician) - ₹400
- Sanjay Gupta (Appliance) - ₹400

#### Verified Only:

- 11 technicians have verified status

#### Premium (≥₹600/hr):

- Suresh Singh (Plumber) - ₹600
- Arjun Malhotra (Mobile) - ₹700
- Manoj Tiwari (Appliance) - ₹650

---

## 🔄 Re-running the Seed Script

If you want to reset or re-populate the data:

```bash
cd server_side/online_store_api
node seed_technicians.js
```

The script will:

1. Clear all existing technicians
2. Insert fresh sample data
3. Show summary statistics

---

## 📝 Adding More Technicians

To add more technicians, edit `seed_technicians.js` and add entries to the `sampleTechnicians` array with this format:

```javascript
{
  name: "Worker Name",
  phone: "+91-9876543XXX",  // Unique phone number
  skills: ["skill1", "skill2"],  // ac, plumbing, electrical, mobile, appliance, painting
  active: true,
  latitude: 28.XXXX,  // Delhi NCR: 28.4-28.7
  longitude: 77.XXXX,  // Delhi NCR: 77.0-77.4
  rating: 4.5,  // 0-5
  totalJobs: 100,
  yearsExperience: 5,
  profileImage: "https://randomuser.me/api/portraits/men/XX.jpg",
  certifications: ["Cert 1"],
  verified: true,
  bio: "Description...",
  pricePerHour: 500,
  currentlyAvailable: true
}
```

---

## 🧪 Testing in the App

1. **Run the Flutter app**:

   ```bash
   cd client_side/client_app
   flutter run
   ```

2. **Navigate to Services**:

   - Home → Services Tab → Select Category

3. **Choose "Find Workers Nearby"**:

   - Grant location permission
   - Map will show your location + nearby workers
   - Green markers = verified workers
   - Red markers = unverified workers

4. **Test Filters**:

   - Tap filter icon
   - Adjust rating, price, verified toggles
   - Apply and see filtered results

5. **View Worker Profile**:
   - Tap any marker or list item
   - See full profile with ratings, skills, certifications
   - Tap "Call" to phone worker
   - Tap "Book Service" to create booking

---

## 🐛 Troubleshooting

### No workers showing on map?

1. Check if backend server is running
2. Verify MongoDB connection
3. Run seed script again
4. Check API endpoint: `http://your-api-url/technicians`

### Workers too far away?

- Increase search radius in `worker_discovery_screen.dart` (line 26)
- Or adjust your emulator GPS location to Delhi NCR coordinates

### Map not loading?

- Add Google Maps API key (see SETUP_CHECKLIST.md)
- Enable billing on Google Cloud
- Check internet connection

---

**Happy Testing! 🚀**
