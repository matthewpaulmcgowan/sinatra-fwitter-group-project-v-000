class User < ActiveRecord::Base 
  has_many :tweets
  has_secure_password
  
  validates_presence_of :username, :password, :email
  
  def slug
    @slug = username.downcase.gsub(/\W+/,"-")
  end
     
  def self.find_by_slug(slug)
    User.all.find do |instance|
      if !instance.username.nil?
        instance.slug == slug
      end
    end
  end
end