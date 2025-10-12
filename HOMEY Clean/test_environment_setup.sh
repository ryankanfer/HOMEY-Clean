#!/bin/bash

# Test Environment Setup Script
# This script sets up the test environment and runs comprehensive system tests

set -e  # Exit on any error

echo "🚀 Setting up Test Environment for HOMEY Clean System"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required environment variables are set
check_env_vars() {
    print_status "Checking environment variables..."
    
    local missing_vars=()
    
    if [ -z "$SUPABASE_URL" ]; then
        missing_vars+=("SUPABASE_URL")
    fi
    
    if [ -z "$SUPABASE_ANON_KEY" ]; then
        missing_vars+=("SUPABASE_ANON_KEY")
    fi
    
    if [ -z "$SUPABASE_SERVICE_KEY" ]; then
        missing_vars+=("SUPABASE_SERVICE_KEY")
    fi
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "Please set these variables in your environment or create a .env file:"
        echo "export SUPABASE_URL='https://your-project.supabase.co'"
        echo "export SUPABASE_ANON_KEY='your-anon-key'"
        echo "export SUPABASE_SERVICE_KEY='your-service-key'"
        exit 1
    fi
    
    print_success "All required environment variables are set"
}

# Check if Python is installed
check_python() {
    print_status "Checking Python installation..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3.8 or higher."
        exit 1
    fi
    
    python_version=$(python3 --version | cut -d' ' -f2)
    print_success "Python $python_version is installed"
}

# Install required Python packages
install_dependencies() {
    print_status "Installing Python dependencies..."
    
    # Create requirements.txt if it doesn't exist
    if [ ! -f "requirements.txt" ]; then
        print_status "Creating requirements.txt..."
        cat > requirements.txt << EOF
requests>=2.28.0
python-dotenv>=0.19.0
asyncio
logging
uuid
datetime
typing
json
os
time
EOF
    fi
    
    # Install dependencies
    python3 -m pip install --upgrade pip
    python3 -m pip install -r requirements.txt
    
    print_success "Dependencies installed successfully"
}

# Load environment variables from .env file if it exists
load_env_file() {
    if [ -f ".env" ]; then
        print_status "Loading environment variables from .env file..."
        export $(cat .env | grep -v '^#' | xargs)
        print_success "Environment variables loaded from .env file"
    fi
}

# Execute SQL migration files
run_sql_migrations() {
    print_status "Checking SQL migration files..."
    
    local sql_files=(
        "fix_existing_table_rls_policies.sql"
        "create_missing_tables.sql"
        "unified_profiles_migration.sql"
        "agent_invitation_system.sql"
        "document_management_supabase.sql"
        "secure_messaging_system.sql"
    )
    
    local missing_files=()
    
    for file in "${sql_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        print_warning "Some SQL migration files are missing:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        print_warning "Please ensure all SQL files are present before running tests"
    else
        print_success "All SQL migration files are present"
    fi
    
    print_status "Note: SQL files should be executed in your Supabase dashboard or via psql"
    echo "Execution order:"
    for i in "${!sql_files[@]}"; do
        echo "  $((i+1)). ${sql_files[$i]}"
    done
}

# Run comprehensive system tests
run_tests() {
    print_status "Running comprehensive system tests..."
    
    if [ ! -f "comprehensive_system_test.py" ]; then
        print_error "comprehensive_system_test.py not found!"
        exit 1
    fi
    
    # Make the test file executable
    chmod +x comprehensive_system_test.py
    
    # Run the tests
    python3 comprehensive_system_test.py
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        print_success "All tests completed successfully!"
    else
        print_error "Some tests failed. Please check the output above."
        exit $exit_code
    fi
}

# Create a sample .env file
create_sample_env() {
    if [ ! -f ".env.example" ]; then
        print_status "Creating .env.example file..."
        cat > .env.example << EOF
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here

# Test Configuration
TEST_MODE=true
LOG_LEVEL=INFO
EOF
        print_success ".env.example created. Copy it to .env and fill in your values."
    fi
}

# Generate test report
generate_test_report() {
    print_status "Generating test report..."
    
    local report_file="test_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# HOMEY Clean System Test Report

**Generated:** $(date)
**Environment:** Test
**Test Suite:** Comprehensive System Tests

## Test Environment

- **Supabase URL:** ${SUPABASE_URL:-"Not set"}
- **Python Version:** $(python3 --version)
- **Test Runner:** comprehensive_system_test.py

## Test Categories

1. **User Registration and Onboarding**
   - Agent registration with company information
   - Client registration
   - Profile creation and validation

2. **Agent Invitation System**
   - Invitation code generation
   - Code validation and usage
   - Agent-client relationship establishment

3. **Document Management**
   - Document creation and storage
   - Document sharing and permissions
   - Document retrieval and access control

4. **Secure Messaging System**
   - Message sending and receiving
   - Message threading and replies
   - Read receipts and reactions

5. **Row-Level Security (RLS)**
   - Profile access isolation
   - Message access control
   - Document permission enforcement

6. **Agent-Client Relationships**
   - Relationship management
   - Client and agent listing
   - Link verification

7. **User Preferences**
   - Preference creation and retrieval
   - Preference management

8. **Analytics and Reporting**
   - Messaging analytics
   - Document analytics
   - Invitation analytics

## Test Results

See console output for detailed test results.

## Next Steps

1. Review any failed tests
2. Fix identified issues
3. Re-run tests until all pass
4. Deploy to production environment

---
*Generated by HOMEY Clean Test Suite*
EOF

    print_success "Test report generated: $report_file"
}

# Main execution
main() {
    echo ""
    print_status "Starting test environment setup..."
    
    # Load environment variables
    load_env_file
    
    # Run setup steps
    check_env_vars
    check_python
    install_dependencies
    create_sample_env
    run_sql_migrations
    
    echo ""
    print_status "Environment setup complete!"
    echo ""
    
    # Ask user if they want to run tests
    read -p "Do you want to run the comprehensive tests now? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        run_tests
        generate_test_report
    else
        print_status "Tests skipped. You can run them later with:"
        echo "python3 comprehensive_system_test.py"
    fi
    
    echo ""
    print_success "Setup complete! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Execute the SQL migration files in your Supabase dashboard"
    echo "2. Run the comprehensive tests: python3 comprehensive_system_test.py"
    echo "3. Review test results and fix any issues"
    echo "4. Update your frontend code to use the new schema"
}

# Run main function
main "$@"