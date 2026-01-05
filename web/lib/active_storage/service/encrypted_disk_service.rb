# frozen_string_literal: true

require "active_storage/service/disk_service"
require "active_support/key_generator"
require "active_support/message_encryptor"
require "base64"
require "openssl"
require "stringio"

module ActiveStorage
  class Service::EncryptedDiskService < Service::DiskService
    def initialize(root:, key:, salt:, **options)
      super(root: root, **options)

      if key.blank? || salt.blank?
        raise ArgumentError, "Active Storage encryption key and salt must be set"
      end

      derived_key = ActiveSupport::KeyGenerator.new(key).generate_key(salt, 32)
      @encryptor = ActiveSupport::MessageEncryptor.new(
        derived_key,
        cipher: "aes-256-gcm",
        serializer: ActiveSupport::MessageEncryptor::NullSerializer
      )
    end

    def upload(key, io, checksum: nil, **options)
      data = io.read
      data = data.b
      verify_checksum(data, checksum) if checksum
      encrypted = @encryptor.encrypt_and_sign(data)
      super(key, StringIO.new(encrypted), checksum: nil, **options)
    ensure
      io.rewind if io.respond_to?(:rewind)
    end

    def download(key, &block)
      decrypted = decrypt_file(key)
      if block_given?
        yield decrypted
      else
        decrypted
      end
    end

    def download_chunk(key, range)
      decrypt_file(key).byteslice(range)
    end

    private

    def decrypt_file(key)
      encrypted = File.binread(path_for(key))
      @encryptor.decrypt_and_verify(encrypted)
    end

    def verify_checksum(data, checksum)
      digest = checksum_digest(data)
      encoded = Base64.strict_encode64(digest)
      unless ActiveSupport::SecurityUtils.secure_compare(encoded, checksum)
        raise ActiveStorage::IntegrityError
      end
    end

    def checksum_digest(data)
      if ActiveStorage.respond_to?(:checksum_implementation)
        ActiveStorage.checksum_implementation.digest(data)
      elsif defined?(ActiveStorage::ChecksumImplementation)
        ActiveStorage::ChecksumImplementation.digest(data)
      else
        OpenSSL::Digest::MD5.digest(data)
      end
    end
  end
end
