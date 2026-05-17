const { GoogleGenerativeAI } = require('@google/generative-ai');
const dotenv = require('dotenv');
dotenv.config();

class GeminiService {
  constructor() {
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    this.model = this.genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  }

  /**
   * Analyze an image from base64 string
   */
  async analyzeImage(base64Image, mimeType, prompt) {
    try {
      const imageParts = [
        {
          inlineData: {
            data: base64Image,
            mimeType: mimeType
          }
        }
      ];

      const result = await this.model.generateContent([prompt, ...imageParts]);
      const response = await result.response;
      return response.text();
    } catch (error) {
      console.error('Gemini Vision Error:', error);
      throw new Error('Failed to process image with Vision AI');
    }
  }
}

module.exports = new GeminiService();
