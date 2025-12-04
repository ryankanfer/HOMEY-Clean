'use client';

import { useState, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Upload, Camera, Sparkles, X, Check, ZoomIn, ZoomOut } from 'lucide-react';
import Cropper from 'react-easy-crop';
import { supabase } from '@/lib/supabase';
import {
  generateUserAvatar,
  getAvatarStylePreviews,
  AVATAR_STYLE_INFO,
  AvatarStyle,
} from '@/lib/avatarGenerator';

interface AvatarUploaderProps {
  currentAvatar?: string | null;
  userId: string;
  userName?: string;
  onAvatarChange: (avatarUrl: string) => void;
  onClose: () => void;
}

export default function AvatarUploader({
  currentAvatar,
  userId,
  userName,
  onAvatarChange,
  onClose,
}: AvatarUploaderProps) {
  const [selectedTab, setSelectedTab] = useState<'upload' | 'generate' | 'ai-prompt'>('upload');
  const [selectedStyle, setSelectedStyle] = useState<AvatarStyle>('bottts');
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [aiPrompt, setAiPrompt] = useState('');
  const [generatingAI, setGeneratingAI] = useState(false);
  const [aiGeneratedUrl, setAiGeneratedUrl] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Cropping state
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState(null);
  const [showCropper, setShowCropper] = useState(false);

  // Generate previews for all styles
  const stylePreviews = getAvatarStylePreviews(userName || userId);

  const onCropComplete = useCallback((croppedArea: any, croppedAreaPixels: any) => {
    setCroppedAreaPixels(croppedAreaPixels);
  }, []);

  const createCroppedImage = async (imageSrc: string, pixelCrop: any): Promise<Blob> => {
    const image = await createImage(imageSrc);
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    canvas.width = pixelCrop.width;
    canvas.height = pixelCrop.height;

    ctx?.drawImage(
      image,
      pixelCrop.x,
      pixelCrop.y,
      pixelCrop.width,
      pixelCrop.height,
      0,
      0,
      pixelCrop.width,
      pixelCrop.height
    );

    return new Promise((resolve) => {
      canvas.toBlob((blob) => {
        resolve(blob!);
      }, 'image/jpeg', 0.95);
    });
  };

  const createImage = (url: string): Promise<HTMLImageElement> => {
    return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', () => resolve(image));
      image.addEventListener('error', (error) => reject(error));
      image.src = url;
    });
  };

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      alert('Please select an image file');
      return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert('Image must be less than 5MB');
      return;
    }

    // Create preview and show cropper
    const reader = new FileReader();
    reader.onload = (e) => {
      setPreviewUrl(e.target?.result as string);
      setShowCropper(true); // Show cropper when image is loaded
    };
    reader.readAsDataURL(file);
  };

  const handleUpload = async () => {
    if (!previewUrl || !croppedAreaPixels) return;

    setUploading(true);
    try {
      // Create cropped image blob
      const croppedBlob = await createCroppedImage(previewUrl, croppedAreaPixels);

      const fileName = `${userId}-${Date.now()}.jpg`;
      const filePath = `avatars/${fileName}`;

      // Upload cropped image to Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('agent-avatars')
        .upload(filePath, croppedBlob, {
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/jpeg',
        });

      if (uploadError) throw uploadError;

      // Get public URL
      const { data } = supabase.storage.from('agent-avatars').getPublicUrl(filePath);

      // Update profile
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ avatar_url: data.publicUrl })
        .eq('id', userId);

      if (updateError) throw updateError;

      onAvatarChange(data.publicUrl);
      onClose();
    } catch (error: any) {
      console.error('Upload error:', error);
      alert(`Failed to upload avatar: ${error.message}`);
    } finally {
      setUploading(false);
    }
  };

  const handleGenerateAvatar = async () => {
    setUploading(true);
    try {
      const generatedUrl = generateUserAvatar(userId, userName, selectedStyle);

      // Update profile with generated avatar URL
      const { error } = await supabase
        .from('profiles')
        .update({ avatar_url: generatedUrl })
        .eq('id', userId);

      if (error) throw error;

      onAvatarChange(generatedUrl);
      onClose();
    } catch (error: any) {
      console.error('Generate error:', error);
      alert(`Failed to save avatar: ${error.message}`);
    } finally {
      setUploading(false);
    }
  };

  const handleGenerateAIImage = async () => {
    if (!aiPrompt.trim()) {
      alert('Please enter a prompt');
      return;
    }

    setGeneratingAI(true);
    try {
      // Call API route to generate image
      const response = await fetch('/api/generate-avatar', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: aiPrompt, userId }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to generate image');
      }

      const { imageUrl } = await response.json();
      setAiGeneratedUrl(imageUrl);
    } catch (error: any) {
      console.error('AI generation error:', error);
      alert(`Failed to generate image: ${error.message}`);
    } finally {
      setGeneratingAI(false);
    }
  };

  const handleSaveAIImage = async () => {
    if (!aiGeneratedUrl) return;

    setUploading(true);
    try {
      // Update profile with AI-generated avatar URL
      const { error } = await supabase
        .from('profiles')
        .update({ avatar_url: aiGeneratedUrl })
        .eq('id', userId);

      if (error) throw error;

      onAvatarChange(aiGeneratedUrl);
      onClose();
    } catch (error: any) {
      console.error('Save error:', error);
      alert(`Failed to save avatar: ${error.message}`);
    } finally {
      setUploading(false);
    }
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center">
        {/* Backdrop */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        />

        {/* Modal */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          className="relative w-full max-w-2xl max-h-[90vh] overflow-hidden"
        >
          <div className="glass-strong rounded-3xl border border-white/10 overflow-hidden shadow-2xl">
            {/* Header */}
            <div className="p-6 border-b border-white/10 flex items-center justify-between">
              <h2 className="text-2xl font-bold text-white">Choose Your Avatar</h2>
              <button
                onClick={onClose}
                className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
              >
                <X className="w-5 h-5 text-white/60" />
              </button>
            </div>

            {/* Tabs */}
            <div className="flex border-b border-white/10">
              <button
                onClick={() => setSelectedTab('upload')}
                className={`flex-1 py-4 px-6 text-sm font-medium transition-colors flex items-center justify-center gap-2 ${
                  selectedTab === 'upload'
                    ? 'text-white border-b-2 border-purple-500 bg-purple-500/10'
                    : 'text-white/60 hover:text-white hover:bg-white/5'
                }`}
              >
                <Upload className="w-4 h-4" />
                Upload Photo
              </button>
              <button
                onClick={() => setSelectedTab('generate')}
                className={`flex-1 py-4 px-6 text-sm font-medium transition-colors flex items-center justify-center gap-2 ${
                  selectedTab === 'generate'
                    ? 'text-white border-b-2 border-purple-500 bg-purple-500/10'
                    : 'text-white/60 hover:text-white hover:bg-white/5'
                }`}
              >
                <Sparkles className="w-4 h-4" />
                AI Avatar
              </button>
              <button
                onClick={() => setSelectedTab('ai-prompt')}
                className={`flex-1 py-4 px-6 text-sm font-medium transition-colors flex items-center justify-center gap-2 ${
                  selectedTab === 'ai-prompt'
                    ? 'text-white border-b-2 border-purple-500 bg-purple-500/10'
                    : 'text-white/60 hover:text-white hover:bg-white/5'
                }`}
              >
                <Camera className="w-4 h-4" />
                AI Image
              </button>
            </div>

            {/* Content */}
            <div className="p-6 max-h-[60vh] overflow-y-auto">
              {selectedTab === 'upload' ? (
                <div className="space-y-6">
                  {/* Cropper or Preview */}
                  {showCropper && previewUrl ? (
                    <div className="space-y-4">
                      <div className="relative w-full h-80 bg-slate-900/50 rounded-xl overflow-hidden">
                        <Cropper
                          image={previewUrl}
                          crop={crop}
                          zoom={zoom}
                          aspect={1}
                          cropShape="round"
                          showGrid={false}
                          onCropChange={setCrop}
                          onZoomChange={setZoom}
                          onCropComplete={onCropComplete}
                        />
                      </div>

                      {/* Zoom Control */}
                      <div className="flex items-center gap-3">
                        <ZoomOut className="w-4 h-4 text-white/40" />
                        <input
                          type="range"
                          min={1}
                          max={3}
                          step={0.1}
                          value={zoom}
                          onChange={(e) => setZoom(Number(e.target.value))}
                          className="flex-1 h-2 bg-white/10 rounded-lg appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-purple-500"
                        />
                        <ZoomIn className="w-4 h-4 text-white/40" />
                      </div>

                      {/* Cancel Crop Button */}
                      <button
                        onClick={() => {
                          setShowCropper(false);
                          setPreviewUrl(null);
                          setCrop({ x: 0, y: 0 });
                          setZoom(1);
                        }}
                        className="w-full py-3 bg-white/10 hover:bg-white/20 text-white font-medium rounded-xl transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center gap-4">
                      <div className="relative">
                        <div className="w-32 h-32 rounded-full overflow-hidden bg-slate-800/50 border-4 border-white/10">
                          {currentAvatar ? (
                            <img src={currentAvatar} alt="Current" className="w-full h-full object-cover" />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center">
                              <Camera className="w-12 h-12 text-white/40" />
                            </div>
                          )}
                        </div>
                      </div>
                      <p className="text-white/60 text-sm text-center">
                        Upload a professional photo of yourself
                      </p>
                    </div>
                  )}

                  {/* Upload Button */}
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*"
                    onChange={handleFileSelect}
                    className="hidden"
                  />
                  <button
                    onClick={() => fileInputRef.current?.click()}
                    className="w-full py-4 bg-white/10 hover:bg-white/20 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
                  >
                    <Upload className="w-5 h-5" />
                    Choose File
                  </button>

                  {/* Upload Guidelines */}
                  <div className="bg-slate-800/30 rounded-xl p-4 space-y-2">
                    <h3 className="text-white font-medium text-sm">Photo Guidelines:</h3>
                    <ul className="text-white/60 text-xs space-y-1">
                      <li>• Use a clear, professional headshot</li>
                      <li>• Maximum file size: 5MB</li>
                      <li>• Recommended: Square format, 400x400px or larger</li>
                      <li>• Supported formats: JPG, PNG, WebP</li>
                    </ul>
                  </div>

                  {/* Action Button - Only show when cropping */}
                  {showCropper && previewUrl && croppedAreaPixels && (
                    <button
                      onClick={handleUpload}
                      disabled={uploading || !croppedAreaPixels}
                      className="w-full py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 disabled:opacity-50 text-white font-medium rounded-xl transition-opacity flex items-center justify-center gap-2"
                    >
                      {uploading ? (
                        <>
                          <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                          Uploading...
                        </>
                      ) : (
                        <>
                          <Check className="w-5 h-5" />
                          Save Photo
                        </>
                      )}
                    </button>
                  )}
                </div>
              ) : selectedTab === 'generate' ? (
                <div className="space-y-6">
                  {/* Style Preview */}
                  <div className="flex flex-col items-center gap-4">
                    <div className="w-32 h-32 rounded-full overflow-hidden bg-slate-800/50 border-4 border-purple-500/50">
                      <img
                        src={stylePreviews[selectedStyle]}
                        alt="Avatar preview"
                        className="w-full h-full"
                      />
                    </div>
                    <div className="text-center">
                      <h3 className="text-white font-semibold">
                        {AVATAR_STYLE_INFO[selectedStyle].name}
                      </h3>
                      <p className="text-white/60 text-sm">
                        {AVATAR_STYLE_INFO[selectedStyle].description}
                      </p>
                    </div>
                  </div>

                  {/* Style Grid */}
                  <div>
                    <h3 className="text-white font-medium mb-3">Choose Style:</h3>
                    <div className="grid grid-cols-5 gap-3">
                      {Object.entries(stylePreviews).map(([style, url]) => (
                        <button
                          key={style}
                          onClick={() => setSelectedStyle(style as AvatarStyle)}
                          className={`relative aspect-square rounded-xl overflow-hidden transition-all ${
                            selectedStyle === style
                              ? 'ring-2 ring-purple-500 scale-105'
                              : 'ring-1 ring-white/10 hover:ring-white/30 hover:scale-105'
                          }`}
                        >
                          <img src={url} alt={style} className="w-full h-full" />
                          {selectedStyle === style && (
                            <div className="absolute inset-0 bg-purple-500/20 flex items-center justify-center">
                              <Check className="w-6 h-6 text-white" />
                            </div>
                          )}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Action Button */}
                  <button
                    onClick={handleGenerateAvatar}
                    disabled={uploading}
                    className="w-full py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 disabled:opacity-50 text-white font-medium rounded-xl transition-opacity flex items-center justify-center gap-2"
                  >
                    {uploading ? (
                      <>
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                        Saving...
                      </>
                    ) : (
                      <>
                        <Sparkles className="w-5 h-5" />
                        Use This Avatar
                      </>
                    )}
                  </button>

                  {/* Info */}
                  <p className="text-white/40 text-xs text-center">
                    AI-generated avatars are unique to your profile and can be changed anytime
                  </p>
                </div>
              ) : selectedTab === 'ai-prompt' ? (
                <div className="space-y-6">
                  {/* AI Image Preview */}
                  <div className="flex flex-col items-center gap-4">
                    <div className="relative">
                      <div className="w-48 h-48 rounded-2xl overflow-hidden bg-slate-800/50 border-4 border-white/10">
                        {aiGeneratedUrl ? (
                          <img src={aiGeneratedUrl} alt="AI Generated" className="w-full h-full object-cover" />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center">
                            <Camera className="w-16 h-16 text-white/20" />
                          </div>
                        )}
                      </div>
                    </div>
                    <p className="text-white/60 text-sm text-center max-w-md">
                      Generate a custom AI image with any prompt like "NYC real estate agent" or "poodle as a real estate agent"
                    </p>
                  </div>

                  {/* Prompt Input */}
                  <div>
                    <label className="text-white font-medium mb-2 block">Describe Your Image:</label>
                    <textarea
                      value={aiPrompt}
                      onChange={(e) => setAiPrompt(e.target.value)}
                      placeholder="e.g., professional NYC real estate agent in modern office, portrait style"
                      className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-purple-500 focus:bg-white/[0.15] transition-colors resize-none"
                      rows={3}
                      disabled={generatingAI}
                    />

                    {/* Example Prompts */}
                    <div className="mt-3 flex flex-wrap gap-2">
                      <p className="text-white/40 text-xs w-full mb-1">Quick examples:</p>
                      {[
                        'NYC real estate agent',
                        'poodle as a real estate agent',
                        'friendly agent in suit',
                        'modern professional headshot'
                      ].map((example) => (
                        <button
                          key={example}
                          onClick={() => setAiPrompt(example)}
                          disabled={generatingAI}
                          className="px-3 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-white/60 hover:text-white text-xs transition-colors disabled:opacity-50"
                        >
                          {example}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Generate Button */}
                  <button
                    onClick={handleGenerateAIImage}
                    disabled={generatingAI || !aiPrompt.trim()}
                    className="w-full py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 disabled:opacity-50 text-white font-medium rounded-xl transition-opacity flex items-center justify-center gap-2"
                  >
                    {generatingAI ? (
                      <>
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                        Generating Image...
                      </>
                    ) : (
                      <>
                        <Sparkles className="w-5 h-5" />
                        Generate Image
                      </>
                    )}
                  </button>

                  {/* Save Button (only show if image was generated) */}
                  {aiGeneratedUrl && (
                    <button
                      onClick={handleSaveAIImage}
                      disabled={uploading}
                      className="w-full py-4 bg-green-600 hover:opacity-90 disabled:opacity-50 text-white font-medium rounded-xl transition-opacity flex items-center justify-center gap-2"
                    >
                      {uploading ? (
                        <>
                          <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                          Saving...
                        </>
                      ) : (
                        <>
                          <Check className="w-5 h-5" />
                          Use This Image
                        </>
                      )}
                    </button>
                  )}

                  {/* Info */}
                  <p className="text-white/40 text-xs text-center">
                    AI-generated images are created using advanced AI and saved to your profile
                  </p>
                </div>
              ) : null}
            </div>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
