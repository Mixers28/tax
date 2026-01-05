# Getting Started - Running the Tax Helper Locally

This guide walks you through running the complete application with all components (Web App, Database, Encryption, LLM).

---

## TL;DR - Fast Setup (10 minutes)

```bash
# 1. Clone/navigate to repo
cd tax/web

# 2. Install dependencies
bundle install

# 3. Set encryption keys (generate new ones)
export AR_ENCRYPTION_PRIMARY_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")
export AR_ENCRYPTION_DETERMINISTIC_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")
export AR_ENCRYPTION_KEY_DERIVATION_SALT=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(16))")
export ACTIVE_STORAGE_ENCRYPTION_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")
export ACTIVE_STORAGE_ENCRYPTION_SALT=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(16))")

# 4. Setup database
rails db:create db:migrate

# 5. Start Ollama (Terminal 1)
ollama serve

# 6. Pull LLM model (Terminal 2)
ollama pull gemma3:1b

# 7. Start Rails app (Terminal 3)
rails server

# 8. Open browser
open http://localhost:3000
```

---

## Prerequisites

### Required Software

- **Ruby 3.3+**
  ```bash
  ruby --version
  # Should output: ruby 3.3.x (x >= 0)
  ```

- **Bundler**
  ```bash
  gem install bundler
  bundler --version
  ```

- **SQLite3**
  ```bash
  sqlite3 --version
  # Should output: 3.x.x
  ```

- **Ollama** (for PDF extraction)
  ```bash
  # Download from https://ollama.ai
  ollama --version
  ```

### System Requirements

- **Disk Space:** 4GB (for Ollama model)
- **RAM:** 4GB minimum (8GB recommended)
- **Network:** Internet only needed for initial gem install and Ollama model download

### Optional Tools

- **Git** (for version control)
- **VS Code** (recommended editor)
- **Docker** (for containerized deployment)

---

## Step 1: Setup Environment

### 1.1 Clone or Navigate to Project

```bash
# If you have the repo
cd tax/web

# Or clone if needed
git clone <repo-url>
cd tax/web
```

### 1.2 Check Ruby Version

```bash
ruby --version
# Expected: ruby 3.3.x or higher

# If not installed, install with:
# - rbenv: brew install rbenv && rbenv install 3.3.0
# - rvm: rvm install 3.3.0
# - asdf: asdf install ruby 3.3.0
```

### 1.3 Install Gems

```bash
bundle install
# Downloads and installs all dependencies

# First time may take a few minutes
# Installs: Rails, Prawn (PDF), bcrypt, Active Record, etc.
```

### 1.4 Generate Encryption Keys

**IMPORTANT:** These keys encrypt all sensitive data. Keep them secure!

```bash
# Generate all 5 required keys
export AR_ENCRYPTION_PRIMARY_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")

export AR_ENCRYPTION_DETERMINISTIC_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")

export AR_ENCRYPTION_KEY_DERIVATION_SALT=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(16))")

export ACTIVE_STORAGE_ENCRYPTION_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")

export ACTIVE_STORAGE_ENCRYPTION_SALT=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(16))")

# Verify they're set
echo $AR_ENCRYPTION_PRIMARY_KEY
```

**For Development:** You can add these to a `.env` file:

```bash
# Create .env file
cat > .env << 'EOF'
AR_ENCRYPTION_PRIMARY_KEY=<generated_key>
AR_ENCRYPTION_DETERMINISTIC_KEY=<generated_key>
AR_ENCRYPTION_KEY_DERIVATION_SALT=<generated_salt>
ACTIVE_STORAGE_ENCRYPTION_KEY=<generated_key>
ACTIVE_STORAGE_ENCRYPTION_SALT=<generated_salt>
EOF

# Use with gem 'dotenv'
source .env
```

---

## Step 2: Setup Database

### 2.1 Create Database

```bash
cd web

# Create SQLite database
rails db:create

# Expected output: Created database 'db/development.sqlite3'
```

### 2.2 Run Migrations

```bash
# Run all migrations to setup schema
rails db:migrate

# Expected output: Multiple migration files run (20+ migrations)
```

### 2.3 Verify Database

```bash
# Check database was created
ls -lh db/development.sqlite3
# Expected: File size ~200KB

# Or check with Rails
rails db:version
# Expected: Current version: <latest_migration_timestamp>
```

---

## Step 3: Setup Ollama (LLM)

### 3.1 Install Ollama

```bash
# Download from https://ollama.ai
# Or on macOS:
brew install ollama

# Or on Linux:
curl https://ollama.ai/install.sh | sh

# Verify installation
ollama --version
```

### 3.2 Start Ollama Service

**Terminal 1 (Keep Running):**
```bash
ollama serve

# Expected output:
# time=2024-01-05T10:00:00.000Z level=INFO msg="Listening on 127.0.0.1:11434"
```

### 3.3 Pull LLM Model

**Terminal 2 (New terminal, keep Terminal 1 running):**
```bash
ollama pull gemma3:1b

# Expected output:
# pulling manifest
# pulling e50d48e9f1d7...
# ...
# success
```

