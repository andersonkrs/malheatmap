require "open3"

class HtmlScreenshot
  class << self
    def source(file)
      @source = file
      self
    end

    def crop(width:, height:)
      params << "#{width}x#{height} --crop"
      self
    end

    def selector(selector)
      params << "--selector='#{selector}'"
      self
    end

    def take(&block)
      if run_command
        File.open("#{@source.path}.png") do |file|
          block.call(file)
        ensure
          File.delete(file)
        end

        true
      else
        false
      end
    end

    private

    def params
      @params ||= []
    end

    def run_command
      stdout, stderr, status = exec_in_source_path

      if status.success?
        Rails.logger.info stdout
        true
      else
        Rails.logger.error stderr
        false
      end
    end

    def exec_in_source_path
      Dir.chdir File.dirname(@source) do
        cmd = "#{executable} #{@source.path} --filename='<%= url %>' #{params.join(' ')}"
        Rails.logger.info(cmd)

        Open3.capture3(cmd)
      end
    end

    def executable
      Rails.root.join("node_modules/.bin/pageres")
    end
  end
end
