-- Migration to fix user_preferences table
-- This adds ALL missing columns that the onboarding trigger expects

-- First, check if the table exists and add missing columns
DO $$
BEGIN
    -- CRITICAL COLUMNS FOR ONBOARDING TRIGGER (from profiles_schema.sql)

    -- Add location column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'location'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN location TEXT;
        RAISE NOTICE 'Added location column to user_preferences';
    END IF;

    -- Add neighborhoods column (array of text)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'neighborhoods'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN neighborhoods TEXT[];
        RAISE NOTICE 'Added neighborhoods column to user_preferences';
    END IF;

    -- Add property_types column (array of text)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'property_types'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN property_types TEXT[];
        RAISE NOTICE 'Added property_types column to user_preferences';
    END IF;

    -- Add user_type column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'user_type'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN user_type TEXT;
        RAISE NOTICE 'Added user_type column to user_preferences';
    END IF;

    -- Add has_agent column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'has_agent'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN has_agent BOOLEAN;
        RAISE NOTICE 'Added has_agent column to user_preferences';
    END IF;

    -- Add min_price column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'min_price'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN min_price DECIMAL(12, 2);
        RAISE NOTICE 'Added min_price column to user_preferences';
    END IF;

    -- Add max_price column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'max_price'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN max_price DECIMAL(12, 2);
        RAISE NOTICE 'Added max_price column to user_preferences';
    END IF;

    -- Add bedrooms column (array of integers)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'bedrooms'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN bedrooms INTEGER[];
        RAISE NOTICE 'Added bedrooms column to user_preferences';
    END IF;

    -- Add bathrooms column (array of decimals)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'bathrooms'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN bathrooms DECIMAL(3,1)[];
        RAISE NOTICE 'Added bathrooms column to user_preferences';
    END IF;

    -- SWIPE TRACKING COLUMNS

    -- Add total_swipes if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'total_swipes'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN total_swipes INTEGER DEFAULT 0;
    END IF;

    -- Add total_likes if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'total_likes'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN total_likes INTEGER DEFAULT 0;
    END IF;

    -- Add total_loves if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'total_loves'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN total_loves INTEGER DEFAULT 0;
    END IF;

    -- Add avg_price_swiped_right if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_preferences' AND column_name = 'avg_price_swiped_right'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN avg_price_swiped_right DECIMAL(12, 2);
    END IF;
END $$;

-- Verify the columns were added
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'user_preferences'
ORDER BY ordinal_position;
