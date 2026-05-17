const modes = {
  Love: { confidence: 'high', humor: 'sweet', flirting: 'high', tone: 'warm, deeply engaged' },
  OneSide: { confidence: 'low', humor: 'subtle', flirting: 'low', tone: 'hinting, trying to impress' },
  Friend: { confidence: 'medium', humor: 'high', flirting: 'none', tone: 'casual, funny, relaxed' },
  Fight: { confidence: 'high', humor: 'none', flirting: 'none', tone: 'calm, de-escalating, firm' },
  Enemy: { confidence: 'high', humor: 'dark', flirting: 'none', tone: 'savage, sharp, cold' },
  Stranger: { confidence: 'medium', humor: 'light', flirting: 'none', tone: 'polite, curious, safe' },
  MaleFriend: { confidence: 'high', humor: 'roast', flirting: 'none', tone: 'bro energy, direct' },
  FemaleFriend: { confidence: 'high', humor: 'high', flirting: 'none', tone: 'expressive, emotional' },
  Crush: { confidence: 'medium', humor: 'playful', flirting: 'high', tone: 'playful, flirty, mysterious' },
  BestFriend: { confidence: 'high', humor: 'roast', flirting: 'none', tone: 'brutally honest, inside jokes' },
  Bestie: { confidence: 'high', humor: 'high', flirting: 'none', tone: 'deep comfort, no filter' }
};

class ModeEngine {
  getModeConfig(modeName) {
    const formattedMode = modeName.replace(/\s+/g, '');
    return modes[formattedMode] || modes['Friend']; // Default to Friend
  }

  getModeInstructions(modeName) {
    const config = this.getModeConfig(modeName);
    return `
      Relationship Mode: ${modeName}
      Tone: ${config.tone}
      Confidence Level: ${config.confidence}
      Humor Style: ${config.humor}
      Flirting Level: ${config.flirting}
    `;
  }
}

module.exports = new ModeEngine();
