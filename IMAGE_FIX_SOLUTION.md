# 🚨 APK Image Loading Issue - SOLUTION GUIDE

## ❌ **Problem Identified**

Your APK isn't showing images because **the database contains localhost URLs instead of production URLs**.

### **Current Database URLs (WRONG):**

```
http://localhost:3000/image/products/1754469976732_Bags.jpg
http://localhost:3000/image/products/1754497458352_bag 3.jpg
```

### **Should Be (CORRECT):**

```
https://quickgo-tpum.onrender.com/image/products/1754469976732_Bags.jpg
https://quickgo-tpum.onrender.com/image/products/1754497458352_bag 3.jpg
```

## 🔧 **Root Cause**

When products were uploaded to the database, the server was running locally (`localhost:3000`), so the image URLs were generated with the local base URL instead of the production URL.

## ✅ **SOLUTION: Database URL Migration**

### **Option 1: Automated Database Update Script**

Create a database migration script to fix all URLs:

```javascript
// database_url_migration.js
const mongoose = require("mongoose");
const Product = require("./model/product");
require("dotenv").config();

async function migrateImageUrls() {
  try {
    await mongoose.connect(process.env.MONGO_URL);
    console.log("Connected to database");

    // Find all products with localhost URLs
    const products = await Product.find({
      "images.url": { $regex: "localhost:3000" },
    });

    console.log(`Found ${products.length} products with localhost URLs`);

    for (const product of products) {
      let updated = false;

      product.images.forEach((image) => {
        if (image.url && image.url.includes("localhost:3000")) {
          image.url = image.url.replace(
            "http://localhost:3000",
            "https://quickgo-tpum.onrender.com"
          );
          updated = true;
        }
      });

      if (updated) {
        await product.save();
        console.log(`Updated product: ${product.name}`);
      }
    }

    console.log("Migration completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("Migration failed:", error);
    process.exit(1);
  }
}

migrateImageUrls();
```

### **Option 2: Manual Database Update (MongoDB)**

If you have MongoDB access, run this command:

```javascript
// Update all products with localhost URLs
db.products.updateMany(
  { "images.url": { $regex: "localhost:3000" } },
  {
    $set: {
      "images.$[elem].url": {
        $replaceAll: {
          input: "$$elem.url",
          find: "http://localhost:3000",
          replacement: "https://quickgo-tpum.onrender.com",
        },
      },
    },
  },
  {
    arrayFilters: [{ "elem.url": { $regex: "localhost:3000" } }],
    multi: true,
  }
);
```

### **Option 3: Server Environment Fix**

Update your server to always use production URLs:

```javascript
// In routes/product.js and routes/category.js
// Replace this:
const base =
  process.env.PUBLIC_BASE_URL || `${req.protocol}://${req.get("host")}`;

// With this for production:
const base = process.env.PUBLIC_BASE_URL || "https://quickgo-tpum.onrender.com";
```

Then set environment variable in Render:

```
PUBLIC_BASE_URL=https://quickgo-tpum.onrender.com
```

## 🛠️ **Immediate Fix Steps**

### **Step 1: Create Migration Script**
