require 'test/unit'

require 'nokogiri'

require 'open-uri'
require 'simplecov'
require 'simplecov-cobertura'

class CoberturaFormatterTest < Test::Unit::TestCase

  def setup
    @result = SimpleCov::Result.new("#{__FILE__}" => [1,2])
    @formatter = SimpleCov::Formatter::CoberturaFormatter.new
  end

  def teardown
    SimpleCov.groups.clear
  end

  def test_format_save_file
    xml = @formatter.format(@result)
    result_path = File.join(SimpleCov.coverage_path, SimpleCov::Formatter::CoberturaFormatter::RESULT_FILE_NAME)
    assert_not_empty(xml)
    assert_equal(xml, IO.read(result_path))
  end

  def test_format_dtd_validates
    xml = @formatter.format(@result)
    options = Nokogiri::XML::ParseOptions::DTDLOAD
    doc = Nokogiri::XML::Document.parse(xml, nil, nil, options)
    assert_empty doc.external_subset.validate(doc)
  end

  def test_no_groups
    xml = @formatter.format(@result)
    doc = Nokogiri::XML::Document.parse(xml)

    coverage = doc.xpath '/coverage'
    assert_equal '1.0', coverage.attribute('line-rate').value
    assert_equal '0', coverage.attribute('branch-rate').value
    assert_equal '2', coverage.attribute('lines-covered').value
    assert_equal '2', coverage.attribute('lines-valid').value
    assert_equal '0', coverage.attribute('branches-covered').value
    assert_equal '0', coverage.attribute('branches-valid').value
    assert_equal '0', coverage.attribute('complexity').value
    assert_equal '0', coverage.attribute('version').value
    assert_not_empty coverage.attribute('timestamp').value

    sources = doc.xpath '/coverage/sources/source'
    assert_equal 1, sources.length
    assert_equal 'simplecov-cobertura', File.basename(sources.first.text)

    packages = doc.xpath '/coverage/packages/package'
    assert_equal 1, packages.length
    package = packages.first
    assert_equal 'simplecov-cobertura', package.attribute('name').value
    assert_equal '1.0', package.attribute('line-rate').value
    assert_equal '0', package.attribute('branch-rate').value
    assert_equal '0', package.attribute('complexity').value

    classes = doc.xpath '/coverage/packages/package/classes/class'
    assert_equal 1, classes.length
    clazz = classes.first
    assert_equal 'simplecov-cobertura_test', clazz.attribute('name').value
    assert_equal 'test/simplecov-cobertura_test.rb', clazz.attribute('filename').value
    assert_equal '1.0', clazz.attribute('line-rate').value
    assert_equal '0', clazz.attribute('branch-rate').value
    assert_equal '0', clazz.attribute('complexity').value

    lines = doc.xpath '/coverage/packages/package/classes/class/lines/line'
    assert_equal 2, lines.length
    first_line = lines.first
    assert_equal '1', first_line.attribute('number').value
    assert_equal 'false', first_line.attribute('branch').value
    assert_equal '1', first_line.attribute('hits').value
    last_line = lines.last
    assert_equal '2', last_line.attribute('number').value
    assert_equal 'false', last_line.attribute('branch').value
    assert_equal '2', last_line.attribute('hits').value
  end

  def test_groups
    SimpleCov.add_group('test_group', 'test/')

    xml = @formatter.format(@result)
    doc = Nokogiri::XML::Document.parse(xml)

    coverage = doc.xpath '/coverage'
    assert_equal '1.0', coverage.attribute('line-rate').value
    assert_equal '0', coverage.attribute('branch-rate').value
    assert_equal '2', coverage.attribute('lines-covered').value
    assert_equal '2', coverage.attribute('lines-valid').value
    assert_equal '0', coverage.attribute('branches-covered').value
    assert_equal '0', coverage.attribute('branches-valid').value
    assert_equal '0', coverage.attribute('complexity').value
    assert_equal '0', coverage.attribute('version').value
    assert_not_empty coverage.attribute('timestamp').value

    sources = doc.xpath '/coverage/sources/source'
    assert_equal 1, sources.length
    assert_equal 'simplecov-cobertura', File.basename(sources.first.text)

    packages = doc.xpath '/coverage/packages/package'
    assert_equal 1, packages.length
    package = packages.first
    assert_equal 'test_group', package.attribute('name').value
    assert_equal '1.0', package.attribute('line-rate').value
    assert_equal '0', package.attribute('branch-rate').value
    assert_equal '0', package.attribute('complexity').value

    classes = doc.xpath '/coverage/packages/package/classes/class'
    assert_equal 1, classes.length
    clazz = classes.first
    assert_equal 'simplecov-cobertura_test', clazz.attribute('name').value
    assert_equal 'test/simplecov-cobertura_test.rb', clazz.attribute('filename').value
    assert_equal '1.0', clazz.attribute('line-rate').value
    assert_equal '0', clazz.attribute('branch-rate').value
    assert_equal '0', clazz.attribute('complexity').value

    lines = doc.xpath '/coverage/packages/package/classes/class/lines/line'
    assert_equal 2, lines.length
    first_line = lines.first
    assert_equal '1', first_line.attribute('number').value
    assert_equal 'false', first_line.attribute('branch').value
    assert_equal '1', first_line.attribute('hits').value
    last_line = lines.last
    assert_equal '2', last_line.attribute('number').value
    assert_equal 'false', last_line.attribute('branch').value
    assert_equal '2', last_line.attribute('hits').value
  end
end