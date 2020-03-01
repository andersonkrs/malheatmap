class User < ApplicationRecord
  has_many :entries, dependent: :destroy

  def to_param
    username
  end
end
