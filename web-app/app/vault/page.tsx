'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import XRayDocument from '@/components/vault/XRayDocument';
import { useDocumentExtraction } from '@/hooks/useDocumentExtraction';
import { auth, db, supabase } from '@/lib/supabase';
import type { DocumentType, ExtractedData } from '@/types/documents';

interface VaultDocument {
  id: string;
  file_name: string;
  file_url: string;
  file_size: number;
  mime_type: string;
  document_type?: DocumentType;
  extracted_data?: ExtractedData;
  extraction_status: 'pending' | 'processing' | 'completed' | 'failed';
  extraction_confidence?: number;
  view_mode?: 'executive' | 'card' | 'digest';
  category?: string;
  created_at: string;
}

type DocumentCategory = 'all' | 'leases' | 'inspections' | 'financial' | 'insurance' | 'identification' | 'other';

export default function VaultPage() {
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [documents, setDocuments] = useState<VaultDocument[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<DocumentCategory>('all');
  const [userId, setUserId] = useState<string | null>(null);
  const [selectedDoc, setSelectedDoc] = useState<VaultDocument | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [xrayMode, setXrayMode] = useState(true); // Default to X-Ray view
  const [uploadProgress, setUploadProgress] = useState(0);
  const [showUploadDisclaimer, setShowUploadDisclaimer] = useState(false);
  const [pendingFiles, setPendingFiles] = useState<FileList | null>(null);

  const { extractDocument } = useDocumentExtraction();

  useEffect(() => {
    initPage();
  }, []);

  const initPage = async () => {
    const { data: { user } } = await auth.getUser();
    if (user) {
      setUserId(user.id);
      loadDocuments(user.id);
    }
  };

  const loadDocuments = async (uid: string) => {
    const { data, error } = await db.getDocuments(uid);
    if (error) {
      console.error('Failed to load documents:', error);
      return;
    }
    setDocuments(data || []);
  };

  // Generate a secure, temporary signed URL for viewing documents
  const getSignedUrl = async (storagePath: string): Promise<string> => {
    const { data, error } = await supabase.storage
      .from('documents')
      .createSignedUrl(storagePath, 3600); // 1 hour expiration

    if (error) {
      console.error('Failed to generate signed URL:', error);
      return '';
    }

    return data.signedUrl;
  };

  // Open document in new tab with signed URL
  const openDocument = async (storagePath: string) => {
    const signedUrl = await getSignedUrl(storagePath);
    if (signedUrl) {
      window.open(signedUrl, '_blank');
    }
  };

  const handleFileSelect = () => {
    fileInputRef.current?.click();
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = event.target.files;
    if (!files || files.length === 0 || !userId) return;

    // Show disclaimer modal before uploading
    setPendingFiles(files);
    setShowUploadDisclaimer(true);
  };

  const cancelUpload = () => {
    setShowUploadDisclaimer(false);
    setPendingFiles(null);
    // Reset file input
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const proceedWithUpload = async () => {
    if (!pendingFiles || !userId) return;

    setShowUploadDisclaimer(false);
    setIsUploading(true);
    setUploadProgress(10);

    for (const file of Array.from(pendingFiles)) {
      try {
        // Upload file directly to storage
        const fileName = `${Date.now()}_${file.name}`;
        const filePath = `${userId}/${fileName}`;

        setUploadProgress(30);

        const { data: uploadData, error: uploadError } = await supabase.storage
          .from('documents')
          .upload(filePath, file, {
            cacheControl: '3600',
            upsert: false
          });

        if (uploadError) {
          console.error('Upload failed:', uploadError);
          alert(`Failed to upload ${file.name}`);
          continue;
        }

        setUploadProgress(50);

        // Save to database
        const { data: docData, error: dbError } = await db.uploadDocument({
          userId,
          fileName: file.name,
          fileUrl: uploadData.path,
          fileSize: file.size,
          mimeType: file.type,
        });

        if (dbError || !docData) {
          console.error('Failed to save document metadata:', dbError);
          alert(`Failed to save ${file.name} metadata`);
          continue;
        }

        setUploadProgress(70);

        // Trigger extraction (handles PDFs via PDF.co API server-side)
        extractDocumentAsync(docData.id, uploadData.path, file.name);

        // Add to local state immediately
        setDocuments(prev => [docData, ...prev]);

      } catch (error) {
        console.error('Error uploading file:', error);
        alert(`Error uploading ${file.name}`);
      }
    }

    setUploadProgress(100);
    setIsUploading(false);

    // Reset file input
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }

    // Reload documents to get latest
    if (userId) {
      setTimeout(() => loadDocuments(userId), 1000);
    }
  };

  const extractDocumentAsync = async (
    documentId: string,
    fileUrl: string,
    fileName: string
  ) => {
    try {
      console.log('Starting extraction for:', fileName);

      // Update status to processing
      await supabase
        .from('user_documents')
        .update({ extraction_status: 'processing' })
        .eq('id', documentId);

      // Extract data
      const extraction = await extractDocument(fileUrl, fileName);

      console.log('Extraction complete:', extraction);

      // Save extracted data
      await db.updateDocumentExtraction({
        documentId,
        documentType: extraction.documentType,
        extractedData: extraction.extractedData,
        viewMode: extraction.viewMode,
        confidence: extraction.confidence,
      });

      // Reload documents
      if (userId) {
        loadDocuments(userId);
      }

    } catch (error) {
      console.error('Extraction failed:', error);

      // Mark as failed
      await supabase
        .from('user_documents')
        .update({
          extraction_status: 'failed',
          extraction_error: error instanceof Error ? error.message : 'Unknown error'
        })
        .eq('id', documentId);
    }
  };

  const handleDeleteDocument = async (doc: VaultDocument) => {
    if (!userId) return;

    if (!confirm(`Delete "${doc.file_name}"? This cannot be undone.`)) {
      return;
    }

    const { error } = await db.deleteDocument(doc.id, userId, doc.file_url);

    if (error) {
      console.error('Failed to delete document:', error);
      alert('Failed to delete document');
      return;
    }

    // Remove from local state
    setDocuments(prev => prev.filter(d => d.id !== doc.id));

    // Close modal if this was the selected doc
    if (selectedDoc?.id === doc.id) {
      setSelectedDoc(null);
    }
  };

  const categories = [
    { id: 'all', label: 'All Documents', icon: '📁' },
    { id: 'leases', label: 'Leases', icon: '📄' },
    { id: 'inspections', label: 'Inspections', icon: '🔍' },
    { id: 'financial', label: 'Financial', icon: '💰' },
    { id: 'insurance', label: 'Insurance', icon: '🛡️' },
    { id: 'identification', label: 'ID & Verification', icon: '🪪' },
    { id: 'other', label: 'Other', icon: '📌' },
  ];

  const filteredDocs = selectedCategory === 'all'
    ? documents
    : documents.filter(d => {
        if (!d.document_type) return selectedCategory === 'other';

        // Map document types to categories
        const typeMap: Record<string, DocumentCategory> = {
          'lease': 'leases',
          'inspection': 'inspections',
          'pre-approval': 'financial',
          'paystub': 'financial',
          'bank-statement': 'financial',
          'insurance': 'insurance',
          'identification': 'identification',
          'other': 'other',
        };

        return typeMap[d.document_type] === selectedCategory;
      });

  const searchedDocs = searchQuery
    ? filteredDocs.filter(doc =>
        doc.file_name.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : filteredDocs;

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  const getExtractionStatusBadge = (status: string) => {
    if (status === 'pending') {
      return <span className="text-xs px-2 py-1 bg-yellow-500/20 text-yellow-400 rounded-full">Queued</span>;
    }
    if (status === 'processing') {
      return <span className="text-xs px-2 py-1 bg-blue-500/20 text-blue-400 rounded-full animate-pulse">Extracting...</span>;
    }
    if (status === 'completed') {
      return <span className="text-xs px-2 py-1 bg-green-500/20 text-green-400 rounded-full">✓ Extracted</span>;
    }
    if (status === 'failed') {
      return <span className="text-xs px-2 py-1 bg-red-500/20 text-red-400 rounded-full">⚠ Failed</span>;
    }
    return null;
  };

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="night" />

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        multiple
        accept=".pdf,.jpg,.jpeg,.png"
        onChange={handleFileUpload}
        className="hidden"
      />

      {/* Upload Disclaimer Modal */}
      <AnimatePresence>
        {showUploadDisclaimer && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4"
              onClick={cancelUpload}
            >
              <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.9, opacity: 0 }}
                onClick={(e) => e.stopPropagation()}
                className="bg-gradient-to-br from-purple-900/90 via-pink-800/90 to-orange-700/90 backdrop-blur-xl rounded-2xl p-6 max-w-lg w-full border border-white/10 shadow-2xl"
              >
                <div className="flex items-start gap-4 mb-6">
                  <div className="text-4xl flex-shrink-0">🔒</div>
                  <div className="flex-1">
                    <h2 className="text-2xl font-bold text-white mb-2">Before You Upload</h2>
                    <p className="text-white/80 text-sm">Please review our security and privacy information</p>
                  </div>
                </div>

                {/* Trust Indicators */}
                <div className="space-y-4 mb-6">
                  <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
                    <h3 className="text-white font-semibold mb-2 flex items-center gap-2">
                      <span>🔐</span> Your Data is Secure
                    </h3>
                    <ul className="text-white/80 text-sm space-y-1">
                      <li>• End-to-end encrypted storage</li>
                      <li>• Never shared with third parties</li>
                      <li>• SOC 2 Type II compliant</li>
                      <li>• Auto-deleted after 365 days of inactivity</li>
                    </ul>
                  </div>

                  {/* Security Warning */}
                  <div className="bg-red-500/20 border-2 border-red-400 rounded-lg p-4">
                    <h3 className="text-red-300 font-bold mb-2 flex items-center gap-2">
                      <span>⚠️</span> Important Security Reminder
                    </h3>
                    <p className="text-white/90 text-sm leading-relaxed">
                      <strong>Before uploading bank statements or financial documents:</strong>
                    </p>
                    <p className="text-white/90 text-sm mt-2 leading-relaxed">
                      Please ensure all account numbers are redacted except for the last 4 digits. This protects you from unauthorized access.
                    </p>
                  </div>

                  <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
                    <h3 className="text-white font-semibold mb-2 flex items-center gap-2">
                      <span>🧠</span> How Homey Uses Your Documents
                    </h3>
                    <ul className="text-white/80 text-sm space-y-1">
                      <li>• Extracts key info (dates, amounts, terms)</li>
                      <li>• Learns your preferences and budget</li>
                      <li>• Personalizes property recommendations</li>
                      <li>• Never reads sensitive details beyond extraction</li>
                    </ul>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3">
                  <button
                    onClick={cancelUpload}
                    className="flex-1 px-6 py-3 bg-white/10 hover:bg-white/20 text-white rounded-lg font-semibold transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={proceedWithUpload}
                    className="flex-1 px-6 py-3 bg-primary hover:bg-primary/80 text-white rounded-lg font-semibold transition-colors shadow-lg"
                  >
                    I Understand, Proceed
                  </button>
                </div>

                <p className="text-white/50 text-xs text-center mt-4">
                  By proceeding, you acknowledge that you've reviewed our security practices
                </p>
              </motion.div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Header */}
      <header className="relative z-20 px-4 sm:px-5 py-4 sm:py-6 bg-gradient-to-b from-black/60 to-transparent">
        <div className="flex items-center gap-3 sm:gap-4 mb-4 sm:mb-6">
          <button
            onClick={() => router.push('/home')}
            className="text-white/80 hover:text-white transition-colors"
          >
            ← Back
          </button>
          <div className="flex-1">
            <h1 className="text-2xl sm:text-3xl font-bold text-white">🔐 Vault</h1>
            <p className="text-white/60 text-xs sm:text-sm mt-1">X-Ray powered document intelligence</p>
          </div>
        </div>

        {/* Search Bar */}
        <div className="mb-4">
          <div className="relative">
            <input
              type="text"
              placeholder="Ask your vault anything..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full px-4 py-3 pl-12 bg-white/10 backdrop-blur-sm border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:border-primary/50"
            />
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-xl">🔍</span>
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-white/50 hover:text-white"
              >
                ✕
              </button>
            )}
          </div>
        </div>

        {/* Category Filters */}
        <div className="overflow-x-auto scrollbar-hide">
          <div className="flex gap-2 pb-2">
            {categories.map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id as DocumentCategory)}
                className={`px-4 py-2 rounded-full text-sm font-semibold whitespace-nowrap transition-all ${
                  selectedCategory === cat.id
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white/70 hover:bg-white/20'
                }`}
              >
                {cat.icon} {cat.label}
              </button>
            ))}
          </div>
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 px-4 sm:px-5 space-y-4 sm:space-y-6">
        {/* Upload Progress */}
        {isUploading && (
          <motion.div
            className="glass-strong rounded-2xl p-5"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex items-center gap-3 mb-3">
              <span className="text-2xl">📤</span>
              <span className="text-white font-semibold">Uploading & Extracting...</span>
            </div>
            <div className="w-full bg-white/10 rounded-full h-2 overflow-hidden">
              <motion.div
                className="bg-primary h-full rounded-full"
                initial={{ width: 0 }}
                animate={{ width: `${uploadProgress}%` }}
                transition={{ duration: 0.3 }}
              />
            </div>
            <p className="text-white/60 text-sm mt-2">AI is analyzing your documents...</p>
          </motion.div>
        )}

        {/* Upload Area */}
        <motion.div
          className="glass-strong rounded-2xl p-5 sm:p-8 text-center border-2 border-dashed border-white/20 hover:border-primary/50 transition-colors cursor-pointer"
          whileHover={{ scale: 1.01 }}
          whileTap={{ scale: 0.99 }}
          onClick={handleFileSelect}
        >
          <div className="text-4xl sm:text-5xl mb-3">📤</div>
          <h3 className="text-lg sm:text-xl font-bold text-white mb-2">Upload Documents</h3>
          <p className="text-white/60 text-sm sm:text-base mb-4">
            X-Ray AI will automatically extract and analyze
          </p>
          <button className="px-4 sm:px-6 py-2 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors text-sm sm:text-base">
            Choose Files
          </button>
          <p className="text-white/40 text-xs mt-3">Supports PDF, JPG, PNG</p>

          {/* Trust & Privacy Indicators */}
          <div className="mt-4 sm:mt-6 pt-4 border-t border-white/10 space-y-3">
            <div className="flex flex-col sm:flex-row items-center justify-center gap-2 text-xs text-white/60">
              <span className="text-green-400">🔒</span>
              <span className="text-center sm:text-left">End-to-end encrypted • Never shared • SOC 2 Type II</span>
            </div>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-4 text-xs">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  alert('Privacy Modal - Coming soon!');
                }}
                className="text-primary hover:text-primary/80 underline"
              >
                What data is extracted?
              </button>
              <span className="hidden sm:inline text-white/30">•</span>
              <a
                href="/privacy"
                onClick={(e) => e.stopPropagation()}
                className="text-primary hover:text-primary/80 underline"
              >
                Privacy Policy
              </a>
            </div>
            <p className="text-white/40 text-xs">
              Documents automatically deleted after 365 days of inactivity
            </p>
          </div>
        </motion.div>

        {/* Documents List */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold text-white">
              {searchedDocs.length} Document{searchedDocs.length !== 1 ? 's' : ''}
            </h2>
            {searchedDocs.length > 0 && (
              <button
                onClick={() => setXrayMode(!xrayMode)}
                className="px-3 py-1.5 bg-white/10 hover:bg-white/20 border border-white/20 rounded-lg text-white text-sm font-medium transition-colors flex items-center gap-2"
              >
                {xrayMode ? '🔍 X-Ray' : '📄 PDF'} View
              </button>
            )}
          </div>

          {searchedDocs.length === 0 ? (
            <div className="glass rounded-xl p-12 text-center">
              <div className="text-6xl mb-4">📂</div>
              <h3 className="text-xl font-semibold text-white mb-2">
                {searchQuery ? 'No documents found' : 'No documents yet'}
              </h3>
              <p className="text-white/60">
                {searchQuery ? 'Try a different search term' : 'Upload your first document to get started'}
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {searchedDocs.map((doc) => (
                <motion.div
                  key={doc.id}
                  className="glass rounded-xl p-3 sm:p-4 hover:bg-white/10 transition-colors cursor-pointer"
                  whileHover={{ x: 4 }}
                  onClick={() => setSelectedDoc(doc)}
                >
                  <div className="flex items-start gap-3 sm:gap-4">
                    {/* Icon */}
                    <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-primary/20 flex items-center justify-center text-xl sm:text-2xl flex-shrink-0">
                      {doc.document_type === 'lease' && '📄'}
                      {doc.document_type === 'inspection' && '🔍'}
                      {doc.document_type === 'pre-approval' && '💰'}
                      {doc.document_type === 'insurance' && '🛡️'}
                      {doc.document_type === 'identification' && '🪪'}
                      {doc.document_type === 'paystub' && '💵'}
                      {doc.document_type === 'bank-statement' && '🏦'}
                      {(!doc.document_type || doc.document_type === 'other') && '📄'}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-1 sm:gap-2 mb-2">
                        <h3 className="text-white font-semibold truncate text-sm sm:text-base">
                          {doc.file_name}
                        </h3>
                        {getExtractionStatusBadge(doc.extraction_status)}
                      </div>

                      <div className="flex flex-wrap items-center gap-2 text-xs sm:text-sm text-white/60 mb-2">
                        <span>{formatFileSize(doc.file_size)}</span>
                        <span>•</span>
                        <span>{new Date(doc.created_at).toLocaleDateString()}</span>
                        {doc.document_type && (
                          <>
                            <span className="hidden sm:inline">•</span>
                            <span className="capitalize hidden sm:inline">{doc.document_type.replace('-', ' ')}</span>
                          </>
                        )}
                      </div>

                      {/* Confidence Score */}
                      {doc.extraction_confidence && (
                        <div className="flex items-center gap-2 text-xs">
                          <span className="text-white/50 flex-shrink-0">Confidence:</span>
                          <div className="flex-1 max-w-24 sm:max-w-32 bg-white/10 rounded-full h-1.5 overflow-hidden">
                            <div
                              className={`h-full rounded-full ${
                                doc.extraction_confidence >= 0.8 ? 'bg-green-500' :
                                doc.extraction_confidence >= 0.6 ? 'bg-yellow-500' :
                                'bg-red-500'
                              }`}
                              style={{ width: `${doc.extraction_confidence * 100}%` }}
                            />
                          </div>
                          <span className="text-white/60 flex-shrink-0">{Math.round(doc.extraction_confidence * 100)}%</span>
                        </div>
                      )}

                      {/* Mobile Actions */}
                      <div className="flex sm:hidden gap-2 mt-3">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedDoc(doc);
                          }}
                          className="flex-1 px-3 py-1.5 bg-white/10 hover:bg-white/20 text-white text-xs font-semibold rounded-lg transition-colors"
                        >
                          {xrayMode ? 'X-Ray' : 'View'}
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleDeleteDocument(doc);
                          }}
                          className="px-3 py-1.5 bg-red-500/20 hover:bg-red-500/30 text-red-400 text-xs font-semibold rounded-lg transition-colors"
                        >
                          Delete
                        </button>
                      </div>
                    </div>

                    {/* Desktop Actions */}
                    <div className="hidden sm:flex flex-col gap-2">
                      <button className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white text-sm font-semibold rounded-lg transition-colors flex-shrink-0">
                        {xrayMode ? 'X-Ray' : 'View'}
                      </button>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDeleteDocument(doc);
                        }}
                        className="px-4 py-2 bg-red-500/20 hover:bg-red-500/30 text-red-400 text-sm font-semibold rounded-lg transition-colors flex-shrink-0"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>

        {/* Security Info */}
        <div className="glass-strong rounded-xl p-6 border border-green-500/30">
          <div className="flex items-start gap-4">
            <div className="text-3xl">🛡️</div>
            <div>
              <h3 className="text-lg font-bold text-white mb-2">
                Bank-Level Security
              </h3>
              <p className="text-white/70 text-sm leading-relaxed">
                Your documents are encrypted end-to-end and stored securely. X-Ray AI processes documents
                with enterprise-grade privacy protection.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Document Detail Modal */}
      <AnimatePresence>
        {selectedDoc && (
          <motion.div
            className="fixed inset-0 z-[200] bg-black/50 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSelectedDoc(null)}
          >
            <motion.div
              className="bg-gradient-to-b from-gray-900 to-black rounded-t-3xl sm:rounded-2xl w-full sm:max-w-4xl max-h-[90vh] overflow-y-auto border-t sm:border border-white/10"
              initial={{ opacity: 0, y: 100 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 100 }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <div className="sticky top-0 bg-gray-900/95 backdrop-blur-sm border-b border-white/10 p-6 z-10">
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <h2 className="text-xl font-bold text-white mb-1 truncate">{selectedDoc.file_name}</h2>
                    <div className="flex items-center gap-3 text-sm text-white/60">
                      <span>{formatFileSize(selectedDoc.file_size)}</span>
                      <span>•</span>
                      <span>{new Date(selectedDoc.created_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedDoc(null)}
                    className="text-white/60 hover:text-white text-2xl ml-4"
                  >
                    ✕
                  </button>
                </div>

                {/* View Mode Toggle */}
                <div className="flex gap-2 mt-4">
                  <button
                    onClick={() => setXrayMode(true)}
                    className={`flex-1 px-4 py-2 rounded-lg text-sm font-semibold transition-colors ${
                      xrayMode
                        ? 'bg-primary text-white'
                        : 'bg-white/10 text-white/60 hover:bg-white/20'
                    }`}
                  >
                    🔍 X-Ray View
                  </button>
                  <button
                    onClick={() => setXrayMode(false)}
                    className={`flex-1 px-4 py-2 rounded-lg text-sm font-semibold transition-colors ${
                      !xrayMode
                        ? 'bg-primary text-white'
                        : 'bg-white/10 text-white/60 hover:bg-white/20'
                    }`}
                  >
                    📄 PDF View
                  </button>
                </div>
              </div>

              {/* Modal Content */}
              <div className="p-6">
                {xrayMode ? (
                  // X-Ray View
                  selectedDoc.extraction_status === 'completed' && selectedDoc.extracted_data ? (
                    <XRayDocument
                      data={selectedDoc.extracted_data}
                      viewMode={selectedDoc.view_mode}
                      securityWarnings={(selectedDoc.extracted_data as any)?._securityWarnings}
                      onViewOriginal={() => openDocument(selectedDoc.file_url)}
                    />
                  ) : selectedDoc.extraction_status === 'processing' ? (
                    <div className="text-center py-12">
                      <div className="text-6xl mb-4 animate-pulse">🔍</div>
                      <h3 className="text-xl font-bold text-white mb-2">Processing Document...</h3>
                      <p className="text-white/60">X-Ray AI is extracting information</p>
                    </div>
                  ) : selectedDoc.extraction_status === 'failed' ? (
                    <div className="text-center py-12">
                      <div className="text-6xl mb-4">⚠️</div>
                      <h3 className="text-xl font-bold text-white mb-2">Extraction Failed</h3>
                      <p className="text-white/60 mb-4">Unable to extract data from this document</p>
                      <button
                        onClick={() => extractDocumentAsync(selectedDoc.id, selectedDoc.file_url, selectedDoc.file_name)}
                        className="px-6 py-2 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors"
                      >
                        Retry Extraction
                      </button>
                    </div>
                  ) : (
                    <div className="text-center py-12">
                      <div className="text-6xl mb-4">⏳</div>
                      <h3 className="text-xl font-bold text-white mb-2">Extraction Pending</h3>
                      <p className="text-white/60">This document will be processed shortly</p>
                    </div>
                  )
                ) : (
                  // PDF View
                  <div className="text-center py-12">
                    <div className="text-6xl mb-4">📄</div>
                    <h3 className="text-xl font-bold text-white mb-4">Original Document</h3>
                    <button
                      onClick={() => openDocument(selectedDoc.file_url)}
                      className="inline-block px-6 py-3 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors"
                    >
                      Open PDF
                    </button>
                  </div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
