# Deployment Guide

This guide covers deploying the UK Tax Self Assessment Helper application in development and production environments.

## System Requirements

### Development
- Ruby 3.3+
- SQLite 3
- Bundler
- Node.js 18+
- Ollama (for PDF extraction)

### Production
- Ruby 3.3+
- PostgreSQL 14+ (recommended) or SQLite 3
- Puma web server
- Nginx or Apache (reverse proxy)
- Ollama (for PDF extraction)
- SSL/TLS certificate

## Database Setup

### Development

```bash
bundle install
bundle exec rails db:create db:migrate
```

### Production

1. Create PostgreSQL database and user:
```sql
CREATE DATABASE tax_production;
CREATE USER tax_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE tax_production TO tax_user;
```

2. Configure database connection in `config/database.yml`:
```yaml
production:
  adapter: postgresql
  database: tax_production
  username: tax_user
  password: <%= ENV["DATABASE_PASSWORD"] %>
  host: localhost
  pool: 5
  timeout: 5000
```

3. Run migrations:
```bash
RAILS_ENV=production bundle exec rails db:migrate
```

## Encryption Key Setup

This application uses **AES-256-GCM encryption** for sensitive data. You must generate and securely store encryption keys before running the application.

### Generating Encryption Keys

Generate random 32-byte base64-encoded keys:

```bash
# Primary key for Active Record encryption
ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))"

# Deterministic key for encrypted columns that need to be searched
ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))"

# Key derivation salt
ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(16))"

# Active Storage encryption key
ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(32))"

# Active Storage encryption salt
ruby -rbigdecimal -rsecurerand -rbase64 -e "puts Base64.strict_encode64(SecureRandom.random_bytes(16))"
```

### Setting Environment Variables

Create a `.env` file in the project root (development) or set in your deployment platform:

```bash
# Development (.env file)
AR_ENCRYPTION_PRIMARY_KEY=<generated_key>
AR_ENCRYPTION_DETERMINISTIC_KEY=<generated_key>
AR_ENCRYPTION_KEY_DERIVATION_SALT=<generated_salt>
ACTIVE_STORAGE_ENCRYPTION_KEY=<generated_key>
ACTIVE_STORAGE_ENCRYPTION_SALT=<generated_salt>

# Database
DATABASE_PASSWORD=<secure_password>

# Ollama
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=gemma3:1b
```

### Using Rails Credentials (Production Recommended)

```bash
EDITOR=nano bundle exec rails credentials:edit --environment production
```

Add to credentials file:
```yaml
encryption:
  ar_primary_key: <generated_key>
  ar_deterministic_key: <generated_key>
  ar_key_derivation_salt: <generated_salt>
  storage_encryption_key: <generated_key>
  storage_encryption_salt: <generated_salt>
database:
  password: <secure_password>
```

Reference in environment configuration:
```ruby
# config/environments/production.rb
config.active_record.encryption.primary_key = Rails.application.credentials.dig(:encryption, :ar_primary_key)
config.active_record.encryption.deterministic_key = Rails.application.credentials.dig(:encryption, :ar_deterministic_key)
config.active_record.encryption.key_derivation_salt = Rails.application.credentials.dig(:encryption, :ar_key_derivation_salt)
```

## Ollama Setup

### Local Installation (Development)

1. Install Ollama from https://ollama.ai
2. Start Ollama:
```bash
ollama serve
```

3. Pull the required model:
```bash
ollama pull gemma3:1b
```

4. Verify availability:
```bash
curl http://localhost:11434/api/tags
```

### Remote Ollama (Production)

Configure connection via environment variables:
```bash
OLLAMA_URL=http://remote-ollama-server:11434
OLLAMA_MODEL=gemma3:1b
```

### Troubleshooting Ollama

If extraction fails with "Ollama service is not available":

1. Check Ollama is running: `curl http://localhost:11434/api/tags`
2. Verify model is installed: `ollama list`
3. Pull model if missing: `ollama pull gemma3:1b`
4. Check network connectivity and firewall rules
5. Ensure OLLAMA_URL environment variable is correct

## Running the Application

### Development

```bash
bundle exec rails server
# Access at http://localhost:3000
```

### Production (Puma + Nginx)

1. Build assets:
```bash
RAILS_ENV=production bundle exec rails assets:precompile
```

2. Start Puma:
```bash
RAILS_ENV=production bundle exec puma -c config/puma.rb
```

