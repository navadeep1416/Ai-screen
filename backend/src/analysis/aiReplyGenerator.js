const groqService = require('../ai/groqService');
const promptEngine = require('../prompts/promptEngine');

class AiReplyGenerator {
  /**
   * Generates smart replies based on OCR text and mode
   */
  async generateReplies(text, mode) {
    const systemPrompt = promptEngine.buildGenerateRepliesPrompt(mode);
    const userPrompt = `Context to reply to:\n"${text}"`;
    
    // Higher temperature for creative replies
    const response = await groqService.generateChatCompletion(systemPrompt, userPrompt, 0.8);
    return response.replies || [];
  }

  /**
   * Analyzes conversation context
   */
  async analyzeContext(text, mode) {
    const systemPrompt = promptEngine.buildAnalyzeChatPrompt(mode);
    const userPrompt = `Analyze this text:\n"${text}"`;
    
    // Lower temperature for analytical output
    const response = await groqService.generateChatCompletion(systemPrompt, userPrompt, 0.3);
    return response.analysis;
  }
  
  /**
   * Combined API to do both simultaneously
   */
  async analyzeAndReply(text, mode) {
    const [analysis, replies] = await Promise.all([
      this.analyzeContext(text, mode),
      this.generateReplies(text, mode)
    ]);
    
    return { analysis, replies };
  }
}

module.exports = new AiReplyGenerator();
