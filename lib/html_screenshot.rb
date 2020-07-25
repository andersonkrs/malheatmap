require "open3"

class HtmlScreenshot
  class ScreenshotError < StandardError; end

  def initialize(source)
    @source = source
  end

  def self.from(source)
    new(source)
  end

  def crop(width:, height:)
    params << "--width=#{width}"
    params << "--height=#{height}"
    self
  end

  def element(selector)
    params << "--element='#{selector}'"
    self
  end

  def transparent_background
    params << "--no-default-background"
    self
  end

  def take(&block)
    output, err, status = Open3.capture3(executable, @source, *params, binmode: true)
    raise ScreenshotError, err unless status.success?

    block.call(StringIO.new(output))
  end

  private

  def params
    @params ||= ["--scale-factor=1", launch_options]
  end

  def executable
    Rails.root.join("node_modules/.bin/capture-website").to_s
  end

  def launch_options
    options = {
      "args" => %w[--no-sandbox --disable-setuid-sandbox]
    }
    "--launch-options='#{options.to_json}'"
  end
end
