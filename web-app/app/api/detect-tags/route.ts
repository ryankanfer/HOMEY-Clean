import { NextRequest, NextResponse } from 'next/server';
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const AVAILABLE_TAGS = ['Coffee', 'Food', 'Nightlife', 'Quiet', 'Parks', 'Shopping', 'Work', 'Holiday'];

export async function POST(req: NextRequest) {
  try {
    const { text } = await req.json();

    if (!text || text.trim().length === 0) {
      return NextResponse.json({ tags: [] });
    }

    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: `You are a tag detection system. Analyze the given text and return ONLY relevant tags from this list: ${AVAILABLE_TAGS.join(', ')}.

Rules:
- Return 0-3 tags maximum
- Only return tags that are clearly relevant
- Return tags as a JSON array
- If no tags match, return empty array
- Be strict - only tag if there's clear evidence

Examples:
"Great coffee shop with amazing lattes" -> ["Coffee"]
"Amazing dinner at this new Italian place" -> ["Food"]
"Went to a bar and had great cocktails" -> ["Nightlife", "Food"]
"Peaceful park for morning walks" -> ["Parks", "Quiet"]`,
        },
        {
          role: 'user',
          content: text,
        },
      ],
      response_format: { type: 'json_object' },
      temperature: 0.3,
      max_tokens: 100,
    });

    const response = completion.choices[0].message.content;
    if (!response) {
      return NextResponse.json({ tags: [] });
    }

    const parsed = JSON.parse(response);
    const tags = Array.isArray(parsed.tags) ? parsed.tags : [];

    // Validate tags are in our allowed list
    const validTags = tags.filter((tag: string) => AVAILABLE_TAGS.includes(tag));

    return NextResponse.json({ tags: validTags.slice(0, 3) });
  } catch (error) {
    console.error('Error detecting tags:', error);
    return NextResponse.json({ tags: [] }, { status: 500 });
  }
}
