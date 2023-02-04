module MAL
  module Parsers
  module Helpers
  def clean_text(text)
    text.gsub(/[[:space:]]/, " ").strip
  end
  end
  end
end
