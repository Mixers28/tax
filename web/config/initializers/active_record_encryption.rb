# frozen_string_literal: true

Rails.application.configure do
  config.active_record.encryption.primary_key = ENV["AR_ENCRYPTION_PRIMARY_KEY"] ||
    Rails.application.credentials.dig(:active_record_encryption, :primary_key)
  config.active_record.encryption.deterministic_key = ENV["AR_ENCRYPTION_DETERMINISTIC_KEY"] ||
    Rails.application.credentials.dig(:active_record_encryption, :deterministic_key)
  config.active_record.encryption.key_derivation_salt = ENV["AR_ENCRYPTION_KEY_DERIVATION_SALT"] ||
    Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt)
  config.active_record.encryption.support_unencrypted_data = true
end

missing_keys = %i[primary_key deterministic_key key_derivation_salt].select do |key|
  Rails.application.config.active_record.encryption.public_send(key).blank?
end

if missing_keys.any?
  raise "Missing Active Record encryption keys: #{missing_keys.join(", ")}. " \
        "Set AR_ENCRYPTION_* env vars or credentials." unless Rails.env.test?
end
