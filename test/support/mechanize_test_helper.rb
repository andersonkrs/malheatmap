module MechanizeTestHelper
  module_function

  def fake_page(fixture_name)
    html = file_fixture(fixture_name).read
    url = URI.parse(Faker::Internet.url)
    Mechanize::Page.new(url, nil, html, 200, Mechanize.new)
  end
end
