class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
  format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
  uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  
  ### ここから　###
  #User が Relationship と一対多である関係
  has_many :relationships
  #自分がフォローしている Userを取得(中間テーブルから先のモデルを参照)
  #Following クラスは無くこのために利用しているだけ
  #through: :relationshipsは、has_many: relationships の結果を中間テーブルとして指定
  #source: :follow 指定した中間テーブルのfollowidを指定している
  has_many :followings, through: :relationships, source: :follow
  ### ここまでが自分がフォローしている User 達を取得　###

  #has_many :relationships の逆方向(reverse)
  #reverses_of_relationshipは実際にはない
  #foreign_key: 'follow_id' と指定して、 user_id 側ではないことを明示
  #こうしないとRails の命名規則により、User から Relationship を取得するとき、
  #user_id が使用される
  has_many :reverses_of_relationship, class_name: "Relationship", foreign_key: 'follow_id'
  #source: :user で 中間テーブルの user_id のほうが取得したい User だと指定
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :favorites
  #分かりやすいメソッドを定義　被らないよう注意
  has_many :favorite_microposts, through: :favorites, source: :micropost
  
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
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def favorite(micropost) 
    self.favorites.find_or_create_by(micropost_id: micropost.id)
  end
    
  def unfavorite(micropost)
    favorite = self.favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  def favorite?(micropost)
    self.favorite_microposts.include?(micropost)
  end
end
