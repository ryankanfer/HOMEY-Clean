'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import {
  FileText,
  Upload,
  Download,
  Eye,
  Search,
  Filter,
  File,
  Image as ImageIcon,
  FileSignature,
  CheckCircle2,
  XCircle,
  Clock,
  MoreVertical,
  Trash2,
  Share2,
  Calendar
} from 'lucide-react';

type DocumentType = 'contract' | 'disclosure' | 'inspection' | 'appraisal' | 'image' | 'other';

interface SharedDocument {
  id: string;
  documentName: string;
  documentType: DocumentType;
  fileUrl: string;
  fileSizeBytes: number;
  uploadedBy: string;
  uploaderType: 'agent' | 'client';
  client: {
    id: string;
    name: string;
  };
  listingId?: string;
  requiresSignature: boolean;
  signedAt?: string;
  viewedByClient: boolean;
  viewedByAgent: boolean;
  clientViewedAt?: string;
  createdAt: string;
}

export default function DocumentsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedClient, setSelectedClient] = useState<string>('all');
  const [selectedType, setSelectedType] = useState<DocumentType | 'all'>('all');
  const [showUploadModal, setShowUploadModal] = useState(false);

  // Mock data - will be replaced with real Supabase data
  const documents: SharedDocument[] = [
    {
      id: '1',
      documentName: 'Purchase Agreement - 123 Main St.pdf',
      documentType: 'contract',
      fileUrl: '/docs/purchase-agreement.pdf',
      fileSizeBytes: 2458624,
      uploadedBy: 'agent',
      uploaderType: 'agent',
      client: { id: 'c1', name: 'Sarah Johnson' },
      listingId: 'listing-123',
      requiresSignature: true,
      signedAt: '2024-02-24T15:30:00Z',
      viewedByClient: true,
      viewedByAgent: true,
      clientViewedAt: '2024-02-24T14:00:00Z',
      createdAt: '2024-02-24T10:00:00Z'
    },
    {
      id: '2',
      documentName: 'Property Disclosure Statement.pdf',
      documentType: 'disclosure',
      fileUrl: '/docs/disclosure.pdf',
      fileSizeBytes: 1245800,
      uploadedBy: 'agent',
      uploaderType: 'agent',
      client: { id: 'c1', name: 'Sarah Johnson' },
      listingId: 'listing-123',
      requiresSignature: true,
      viewedByClient: true,
      viewedByAgent: true,
      clientViewedAt: '2024-02-23T16:00:00Z',
      createdAt: '2024-02-23T14:00:00Z'
    },
    {
      id: '3',
      documentName: 'Home Inspection Report - 456 Oak Ave.pdf',
      documentType: 'inspection',
      fileUrl: '/docs/inspection.pdf',
      fileSizeBytes: 5242880,
      uploadedBy: 'agent',
      uploaderType: 'agent',
      client: { id: 'c2', name: 'Michael Chen' },
      listingId: 'listing-456',
      requiresSignature: false,
      viewedByClient: true,
      viewedByAgent: true,
      clientViewedAt: '2024-02-22T10:00:00Z',
      createdAt: '2024-02-22T09:00:00Z'
    },
    {
      id: '4',
      documentName: 'Appraisal Report.pdf',
      documentType: 'appraisal',
      fileUrl: '/docs/appraisal.pdf',
      fileSizeBytes: 3145728,
      uploadedBy: 'agent',
      uploaderType: 'agent',
      client: { id: 'c2', name: 'Michael Chen' },
      requiresSignature: false,
      viewedByClient: false,
      viewedByAgent: true,
      createdAt: '2024-02-20T11:00:00Z'
    },
    {
      id: '5',
      documentName: 'Pre-approval Letter.pdf',
      documentType: 'other',
      fileUrl: '/docs/pre-approval.pdf',
      fileSizeBytes: 524288,
      uploadedBy: 'c3',
      uploaderType: 'client',
      client: { id: 'c3', name: 'Emily Davis' },
      requiresSignature: false,
      viewedByClient: true,
      viewedByAgent: true,
      createdAt: '2024-02-19T13:00:00Z'
    },
    {
      id: '6',
      documentName: 'Property Photos - 789 Pine Rd.zip',
      documentType: 'image',
      fileUrl: '/docs/photos.zip',
      fileSizeBytes: 15728640,
      uploadedBy: 'agent',
      uploaderType: 'agent',
      client: { id: 'c1', name: 'Sarah Johnson' },
      listingId: 'listing-789',
      requiresSignature: false,
      viewedByClient: true,
      viewedByAgent: true,
      clientViewedAt: '2024-02-18T12:00:00Z',
      createdAt: '2024-02-18T10:00:00Z'
    }
  ];

  const clients = Array.from(new Set(documents.map(d => d.client.id)))
    .map(id => documents.find(d => d.client.id === id)!.client);

  const filteredDocuments = documents.filter(doc => {
    const matchesSearch = doc.documentName.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesClient = selectedClient === 'all' || doc.client.id === selectedClient;
    const matchesType = selectedType === 'all' || doc.documentType === selectedType;
    return matchesSearch && matchesClient && matchesType;
  });

  const getDocumentIcon = (type: DocumentType) => {
    switch (type) {
      case 'contract':
        return <FileSignature className="w-5 h-5" />;
      case 'disclosure':
        return <FileText className="w-5 h-5" />;
      case 'inspection':
        return <File className="w-5 h-5" />;
      case 'appraisal':
        return <FileText className="w-5 h-5" />;
      case 'image':
        return <ImageIcon className="w-5 h-5" />;
      default:
        return <File className="w-5 h-5" />;
    }
  };

  const getDocumentColor = (type: DocumentType) => {
    switch (type) {
      case 'contract':
        return 'from-purple-500 to-pink-500';
      case 'disclosure':
        return 'from-blue-500 to-cyan-500';
      case 'inspection':
        return 'from-green-500 to-emerald-500';
      case 'appraisal':
        return 'from-orange-500 to-amber-500';
      case 'image':
        return 'from-pink-500 to-rose-500';
      default:
        return 'from-gray-500 to-slate-500';
    }
  };

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
              Documents
            </h1>
            <p className="text-white/60">
              Manage and share documents with your clients
            </p>
          </div>

          <button
            onClick={() => setShowUploadModal(true)}
            className="flex items-center gap-2 px-4 md:px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all"
          >
            <Upload className="w-5 h-5" />
            <span className="hidden md:inline">Upload Document</span>
            <span className="md:hidden">Upload</span>
          </button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mb-6">
          {[
            { label: 'Total', value: documents.length, icon: FileText, color: 'from-purple-500 to-pink-500' },
            { label: 'Pending Signature', value: documents.filter(d => d.requiresSignature && !d.signedAt).length, icon: FileSignature, color: 'from-yellow-500 to-orange-500' },
            { label: 'Unviewed', value: documents.filter(d => !d.viewedByClient).length, icon: Eye, color: 'from-blue-500 to-cyan-500' },
            { label: 'Signed', value: documents.filter(d => d.signedAt).length, icon: CheckCircle2, color: 'from-green-500 to-emerald-500' }
          ].map((stat) => {
            const Icon = stat.icon;
            return (
              <div
                key={stat.label}
                className="glass-strong rounded-xl p-4 border border-white/10"
              >
                <div className={`w-10 h-10 rounded-lg bg-gradient-to-br ${stat.color} flex items-center justify-center mb-3`}>
                  <Icon className="w-5 h-5 text-white" />
                </div>
                <div className="text-2xl font-bold text-white mb-1">{stat.value}</div>
                <div className="text-white/60 text-sm">{stat.label}</div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Filters */}
      <div className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="text"
              placeholder="Search documents..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
            />
          </div>

          {/* Client Filter */}
          <select
            value={selectedClient}
            onChange={(e) => setSelectedClient(e.target.value)}
            className="px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
          >
            <option value="all">All Clients</option>
            {clients.map((client) => (
              <option key={client.id} value={client.id}>
                {client.name}
              </option>
            ))}
          </select>

          {/* Type Filter */}
          <select
            value={selectedType}
            onChange={(e) => setSelectedType(e.target.value as DocumentType | 'all')}
            className="px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
          >
            <option value="all">All Types</option>
            <option value="contract">Contracts</option>
            <option value="disclosure">Disclosures</option>
            <option value="inspection">Inspections</option>
            <option value="appraisal">Appraisals</option>
            <option value="image">Images</option>
            <option value="other">Other</option>
          </select>
        </div>
      </div>

      {/* Documents Grid */}
      {filteredDocuments.length === 0 ? (
        <div className="glass-strong rounded-2xl p-12 border border-white/10 text-center">
          <FileText className="w-16 h-16 text-white/20 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-white mb-2">No documents found</h3>
          <p className="text-white/60 mb-6">
            {searchQuery ? 'Try adjusting your search' : 'Start by uploading your first document'}
          </p>
          {!searchQuery && (
            <button
              onClick={() => setShowUploadModal(true)}
              className="px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all"
            >
              Upload Document
            </button>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {filteredDocuments.map((doc, index) => (
            <motion.div
              key={doc.id}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: index * 0.05 }}
              className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 hover:border-white/20 transition-all"
            >
              <div className="flex items-start gap-4">
                {/* Icon */}
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${getDocumentColor(doc.documentType)} flex items-center justify-center flex-shrink-0`}>
                  {getDocumentIcon(doc.documentType)}
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1 min-w-0 pr-2">
                      <h3 className="text-white font-semibold text-sm mb-1 truncate">
                        {doc.documentName}
                      </h3>
                      <div className="flex items-center gap-2 flex-wrap text-xs text-white/60">
                        <span className="flex items-center gap-1">
                          <Calendar className="w-3 h-3" />
                          {formatDate(doc.createdAt)}
                        </span>
                        <span>•</span>
                        <span>{formatFileSize(doc.fileSizeBytes)}</span>
                        <span>•</span>
                        <span className="capitalize">{doc.documentType}</span>
                      </div>
                    </div>

                    {/* More Menu */}
                    <button className="w-8 h-8 rounded-lg bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all flex-shrink-0">
                      <MoreVertical className="w-4 h-4 text-white/60" />
                    </button>
                  </div>

                  {/* Client & Property */}
                  <div className="flex items-center gap-2 mb-3">
                    <div className="w-6 h-6 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                      <span className="text-white text-xs font-bold">
                        {doc.client.name.split(' ').map(n => n[0]).join('')}
                      </span>
                    </div>
                    <span className="text-white/60 text-xs">{doc.client.name}</span>
                    {doc.listingId && (
                      <>
                        <span className="text-white/40">•</span>
                        <span className="text-white/60 text-xs">Property: {doc.listingId}</span>
                      </>
                    )}
                  </div>

                  {/* Status Badges */}
                  <div className="flex items-center gap-2 flex-wrap mb-4">
                    {doc.requiresSignature && (
                      <span className={`px-2 py-1 rounded-lg text-xs font-medium flex items-center gap-1 ${
                        doc.signedAt
                          ? 'bg-green-500/20 text-green-300 border border-green-500/30'
                          : 'bg-yellow-500/20 text-yellow-300 border border-yellow-500/30'
                      }`}>
                        {doc.signedAt ? (
                          <>
                            <CheckCircle2 className="w-3 h-3" />
                            Signed
                          </>
                        ) : (
                          <>
                            <Clock className="w-3 h-3" />
                            Awaiting Signature
                          </>
                        )}
                      </span>
                    )}

                    <span className={`px-2 py-1 rounded-lg text-xs font-medium flex items-center gap-1 ${
                      doc.viewedByClient
                        ? 'bg-blue-500/20 text-blue-300 border border-blue-500/30'
                        : 'bg-orange-500/20 text-orange-300 border border-orange-500/30'
                    }`}>
                      <Eye className="w-3 h-3" />
                      {doc.viewedByClient ? 'Viewed by client' : 'Not viewed'}
                    </span>

                    <span className={`px-2 py-1 rounded-lg text-xs font-medium ${
                      doc.uploaderType === 'agent'
                        ? 'bg-purple-500/20 text-purple-300'
                        : 'bg-white/10 text-white/60'
                    }`}>
                      {doc.uploaderType === 'agent' ? 'You uploaded' : 'Client uploaded'}
                    </span>
                  </div>

                  {/* Actions */}
                  <div className="flex gap-2">
                    <button className="flex-1 flex items-center justify-center gap-2 px-3 py-2 rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
                      <Eye className="w-4 h-4" />
                      View
                    </button>
                    <button className="flex-1 flex items-center justify-center gap-2 px-3 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                      <Download className="w-4 h-4" />
                      Download
                    </button>
                    <button className="px-3 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white border border-white/10 transition-all">
                      <Share2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Upload Modal - Placeholder */}
      {showUploadModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="glass-strong rounded-2xl p-6 md:p-8 border border-white/10 max-w-md w-full"
          >
            <h2 className="text-2xl font-bold text-white mb-4">Upload Document</h2>
            <p className="text-white/60 mb-6">
              Share a document with one of your clients. They'll be notified when you upload.
            </p>

            <div className="space-y-4 mb-6">
              <div>
                <label className="block text-white text-sm font-medium mb-2">
                  Select Client
                </label>
                <select className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50">
                  <option value="">Choose a client...</option>
                  {clients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-white text-sm font-medium mb-2">
                  Document Type
                </label>
                <select className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50">
                  <option value="contract">Contract</option>
                  <option value="disclosure">Disclosure</option>
                  <option value="inspection">Inspection Report</option>
                  <option value="appraisal">Appraisal</option>
                  <option value="image">Images</option>
                  <option value="other">Other</option>
                </select>
              </div>

              <div>
                <label className="block text-white text-sm font-medium mb-2">
                  File
                </label>
                <div className="border-2 border-dashed border-white/20 rounded-xl p-8 text-center hover:border-purple-500/50 transition-all cursor-pointer">
                  <Upload className="w-8 h-8 text-white/40 mx-auto mb-2" />
                  <p className="text-white/60 text-sm">
                    Click to upload or drag and drop
                  </p>
                  <p className="text-white/40 text-xs mt-1">
                    PDF, DOC, DOCX, JPG, PNG up to 50MB
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="requireSignature"
                  className="w-4 h-4 rounded bg-white/5 border-white/20"
                />
                <label htmlFor="requireSignature" className="text-white text-sm">
                  Requires client signature
                </label>
              </div>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => setShowUploadModal(false)}
                className="flex-1 px-4 py-3 rounded-xl bg-white/5 hover:bg-white/10 text-white font-semibold border border-white/10 transition-all"
              >
                Cancel
              </button>
              <button className="flex-1 px-4 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
                Upload
              </button>
            </div>
          </motion.div>
        </div>
      )}
    </div>
  );
}
