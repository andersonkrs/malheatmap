require "test_helper"

module Patterns
  class FormTest < ActiveSupport::TestCase
    class TestForm
      include Patterns::Form

      attribute :id
      attribute :name

      validates :name, presence: true

      def persist
        self.id = SecureRandom.uuid
      end

      def persisted?
        id.present?
      end
    end

    setup do
      @form = TestForm.new
    end

    test "returns form name as model name" do
      assert_equal "Test", @form.model_name
    end

    test "returns true when call save with valid form" do
      @form.name = Faker::Name.female_first_name

      assert @form.save
      assert @form.persisted?
    end

    test "returns false when call save with invalid form" do
      assert_not @form.save
      assert_not @form.persisted?
    end

    test "raises an validation error when call! save with invalid form" do
      assert_raises ActiveModel::ValidationError do
        @form.save!
      end

      assert_not @form.persisted?
    end
  end
end
