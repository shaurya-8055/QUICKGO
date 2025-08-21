const express = require('express');
const router = express.Router();
const reviewController = require('../controller/review');
const { authenticateToken } = require('../middleware/auth');

// Public routes (no authentication required)
router.get('/product/:productId', reviewController.getProductReviews);
router.get('/product/:productId/rating', reviewController.getProductRating);

// Protected routes (authentication required)
router.post('/', authenticateToken, reviewController.submitReview);
router.put('/:reviewId', authenticateToken, reviewController.updateReview);
router.delete('/:reviewId', authenticateToken, reviewController.deleteReview);
router.post('/:reviewId/helpful', authenticateToken, reviewController.markReviewHelpful);
router.get('/can-review/:productId/:userId', authenticateToken, reviewController.canUserReview);

module.exports = router;
