module Patterns
  class Query
    def self.through(relation)
      self.relation = relation
    end

    def self.expires_in(expiration)
      self.expiration = expiration
    end

    def self.execute(**args)
      new(**args).run
    end

    def initialize(**args)
      @params = OpenStruct.new(**args)
    end

    def execute; end

    def cache_param; end

    def run
      if expiration.zero?
        execute
      else
        with_cache do
          execute
        end
      end
    end

    private

    attr_reader :params

    class_attribute :relation
    class_attribute :expiration, default: 0

    def with_cache(&block)
      cache_key = [self.class.to_s.underscore, cache_param].compact.join("/")
      Rails.cache.fetch(cache_key, expires_in: expiration.from_now) do
        block.call
      end
    end
  end
end
