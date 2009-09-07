require 'data/image'
require 'data/commentable'
require 'data/viewable'
require 'data/taggable'
require 'data/user'
require 'data/bot'
require 'data/tag'

class Article
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :url, String


  remix 1, :images, :as => "pics"

  remix n, :viewables, :as => "views"

  remix n, :commentables, :as => "comments", :for => "User"

  remix n, "My::Nested::Remixable::Rating", :as => :ratings

  remix n, :taggable, :as => "user_taggings", :for => "User", :model => "UserTagging"

  remix n, :taggable, :as => "bot_taggings", :for => "Bot", :model => "BotTagging"

  enhance :viewables do
    belongs_to :user
  end

  enhance :taggable, "UserTagging" do
    belongs_to :user
    belongs_to :tag
  end

  enhance :taggable, "BotTagging" do
    belongs_to :bot
    belongs_to :tag
  end

  def viewed_by(usr)
    art_view = ArticleView.new
    art_view.ip = "127.0.0.1"
    art_view.user_id = usr.id

    self.views << art_view
  end

end
