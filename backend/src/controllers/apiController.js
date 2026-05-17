const aiReplyGenerator = require('../analysis/aiReplyGenerator');
const geminiService = require('../ai/geminiService');
const { db } = require('../config/firebase');

exports.generateReplies = async (req, res, next) => {
  try {
    // Accept either "text" or "chat" field
    const { text, chat, mode } = req.body;
    const inputText = text || chat;

    if (!inputText || !mode) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: text/chat and mode'
      });
    }

    const replies = await aiReplyGenerator.generateReplies(inputText, mode);

    // Transform to array of strings
    const replyTexts = replies.map(r => r.text || r);

    res.json({
      success: true,
      replies: replyTexts
    });
  } catch (error) {
    next(error);
  }
};

exports.analyzeChat = async (req, res, next) => {
  try {
    const { text, mode } = req.body;
    const analysis = await aiReplyGenerator.analyzeContext(text, mode);
    
    res.json({
      success: true,
      mode,
      analysis
    });
  } catch (error) {
    next(error);
  }
};

exports.ocrProcess = async (req, res, next) => {
  try {
    const { text, mode, userId } = req.body;
    
    // Combined analysis and replies
    const result = await aiReplyGenerator.analyzeAndReply(text, mode);
    
    // Optional: Log to Firebase analytics async if db is initialized
    if (db && userId) {
      db.collection('analytics').doc(userId).collection('logs').add({
        timestamp: new Date(),
        mode,
        action: 'ocr-process'
      }).catch(e => console.error('Firebase log error', e));
    }
    
    res.json({
      success: true,
      mode,
      analysis: result.analysis,
      replies: result.replies
    });
  } catch (error) {
    next(error);
  }
};

exports.moodAnalysis = async (req, res, next) => {
  try {
    const { text, mode } = req.body;
    const analysis = await aiReplyGenerator.analyzeContext(text, mode);
    
    res.json({
      success: true,
      mood: analysis.mood,
      emotions: analysis.emotions
    });
  } catch (error) {
    next(error);
  }
};

exports.analyzeReel = async (req, res, next) => {
  try {
    const { base64Image, mimeType, prompt } = req.body;
    const defaultPrompt = prompt || "Analyze this image/screenshot/reel frame. Describe what is happening, detect any humor, sadness, or flirting, and summarize the emotional context.";
    
    const analysisText = await geminiService.analyzeImage(base64Image, mimeType, defaultPrompt);
    
    res.json({
      success: true,
      analysis: analysisText
    });
  } catch (error) {
    next(error);
  }
};
