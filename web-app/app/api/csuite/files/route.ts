import { NextRequest, NextResponse } from 'next/server';
import { readdir, readFile, stat } from 'fs/promises';
import { join, relative, extname } from 'path';
// Force dynamic rendering to avoid build-time errors
export const dynamic = 'force-dynamic';


/**
 * API endpoint for C-Suite to read code files from the web-app
 * Supports searching and reading files
 */

const WEB_APP_ROOT = process.cwd();

// File types to exclude from search
const EXCLUDED_DIRS = [
  'node_modules',
  '.next',
  '.git',
  'dist',
  'build',
  '.vercel',
  'coverage',
];

const EXCLUDED_EXTENSIONS = [
  '.map',
  '.lock',
  '.log',
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.svg',
  '.ico',
  '.woff',
  '.woff2',
  '.ttf',
  '.eot',
];

/**
 * Recursively search for files matching a query
 */
async function searchFiles(dir: string, query: string, results: string[] = []): Promise<string[]> {
  const entries = await readdir(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = join(dir, entry.name);
    const relativePath = relative(WEB_APP_ROOT, fullPath);

    // Skip excluded directories
    if (entry.isDirectory()) {
      if (EXCLUDED_DIRS.includes(entry.name)) {
        continue;
      }
      await searchFiles(fullPath, query, results);
    } else {
      // Skip excluded file types
      const ext = extname(entry.name);
      if (EXCLUDED_EXTENSIONS.includes(ext)) {
        continue;
      }

      // Check if filename matches query (case-insensitive)
      if (entry.name.toLowerCase().includes(query.toLowerCase()) ||
          relativePath.toLowerCase().includes(query.toLowerCase())) {
        results.push(relativePath);
      }
    }
  }

  return results;
}

/**
 * Read file content
 */
async function readFileContent(filePath: string) {
  const absolutePath = join(WEB_APP_ROOT, filePath);

  // Security check: ensure path is within web-app directory
  const resolvedPath = relative(WEB_APP_ROOT, absolutePath);
  if (resolvedPath.startsWith('..')) {
    throw new Error('Invalid file path');
  }

  const content = await readFile(absolutePath, 'utf-8');
  const stats = await stat(absolutePath);
  const lines = content.split('\n');
  const ext = extname(filePath).slice(1); // Remove leading dot

  return {
    path: filePath,
    content,
    lineCount: lines.length,
    size: stats.size,
    fileType: ext || 'txt',
  };
}

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = searchParams.get('q');
    const path = searchParams.get('path');

    let responseData;
    let status = 200;

    // Search for files
    if (query) {
      const files = await searchFiles(WEB_APP_ROOT, query);
      responseData = {
        files: files.slice(0, 50), // Limit to 50 results
        count: files.length,
        query,
      };
    }
    // Read specific file
    else if (path) {
      responseData = await readFileContent(path);
    }
    // Invalid request
    else {
      responseData = { error: 'Please provide either q (query) or path parameter' };
      status = 400;
    }

    // Return with CORS headers
    return NextResponse.json(responseData, {
      status,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });

  } catch (error: any) {
    console.error('File API error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to process request' },
      {
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      }
    );
  }
}

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}
