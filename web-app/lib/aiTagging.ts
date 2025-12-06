// AI-powered tag detection for vibe posts
// Uses OpenAI to automatically detect relevant tags from text

const AVAILABLE_TAGS = ['Coffee', 'Food', 'Nightlife', 'Quiet', 'Parks', 'Shopping', 'Work', 'Holiday'];

export async function detectTags(text: string): Promise<string[]> {
  try {
    const response = await fetch('/api/detect-tags', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text }),
    });

    if (!response.ok) {
      console.error('Tag detection failed, using fallback');
      return fallbackTagDetection(text);
    }

    const { tags } = await response.json();
    return tags;
  } catch (error) {
    console.error('Error detecting tags:', error);
    return fallbackTagDetection(text);
  }
}

// Fallback: Simple keyword matching if AI fails
function fallbackTagDetection(text: string): string[] {
  const lowerText = text.toLowerCase();
  const detected: string[] = [];

  const keywords: Record<string, string[]> = {
    'Coffee': ['coffee', 'cafe', 'espresso', 'latte', 'cappuccino', 'brew'],
    'Food': ['food', 'restaurant', 'dining', 'meal', 'lunch', 'dinner', 'breakfast', 'brunch', 'eat'],
    'Nightlife': ['bar', 'club', 'nightlife', 'drinks', 'party', 'cocktail', 'beer', 'dancing'],
    'Quiet': ['quiet', 'peaceful', 'calm', 'relaxing', 'serene', 'tranquil'],
    'Parks': ['park', 'garden', 'nature', 'green space', 'outdoor', 'trees'],
    'Shopping': ['shop', 'store', 'boutique', 'retail', 'mall', 'shopping'],
    'Work': ['work', 'coworking', 'office', 'workspace', 'productive', 'wifi'],
    'Holiday': ['holiday', 'christmas', 'festive', 'decorations', 'lights', 'seasonal'],
  };

  for (const [tag, words] of Object.entries(keywords)) {
    if (words.some(word => lowerText.includes(word))) {
      detected.push(tag);
    }
  }

  return detected.slice(0, 3); // Max 3 tags
}
