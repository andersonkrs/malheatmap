class User < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :activities, -> { order(date: :desc) }, dependent: :destroy, inverse_of: :user

  def to_param
    username
  end
end
