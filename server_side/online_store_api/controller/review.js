const Review = require('../model/review');
const Order = require('../model/order');
const Product = require('../model/product');
const User = require('../model/user');
const mongoose = require('mongoose');

// Get reviews for a product with pagination and sorting
exports.getProductReviews = async (req, res) => {
    try {
        const { productId } = req.params;
        const { page = 1, limit = 10, sortBy = 'createdAt', sortOrder = 'desc' } = req.query;
        
        const skip = (parseInt(page) - 1) * parseInt(limit);
        const sort = { [sortBy]: sortOrder === 'desc' ? -1 : 1 };
        
        const reviews = await Review.find({ 
            productId, 
            status: 'active' 
        })
        .populate('userId', 'name email avatar')
        .sort(sort)
        .skip(skip)
        .limit(parseInt(limit));
        
        // Transform the response to match frontend expectations
        const transformedReviews = reviews.map(review => ({
            ...review.toObject(),
            user: review.userId ? {
                _id: review.userId._id,
                name: review.userId.name,
                email: review.userId.email,
                avatar: review.userId.avatar
            } : null
        }));
        
        const totalReviews = await Review.countDocuments({ 
            productId, 
            status: 'active' 
        });
        
        res.json({
            success: true,
            message: 'Reviews fetched successfully',
            data: {
                reviews: transformedReviews,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total: totalReviews,
                    totalPages: Math.ceil(totalReviews / parseInt(limit))
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Get product rating summary
exports.getProductRating = async (req, res) => {
    try {
        const { productId } = req.params;
        
        const ratingStats = await Review.aggregate([
            { $match: { productId: new mongoose.Types.ObjectId(productId), status: 'active' } },
            {
                $group: {
                    _id: null,
                    averageRating: { $avg: '$rating' },
                    totalReviews: { $sum: 1 },
                    ratingDistribution: {
                        $push: '$rating'
                    }
                }
            }
        ]);
        
        let result = {
            averageRating: 0,
            totalReviews: 0,
            ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
        };
        
        if (ratingStats.length > 0) {
            const stats = ratingStats[0];
            result.averageRating = parseFloat(stats.averageRating.toFixed(1));
            result.totalReviews = stats.totalReviews;
            
            // Calculate rating distribution
            stats.ratingDistribution.forEach(rating => {
                result.ratingDistribution[rating]++;
            });
        }
        
        res.json({
            success: true,
            message: 'Product rating fetched successfully',
            data: result
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Submit a new review
exports.submitReview = async (req, res) => {
    try {
        const { productId, userId, rating, comment, title, images } = req.body;
        
        // Check if user has already reviewed this product
        const existingReview = await Review.findOne({ userId, productId });
        if (existingReview) {
            return res.status(400).json({
                success: false,
                message: 'You have already reviewed this product',
                data: null
            });
        }
        
        // Check if user has purchased and received this product
        const isVerifiedPurchase = await checkVerifiedPurchase(userId, productId);
        
        const review = new Review({
            userId,
            productId,
            rating,
            comment,
            title,
            images: images || [],
            isVerifiedPurchase
        });
        
        await review.save();
        
        // Populate user info for response
        await review.populate('userId', 'name email avatar');
        
        // Update product rating cache if you have one
        await updateProductRatingCache(productId);
        
        res.status(201).json({
            success: true,
            message: 'Review submitted successfully',
            data: { review }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Update a review
exports.updateReview = async (req, res) => {
    try {
        const { reviewId } = req.params;
        const { rating, comment, title, images } = req.body;
        const userId = req.user?.id;
        
        const review = await Review.findOne({ _id: reviewId, userId });
        if (!review) {
            return res.status(404).json({
                success: false,
                message: 'Review not found or you are not authorized to update it',
                data: null
            });
        }
        
        review.rating = rating;
        review.comment = comment;
        review.title = title;
        review.images = images || [];
        
        await review.save();
        await review.populate('userId', 'name email avatar');
        
        // Update product rating cache
        await updateProductRatingCache(review.productId);
        
        res.json({
            success: true,
            message: 'Review updated successfully',
            data: { review }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Delete a review
exports.deleteReview = async (req, res) => {
    try {
        const { reviewId } = req.params;
        const userId = req.user?.id;
        
        const review = await Review.findOne({ _id: reviewId, userId });
        if (!review) {
            return res.status(404).json({
                success: false,
                message: 'Review not found or you are not authorized to delete it',
                data: null
            });
        }
        
        const productId = review.productId;
        await Review.findByIdAndDelete(reviewId);
        
        // Update product rating cache
        await updateProductRatingCache(productId);
        
        res.json({
            success: true,
            message: 'Review deleted successfully',
            data: null
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Mark review as helpful
exports.markReviewHelpful = async (req, res) => {
    try {
        const { reviewId } = req.params;
        const userId = req.user?.id;
        
        const review = await Review.findById(reviewId);
        if (!review) {
            return res.status(404).json({
                success: false,
                message: 'Review not found',
                data: null
            });
        }
        
        // Check if user already marked this review as helpful
        if (review.helpfulUsers.includes(userId)) {
            return res.status(400).json({
                success: false,
                message: 'You have already marked this review as helpful',
                data: null
            });
        }
        
        review.helpfulUsers.push(userId);
        review.helpfulCount = review.helpfulUsers.length;
        await review.save();
        
        res.json({
            success: true,
            message: 'Review marked as helpful',
            data: { helpfulCount: review.helpfulCount }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Check if user can review product (has purchased and delivered)
exports.canUserReview = async (req, res) => {
    try {
        const { productId, userId } = req.params;
        
        // Check if user has already reviewed this product
        const existingReview = await Review.findOne({ userId, productId });
        if (existingReview) {
            return res.json({
                success: true,
                message: 'User has already reviewed this product',
                data: { canReview: false, reason: 'already_reviewed' }
            });
        }
        
        // Check if user has purchased and received this product
        const canReview = await checkVerifiedPurchase(userId, productId);
        
        res.json({
            success: true,
            message: 'Review eligibility checked',
            data: { canReview }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message,
            data: null
        });
    }
};

// Helper function to check if user has purchased and received the product
async function checkVerifiedPurchase(userId, productId) {
    try {
        const order = await Order.findOne({
            user: userId,
            'orderItems.product': productId,
            orderStatus: 'delivered'
        });
        
        return !!order;
    } catch (error) {
        console.error('Error checking verified purchase:', error);
        return false;
    }
}

// Helper function to update product rating cache
async function updateProductRatingCache(productId) {
    try {
        const ratingStats = await Review.aggregate([
            { $match: { productId: new mongoose.Types.ObjectId(productId), status: 'active' } },
            {
                $group: {
                    _id: null,
                    averageRating: { $avg: '$rating' },
                    totalReviews: { $sum: 1 }
                }
            }
        ]);
        
        let averageRating = 0;
        let reviewCount = 0;
        
        if (ratingStats.length > 0) {
            averageRating = parseFloat(ratingStats[0].averageRating.toFixed(1));
            reviewCount = ratingStats[0].totalReviews;
        }
        
        // Update product with rating info if your product model supports it
        await Product.findByIdAndUpdate(productId, {
            averageRating,
            reviewCount
        });
    } catch (error) {
        console.error('Error updating product rating cache:', error);
    }
}
