module HttpClient
  module NetHttpRefinements
    refine Net::HTTPResponse do
      def parsed
        @parsed ||= case headers["content-type"]
        when /json/
          JSON.parse(body)
        else
          body
        end
      end
    end
  end
end
