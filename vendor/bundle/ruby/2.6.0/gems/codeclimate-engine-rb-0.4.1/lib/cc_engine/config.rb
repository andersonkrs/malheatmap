require "json"

module CCEngine
  class Config
    def initialize(json_string)
      @json_string = json_string
    end

    def include_paths
      parsed_json.fetch("include_paths")
    end

    def exclude_paths
      parsed_json.fetch("exclude_paths")
    end

    def enabled?
      parsed_json.fetch("enabled")
    end

    protected

    attr_reader :json_string

    private

    def parsed_json
      @parsed_json = JSON.parse(json_string)
    end
  end
end
