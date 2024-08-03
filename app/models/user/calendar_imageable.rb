module User::CalendarImageable
  extend ActiveSupport::Concern

  included do
    has_one_attached :calendar_image do |attachable|
      attachable.variant :small, resize_to_limit: [600, 150], saver: { quality: 100 }, preprocessed: true
    end

    has_one_attached :signature # Deprecated

    after_create_commit :enqueue_calendar_images_generation
    after_update_commit :enqueue_calendar_images_generation, if: -> { calendar_images.obsolete? }
  end

  def calendar_images
    User::CalendarImages.new(self)
  end

  private

  def enqueue_calendar_images_generation
    calendar_images.generate_later
  end
end
