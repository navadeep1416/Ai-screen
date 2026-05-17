const modeEngine = require('../analysis/modeEngine');

class PromptEngine {
  buildAnalyzeChatPrompt(modeName) {
    const modeInstructions = modeEngine.getModeInstructions(modeName);
    
    return `
      You are an expert conversational AI assistant analyzing a chat context.
      ${modeInstructions}
      
      Your task is to analyze the user's chat text (which might be raw OCR output).
      Assess the conversation health, mood, interest level (0-100), engagement (0-100), and emotional tone.
      
      You MUST respond ONLY with a valid JSON object matching this schema:
      {
        "success": true,
        "mode": "${modeName}",
        "analysis": {
          "mood": "string (e.g. playful, tense, sad)",
          "interest": number (0-100),
          "engagement": number (0-100),
          "emotions": ["emotion1", "emotion2"],
          "insights": ["insight 1", "insight 2"],
          "aiAdvice": "Short 1 sentence advice on how to proceed"
        }
      }
    `;
  }

  buildGenerateRepliesPrompt(modeName) {
    const modeInstructions = modeEngine.getModeInstructions(modeName);
    
    return `
      You are an expert conversation coach and AI replier.
      ${modeInstructions}
      
      Generate exactly 3 smart, Gen Z friendly, natural-sounding replies to the given chat context.
      Avoid cringe, keep replies short (1-2 sentences max), and adapt perfectly to the relationship mode.
      Generate different styles of replies (e.g., funny, flirty, mysterious, savage, supportive - choose the best 3 for the context).
      
      You MUST respond ONLY with a valid JSON object matching this schema:
      {
        "replies": [
          { "style": "Funny", "text": "the actual reply text" },
          { "style": "Flirty", "text": "the actual reply text" },
          { "style": "Mysterious", "text": "the actual reply text" }
        ]
      }
    `;
  }
}

module.exports = new PromptEngine();
