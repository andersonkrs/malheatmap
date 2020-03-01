require "virtus"
require "json"

module CCEngine
  class Issue
    include Virtus.model(strict: true)

    attribute :check_name, String
    attribute :description, String
    attribute :categories, Array[String]
    attribute :location
    attribute :remediation_points
    attribute :content
    attribute :fingerprint

    def render
      to_hash.to_json + "\0"
    end

    def to_json
      to_hash.to_json
    end

    def to_hash
      {
        type: "issue",
        check_name: check_name,
        description: description,
        categories: categories,
        location: location.to_hash
      }.merge(remediation_points_hash).merge(content_hash).merge(fingerprint_hash)
    end

    private

    def remediation_points_hash
      return {} unless remediation_points

      {
        remediation_points: remediation_points
      }
    end

    def content_hash
      return {} unless content

      {
        content: {
          body: content
        }
      }
    end

    def fingerprint_hash
      return {} unless fingerprint

      {
        fingerprint: fingerprint
      }
    end
  end
end