**Note:** First time takes 5-10 minutes (3.5GB download)

### 3.4 Verify Ollama

```bash
# Check model is available
ollama list
# Expected: gemma3:1b (3.5GB)

# Test API
curl http://localhost:11434/api/tags
# Expected: JSON response with models
```

**Keep `ollama serve` running for the app to work!**

---

## Step 4: Run Rails Application

### 4.1 Start Rails Server

**Terminal 3 (New terminal, keep Terminal 1 & 2 running):**
```bash
cd tax/web

# Set environment variables (if not in .env)
export AR_ENCRYPTION_PRIMARY_KEY="..."
export RAILS_ENV=development

# Start Rails server
rails server

# Or short form:
rails s

# Expected output:
# => Booting Puma
# => Rails 8.1.1 application starting in development
# => Listening on http://127.0.0.1:3000
```

### 4.2 Access Application

**Terminal 4 (Or browser):**
```bash
# Open browser to app
open http://localhost:3000

# Or use curl to test
curl http://localhost:3000/
# Expected: HTML response or redirect to login
```

---

## Step 5: Create Your First Tax Return

### 5.1 Login

1. Navigate to http://localhost:3000
2. Should see login page
3. Create account or login with test credentials:
   ```
   Email: test@local.test
   Password: TestPassword123
   ```

### 5.2 Create Tax Return

1. Click "Create New Tax Return" or equivalent button
2. Select tax year: "2024-25"
3. System creates draft return

### 5.3 Upload Evidence

1. Click "Upload Evidence"
2. Select a PDF file (tax documents, receipts, etc.)
3. File is encrypted and stored locally

### 5.4 Extract Data from PDF

1. Select uploaded evidence
2. Click "Extract" button
3. App sends PDF to local Ollama
4. LLM suggests values (1.1B parameter model)
5. Review and accept/reject suggestions

### 5.5 Run Validations

1. Click "Validations" tab
2. See completeness checks
3. See confidence scores on extracted values

### 5.6 Calculate Tax Reliefs

1. Enter or verify box values
2. Click "Calculations"
3. System calculates:
   - FTCR (50% rental relief)
   - Gift Aid (25/75 gross-up)
   - HICBC (child benefit charge)

### 5.7 Generate Export

1. Click "Generate Export"
2. Choose format: PDF, JSON, or Both
3. System creates export with:
   - All box values
   - Validation status
   - Calculation results
   - Evidence references
4. Download PDF or JSON

---

## Running Tests

### Test All Components

```bash
cd web

# Run all tests
rails test

# Expected: 70+ tests passing

# Or run specific test suites
rails test test/services/              # Service tests
rails test test/controllers/           # Controller tests
rails test test/integration/           # Integration tests
```

### Run Offline Workflow Test

```bash
# Verify app works completely offline
rails test test/integration/full_offline_workflow_test.rb

# This test verifies:
# ✓ Login works (local auth)
# ✓ Upload works (local storage)
# ✓ Extraction works (local LLM)
# ✓ Calculations work (local formulas)
# ✓ Export works (local generation)
# ✓ No external calls made
```

### Test Database Setup

```bash
# Prepare test database
rails db:test:prepare

# Run tests again
rails test
```

---

## Application Structure

```
tax/
├── web/                           # Rails application
│   ├── app/
│   │   ├── controllers/           # Request handlers
│   │   ├── models/                # Database models
│   │   ├── services/              # Business logic (validators, calculators, exporters)
│   │   └── views/                 # HTML templates
│   ├── config/
│   │   ├── database.yml           # Database config
│   │   ├── storage.yml            # Encryption config
│   │   └── routes.rb              # URL routes
│   ├── db/
│   │   ├── migrate/               # Database migrations
│   │   └── development.sqlite3    # Development database
│   ├── storage/                   # Encrypted evidence files
│   ├── Gemfile                    # Dependencies
│   └── README.md                  # Documentation
├── GETTING_STARTED.md             # This file
├── DEPLOYMENT.md                  # Production setup
├── VERIFICATION_CHECKLIST.md      # Spec compliance
└── TESTING_PHASE_4.md             # Test documentation
```

---

## Accessing the Application

### Web Interface

```
URL: http://localhost:3000
Port: 3000
```

### Database Console

```bash
# Access SQLite database
sqlite3 db/development.sqlite3

# Or use Rails console
rails console

# Example commands:
User.all
TaxReturn.first
BoxValue.where(tax_return_id: 1)
```

### Rails Console

```bash
# Interactive Rails shell
rails console

# Create test user
User.create!(email: 'test@local', password: 'password123')

# View tax returns
TaxReturn.all

# View validations
ValidationRule.all

# Run calculations
tax_return = TaxReturn.first
Calculators::FTCRCalculator.new(tax_return).calculate
```

---

## Troubleshooting

### Issue: "Gems not installed"

```bash
# Solution: Install dependencies
bundle install

# Or update gems
bundle update
```

### Issue: "Database doesn't exist"

