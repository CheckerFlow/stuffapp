class Storage < ApplicationRecord
    belongs_to :user
    
    belongs_to :room

    has_many :items, dependent: :destroy

    has_many_attached :images, dependent: :destroy

    self.per_page = 20

    has_many :sharing_group_members, as: :shareable    
end
