class Item < ApplicationRecord
  belongs_to :user
  
  belongs_to :storage

  has_many :list_items, dependent: :destroy
  has_many :lists, through: :list_items

  has_many_attached :images, dependent: :destroy

  acts_as_taggable

  acts_as_taggable_on :owner

  self.per_page = 20

  has_many :sharing_group_members, as: :shareable

end
