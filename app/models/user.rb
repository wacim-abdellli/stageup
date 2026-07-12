class User < ApplicationRecord
  belongs_to :profileable, polymorphic: true
  has_many :notifications, as: :recipient, dependent: :destroy

  validates :profileable, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