3. Configure Nginx as reverse proxy:
```nginx
upstream puma {
  server unix:///var/run/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name your-domain.com;

  client_max_body_size 500M;

  location / {
    proxy_pass http://puma;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

## Docker Deployment

### Building Docker Image

```bash
docker build -t tax-helper:latest .
```

### Running with Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgresql://tax_user:password@postgres:5432/tax_production
      AR_ENCRYPTION_PRIMARY_KEY: ${AR_ENCRYPTION_PRIMARY_KEY}
      AR_ENCRYPTION_DETERMINISTIC_KEY: ${AR_ENCRYPTION_DETERMINISTIC_KEY}
      AR_ENCRYPTION_KEY_DERIVATION_SALT: ${AR_ENCRYPTION_KEY_DERIVATION_SALT}
      ACTIVE_STORAGE_ENCRYPTION_KEY: ${ACTIVE_STORAGE_ENCRYPTION_KEY}
      ACTIVE_STORAGE_ENCRYPTION_SALT: ${ACTIVE_STORAGE_ENCRYPTION_SALT}
      OLLAMA_URL: http://ollama:11434
      OLLAMA_MODEL: gemma3:1b
    depends_on:
      - postgres
      - ollama
    volumes:
      - storage:/app/storage

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: tax_production
      POSTGRES_USER: tax_user
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      OLLAMA_MODELS: /root/.ollama/models

volumes:
  postgres_data:
  ollama_data:
  storage:
```

Deploy:
```bash
docker-compose up -d
docker-compose exec web rails db:migrate
```

## SSL/TLS Configuration

### With Let's Encrypt

```bash
sudo certbot certonly --standalone -d your-domain.com
```

Update Nginx configuration to use certificate:
```nginx
listen 443 ssl;
ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

# Redirect HTTP to HTTPS
server {
  listen 80;
  return 301 https://$server_name$request_uri;
}
```

## Backup & Recovery

### Database Backup

```bash
# Development (SQLite)
cp db/production.sqlite3 backups/production.sqlite3.$(date +%s)

# Production (PostgreSQL)
pg_dump -U tax_user -h localhost tax_production > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Evidence Files Backup

Evidence files are stored in `storage/` directory:
```bash
tar -czf evidence_backup_$(date +%Y%m%d).tar.gz storage/
```

### Recovery

```bash
# PostgreSQL restore
psql -U tax_user -h localhost tax_production < backup.sql

# SQLite restore
cp backup.sqlite3 db/production.sqlite3

# Evidence files restore
tar -xzf evidence_backup.tar.gz
```

## Monitoring & Logging

### Application Logs

```bash
tail -f log/production.log
```

### Encryption Key Rotation (Future Implementation)

Key rotation strategy should be documented when implemented. Current keys are static and should be:
1. Stored securely (environment variables, secrets manager, or Rails credentials)
2. Never committed to version control
3. Rotated periodically following security best practices
4. Backed up securely in case of disaster recovery

## Troubleshooting

### Database Connection Errors

- Verify DATABASE_PASSWORD is set correctly
- Check database server is running
- Ensure database exists: `rails db:create`
- Run migrations: `rails db:migrate`

### Encryption Key Errors

```
ActiveRecord::Encryption::Errors::Internal: The table db_config doesn't have a valid encryption_key_derivation_salt value.
```

Solution: All 5 encryption environment variables must be set before server boot.

### PDF Extraction Failures

- Verify PDF file is valid and not corrupted
- Check PDF is not password-protected
- Ensure Ollama service is running
- Check OLLAMA_URL is correctly configured
- Verify gemma3:1b model is installed

### File Upload Issues

- Check storage directory permissions
- Verify free disk space
- Ensure ACTIVE_STORAGE_ENCRYPTION_KEY and SALT are set
- Check maximum file size limits in Nginx/Puma

## Security Considerations

1. **Encryption Keys**: Store outside version control using environment variables or Rails credentials
2. **Database Credentials**: Use strong passwords and restrict database access
3. **SSL/TLS**: Always use HTTPS in production
4. **File Uploads**: Validate file types and scan for malware
5. **Authentication**: Require strong passwords (minimum 8 characters recommended)
6. **Data Retention**: Implement data deletion policies for compliance
7. **Audit Logging**: Monitor AuditLog for suspicious activity
8. **Network Security**: Restrict Ollama access to trusted networks only

## Support & Questions

For issues or questions:
1. Check logs: `tail -f log/production.log`
2. Verify all environment variables are set
3. Consult troubleshooting section above
4. Review Git commit history: `git log --oneline`
