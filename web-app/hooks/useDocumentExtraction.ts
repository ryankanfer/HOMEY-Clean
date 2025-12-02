import { useState, useCallback } from 'react';
import {
  DocumentType,
  ExtractedData,
  ViewMode,
  DocumentExtractionResponse,
} from '@/types/documents';
import { supabase } from '@/lib/supabase';

interface ExtractionState {
  isProcessing: boolean;
  progress: number; // 0-100
  error: string | null;
  result: DocumentExtractionResponse | null;
}

export function useDocumentExtraction() {
  const [state, setState] = useState<ExtractionState>({
    isProcessing: false,
    progress: 0,
    error: null,
    result: null,
  });

  /**
   * Extract data from a document
   */
  const extractDocument = useCallback(
    async (fileUrl: string, fileName: string, documentId?: string) => {
      setState({
        isProcessing: true,
        progress: 10,
        error: null,
        result: null,
      });

      try {
        // Get auth token
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) {
          throw new Error('Not authenticated');
        }

        // Simulate progress during processing
        const progressInterval = setInterval(() => {
          setState((prev) => ({
            ...prev,
            progress: Math.min(prev.progress + 5, 90),
          }));
        }, 500);

        const response = await fetch('/api/documents/extract', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
          },
          body: JSON.stringify({
            fileUrl,
            fileName,
            documentId,
          }),
        });

        clearInterval(progressInterval);

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Failed to extract document');
        }

        const result: DocumentExtractionResponse = await response.json();

        setState({
          isProcessing: false,
          progress: 100,
          error: null,
          result,
        });

        return result;
      } catch (error) {
        const errorMessage =
          error instanceof Error ? error.message : 'Unknown error occurred';

        setState({
          isProcessing: false,
          progress: 0,
          error: errorMessage,
          result: null,
        });

        throw error;
      }
    },
    []
  );

  /**
   * Reset the extraction state
   */
  const reset = useCallback(() => {
    setState({
      isProcessing: false,
      progress: 0,
      error: null,
      result: null,
    });
  }, []);

  return {
    ...state,
    extractDocument,
    reset,
  };
}

/**
 * Hook for batch document extraction
 */
export function useBatchDocumentExtraction() {
  const [documents, setDocuments] = useState<
    Map<string, ExtractionState & { fileName: string }>
  >(new Map());

  const extractDocuments = useCallback(
    async (
      files: Array<{ id: string; fileUrl: string; fileName: string }>
    ) => {
      // Initialize all documents
      const newDocuments = new Map(documents);
      files.forEach((file) => {
        newDocuments.set(file.id, {
          fileName: file.fileName,
          isProcessing: true,
          progress: 0,
          error: null,
          result: null,
        });
      });
      setDocuments(newDocuments);

      // Process documents in parallel (with limit)
      const CONCURRENT_LIMIT = 3; // Process 3 at a time
      const results: Array<{
        id: string;
        result?: DocumentExtractionResponse;
        error?: string;
      }> = [];

      for (let i = 0; i < files.length; i += CONCURRENT_LIMIT) {
        const batch = files.slice(i, i + CONCURRENT_LIMIT);

        const batchPromises = batch.map(async (file) => {
          try {
            // Get auth token
            const { data: { session } } = await supabase.auth.getSession();
            if (!session) {
              throw new Error('Not authenticated');
            }

            const response = await fetch('/api/documents/extract', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${session.access_token}`,
              },
              body: JSON.stringify({
                fileUrl: file.fileUrl,
                fileName: file.fileName,
                documentId: file.id,
              }),
            });

            if (!response.ok) {
              const errorData = await response.json();
              throw new Error(errorData.error || 'Failed to extract document');
            }

            const result: DocumentExtractionResponse = await response.json();

            // Update state
            setDocuments((prev) => {
              const updated = new Map(prev);
              updated.set(file.id, {
                fileName: file.fileName,
                isProcessing: false,
                progress: 100,
                error: null,
                result,
              });
              return updated;
            });

            return { id: file.id, result };
          } catch (error) {
            const errorMessage =
              error instanceof Error ? error.message : 'Unknown error';

            // Update state with error
            setDocuments((prev) => {
              const updated = new Map(prev);
              updated.set(file.id, {
                fileName: file.fileName,
                isProcessing: false,
                progress: 0,
                error: errorMessage,
                result: null,
              });
              return updated;
            });

            return { id: file.id, error: errorMessage };
          }
        });

        const batchResults = await Promise.all(batchPromises);
        results.push(...batchResults);
      }

      return results;
    },
    [documents]
  );

  const reset = useCallback(() => {
    setDocuments(new Map());
  }, []);

  return {
    documents: Array.from(documents.entries()).map(([id, state]) => ({
      id,
      ...state,
    })),
    extractDocuments,
    reset,
  };
}