```bash
# Solution: Create and migrate database
rails db:create
rails db:migrate
```

### Issue: "Encryption keys not set"

```bash
# Solution: Set environment variables
export AR_ENCRYPTION_PRIMARY_KEY=$(ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))")

# Or create .env file and load it
source .env
```

### Issue: "Ollama not available"

```bash
# Solution: Start Ollama in another terminal
ollama serve

# Verify it's running
curl http://localhost:11434/api/tags

# If not installed, install it:
# macOS: brew install ollama
# Linux: curl https://ollama.ai/install.sh | sh
```

### Issue: "Port 3000 already in use"

```bash
# Solution: Use different port
rails server -p 3001

# Or kill process using port 3000
lsof -ti:3000 | xargs kill -9
rails server
```

### Issue: "Cannot read evidence files"

```bash
# Solution: Verify encryption keys match
# Encryption is key-based, so wrong keys = unreadable data

# Check keys are set
echo $AR_ENCRYPTION_PRIMARY_KEY

# If not set, regenerate and re-upload evidence files
```

### Issue: "Tests fail"

```bash
# Solution: Setup test database
rails db:test:prepare

# Run tests again
rails test

# Or check for errors
rails test --verbose

# Or run single test
rails test test/models/user_test.rb
```

---

## Common Tasks

### Create Test User

```bash
rails console
> User.create!(email: 'test@example.com', password: 'Password123')
> exit
```

### View Application Logs

```bash
# Real-time logs
tail -f log/development.log

# Or see Rails logs in console while running
# (logs appear as requests are made)
```

### Access Database

```bash
# Direct SQLite access
sqlite3 db/development.sqlite3

# Or Rails console (recommended)
rails console
```

### Run Specific Controller

```bash
# Test a specific controller
rails test test/controllers/exports_controller_test.rb

# Run specific test
rails test test/controllers/exports_controller_test.rb -n test_user_can_view_their_exports
```

### Generate New Database

```bash
# Reset database (deletes all data)
rails db:drop db:create db:migrate

# Warning: This deletes all local data!
```

---

## Running Multiple Instances

### Terminal Setup

You need **3+ terminals** running simultaneously:

**Terminal 1 - Ollama (LLM)**
```bash
ollama serve
```

**Terminal 2 - Rails App**
```bash
cd tax/web
rails server
```

**Terminal 3 - Manual Testing**
```bash
# Run tests, console, curl commands, etc.
cd tax/web
rails test

# or
rails console

# or
curl http://localhost:3000
```

**Terminal 4 - Database Access (Optional)**
```bash
cd tax/web
rails console
```

---

## Verify Everything is Running

### Health Check

```bash
#!/bin/bash

echo "=== APPLICATION HEALTH CHECK ==="

# 1. Check Rails
echo -n "Rails App: "
curl -s http://localhost:3000/ > /dev/null && echo "✅ Running" || echo "❌ Not running"

# 2. Check Ollama
echo -n "Ollama LLM: "
curl -s http://localhost:11434/api/tags > /dev/null && echo "✅ Running" || echo "❌ Not running"

# 3. Check Database
echo -n "Database: "
[ -f web/db/development.sqlite3 ] && echo "✅ Present" || echo "❌ Missing"

# 4. Check Encryption
echo -n "Encryption Keys: "
[ -n "$AR_ENCRYPTION_PRIMARY_KEY" ] && echo "✅ Set" || echo "❌ Not set"

echo ""
echo "=== READY TO USE ==="
```

Run with:
```bash
bash HEALTH_CHECK.sh
```

---

## Next Steps

1. **Read Documentation**
   - [DEPLOYMENT.md](DEPLOYMENT.md) - Production setup
   - [TESTING_PHASE_4.md](TESTING_PHASE_4.md) - Test guide
   - [VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md) - Spec compliance

2. **Explore the App**
   - Create a user
   - Upload evidence
   - Test extraction
   - Run calculations
   - Generate exports

3. **Run Tests**
   ```bash
   rails test
   ```

4. **Develop Further**
   - Add custom validation rules
   - Extend calculators
   - Build UI components
   - Add integrations

---

## Support

### Common Questions

**Q: Can I run without Ollama?**
A: Yes! The app works fine without Ollama. Extraction won't work, but everything else does. All calculations are deterministic and don't require LLM.

**Q: How are my files encrypted?**
A: AES-256-GCM encryption with keys you control. Files are encrypted on disk in `storage/` directory.

**Q: Can I use PostgreSQL instead of SQLite?**
A: Yes, edit `config/database.yml` to use PostgreSQL.

**Q: How do I backup my data?**
A: Copy `db/development.sqlite3` and `storage/` directory.

**Q: Is it really offline?**
A: Yes! Verified in [VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md). No outbound network calls by default.

---

## Success!

You now have the tax helper running locally with:
- ✅ User authentication
- ✅ Encrypted database
- ✅ Encrypted evidence storage
- ✅ Local LLM integration
- ✅ Tax calculations
- ✅ Export generation
- ✅ Full offline operation

**Visit http://localhost:3000 to start using it!**
