require "open-uri"
require "zip"

namespace :geonames do
  desc "Downloads and imports geonames dataset"
  task import: [:environment] do
    puts "Downloading zip from geonames..."

    open("https://download.geonames.org/export/dump/cities15000.zip", "rb") do |zipped|
      Zip::File.open_buffer(zipped) do |zip|
        puts "Extracting..."

        csv_text = zip.entries.first.get_input_stream.read.force
        CSV.parse(csv_text, headers: true, header_converters: :symbol) do |row|
          puts row
        end
      end
    end
  end
end
