-- Documents Table with X-Ray Extraction Support
-- Stores user documents with extracted structured data

CREATE TABLE IF NOT EXISTS user_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- File information
  file_name VARCHAR(500) NOT NULL,
  file_url TEXT NOT NULL,
  file_size BIGINT, -- Size in bytes
  mime_type VARCHAR(100),

  -- Document classification
  document_type VARCHAR(50) NOT NULL CHECK (document_type IN (
    'lease',
    'inspection',
    'pre-approval',
    'insurance',
    'identification',
    'paystub',
    'bank-statement',
    'other'
  )),

  -- X-Ray extraction data
  extracted_data JSONB, -- Structured data extracted from document
  extraction_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (extraction_status IN (
    'pending',
    'processing',
    'completed',
    'failed'
  )),
  extraction_confidence DECIMAL(3, 2), -- 0.00 to 1.00
  extraction_error TEXT,
  extracted_at TIMESTAMPTZ,

  -- View mode for X-Ray display
  view_mode VARCHAR(20) CHECK (view_mode IN ('executive', 'card', 'digest')),

  -- Organization
  category VARCHAR(100), -- e.g., "Leases", "Financial", "ID & Verification"
  tags TEXT[], -- Array of tags for search/filtering

  -- Related entities
  related_listing_id UUID REFERENCES listings(id) ON DELETE SET NULL,
  related_tour_id UUID,

  -- Agent collaboration
  shared_with_agent BOOLEAN DEFAULT FALSE,
  agent_comments JSONB, -- Array of agent comments

  -- Status
  is_archived BOOLEAN DEFAULT FALSE,
  is_favorite BOOLEAN DEFAULT FALSE,

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Indexes
  CONSTRAINT unique_user_file UNIQUE(user_id, file_name, created_at)
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_user_documents_user_id ON user_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_type ON user_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_user_documents_status ON user_documents(extraction_status);
CREATE INDEX IF NOT EXISTS idx_user_documents_created ON user_documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_documents_category ON user_documents(category);
CREATE INDEX IF NOT EXISTS idx_user_documents_listing ON user_documents(related_listing_id);

-- GIN index for JSONB extraction data (for querying inside JSON)
CREATE INDEX IF NOT EXISTS idx_user_documents_extracted_data ON user_documents USING GIN (extracted_data);

-- GIN index for tags array
CREATE INDEX IF NOT EXISTS idx_user_documents_tags ON user_documents USING GIN (tags);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_documents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS trigger_user_documents_updated_at ON user_documents;
CREATE TRIGGER trigger_user_documents_updated_at
  BEFORE UPDATE ON user_documents
  FOR EACH ROW
  EXECUTE FUNCTION update_user_documents_updated_at();

-- Function to get documents by category
CREATE OR REPLACE FUNCTION get_documents_by_category(p_user_id UUID, p_category VARCHAR)
RETURNS TABLE (
  id UUID,
  file_name VARCHAR(500),
  file_url TEXT,
  document_type VARCHAR(50),
  extracted_data JSONB,
  extraction_status VARCHAR(20),
  view_mode VARCHAR(20),
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    d.id,
    d.file_name,
    d.file_url,
    d.document_type,
    d.extracted_data,
    d.extraction_status,
    d.view_mode,
    d.created_at
  FROM user_documents d
  WHERE d.user_id = p_user_id
    AND d.category = p_category
    AND d.is_archived = FALSE
  ORDER BY d.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to search documents
CREATE OR REPLACE FUNCTION search_documents(
  p_user_id UUID,
  p_search_query TEXT
)
RETURNS TABLE (
  id UUID,
  file_name VARCHAR(500),
  document_type VARCHAR(50),
  extracted_data JSONB,
  relevance REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    d.id,
    d.file_name,
    d.document_type,
    d.extracted_data,
    ts_rank(
      to_tsvector('english', d.file_name || ' ' || COALESCE(d.extracted_data::text, '')),
      plainto_tsquery('english', p_search_query)
    ) AS relevance
  FROM user_documents d
  WHERE d.user_id = p_user_id
    AND d.is_archived = FALSE
    AND (
      d.file_name ILIKE '%' || p_search_query || '%'
      OR d.extracted_data::text ILIKE '%' || p_search_query || '%'
      OR p_search_query = ANY(d.tags)
    )
  ORDER BY relevance DESC, d.created_at DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Function to get documents requiring action
CREATE OR REPLACE FUNCTION get_documents_requiring_action(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  file_name VARCHAR(500),
  document_type VARCHAR(50),
  extracted_data JSONB,
  urgency VARCHAR(20)
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    d.id,
    d.file_name,
    d.document_type,
    d.extracted_data,
    CASE
      WHEN d.extraction_status = 'failed' THEN 'high'
      WHEN d.extraction_status = 'pending' THEN 'medium'
      WHEN d.agent_comments IS NOT NULL AND jsonb_array_length(d.agent_comments) > 0 THEN 'medium'
      ELSE 'low'
    END AS urgency
  FROM user_documents d
  WHERE d.user_id = p_user_id
    AND d.is_archived = FALSE
    AND (
      d.extraction_status IN ('pending', 'failed')
      OR (d.agent_comments IS NOT NULL AND jsonb_array_length(d.agent_comments) > 0)
    )
  ORDER BY
    CASE
      WHEN d.extraction_status = 'failed' THEN 1
      WHEN d.extraction_status = 'pending' THEN 2
      ELSE 3
    END,
    d.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Enable RLS
ALTER TABLE user_documents ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own documents"
  ON user_documents FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own documents"
  ON user_documents FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own documents"
  ON user_documents FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own documents"
  ON user_documents FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON user_documents TO authenticated;
GRANT EXECUTE ON FUNCTION get_documents_by_category(UUID, VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION search_documents(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_documents_requiring_action(UUID) TO authenticated;

-- Create default categories view
CREATE OR REPLACE VIEW document_categories AS
SELECT DISTINCT
  user_id,
  category,
  COUNT(*) as document_count
FROM user_documents
WHERE is_archived = FALSE
GROUP BY user_id, category;

GRANT SELECT ON document_categories TO authenticated;
