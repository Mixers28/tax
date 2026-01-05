# UK Tax Self Assessment Helper

A local-first Rails application for mapping UK HMRC Self Assessment form inputs, with offline PDF extraction using Ollama.

## Quick Start

### Development

```bash
# Install dependencies
bundle install

# Set up encryption keys (generate new keys or use provided keys)
# See DEPLOYMENT.md for key generation instructions
export AR_ENCRYPTION_PRIMARY_KEY=<your-key>
export AR_ENCRYPTION_DETERMINISTIC_KEY=<your-key>
export AR_ENCRYPTION_KEY_DERIVATION_SALT=<your-salt>
export ACTIVE_STORAGE_ENCRYPTION_KEY=<your-key>
export ACTIVE_STORAGE_ENCRYPTION_SALT=<your-salt>

# Create and migrate database
bin/rails db:create db:migrate

# Start Ollama (in separate terminal)
ollama serve

# In another terminal, pull the model
ollama pull gemma3:1b

# Start Rails server
bin/rails server
```

Visit http://localhost:3000 and log in.

## Architecture

- **Framework**: Rails 8.1 with Hotwire
- **Database**: SQLite (development), PostgreSQL (production)
- **Storage**: Active Storage with encrypted disk service
- **Encryption**: AES-256-GCM for sensitive data and files
- **LLM**: Ollama (local, offline) for PDF extraction
- **Authentication**: Rails session-based with secure password hashing

## Features

- **Multi-user Support**: Each user's data is isolated and encrypted
- **Evidence Management**: Upload and store PDF evidence files
- **PDF Extraction**: Local LLM extracts tax box values from PDFs
- **Audit Trail**: All changes logged with before/after states
- **Encrypted Storage**: All sensitive data encrypted at rest
- **No Cloud Dependency**: Fully local operation (except Ollama, if remote)

## Key Files

| File | Purpose |
|------|---------|
| `DEPLOYMENT.md` | Complete deployment guide |
| `app/models/` | Database models |
| `app/controllers/` | Request handlers |
| `app/services/` | Business logic (PDF extraction, Ollama) |
| `db/migrate/` | Database schema |

## Database Schema

Key tables:
- **users**: User accounts with passwords
- **tax_returns**: User's tax return drafts
- **evidences**: Uploaded PDF evidence files
- **extraction_runs**: PDF extraction attempts and results
- **box_values**: Extracted or manually entered tax box values
- **audit_logs**: Change history

See `db/schema.rb` for complete schema.

## Security

- All user data is encrypted at rest using AES-256-GCM
- Passwords hashed with bcrypt
- Sessions stored securely
- Evidence files encrypted individually
- Audit trail captures all data changes
- No user data sent to external services

## Environment Variables

See `DEPLOYMENT.md` for complete environment variable reference. Key variables:

- `AR_ENCRYPTION_PRIMARY_KEY` - Active Record encryption key
- `ACTIVE_STORAGE_ENCRYPTION_KEY` - File storage encryption key
- `OLLAMA_URL` - Ollama service endpoint (default: http://localhost:11434)
- `OLLAMA_MODEL` - LLM model to use (default: gemma3:1b)

## Testing

```bash
bin/rails test
```

Tests automatically use non-encrypted mode and don't require encryption keys.

## Troubleshooting

See `DEPLOYMENT.md` Troubleshooting section for:
- Encryption key errors
- PDF extraction failures
- Ollama connection issues
- File upload problems

## Development

### Adding Migrations

```bash
bin/rails generate migration AddUserToPosts
```

### Database Console

```bash
bin/rails dbconsole
```

### Rails Console

```bash
bin/rails console
```

## Deployment

See `DEPLOYMENT.md` for:
- Production setup
- Docker deployment
- PostgreSQL configuration
- Nginx reverse proxy setup
- SSL/TLS configuration
- Backup and recovery procedures
