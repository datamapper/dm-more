require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

ADAPTERS.each do |name, connection_uri|
  describe 'DataMapper::Constraints', "(with #{name})" do
    before :all do
      @adapter    = DataMapper.setup(:default, connection_uri)
      @repository = DataMapper.repository(@adapter.name)

      class ::Article
        include DataMapper::Resource
        include DataMapper::Constraints

        property :id,      Serial
        property :title,   String, :nullable => false
        property :content, Text

        has 1, :revision
        has n, :comments
        has n, :authors, :through => Resource
      end

      class ::Author
        include DataMapper::Resource
        include DataMapper::Constraints

        property :first_name, String, :key => true
        property :last_name,  String, :key => true

        has n, :comments
        has n, :articles, :through => Resource
      end

      class ::Comment
        include DataMapper::Resource
        include DataMapper::Constraints

        property :id,   Serial
        property :body, Text

        belongs_to :article
        belongs_to :author
      end

      # Used to test a belongs_to association with no has() association
      # on the other end
      class ::Revision
        include DataMapper::Resource
        include DataMapper::Constraints

        property :id,   Serial
        property :text, String

        belongs_to :article
      end
    end

    describe 'create related objects' do
      before :all do
        class ::Comment
          belongs_to :article, :nullable => true
          belongs_to :author,  :nullable => true
        end

        class ::Revision
          belongs_to :article, :nullable => true
        end
      end

      it 'should be able to create related objects with a foreign key constraint' do
        @article = Article.create(:title => 'Man on the Moon')
        @comment = @article.comments.create(:body => 'So true!')
      end

      it 'should be able to create related objects with a composite foreign key constraint' do
        @author  = Author.create(:first_name => 'John', :last_name => 'Doe')
        @comment = @author.comments.create(:body => 'So true!')
      end

      it 'should not be able to create related objects with a failing foreign key constraint' do
        article = Article.create(:title => 'Man on the Moon')
        lambda { Comment.create(:body => 'So true!', :article_id => article_id.id + 1) }.should raise_error
      end
    end

    describe 'belongs_to without matching has association' do
      before do
        @article       = Article.create(:title => 'Man on the Moon')
        @other_article = Article.create(:title => 'Dolly cloned')
        @revision      = Revision.create(:text => 'Riveting!', :article => @other_article)
      end

      it 'should destroy the parent if there are no children in the association' do
        @article.destroy.should be_true
        @article.model.get(*@article.key).should be_nil
      end

      it 'the child should be destroyable' do
        @revision.destroy.should be_true
        @revision.model.get(*@revision.key).should be_nil
      end
    end

    describe 'constraint options' do
      describe 'when no constraint options are given' do
        before do
          @article      = Article.create(:title => 'Man on the Moon')
          @author       = Author.create(:first_name => 'John', :last_name => 'Doe')
          @other_author = Author.create(:first_name => 'Joe',  :last_name => 'Smith')
          @comment      = @other_author.comments.create(:body => 'So true!', :article => @article)
        end

        it 'should destroy the parent if there are no children in the association' do
          @author.destroy.should be_true
          @author.model.get(*@author.key).should be_nil
        end

        it 'should not destroy the parent if there are children in the association' do
          @other_author.destroy.should be_false
          @other_author.model.get(*@other_author.key).should_not be_nil
        end
      end

      describe 'when :constraint => :protect is given' do
        before :all do
          class ::Article
            has 1, :revision, :constraint => :protect
            has n, :comments, :constraint => :protect
            has n, :authors,  :constraint => :protect, :through => Resource
          end

          class ::Author
            has n, :comments, :constraint => :protect
            has n, :articles, :constraint => :protect, :through => Resource
          end

          class ::Comment
            belongs_to :article
            belongs_to :author
          end

          class ::Revision
            belongs_to :article
          end
        end

        describe 'one-to-one associations' do
          before do
            @article  = Article.create(:title => 'Man on the Moon')
            @revision = Revision.create(:text => 'Riveting!', :article => @article)
          end

          it 'should not destroy the parent if there are children in the association' do
            @article.destroy.should be_false
            @article.model.get(*@article.key).should_not be_nil
          end

          it 'the child should be destroyable' do
            @revision.destroy.should be_true
            @revision.model.get(*@revision.key).should be_nil
          end
        end

        describe 'one-to-many associations' do
          before do
            @article        = Article.create(:title => 'Man on the Moon')
            @author         = Author.create(:first_name => 'John', :last_name => 'Doe')
            @another_author = Author.create(:first_name => 'Joe',  :last_name => 'Smith')
            @comment        = @another_author.comments.create(:body => 'So true!', :article => @article)
          end

          it 'should destroy the parent if there are no children in the association' do
            @author.destroy.should be_true
            @author.model.get(*@author.key).should be_nil
          end

          it 'should not destroy the parent if there are children in the association' do
            @another_author.destroy.should be_false
          end

          it 'the child should be destroyable' do
            @comment.destroy.should be_true
            @comment.model.get(*@comment.key).should be_nil
          end
        end

        describe 'many-to-many associations' do
          before do
            @author         = Author.create(:first_name => 'John', :last_name => 'Doe')
            @another_author = Author.create(:first_name => 'Joe',  :last_name => 'Smith')
            @article        = Article.create(:title => 'Man on the Moon', :authors => [ @author ])
          end

          it 'should destroy the parent if there are no children in the association' do
            @another_author.destroy.should be_true
            @another_author.model.get(*@another_author.key).should be_nil
          end

          it 'should not destroy the parent if there are children in the association' do
            @author.articles.should_not == []
            @author.destroy.should be_false
          end

          it 'the child should be destroyable' do
            @article.authors.clear
            @article.save.should be_true
            @article.authors.should be_empty
          end
        end
      end

      describe 'when :constraint => :destroy! is given' do
        before :all do
          class ::Article
            has 1, :revision, :constraint => :destroy!
            has n, :comments, :constraint => :destroy!
            has n, :authors,  :constraint => :destroy!, :through => Resource
          end

          class ::Author
            has n, :comments, :constraint => :destroy!
            has n, :articles, :constraint => :destroy!, :through => Resource
          end

          class ::Comment
            belongs_to :article
            belongs_to :author
          end

          class ::Revision
            belongs_to :article
          end
        end

        describe 'one-to-one associations' do
          before do
            @article  = Article.create(:title => 'Man on the Moon')
            @revision = Revision.create(:text => 'Riveting!', :article => @article)
          end

          it 'should let the parent to be destroyed' do
            @article.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
          end

          it 'should destroy the children' do
            revision = @article.revision
            @article.destroy.should be_true
            revision.model.get(*revision.key).should be_nil
          end

          it 'the child should be destroyable' do
            @revision.destroy.should be_true
            @revision.model.get(*@revision.key).should be_nil
          end
        end

        describe 'one-to-many associations' do
          before do
            @article         = Article.create(:title => 'Man on the Moon')
            @author          = Author.create(:first_name => 'John', :last_name => 'Doe')
            @comment         = @author.comments.create(:body => 'So true!',     :article => @article)
            @another_comment = @author.comments.create(:body => 'Nice comment', :article => @article)
          end

          it 'should let the parent to be destroyed' do
            @author.destroy.should be_true
            @author.model.get(*@author.key).should be_nil
          end

          it 'should destroy the children' do
            @author.destroy.should be_true
            @author.comments.all? { |comment| comment.should be_new }
          end

          it 'the child should be destroyable' do
            @comment.destroy.should be_true
            @comment.model.get(*@comment.key).should be_nil
          end
        end

        describe 'many-to-many associations' do
          before do
            @article       = Article.create(:title => 'Man on the Moon')
            @other_article = Article.create(:title => 'Dolly cloned')
            @author        = Author.create(:first_name => 'John', :last_name => 'Doe', :articles => [ @article, @other_article ])
          end

          it 'should let the parent to be destroyed' do
            @author.destroy.should be_true
            @author.model.get(*@author.key).should be_nil
          end

          it 'should destroy the children' do
            @author.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
            @other_article.model.get(*@other_article.key).should be_nil
          end

          it 'the child should be destroyable' do
            @article.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
          end
        end
      end

      describe 'when :constraint => :destroy is given' do
        before :all do
          class ::Article
            has 1, :revision, :constraint => :destroy
            has n, :comments, :constraint => :destroy
            has n, :authors,  :constraint => :destroy, :through => Resource
          end

          class ::Author
            has n, :comments, :constraint => :destroy
            has n, :articles, :constraint => :destroy, :through => Resource
          end

          class ::Comment
            belongs_to :article
            belongs_to :author
          end

          class ::Revision
            belongs_to :article
          end
        end

        describe 'one-to-one associations' do
          before do
            @article  = Article.create(:title => 'Man on the Moon')
            @revision = Revision.create(:text => 'Riveting!', :article => @article)
          end

          it 'should let the parent to be destroyed' do
            @article.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
          end

          it 'should destroy the children' do
            revision = @article.revision
            @article.destroy.should be_true
            revision.model.get(*revision.key).should be_nil
          end

          it 'the child should be destroyable' do
            @revision.destroy.should be_true
            @revision.model.get(*@revision.key).should be_nil
          end
        end

        describe 'one-to-many associations' do
          before do
            @article       = Article.create(:title => 'Man on the Moon')
            @author        = Author.create(:first_name => 'John', :last_name => 'Doe')
            @comment       = @author.comments.create(:body => 'So true!',        :article => @article)
            @other_comment = @author.comments.create(:body => "That's nonsense", :article => @article)
          end

          it 'should let the parent to be destroyed' do
            @author.destroy.should be_true
            @author.model.get(*@author.key).should be_nil
          end

          it 'should destroy the children' do
            @author.destroy.should be_true
            @author.comments.all? { |comment| comment.should be_new }
          end

          it 'the child should be destroyable' do
            @comment.destroy.should be_true
            @comment.model.get(*@comment.key).should be_nil
          end
        end

        describe 'many-to-many associations' do
          before do
            @article       = Article.create(:title => 'Man on the Moon')
            @other_article = Article.create(:title => 'Dolly cloned')
            @author        = Author.create(:first_name => 'John', :last_name => 'Doe', :articles => [ @article, @other_article ])
          end

          it 'should destroy the parent and the children, too' do
            pending do
              @author.destroy.should be_true
              @author.model.get(*@author.key).should be_nil

              @article.should_not be_new
              @other_article.should_not be_new
            end
          end

          it 'the child should be destroyable' do
            @article.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
          end
        end
      end

      describe 'when :constraint => :set_nil is given' do
        before :all do
          # NOTE: M:M Relationships are not supported by :set_nil,
          # see 'when checking constraint types' tests at bottom

          class ::Article
            has 1, :revision, :constraint => :set_nil
            has n, :comments, :constraint => :set_nil
          end

          class ::Author
            has n, :comments, :constraint => :set_nil
          end

          class ::Comment
            belongs_to :article, :nullable => true
            belongs_to :author,  :nullable => true
          end

          class ::Revision
            belongs_to :article, :nullable => true
          end
        end

        describe 'one-to-one associations' do
          before do
            @article  = Article.create(:title => 'Man on the Moon')
            @revision = Revision.create(:text => 'Riveting!', :article => @article)
          end

          it 'should let the parent to be destroyed' do
            @article.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
          end

          it "should set the child's foreign_key id to nil" do
            revision = @article.revision
            @article.destroy.should be_true
            revision.article.should be_nil
            revision.model.get(*revision.key).article.should be_nil
          end

          it 'the child should be destroyable' do
            @revision.destroy.should be_true
            @revision.model.get(*@revision.key).should be_nil
          end
        end

        describe 'one-to-many associations' do
          before do
            @author        = Author.create(:first_name => 'John', :last_name => 'Doe')
            @comment       = @author.comments.create(:body => 'So true!')
            @other_comment = @author.comments.create(:body => "That's nonsense")
          end

          it 'should let the parent to be destroyed' do
            @author.destroy.should be_true
            @author.model.get(*@author.key).should be_nil
          end

          it 'should set the foreign_key ids of children to nil' do
            @author.destroy.should be_true
            @author.comments.all? { |comment| comment.author.should be_nil }
          end

          it 'the children should be destroyable' do
            @comment.destroy.should be_true
            @comment.model.get(*@comment.key).should be_nil

            @other_comment.destroy.should be_true
            @other_comment.model.get(*@other_comment.key).should be_nil
          end
        end
      end

      describe 'when :constraint => :skip is given' do
        before :all do
          class ::Article
            has 1, :revision, :constraint => :skip
            has n, :comments, :constraint => :skip
            has n, :authors,  :constraint => :skip, :through => Resource
          end

          class ::Author
            has n, :comments, :constraint => :skip
            has n, :articles, :constraint => :skip, :through => Resource
          end

          class ::Comment
            belongs_to :article
            belongs_to :author
          end

          class ::Revision
            belongs_to :article
          end
        end

        describe 'one-to-one associations' do
          before do
            @article  = Article.create(:title => 'Man on the Moon')
            @revision = Revision.create(:text => 'Riveting!', :article => @article)
          end

          it 'should let the parent be destroyed' do
            @article.destroy.should be_true
            @article.model.get(*@article.key).should be_nil
          end

          it 'should let the children become orphan records' do
            @article.destroy.should be_true
            @revision.model.get(*@revision.key).article.should be_nil
          end

          it 'the child should be destroyable' do
            @revision.destroy.should be_true
            @revision.model.get(*@revision.key).should be_nil
          end
        end

        describe 'one-to-many associations' do
          before do
            @article       = Article.create(:title => 'Man on the Moon')
            @author        = Author.create(:first_name => 'John', :last_name => 'Doe')
            @comment       = @author.comments.create(:body => 'So true!',        :article => @article)
            @other_comment = @author.comments.create(:body => "That's nonsense", :article => @article)
          end

          it 'should let the parent to be destroyed' do
            @author.destroy.should be_true
            @author.model.get(*@author.key).should be_nil
          end

          it 'should let the children become orphan records' do
            @author.destroy.should be_true
            @comment.model.get(*@comment.key).author.should be_nil
            @other_comment.model.get(*@other_comment.key).author.should be_nil
          end

          it 'the children should be destroyable' do
            @comment.destroy.should be_true
            @other_comment.destroy.should be_true
            @other_comment.model.get(*@other_comment.key).should be_nil
          end
        end

        describe 'many-to-many associations' do
          before do
            @article       = Article.create(:title => 'Man on the Moon')
            @other_article = Article.create(:title => 'Dolly cloned')
            @author        = Author.create(:first_name => 'John', :last_name => 'Doe', :articles => [ @article, @other_article ])
          end

          it 'the children should be destroyable' do
            pending do
              @article.destroy.should be_true
              @article.model.get(*@article.key).should be_nil
            end
          end
        end
      end

      describe 'when checking constraint types' do
        # M:M relationships results in a join table composed of composite (composed of two parts)
        # primary key.
        # Setting a portion of this primary key is not possible for two reasons:
        # 1. the columns are defined as :nullable => false
        # 2. there could be duplicate rows if more than one of either of the types
        #   was deleted while being associated to the same type on the other side of the relationshp
        #   Given
        #   Author(name: John Doe, ID: 1) =>
        #       Articles[Article(title: Man on the Moon, ID: 1), Article(title: Dolly cloned, ID: 2)]
        #   Author(Name: James Duncan, ID: 2) =>
        #       Articles[Article(title: Man on the Moon, ID: 1), Article(title: The end is nigh, ID: 3)]
        #
        #   Table authors_articles would look like (author_id, article_id)
        #     (1, 1)
        #     (1, 2)
        #     (2, 1)
        #     (2, 3)
        #
        #   If both articles were deleted and the primary key was set to null
        #     (null, 1)
        #     (null, 2)
        #     (null, 1) # duplicate error!
        #     (null, 3)
        #
        #   I would suggest setting :constraint to :skip in this scenario which will leave
        #     you with orphaned rows.
        it 'should raise an error if :set_nil is given for a M:M relationship' do
          lambda {
            class ::Article
              has n, :authors, :through => Resource, :constraint => :set_nil
            end

            class ::Author
              has n, :articles, :through => Resource, :constraint => :set_nil
            end
          }.should raise_error(ArgumentError)
        end

        it 'should raise an error if an unknown type is given' do
          lambda do
            class ::Author
              has n, :articles, :constraint => :chocolate
            end
          end.should raise_error(ArgumentError)
        end
      end
    end
  end
end
