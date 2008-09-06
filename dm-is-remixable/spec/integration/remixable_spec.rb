require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

require "dm-types"
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'addressable'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'billable'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'commentable'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'article'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'image'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'user'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'viewable'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'topic'
require Pathname(__FILE__).dirname.expand_path.parent / 'data' / 'rating'

DataMapper.auto_migrate!

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::Remixable' do
    describe 'DataMapper::Resource' do
      it "should know if it is remixable" do
        User.is_remixable?.should be(false)
        Image.is_remixable?.should be(true)
        Article.is_remixable?.should be(false)
        Commentable.is_remixable?.should be(true)
      end
    end
    
    it "should only allow remixables to be remixed" do
      lambda { User.remix 1, :articles }.should raise_error(Exception)
    end
    
    it "should not allow enhancements of modules that aren't remixed" do
      begin
        User.enhance Image do
          puts "I can enhance something I didn't remix"
        end
        false
      rescue Exception => e
        true
      end
    end

    it "should provide a default suffix values for models that do 'is :remixable'" do
      Image.suffix.should == "image"
    end

    it "should allow enhancing a model that is remixed" do
      Article.enhance :images do
        def self.test_enhance
          puts "Testing"
        end
      end

      ArticleImage.should respond_to("test_enhance")
    end
    
    it "should allow enhancing a model that was remixed from a nested module" do
      Article.enhance :ratings do
        def self.test_enhance
          puts "Testing"
        end
      end

      ArticleRating.should respond_to("test_enhance")
      ArticleRating.should respond_to("total_rating")
      ArticleRating.new.should respond_to("user_id")
      ArticleRating.new.should respond_to("rating")
    end
    
    it "should provided a map of Remixable Modules to Remixed Models names" do
      User.remixables.should_not be(nil)
    end

    it "should store the remixed model in the map of Remixable Modules to Remixed Models" do
      User.remixables[:billable][:model].should == Account
      # nested remixables
      User.remixables[:rating][:model].should == UserRating
      Article.remixables[:rating][:model].should == ArticleRating
      Topic.remixables[:rating][:model].should == Rating
    end
    
    it "should store the remixee reader name in the map of Remixable Modules to Remixed Models" do
      User.remixables[:billable][:reader].should == :accounts
      # nested remixables
      User.remixables[:rating][:reader].should == :user_ratings
      Article.remixables[:rating][:reader].should == :ratings
      Topic.remixables[:rating][:reader].should == :ratings_for_topic
    end
    
    it "should store the remixee writer name in the map of Remixable Modules to Remixed Models" do
      User.remixables[:billable][:writer].should == :accounts=
      # nested remixables
      User.remixables[:rating][:writer].should == :user_ratings=
      Article.remixables[:rating][:writer].should == :ratings=
      Topic.remixables[:rating][:writer].should == :ratings_for_topic=
    end
    
    it "should allow specifying an alternate class name" do
      User.remixables[:billable][:model].name.should_not == "UserBillable"
      User.remixables[:billable][:model].name.should == "Account"
    end

    it "should create a storage name based on the class name" do

      Article.remixables[:image][:model].storage_names[:default].should == "article_images"
      User.remixables[:billable][:model].storage_names[:default].should == "accounts"
    end

    it "should allow creating an accessor alias" do
      article = Article.new
      article.should respond_to("pics")
      article.should respond_to("article_images")
    end

    it "should copy properties from the Remixable Module to the Remixed Model" do
      #Billabe => Account
      account = Account.new

      account.should respond_to("cc_num")
      account.should respond_to("cc_type")
      account.should respond_to("expiration")
    end

    it "should allow 1:M relationships with the Remixable Module" do
      user = User.new
      addy = UserAddress.new
      addy2 = UserAddress.new

      user.first_name = "Jack"
      user.last_name = "Tester"

      addy.address1 = "888 West Whatnot Ave."
      addy.city = "Los Angeles"
      addy.state = "CA"
      addy.zip = "90230"

      addy2.address1 = "325 East NoWhere Lane"
      addy2.city = "Fort Myers"
      addy2.state = "FL"
      addy2.zip = "33971"

      user.user_addresses << addy
      user.user_addresses << addy2

      user.user_addresses.length.should be(2)
    end

    it "should allow 1:1 relationships with the Remixable Module" do
      article = Article.new
      image1  = ArticleImage.new
      image2  = ArticleImage.new

      article.title = "Really important news!"
      article.url = "http://example.com/index.html"

      image1.description = "Shocking and horrific photo!"
      image1.path = "~/pictures/shocking.jpg"

      image2.description = "Other photo"
      image2.path = "~/pictures/mom_naked.yipes"

      begin
        article.pics << image1
        false
      rescue Exception => e
        e.class.should be(NoMethodError)
      end

      article.pics = image2
      article.pics.path.should == image2.path
    end

    it "should allow M:M unary relationships through the Remixable Module" do
      #User => Commentable => User
      user = User.new
      user.first_name = "Tester"
      user2 = User.new
      user2.first_name = "Testy"

      comment = UserComment.new
      comment.comment = "YOU SUCK!"
      comment.commentor = user2
      user.user_comments << comment

      user2.user_comments.length.should be(0)

      comment.commentor.first_name.should == "Testy"
      user.user_comments.length.should be(1)
    end

    it "should allow M:M relationships through the Remixable Module" do
      #Article => Commentable => User
      user = User.new
      article = Article.new

      ac = ArticleComment.new

      user.first_name = "Talker"
      user.last_name = "OnTheInternetz"

      article.url = "Http://example.com/"
      article.title = "Important internet thingz, lol"

      ac.comment = "This article sux!"

      article.comments << ac
      user.article_comments << ac

      article.comments.first.should be(ac)
      user.article_comments.first.should be(ac)
    end
  end
end
