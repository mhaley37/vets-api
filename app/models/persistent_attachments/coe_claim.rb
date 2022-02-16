# frozen_string_literal: true

class PersistentAttachments::CoeClaim < PersistentAttachment
  include ::ClaimDocumentation::Uploader::Attachment.new(:file)
  binding.pry
  before_destroy(:delete_file)

  private

  def delete_file
    file.delete
  end
end
