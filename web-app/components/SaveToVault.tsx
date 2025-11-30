'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';
import BottomSheet from './BottomSheet';
import { db, auth } from '@/lib/supabase';

interface SaveToVaultProps {
  isOpen: boolean;
  onClose: () => void;
  property: Listing;
}

type DocumentType = 'lease' | 'inspection' | 'application' | 'receipt' | 'other';

export default function SaveToVault({
  isOpen,
  onClose,
  property,
}: SaveToVaultProps) {
  const [selectedType, setSelectedType] = useState<DocumentType>('lease');
  const [uploading, setUploading] = useState(false);
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);

  const documentTypes: Array<{ type: DocumentType; label: string; icon: string; description: string }> = [
    { type: 'lease', label: 'Lease Agreement', icon: '📄', description: 'Rental contract and terms' },
    { type: 'inspection', label: 'Inspection Report', icon: '🔍', description: 'Property condition checklist' },
    { type: 'application', label: 'Application', icon: '📝', description: 'Rental application form' },
    { type: 'receipt', label: 'Receipt', icon: '🧾', description: 'Payment receipts and invoices' },
    { type: 'other', label: 'Other', icon: '📎', description: 'Other property documents' },
  ];

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      setUploadedFile(file);
    }
  };

  const handleUpload = async () => {
    if (!uploadedFile) return;

    setUploading(true);

    try {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        alert('Please sign in to save documents');
        return;
      }

      // In production, upload to Supabase Storage
      // For now, simulate upload
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Save document metadata to database
      const documentMetadata = {
        user_id: user.id,
        property_id: property.id,
        document_type: selectedType,
        file_name: uploadedFile.name,
        file_size: uploadedFile.size,
        property_address: property.address,
        property_neighborhood: property.neighborhood,
      };

      console.log('Document saved:', documentMetadata);

      alert(`✅ ${uploadedFile.name} saved to Vault!`);
      setUploadedFile(null);
      onClose();
    } catch (error) {
      console.error('Upload failed:', error);
      alert('Failed to upload document. Please try again.');
    } finally {
      setUploading(false);
    }
  };

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title="Save to Vault" height="auto">
      <div className="p-6 space-y-6">
        {/* Property Info */}
        <div className="glass-strong rounded-xl p-4 border border-white/10">
          <div className="flex gap-3">
            <img
              src={property.images?.[0] || '/placeholder-property.jpg'}
              alt={property.address}
              className="w-20 h-20 rounded-lg object-cover"
            />
            <div className="flex-1">
              <p className="text-white font-semibold">{property.address}</p>
              <p className="text-white/60 text-sm">{property.neighborhood}</p>
            </div>
          </div>
        </div>

        {/* Document Type Selection */}
        <div>
          <h3 className="text-white font-semibold mb-3">Document Type</h3>
          <div className="space-y-2">
            {documentTypes.map((doc) => (
              <motion.button
                key={doc.type}
                onClick={() => setSelectedType(doc.type)}
                whileTap={{ scale: 0.98 }}
                className={`w-full p-4 rounded-xl text-left transition-all flex items-start gap-3 min-h-[44px] ${
                  selectedType === doc.type
                    ? 'bg-primary/20 border-2 border-primary'
                    : 'bg-white/5 border border-white/10 hover:bg-white/10'
                }`}
              >
                <span className="text-2xl">{doc.icon}</span>
                <div className="flex-1">
                  <p className="text-white font-semibold">{doc.label}</p>
                  <p className="text-white/60 text-sm">{doc.description}</p>
                </div>
                {selectedType === doc.type && (
                  <span className="text-primary text-xl">✓</span>
                )}
              </motion.button>
            ))}
          </div>
        </div>

        {/* File Upload */}
        <div>
          <h3 className="text-white font-semibold mb-3">Upload File</h3>

          {!uploadedFile ? (
            <label className="block">
              <input
                type="file"
                onChange={handleFileSelect}
                accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                className="hidden"
              />
              <div className="w-full p-8 border-2 border-dashed border-white/20 hover:border-primary/50 rounded-xl bg-white/5 hover:bg-white/10 transition-all cursor-pointer text-center">
                <div className="text-5xl mb-3">📤</div>
                <p className="text-white font-semibold mb-1">Tap to upload</p>
                <p className="text-white/60 text-sm">PDF, JPG, PNG, DOC (max 10MB)</p>
              </div>
            </label>
          ) : (
            <div className="glass-strong rounded-xl p-4 border border-white/10 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <span className="text-3xl">📄</span>
                <div>
                  <p className="text-white font-semibold">{uploadedFile.name}</p>
                  <p className="text-white/60 text-sm">
                    {(uploadedFile.size / 1024 / 1024).toFixed(2)} MB
                  </p>
                </div>
              </div>
              <button
                onClick={() => setUploadedFile(null)}
                className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
              >
                ✕
              </button>
            </div>
          )}
        </div>

        {/* Quick Actions */}
        <div className="glass-strong rounded-xl p-4 border border-white/10">
          <p className="text-white/60 text-sm mb-3">Quick Actions</p>
          <div className="flex flex-wrap gap-2">
            <button className="px-3 py-2 bg-white/10 hover:bg-white/20 rounded-lg text-white text-sm transition-colors">
              📸 Take Photo
            </button>
            <button className="px-3 py-2 bg-white/10 hover:bg-white/20 rounded-lg text-white text-sm transition-colors">
              📁 From Files
            </button>
            <button className="px-3 py-2 bg-white/10 hover:bg-white/20 rounded-lg text-white text-sm transition-colors">
              ✉️ From Email
            </button>
          </div>
        </div>

        {/* Upload Button */}
        <button
          onClick={handleUpload}
          disabled={!uploadedFile || uploading}
          className={`w-full py-4 rounded-2xl font-bold transition-all min-h-[44px] ${
            uploadedFile && !uploading
              ? 'bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white hover:opacity-90'
              : 'bg-white/10 text-white/40 cursor-not-allowed'
          }`}
        >
          {uploading ? '⏳ Uploading...' : '💾 Save to Vault'}
        </button>
      </div>
    </BottomSheet>
  );
}
