import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Create admin client with service role for server-side operations
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

export async function POST(req: NextRequest) {
  try {
    const { prompt, userId } = await req.json();

    if (!prompt || !userId) {
      return NextResponse.json(
        { error: 'Missing prompt or userId' },
        { status: 400 }
      );
    }

    // Clean and enhance the prompt for better results
    const enhancedPrompt = `${prompt}, professional photo, high quality, detailed, portrait`;

    // Use Pollinations AI (free, no API key required)
    // Alternative: Use Hugging Face Inference API with your own key
    const imageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(enhancedPrompt)}?width=512&height=512&nologo=true&enhance=true`;

    // Fetch the image to ensure it's generated
    const imageResponse = await fetch(imageUrl);

    if (!imageResponse.ok) {
      throw new Error('Failed to generate image');
    }

    // Convert to blob and upload to Supabase Storage
    const imageBlob = await imageResponse.blob();
    const fileName = `ai-avatar-${userId}-${Date.now()}.png`;
    const filePath = `avatars/${fileName}`;

    const { error: uploadError } = await supabaseAdmin.storage
      .from('agent-avatars')
      .upload(filePath, imageBlob, {
        cacheControl: '3600',
        upsert: true,
        contentType: 'image/png',
      });

    if (uploadError) {
      console.error('Upload error:', uploadError);
      throw new Error('Failed to upload image');
    }

    // Get public URL
    const { data } = supabaseAdmin.storage
      .from('agent-avatars')
      .getPublicUrl(filePath);

    return NextResponse.json({ imageUrl: data.publicUrl });
  } catch (error: any) {
    console.error('Generate avatar error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to generate avatar' },
      { status: 500 }
    );
  }
}
