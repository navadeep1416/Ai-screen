const Groq = require('groq-sdk');

class GroqService {
  constructor() {
    const apiKey = process.env.GROQ_API_KEY;

    if (!apiKey) {
      throw new Error('GROQ_API_KEY is not configured. Please set it in your environment.');
    }

    this.client = new Groq({
      apiKey: apiKey,
    });
  }

  async generateChatCompletion(systemPrompt, userPrompt, temperature = 0.7) {
    if (!process.env.GROQ_API_KEY) {
      throw new Error('GROQ_API_KEY not configured');
    }

    try {
      const completion = await this.client.chat.completions.create({
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        model: 'llama-3.3-70b-versatile',
        temperature: temperature,
        max_tokens: 600,
        response_format: { type: 'json_object' }
      });

      const responseContent = completion.choices[0]?.message?.content;

      if (!responseContent) {
        throw new Error('Empty response from Groq API');
      }

      return JSON.parse(responseContent);
    } catch (error) {
      console.error('Groq API Error:', error.message);

      if (error.status === 429) {
        throw new Error('Rate limit exceeded. Please try again later.');
      }

      throw new Error('Failed to generate AI response');
    }
  }
}

module.exports = new GroqService();
