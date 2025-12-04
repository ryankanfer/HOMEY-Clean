/**
 * Avatar Generation Utility
 *
 * Provides AI-generated avatars using DiceBear API
 * Multiple styles available: fun, professional, abstract
 */

export type AvatarStyle =
  | 'adventurer'      // Fun, colorful characters
  | 'adventurer-neutral' // Professional, neutral tones
  | 'avataaars'       // Cartoon style (like Bitmoji)
  | 'big-ears'        // Cute, big-eared characters
  | 'bottts'          // Robot style (nano banana vibes!)
  | 'croodles'        // Doodle style illustrations
  | 'fun-emoji'       // Emoji-based avatars
  | 'lorelei'         // Professional illustrated faces
  | 'notionists'      // Notion-style avatars
  | 'pixel-art';      // Retro pixel art

interface AvatarOptions {
  seed?: string;        // User ID, name, or email for consistent generation
  style?: AvatarStyle;  // Avatar style
  backgroundColor?: string; // Hex color without #
  size?: number;        // Size in pixels (default: 200)
}

/**
 * Generate AI avatar URL using DiceBear API
 * Free, open-source, no API key required!
 */
export function generateAvatar(options: AvatarOptions): string {
  const {
    seed = Date.now().toString(),
    style = 'bottts', // Default to robot style (nano banana vibes!)
    backgroundColor,
    size = 200,
  } = options;

  // Build URL parameters
  const params = new URLSearchParams();
  if (backgroundColor) {
    params.append('backgroundColor', backgroundColor);
  }
  params.append('size', size.toString());

  const baseUrl = `https://api.dicebear.com/7.x/${style}/svg`;
  const paramString = params.toString();

  return `${baseUrl}?seed=${encodeURIComponent(seed)}${paramString ? '&' + paramString : ''}`;
}

/**
 * Generate avatar from user info
 */
export function generateUserAvatar(userId: string, userName?: string, style?: AvatarStyle): string {
  // Use name if available for more personalized avatars
  const seed = userName || userId;

  return generateAvatar({
    seed,
    style: style || 'bottts',
    size: 200,
  });
}

/**
 * Get avatar URL with fallback
 * Returns uploaded avatar if available, otherwise generates one
 */
export function getAvatarUrl(
  uploadedAvatar: string | null | undefined,
  userId: string,
  userName?: string,
  style?: AvatarStyle
): string {
  if (uploadedAvatar) {
    return uploadedAvatar;
  }

  return generateUserAvatar(userId, userName, style);
}

/**
 * Preload multiple avatar styles for quick preview
 */
export function getAvatarStylePreviews(seed: string): Record<AvatarStyle, string> {
  const styles: AvatarStyle[] = [
    'adventurer',
    'adventurer-neutral',
    'avataaars',
    'big-ears',
    'bottts',
    'croodles',
    'fun-emoji',
    'lorelei',
    'notionists',
    'pixel-art',
  ];

  return styles.reduce((acc, style) => {
    acc[style] = generateAvatar({ seed, style, size: 100 });
    return acc;
  }, {} as Record<AvatarStyle, string>);
}

/**
 * Avatar style descriptions for UI
 */
export const AVATAR_STYLE_INFO: Record<AvatarStyle, { name: string; description: string }> = {
  'adventurer': {
    name: 'Adventurer',
    description: 'Fun, colorful character portraits'
  },
  'adventurer-neutral': {
    name: 'Professional',
    description: 'Neutral, business-appropriate style'
  },
  'avataaars': {
    name: 'Cartoon',
    description: 'Playful cartoon avatars'
  },
  'big-ears': {
    name: 'Big Ears',
    description: 'Cute characters with oversized ears'
  },
  'bottts': {
    name: 'Nano Banana',
    description: 'Quirky robot style (default)'
  },
  'croodles': {
    name: 'Doodles',
    description: 'Hand-drawn doodle illustrations'
  },
  'fun-emoji': {
    name: 'Emoji',
    description: 'Emoji-based fun avatars'
  },
  'lorelei': {
    name: 'Portrait',
    description: 'Professional illustrated portraits'
  },
  'notionists': {
    name: 'Notion Style',
    description: 'Clean, minimal Notion-style avatars'
  },
  'pixel-art': {
    name: 'Pixel Art',
    description: 'Retro 8-bit pixel art style'
  },
};
