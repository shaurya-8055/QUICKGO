const mongoose = require('mongoose');
const Product = require('./model/product');
const Category = require('./model/category');
const Poster = require('./model/poster');
require('dotenv').config();

async function migrateImageUrls() {
    try {
        await mongoose.connect(process.env.MONGO_URL);
        console.log('🔗 Connected to database');

        let totalUpdated = 0;

        // Migrate Product images
        console.log('\n📦 Migrating Product images...');
        const products = await Product.find({
            'images.url': { $regex: 'localhost:3000' }
        });

        console.log(`Found ${products.length} products with localhost URLs`);

        for (const product of products) {
            let updated = false;
            
            product.images.forEach(image => {
                if (image.url && image.url.includes('localhost:3000')) {
                    const oldUrl = image.url;
                    image.url = image.url.replace(
                        'http://localhost:3000',
                        'https://quickgo-tpum.onrender.com'
                    );
                    console.log(`  ✅ ${product.name}: ${oldUrl} → ${image.url}`);
                    updated = true;
                }
            });

            if (updated) {
                await product.save();
                totalUpdated++;
            }
        }

        // Migrate Category images
        console.log('\n📂 Migrating Category images...');
        const categories = await Category.find({
            'image': { $regex: 'localhost:3000' }
        });

        console.log(`Found ${categories.length} categories with localhost URLs`);

        for (const category of categories) {
            if (category.image && category.image.includes('localhost:3000')) {
                const oldUrl = category.image;
                category.image = category.image.replace(
                    'http://localhost:3000',
                    'https://quickgo-tpum.onrender.com'
                );
                console.log(`  ✅ ${category.name}: ${oldUrl} → ${category.image}`);
                await category.save();
                totalUpdated++;
            }
        }

        // Migrate Poster images
        console.log('\n🎯 Migrating Poster images...');
        const posters = await Poster.find({
            'imageUrl': { $regex: 'localhost:3000' }
        });

        console.log(`Found ${posters.length} posters with localhost URLs`);

        for (const poster of posters) {
            if (poster.imageUrl && poster.imageUrl.includes('localhost:3000')) {
                const oldUrl = poster.imageUrl;
                poster.imageUrl = poster.imageUrl.replace(
                    'http://localhost:3000',
                    'https://quickgo-tpum.onrender.com'
                );
                console.log(`  ✅ Poster: ${oldUrl} → ${poster.imageUrl}`);
                await poster.save();
                totalUpdated++;
            }
        }

        console.log('\n🎉 Migration completed successfully!');
        console.log(`📊 Total items updated: ${totalUpdated}`);
        console.log('🔄 Please test your app now - images should load correctly!');
        
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error);
        process.exit(1);
    }
}

// Add warning message
console.log('🚨 DATABASE MIGRATION TOOL');
console.log('📝 This will update all localhost URLs to production URLs');
console.log('⚠️  Make sure you have a database backup before proceeding');
console.log('');

migrateImageUrls();
