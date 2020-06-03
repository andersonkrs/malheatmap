class User < ApplicationRecord
  has_many :entries, dependent: :destroy, inverse_of: :user
  has_many :activities, dependent: :destroy, inverse_of: :user

  def to_param
    username
  end
end
