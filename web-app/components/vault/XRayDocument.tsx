'use client';

import { ExtractedData, ViewMode } from '@/types/documents';
import ExecutiveView from './ExecutiveView';
import CardView from './CardView';
import DigestView from './DigestView';

interface XRayDocumentProps {
  data: ExtractedData;
  viewMode?: ViewMode;
  securityWarnings?: string[];
  onViewOriginal?: () => void;
}

/**
 * Master X-Ray Document component that routes to the appropriate view
 * based on the document type and view mode
 */
export default function XRayDocument({ data, viewMode, securityWarnings, onViewOriginal }: XRayDocumentProps) {
  // Determine view mode from data type if not explicitly provided
  const effectiveViewMode = viewMode || getViewModeFromType(data.type);

  return (
    <div className="space-y-4">
      {/* Security Warnings Banner */}
      {securityWarnings && securityWarnings.length > 0 && (
        <div className="bg-red-500/20 border-2 border-red-500 rounded-xl p-4">
          <div className="flex items-start gap-3">
            <div className="text-3xl flex-shrink-0">🔒</div>
            <div className="flex-1">
              <h3 className="text-lg font-bold text-red-400 mb-2">Security Alert</h3>
              <div className="space-y-2">
                {securityWarnings.map((warning, index) => (
                  <p key={index} className="text-white/90 text-sm leading-relaxed">
                    {warning}
                  </p>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Document View */}
      {effectiveViewMode === 'executive' ? (
        <ExecutiveView data={data as any} onViewOriginal={onViewOriginal} />
      ) : effectiveViewMode === 'card' ? (
        <CardView data={data as any} onViewOriginal={onViewOriginal} />
      ) : (
        <DigestView data={data as any} onViewOriginal={onViewOriginal} />
      )}
    </div>
  );
}

/**
 * Helper function to determine view mode from document type
 */
function getViewModeFromType(type: string): ViewMode {
  switch (type) {
    case 'lease':
    case 'paystub':
    case 'bank-statement':
      return 'executive';

    case 'inspection':
    case 'identification':
      return 'card';

    case 'pre-approval':
    case 'insurance':
    case 'other':
    default:
      return 'digest';
  }
}
