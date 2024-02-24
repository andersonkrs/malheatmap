class CompressedText < ActiveRecord::Type::Text
  def type
    :compressed_text
  end

  def deserialize(value)
    Base64.decode64(value) if value.is_a?(String)
  end

  def serialize(value)
    Base64.encode64(value) if value.present?
  end
end

ActiveRecord::Type.register(:compressed_text, CompressedText)
