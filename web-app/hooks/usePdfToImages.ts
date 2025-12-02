import { useState, useCallback } from 'react';

let pdfjsLib: any = null;

interface ConversionProgress {
  currentPage: number;
  totalPages: number;
  status: 'idle' | 'converting' | 'completed' | 'error';
  error?: string;
}

export function usePdfToImages() {
  const [progress, setProgress] = useState<ConversionProgress>({
    currentPage: 0,
    totalPages: 0,
    status: 'idle',
  });

  const convertPdfToImages = useCallback(
    async (file: File): Promise<File[]> => {
      setProgress({ currentPage: 0, totalPages: 0, status: 'converting' });

      try {
        // Dynamically import PDF.js (client-side only)
        if (!pdfjsLib) {
          pdfjsLib = await import('pdfjs-dist');
          pdfjsLib.GlobalWorkerOptions.workerSrc = `//cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjsLib.version}/pdf.worker.min.js`;
        }

        // Read file as ArrayBuffer
        const arrayBuffer = await file.arrayBuffer();
        const data = new Uint8Array(arrayBuffer);

        // Load PDF document
        const loadingTask = pdfjsLib.getDocument({ data });
        const pdf = await loadingTask.promise;

        const totalPages = Math.min(pdf.numPages, 10); // Max 10 pages
        setProgress({ currentPage: 0, totalPages, status: 'converting' });

        const imageFiles: File[] = [];

        // Convert each page to image
        for (let pageNum = 1; pageNum <= totalPages; pageNum++) {
          setProgress((prev) => ({ ...prev, currentPage: pageNum }));

          const page = await pdf.getPage(pageNum);

          // Set scale for high quality (2.0 = 2x resolution)
          const viewport = page.getViewport({ scale: 2.0 });

          // Create canvas
          const canvas = document.createElement('canvas');
          const context = canvas.getContext('2d');
          if (!context) {
            throw new Error('Failed to get canvas context');
          }

          canvas.height = viewport.height;
          canvas.width = viewport.width;

          // Render PDF page to canvas
          await page.render({
            canvasContext: context,
            viewport: viewport,
          }).promise;

          // Convert canvas to blob
          const blob = await new Promise<Blob>((resolve, reject) => {
            canvas.toBlob(
              (blob) => {
                if (blob) resolve(blob);
                else reject(new Error('Failed to convert canvas to blob'));
              },
              'image/png',
              0.95
            );
          });

          // Create File from blob
          const imageFile = new File(
            [blob],
            `${file.name.replace('.pdf', '')}_page_${pageNum}.png`,
            { type: 'image/png' }
          );

          imageFiles.push(imageFile);
        }

        setProgress({ currentPage: totalPages, totalPages, status: 'completed' });
        return imageFiles;
      } catch (error) {
        const errorMessage =
          error instanceof Error ? error.message : 'Unknown error';
        setProgress({ currentPage: 0, totalPages: 0, status: 'error', error: errorMessage });
        throw error;
      }
    },
    []
  );

  const reset = useCallback(() => {
    setProgress({ currentPage: 0, totalPages: 0, status: 'idle' });
  }, []);

  return {
    convertPdfToImages,
    progress,
    reset,
    isConverting: progress.status === 'converting',
  };
}
