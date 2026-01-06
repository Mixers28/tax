# Encryption Key Setup Guide

This document explains how to set up and manage encryption keys for the Tax Application.

## Overview

The application uses Active Record encryption for sensitive database data (Phase 5d+ features) and Active Storage encryption for evidence file uploads. All encryption is local and transparent - no external services required.

## Development Setup

### Option 1: Using Rails Credentials (Recommended for Development)

Rails credentials provide encrypted, centralized key management:

1. **Keys are already stored** in `config/credentials/development.yml.enc`
   - Primary Key: Stored securely with development.key
   - Deterministic Key: Stored securely with development.key
   - Key Derivation Salt: Stored securely with development.key

2. **The development key** is stored in `config/credentials/development.key`
   - This file is gitignored and unique to your development environment
   - Keep it safe - losing it means losing access to encrypted data

3. **No environment variables needed** for normal development
   - Rails automatically loads credentials when needed

### Option 2: Using Environment Variables (For Docker/CI)

If you need to use environment variables (e.g., in Docker, CI/CD):

1. Copy the template file:
   ```bash
   cp .env.local.example .env.local
   ```

2. Add your encryption keys to `.env.local`:
   ```bash
   AR_ENCRYPTION_PRIMARY_KEY=bKW+lV+Dq41meQl1iY/gsteaiL36ZaHS6PAvEfFMzVE=
   AR_ENCRYPTION_DETERMINISTIC_KEY=oXyqz/vCpNSVM2smdRjqbXqXxS+QI8HQNLh5vUYqCJg=
   AR_ENCRYPTION_KEY_DERIVATION_SALT=v+8oBEiTqaivIdog32BiYg==
   ACTIVE_STORAGE_ENCRYPTION_KEY=WuxDNOc5+zA7o1GPBM/uYuy38lc92BLMOlYsP35iWLo=
   ACTIVE_STORAGE_ENCRYPTION_SALT=XoNbePiyJt0HFpAydK7VCw==
   ```

3. **IMPORTANT**: `.env.local` is gitignored - never commit it
   - This file contains sensitive keys

4. Load the file before running commands:
   ```bash
   source .env.local
   bundle exec rails db:migrate
   ```

## Running Migrations

### With Credentials (Automatic):
```bash
bundle exec rails db:migrate
```

The application automatically reads keys from `config/credentials/development.yml.enc`.

### With Environment Variables:
```bash
# Export keys first
export AR_ENCRYPTION_PRIMARY_KEY="..."
export AR_ENCRYPTION_DETERMINISTIC_KEY="..."
export AR_ENCRYPTION_KEY_DERIVATION_SALT="..."

# Then run migrations
bundle exec rails db:migrate
```

Or use a .env.local file with dotenv gem (ensure dotenv is in Gemfile).

## Production Setup

**Important**: In production, always use environment variables, not credentials files.

1. Set environment variables in your hosting platform:
   - AWS: Parameter Store, Secrets Manager
   - Heroku: Config Vars
   - Docker: Use secrets management
   - Kubernetes: Use Secrets

2. Variables needed:
   ```
   AR_ENCRYPTION_PRIMARY_KEY
   AR_ENCRYPTION_DETERMINISTIC_KEY
   AR_ENCRYPTION_KEY_DERIVATION_SALT
   ACTIVE_STORAGE_ENCRYPTION_KEY
   ACTIVE_STORAGE_ENCRYPTION_SALT
   ```

3. Example Docker Compose production setup:
   ```yaml
   services:
     web:
       environment:
         AR_ENCRYPTION_PRIMARY_KEY: ${AR_ENCRYPTION_PRIMARY_KEY}
         AR_ENCRYPTION_DETERMINISTIC_KEY: ${AR_ENCRYPTION_DETERMINISTIC_KEY}
         AR_ENCRYPTION_KEY_DERIVATION_SALT: ${AR_ENCRYPTION_KEY_DERIVATION_SALT}
         ACTIVE_STORAGE_ENCRYPTION_KEY: ${ACTIVE_STORAGE_ENCRYPTION_KEY}
         ACTIVE_STORAGE_ENCRYPTION_SALT: ${ACTIVE_STORAGE_ENCRYPTION_SALT}
   ```

## Key Management Best Practices

### ✅ DO:

- **Store development.key securely**: Keep `config/credentials/development.key` safe
- **Use a password manager**: Store production keys in AWS Secrets Manager, LastPass, 1Password, etc.
- **Rotate keys periodically**: Especially for production
- **Use different keys per environment**: Development, staging, and production should have different keys
- **Document key rotation**: Create a runbook for when keys expire
- **Audit access**: Monitor who has access to encryption keys

### ❌ DON'T:

- **Commit encryption keys to git**: Use .gitignore (already configured)
- **Share keys in chat/email**: Use secure password managers instead
- **Use weak or predictable keys**: Rails generates them cryptographically securely
- **Reuse keys across environments**: Each environment should have unique keys
- **Lose the master key**: Losing `config/credentials/development.key` means losing access to encrypted data

## Editing Credentials

To edit your development credentials (add/change keys):

```bash
# This opens an editor with your decrypted credentials
EDITOR=nano bundle exec rails credentials:edit
```

Changes are automatically encrypted and saved.

## What Gets Encrypted

### Active Record Encryption (Database):
- Evidence file metadata (Phase 2+)
- User authentication data (if implemented)
- Sensitive box values (if marked in model)
- Any model columns marked with `encrypts :column_name`

### Active Storage Encryption (Files):
- Evidence files uploaded by users
- PDFs and documents
- All data in `storage/` directory

## Verifying Setup

To verify encryption keys are properly configured:

```bash
# Should show no errors
bundle exec rails runner "puts Rails.application.credentials.dig(:active_record_encryption, :primary_key)"

# Should show database version (keys are working)
bundle exec rails db:version
```

## Troubleshooting

### "Missing Active Record encryption keys" error
1. Check if `.env.local` exists and has keys (if using env vars)
2. Check if `config/credentials/development.yml.enc` is readable
3. Verify `config/credentials/development.key` exists and is not empty
4. Try: `bundle exec rails credentials:show` to validate credentials

### "Could not decrypt encrypted data" error
- One or more encryption keys has been changed/corrupted
- Keys must match the data they encrypted
- If using new keys, old encrypted data becomes inaccessible
- Restore from backup if available

### Database won't migrate
1. Ensure all three encryption keys are set (primary, deterministic, salt)
2. Keys must be valid Base64 strings
3. Try running with explicit environment variables:
   ```bash
   AR_ENCRYPTION_PRIMARY_KEY="..." bundle exec rails db:migrate
   ```

## References

- Rails Credentials: https://guides.rubyonrails.org/encryption_at_rest.html
- Active Record Encryption: https://api.rubyonrails.org/classes/ActiveRecord/Encryption.html
- Environment Variable Security: https://12factor.net/config
