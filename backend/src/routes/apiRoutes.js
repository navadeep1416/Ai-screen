const express = require('express');
const router = express.Router();
const apiController = require('../controllers/apiController');
const { validateRequest } = require('../middleware/validateRequest');
const Joi = require('joi');

// Schemas
const chatSchema = Joi.object({
  text: Joi.string(),
  chat: Joi.string(),
  mode: Joi.string().required(),
  userId: Joi.string().optional()
}).or('text', 'chat');

const imageSchema = Joi.object({
  base64Image: Joi.string().required(),
  mimeType: Joi.string().default('image/jpeg'),
  prompt: Joi.string().optional(),
  userId: Joi.string().optional()
});

// Routes
router.post('/generate-replies', validateRequest(chatSchema), apiController.generateReplies);
router.post('/analyze-chat', validateRequest(chatSchema), apiController.analyzeChat);
router.post('/analyze-reel', validateRequest(imageSchema), apiController.analyzeReel);
router.post('/mood-analysis', validateRequest(chatSchema), apiController.moodAnalysis);
router.post('/ocr-process', validateRequest(chatSchema), apiController.ocrProcess); // Combined route

module.exports = router;
