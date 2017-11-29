class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
  format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
  uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts

  has_many :relationships
  #自分がフォローしている Userを取得
  has_many :followings, through: :relationships, source: :follow

  #has_many :relationships の逆方向(reverse)
  has_many :reverses_of_relationship, class_name: "Relationship", foreign_key: 'follow_id'
  #順方向に対して、逆の設定
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  def follow(other_user)
    unless self == other_user
       self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
end
