class AuditLog < ApplicationRecord
  validates :action, :object_ref, :logged_at, presence: true
end
