class User < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :activities, dependent: :destroy

  def to_param
    username
  end
end
