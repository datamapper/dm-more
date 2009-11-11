require 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::List' do

    class User
      include DataMapper::Resource

      property :id, Serial
      property :name, String

      has n, :todos
    end

    class Todo
      include DataMapper::Resource

      property :id,    Serial
      property :title, String

      belongs_to :user

      is :list, :scope => [:user_id]
    end

    before :each do
      User.auto_migrate!
      Todo.auto_migrate!

      @u1 = User.create(:name => 'Johnny')
      Todo.create(:user => @u1, :title => 'Write down what is needed in a list-plugin')
      Todo.create(:user => @u1, :title => 'Complete a temporary version of is-list')
      Todo.create(:user => @u1, :title => 'Squash any reported bugs')
      Todo.create(:user => @u1, :title => 'Make public and await public scrutiny')
      Todo.create(:user => @u1, :title => 'Rinse and repeat')
      @u2 = User.create(:name => 'Freddy')
      Todo.create(:user => @u2, :title => 'Eat tasty cupcake')
      Todo.create(:user => @u2, :title => 'Procrastinate on paid work')
      Todo.create(:user => @u2, :title => 'Go to sleep')
    end

    ##
    # Keep things DRY shortcut
    #
    #   todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
    #
    #   todo_list(:user => @u2, :order => [:id]).should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
    #
    def todo_list(options={})
      options = { :user => @u1, :order => [:position] }.merge(options)
      Todo.all(:user => options[:user], :order => options[:order]).map{ |a| [a.id, a.position] }
    end

    describe "Class Methods" do

      describe "#repair_list" do

        it "should repair a scoped list" do
          DataMapper.repository(:default) do |repos|
            items = Todo.all(:user => @u1, :order => [:position])
            items.each{ |item| item.update(:position => [4,2,8,32,16][item.id - 1]) }
            todo_list.should == [ [2, 2], [1, 4], [3, 8], [5, 16], [4, 32] ]

            Todo.repair_list(:user_id => @u1.id)
            todo_list.should == [ [2, 1], [1, 2], [3, 3], [5, 4], [4, 5] ]
          end
        end

        it "should repair unscoped lists" do
          DataMapper.repository(:default) do |repos|
            Todo.all.map { |t| [t.id, t.position] }.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 1], [7, 2], [8, 3] ]
            Todo.repair_list
            # note the order, repairs lists based on position
            Todo.all.map { |t| [t.id, t.position] }.should == [ [1, 1], [2, 3], [3, 5], [4, 7], [5, 8], [6, 2], [7, 4], [8, 6] ]
            Todo.all(:order => [:position]).map { |t| t.id }.should == [1, 6, 2, 7, 3, 8, 4, 5]
          end
        end

      end #/ #repair_list

    end #/ Class Methods

    describe "Instance Methods" do

      describe "#move" do

        describe ":higher" do

          it "should move item :higher in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:higher).should == true
              todo_list.should == [ [2, 1], [1, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :higher when first in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:higher).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :higher

        describe ":lower" do

          it "should move item :lower in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:lower).should == true
              todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :lower when last in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:lower).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :lower

        describe ":up" do

          it "should move item :up in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:up).should == true
              todo_list.should == [ [2, 1], [1, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :up when first in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:up).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :up

        describe ":down" do

          it "should move item :down in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:down).should == true
              todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move :down when last in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:down).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :down

        describe ":top" do

          it "should move item to :top of list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:top).should == true
              todo_list.should == [ [5, 1], [1, 2], [2, 3], [3, 4], [4, 5] ]
            end
          end

          it "should NOT move item to :top of list when it is already first" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:top).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :top

        describe ":bottom" do

          it "should move item to :bottom of list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:bottom).should == true
              todo_list.should == [ [1, 1], [3, 2], [4, 3], [5, 4], [2, 5] ]
            end
          end

          it "should NOT move item to :bottom of list when it is already last" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:bottom).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :bottom

        describe ":highest" do

          it "should move item :highest in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:highest).should == true
              todo_list.should == [ [5, 1], [1, 2], [2, 3], [3, 4], [4, 5] ]
            end
          end

          it "should NOT move item :highest in list when it is already first" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:highest).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :highest

        describe ":lowest" do

          it "should move item :lowest in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:lowest).should == true
              todo_list.should == [ [1, 1], [3, 2], [4, 3], [5, 4], [2, 5] ]
            end
          end

          it "should NOT move item :lowest in list when it is already last" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:lowest).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :lowest

        describe ":above" do

          it "should move item :above another in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(3).move(:above => Todo.get(2) ).should == true
              todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :above itself" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:above => Todo.get(1) ).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :above a lower item (it's already above)" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:above => Todo.get(2) ).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move the item :above another item in a different scope" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:above => Todo.get(6) ).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :above

        describe ":below" do

          it "should move item :below another in list" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(:below => Todo.get(3) ).should == true
              todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :below itself" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:below => Todo.get(1) ).should == false  # is this logical ???
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move item :below a higher item (it's already below)" do
            DataMapper.repository(:default) do |repos|
              Todo.get(5).move(:below => Todo.get(4) ).should == false  # is this logical ???
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it "should NOT move the item :below another item in a different scope" do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).move(:below => Todo.get(6) ).should == false
              todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

        end #/ :below

        describe ":to" do

          describe "=> FixNum" do

            it "should move item to the position" do
              DataMapper.repository(:default) do |repos|
                Todo.get(2).move(:to => 3 ).should == true
                todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
              end
            end

            it "should NOT move item to a position above the first item in list (negative position)" do
              DataMapper.repository(:default) do |repos|
                Todo.get(2).move(:to => -33 ).should == true
                todo_list.should == [ [2, 1], [1, 2], [3, 3], [4, 4], [5, 5] ]
              end
            end

            it "should NOT move item to a position below the last item in list (out of range - position)" do
              DataMapper.repository(:default) do |repos|
                Todo.get(2).move(:to => 33 ).should == true
                todo_list.should == [ [1, 1], [3, 2], [4, 3], [5, 4], [2, 5] ]
              end
            end

          end #/ => FixNum

          describe "=> String" do

            it "should move item to the position" do
              DataMapper.repository(:default) do |repos|
                Todo.get(2).move(:to => '3' ).should == true
                todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
              end
            end

            it "should NOT move item to a position above the first item in list (negative position)" do
              DataMapper.repository(:default) do |repos|
                Todo.get(2).move(:to => '-33' ).should == true
                todo_list.should == [ [2, 1], [1, 2], [3, 3], [4, 4], [5, 5] ]
              end
            end

            it "should NOT move item to a position below the last item in list (out of range - position)" do
              DataMapper.repository(:default) do |repos|
                Todo.get(2).move(:to => '33' ).should == true
                todo_list.should == [ [1, 1], [3, 2], [4, 3], [5, 4], [2, 5] ]
              end
            end

          end #/ => String

        end #/ :to

        describe "X  (position as Integer)" do

          it "should move item to the position" do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(3).should == true
              todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]
            end
          end

          it "should move the same item to different positions multiple times" do
            DataMapper.repository(:default) do |repos|
              item = Todo.get(2)

              item.move(3).should == true
              todo_list.should == [ [1, 1], [3, 2], [2, 3], [4, 4], [5, 5] ]

              item.move(1).should == true
              todo_list.should == [ [2, 1], [1, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it 'should NOT move item to a position above the first item in list (negative position)' do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(-33).should == true
              todo_list.should == [ [2, 1], [1, 2], [3, 3], [4, 4], [5, 5] ]
            end
          end

          it 'should NOT move item to a position below the last item in list (out of range - position)' do
            DataMapper.repository(:default) do |repos|
              Todo.get(2).move(33).should == true
              todo_list.should == [ [1, 1], [3, 2], [4, 3], [5, 4], [2, 5] ]
            end
          end

        end #/ #move(X)

        describe "#move(:non_existant_vector_symbol)" do

          it "should raise an ArgumentError when given an un-recognised symbol value" do
            DataMapper.repository(:default) do |repos|
              lambda { Todo.get(2).move(:non_existant_vector_symbol) }.should raise_error(ArgumentError)
            end
          end

        end #/ #move(:non_existant_vector)

      end #/ #move

      describe "#list_scope" do

        describe 'without scope' do
          class Property
            include DataMapper::Resource

            property :id, Serial

            is :list
          end

          before do
            @property = Property.new
          end

          it 'should return an empty Hash' do
            DataMapper.repository(:default) do |repos|
              @property.list_scope.should == {}
            end
          end

        end

        describe 'with scope' do

          it 'should know the scope of the list the item belongs to' do
            DataMapper.repository(:default) do |repos|
              Todo.get(1).list_scope.should == {:user_id => @u1.id }
            end
          end

        end

      end #/ #list_scope

      describe "#original_list_scope" do

        it "should return a Hash" do
          Todo.get(2).original_list_scope.class.should == Hash
        end

        it 'should know the original list scope after the scope changes' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.user = @u2
            item.original_list_scope.should == {:user_id => @u1.id }
            item.original_list_scope.class.should == Hash
          end
        end

      end #/ #original_list_scope

      describe "#list_query" do

        it "should return a Hash" do
          Todo.get(2).list_query.class.should == Hash
        end

        it 'should return a hash with conditions to get the entire list this item belongs to' do
          DataMapper.repository(:default) do |repos|
            Todo.get(2).list_query.should == { :user_id => @u1.id, :order => [:position] }
          end
        end

      end #/ #list_query

      describe "#list" do

        it "should returns a DataMapper::Collection object" do
          Todo.get(2).list.class.should == DataMapper::Collection
          Todo.get(2).list(:user => @u2 ).class.should == DataMapper::Collection
          Todo.get(2).list(:user_id => nil).class.should == DataMapper::Collection
        end

        it "should return all list items in the current list item's scope" do
          DataMapper.repository(:default) do |repos|
            Todo.get(2).list.should == Todo.all(:user => @u1)
          end
        end

        it "should return all items in the specified scope" do
          DataMapper.repository(:default) do |repos|
            Todo.get(2).list(:user => @u2 ).should == Todo.all(:user => @u2)
          end
        end

      end #/ #list

      describe "#repair_list" do

        it 'should repair the list positions after a manually updated position' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(5)
            item.update(:position => 20)
            item.position.should == 20

            todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 20] ]

            item = Todo.get(5)
            item.repair_list
            item.position.should == 5
          end
        end

        it 'should repair the list positions in a really messed up list while retaining the order' do
          DataMapper.repository(:default) do |repos|
            # need to set these fixed in order to test the outcome
            new_positions = [ 83, 5, 186, 48, 99 ]
            Todo.all.each do |item|
              item.update(:position => new_positions[item.id-1] )
            end
            # note the order of item id's
            todo_list.should == [ [2, 5], [4, 48], [1, 83], [5, 99], [3, 186] ]

            item = Todo.get(5)
            item.repair_list
            # note position numbers being 1 - 5, and it retained the id positions
            todo_list.should == [ [2, 1], [4, 2], [1, 3], [5, 4], [3, 5] ]
          end
        end

      end #/ #repair_list

      describe "#reorder_list" do

        before do
          @u3 = User.create(:name => 'Eve')
          @todo_1 = Todo.create(:user => @u3, :title => "Clean the house")
          @todo_2 = Todo.create(:user => @u3, :title => "Brush the dogs")
          @todo_3 = Todo.create(:user => @u3, :title => "Arrange bookshelf")
        end

        it "should reorder the list based on the order options given" do
          DataMapper.repository(:default) do |repos|
            todo_list(:user => @u3).should == [ [9, 1], [10, 2], [11, 3] ]
            @todo_1.reorder_list([:title.asc]).should == true
            todo_list(:user => @u3).should == [ [11, 1], [10, 2], [9, 3] ]

            @todo_1.reorder_list([:title.desc]).should == true
            todo_list(:user => @u3).should == [ [9, 1], [10, 2], [11, 3] ]
          end
        end

      end #/ #reorder_list

      describe "#detach" do

        it 'should detach from list and retain scope' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.position.should == 2
            item.user.should == @u1

            item.detach

            item.original_list_scope.should == { :user_id => @u1.id }
            item.list_scope.should == { :user_id => @u1.id }
            # item.list_scope.should != item.original_list_scope  # FAIL. accepts both != and ==
            item.position.should == nil

            todo_list.should == [[1, 1], [2,nil], [3, 2], [4, 3], [5, 4]]
          end
        end

        it 'should detach from list and change scope' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.position.should == 2
            item.user.should == @u1

            item.detach(:user_id => 1)

            item.original_list_scope.should == { :user_id => @u1.id }
            item.list_scope.should == { :user_id => @u1.id }
            # item.list_scope.should != item.original_list_scope  # FAIL. accepts both != and ==
            item.position.should == nil

            todo_list.should == [[1, 1], [2,nil], [3, 2], [4, 3], [5, 4]]
          end
        end

      end #/ #detach

      describe "#move_to_list" do

        it "should move an item from one list to the bottom of another list" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            list_scope = Todo.get(6).list_scope
            list_scope.should == { :user_id => @u2.id }

            item.move_to_list(@u2.id)
            # equivalent of:
            #   item.detach
            #   item.user = @u2
            #   item.save
            #   item.reload

            todo_list(:user => @u1).should == [ [1, 1], [3, 2], [4, 3], [5, 4] ]

            todo_list(:user => @u2).should == [ [6, 1], [7, 2], [8, 3], [2, 4] ]
          end
        end

        it "should move an item from one list to a fixed position in another list" do
          pending %Q{Failing Test: Error = [ no such table: todos ]. Error is due to the nested transactions. (See notes in spec)}
          # NOTE:: This error happens because of the nested transactions taking place
          # first within the #move_to_list and then the #move method.
          # If you comment out either of those transactions, the test passes.

          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            list_scope = Todo.get(6).list_scope
            list_scope.should == { :user_id => @u2.id }

            item.move_to_list(@u2.id, 3)

            todo_list(:user => @u1).should == [ [1, 1], [3, 2], [4, 3], [5, 4] ]

            todo_list(:user => @u2).should == [ [6, 1], [7, 2], [2, 3], [8, 4] ]
          end
        end

      end #/ #move_to_list

      describe "#left_sibling (alias #higher_item or #previous_item)" do

        it "should return the higher item in list" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.left_sibling.should == Todo.get(1)
            item.higher_item.should == Todo.get(1)
            item.previous_item.should == Todo.get(1)
          end
        end

        it "should return nil when there's NO higher item" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(1)
            item.left_sibling.should == nil
            item.higher_item.should == nil
            item.previous_item.should == nil
          end
        end

      end #/ #left_sibling (alias #higher_item)

      describe "#right_sibling (alias #lower_item or #next_item)" do

        it "should return the lower item in list" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.right_sibling.should == Todo.get(3)
            item.lower_item.should == Todo.get(3)
            item.next_item.should == Todo.get(3)
          end
        end

        it "should return nil when there's NO lower item" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(5)
            item.right_sibling.should == nil
            item.lower_item.should == nil
            item.next_item.should == nil
          end
        end

      end #/ #right_sibling (alias #lower_item)

    end #/ Instance Methods

    describe "Workflows" do

      describe "CRUD" do

        # describe "#create" do
        #   pending
        # end #/ #create

        describe "Updating list items" do

          it "should NOT loose position when updating other attributes" do
            DataMapper.repository(:default) do |repos|
              item = Todo.get(2)
              item.position.should == 2
              item.user.should == @u1

              item.update(:title => "Updated")

              item = Todo.get(2)
              item.position.should == 2
              item.title.should == 'Updated'
              item.user.should == @u1
            end
          end

        end #/ Updating list items

        describe "Deleting items" do

          describe "using #destroy" do

            it 'should remove from list and old list should automatically repair positions' do
              DataMapper.repository(:default) do |repos|
                todo_list.should == [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
                Todo.get(2).destroy.should == true
                todo_list.should == [[1, 1], [3, 2], [4, 3], [5, 4] ]
              end
            end

          end #/ using #destroy

          describe "using #destroy!" do

            it 'should remove from list and old list does NOT automatically repair positions' do
              DataMapper.repository(:default) do |repos|
                todo_list.should == [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
                Todo.get(2).destroy!.should == true
                todo_list.should == [[1, 1], [3, 3], [4, 4], [5, 5] ]
              end
            end

          end #/ using #destroy!

        end #/ Deleting items

      end #/ CRUD

      describe 'Automatic positioning' do

        it 'should get the shadow variable of the last position' do
          DataMapper.repository do
            Todo.get(3).position = 8
            Todo.get(3).should be_dirty
            Todo.get(3).attribute_dirty?(:position).should == true
            Todo.get(3).original_attributes[ Todo.properties[:position] ].should == 3
            Todo.get(3).list_scope.should == Todo.get(3).original_list_scope
          end
        end

        it 'should insert items into the list automatically on create' do
          DataMapper.repository(:default) do |repos|
            todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]
            todo_list(:user => @u2).should == [ [6, 1], [7, 2], [8, 3] ]
          end
        end

      end # automatic positioning

      describe "Manual Positioning" do
        # NOTE:: The positions in the list does NOT change automatically when an item is given
        # a position via this syntax:
        #
        #   item.position = 4
        #   item.save
        #
        # Enabling this functionality (re-shuffling list on update) causes a lot of extra SQL queries
        # and ultimately still get the list order wrong when doing a batch update.
        #
        # This 'breaks' the common assumption of updating an item variable, but I think it's a worthwhile break

        it 'should NOT rearrange items when setting position manually' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.position = 1
            item.save

            todo_list.should == [ [1, 1], [2, 1], [3, 3], [4, 4], [5, 5] ] # note, the two items with 1 as position

            item.update(:position => 3)
            todo_list.should == [ [1, 1], [2, 3], [3, 3], [4, 4], [5, 5] ] # note, the two items with 3 as position
          end
        end

        it 'should NOT rearrange items when setting position manually via update()' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.update(:position => 1)

            todo_list.should == [ [1, 1], [2, 1], [3, 3], [4, 4], [5, 5] ] # note, the two items with 1 as position

            item.update(:position => 3)
            todo_list.should == [ [1, 1], [2, 3], [3, 3], [4, 4], [5, 5] ] # note, the two items with 3 as position
          end

        end

      end #/ Manual Positioning


      describe "Batch change item positions" do

        describe "when using item.position = N syntax " do

          it "should reverse the list" do
            DataMapper.repository(:default) do |repos|
              items = Todo.all(:user => @u1, :order => [:position])
              items.each{ |item| item.update(:position => [5,4,3,2,1].index(item.id) + 1) }
              todo_list.should == [ [5,1], [4,2], [3,3], [2,4], [1,5] ]
            end
          end

          it "should move the first item to last in list" do
            DataMapper.repository(:default) do |repos|
              items = Todo.all(:user => @u1, :order => [:position])

              items.each{ |item| item.update(:position => [2,3,4,5,1].index(item.id) + 1) }

              todo_list.should == [ [2,1], [3,2], [4,3], [5,4], [1,5] ]
            end
          end

          it "should randomly move items around in the list" do
            DataMapper.repository(:default) do |repos|
              items = Todo.all(:user => @u1, :order => [:position])

              items.each{ |item| item.update(:position => [5,2,4,3,1].index(item.id) + 1) }

              todo_list.should == [ [5,1], [2,2], [4,3], [3,4], [1,5] ]
            end
          end

        end #/ when using item.position = N syntax

        describe "when using item.move(N) syntax => [NB! create more SQL queries]" do

          it "should reverse the list => [NB! creates 5x the number of SQL queries]" do
            DataMapper.repository(:default) do |repos|
              items = Todo.all(:user => @u1, :order => [:position])

              items.each{ |item| item.move([5,4,3,2,1].index(item.id) + 1) }

              todo_list.should == [ [5,1], [4,2], [3,3], [2,4], [1,5] ]
            end
          end

          it "should move the first item to last in list" do
            DataMapper.repository(:default) do |repos|
              items = Todo.all(:user => @u1, :order => [:position])

              items.each{ |item| item.move([2,3,4,5,1].index(item.id) + 1) }

              todo_list.should == [ [2,1], [3,2], [4,3], [5,4], [1,5] ]
            end
          end

          it "should randomly move items around in the list" do
            DataMapper.repository(:default) do |repos|
              items = Todo.all(:user => @u1, :order => [:position])

              items.each{ |item| item.move([5,2,4,3,1].index(item.id) + 1) }

              todo_list.should == [ [5,1], [2,2], [4,3], [3,4], [1,5] ]
            end
          end

        end #/ when using item.move(N) syntax

      end #/ Re-ordering

      describe "Movements" do

        it "see the Instance Methods > #move specs above" do
          # NOTE:: keeping this in the specs since this group was here previously, but it's now redundant.
          # Should the tests be shared and used twice ?
          true.should == true
        end

      end #/ Movements

      describe "Scoping" do

        it 'should detach from old list if scope is changed and retain position in new list' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.position.should == 2
            item.user.should == @u1

            item.user = @u2
            item.save

            item.list_scope.should != item.original_list_scope
            item.list_scope.should == { :user_id => @u2.id }
            item.position.should == 2

            todo_list.should == [[1, 1], [3, 2], [4, 3], [5, 4]]

            todo_list(:user => @u2).should == [[6, 1], [2, 2], [7, 3], [8, 4]]
          end
        end

        it 'should detach from old list if scope is changed and given bottom position in new list if position is empty' do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(2)
            item.position.should == 2
            item.user.should == @u1

            item.position = nil  #  NOTE:: Creates a messed up original list.
            item.user = @u2
            item.save

            item.list_scope.should != item.original_list_scope
            item.list_scope.should == { :user_id => @u2.id }
            item.position.should == 4

            todo_list.should == [ [1, 1], [3, 3], [4, 4], [5, 5] ]  # messed up

            todo_list(:user => @u2).should == [ [6, 1], [7, 2], [8, 3], [2, 4] ]
          end
        end

        describe "when deleting item" do
          # see Workflows > CRUD > Deleting items
        end #/ when deleting item

      end #/ Scoping

      describe "STI inheritance" do

        it "should have some tests" do
          pending
        end

      end #/ STI inheritance

    end #/ Workflows


    describe "Twilight Zone" do

      #  NOTE:: I do not understand the reasons for this behaviour, but perhaps it's how it should be.
      #  Why does having two variables pointing to the same row prevent it from being updated ?
      #
      describe "accessing the same object via two variables" do

        before do
          @todo5 = Todo.get(5)
        end

        it "should NOT update list" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(5)
            item.position.should == 5
            item.position.should == @todo5.position

            @todo5.update(:position => 20) # this should update the position in the DB

            @todo5.position.should == 20
            todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]

            item.position.should == 5
          end
        end

        it "should update list when doing item.reload" do
          DataMapper.repository(:default) do |repos|
            item = Todo.get(5)
            item.position.should == 5
            item.position.should == @todo5.position

            @todo5.update(:position => 20) # this should update the position in the DB

            @todo5.position.should == 20
            todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 5] ]

            item.reload
            item.position.should == 20

            todo_list.should == [ [1, 1], [2, 2], [3, 3], [4, 4], [5, 20] ]
          end
        end

      end #/ accessing the same object via two variables

    end #/ Twilight Zone


    describe "With :unique_index => position defined" do

      class Client
        include DataMapper::Resource

        property :id, Serial
        property :name, String

        has n, :client_todos
      end

      class ClientTodo
        include DataMapper::Resource

        property :id,    Serial
        property :title, String
        property :position, Integer, :required => true, :unique_index => :position
        property :client_id, Integer, :unique_index => :position

        belongs_to :client

        is :list, :scope => [:client_id]
      end

      before :each do
        Client.auto_migrate!
        ClientTodo.auto_migrate!

        @u1 = Client.create(:name => 'Johnny')
        @u2 = Client.create(:name => 'Freddy')
      end

      before(:each) do
        @loop = 20
        @loop.times do |n|
          ClientTodo.create(:client => @u1, :title => "ClientTodo #{n+1}" )
        end
      end

      describe "should handle :unique_index => :position" do

        it "should generate all in the correct order" do
          DataMapper.repository(:default) do |repos|
            ClientTodo.all.map{ |a| [a.id, a.position] }.should == (1..@loop).map { |n| [n,n] }
          end
        end

        it "should move items :higher in list" do
          pending "Failing Test: Error = [ columns position, client_id are not unique ] (See notes in spec)"
          # NOTE:: This error happens because of the :unique_index => position setting.
          # Most likely the reason is due to the order of updates to the position attribute in the DB is NOT
          # fully consistant, and clashes therefore occur.
          # This could be solved(?) with adding an 'ORDER BY position' in the SQL for MySQL, but won't work with SQLite3
          #
          # Commenting out :unique_index => :position in the ClientTodo model enables the tests to pass.

          DataMapper.repository(:default) do |repos|
            ClientTodo.get(2).move(:higher).should == true
            ClientTodo.all.map{ |a| [a.id, a.position] }.should == [ [1, 2], [2, 1] ] + (3..@loop).map { |n| [n,n] }
          end
        end

        it "should move items :lower in list" do
          pending "Failing Test: Error = [ columns position, client_id are not unique ] (See notes in spec)"
          DataMapper.repository(:default) do |repos|
            ClientTodo.get(9).move(:lower).should == true
            ClientTodo.all.map{ |a| [a.id, a.position] }.should == (1..8).map { |n| [n,n] } + [ [9, 10], [10, 9] ] + (11..@loop).map { |n| [n,n] }
          end
        end

      end #/ should handle :unique_index => :position

    end #/ With :unique_index => position defined


  end

end
