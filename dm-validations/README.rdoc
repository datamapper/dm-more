This is a DataMapper plugin that provides validations for DataMapper model
classes.

== Setup
DataMapper validation capabilities are automatically available for DataMapper
resources when you require dm-validations' into your application. For
pure Ruby classes, require 'dm-validations' and then include DataMapper::Validate
module like so:

class ProgrammingLanguage
  #
  # Behaviors
  #

  include ::DataMapper::Validate

  #
  # Accessors
  #

  attr_accessor :name, :allows_manual_memory_management, :allows_optional_parentheses

  #
  # Validations
  #

  validates_present :name
  validates_with_method :ensure_allows_optional_parentheses,     :when => [:implementing_a_dsl]
  validates_with_method :ensure_allows_manual_memory_management, :when => [:doing_system_programming]
end


== Specifying Model Validations
There are two primary ways to implement validations for your models:

1) Placing validation methods with properties as params in your class
   definitions like:
   - validates_length :name
   - validates_length [:name, :description]

2) Using auto-validations, please see DataMapper::Validate::AutoValidate

An example class with validations declared:

  require 'dm-validations'

  class Account
    include DataMapper::Resource

    property :name, String
    validates_length :name
  end

See all of the DataMapper::Validate module's XYZValidator(s) to learn about the
complete collections of validators available to you.

== Validating
DataMapper validations, when included, alter the default save/create/update
process for a model.  Unless you specify a context the resource must be
valid in the :default context before saving.

You may manually validate a resource using the valid? method, which will
return true if the resource is valid, and false if it is invalid.

In addition to the valid? method, there is also an all_valid? method that
recursively walks both the current object and its associated objects and returns
its true/false result for the entire walk.

== Working with Validation Errors
If your validators find errors in your model, they will populate the
DataMapper::Validate::ValidationErrors object that is available through each of
your models via calls to your model's errors method.

For example:

  my_account = Account.new(:name => "Jose")
  if my_account.save
    # my_account is valid and has been saved
  else
    my_account.errors.each do |e|
      puts e
    end
  end

See DataMapper::Validate::ValidationErrors for all you can do with your model's
errors method.

== Contextual Validations

DataMapper Validations also provide a means of grouping your validations into
contexts. This enables you to run different sets of validations when you
need it. For instance, the same model may not only behave differently
when initially saved or saved on update, but also require special validation sets
for publishing, exporting, importing and so on.

Again, using our example for pure Ruby class validations:

class ProgrammingLanguage
  #
  # Behaviors
  #

  include ::DataMapper::Validate

  #
  # Accessors
  #

  attr_accessor :name, :allows_manual_memory_management, :allows_optional_parentheses

  #
  # Validations
  #

  validates_present :name
  validates_with_method :ensure_allows_optional_parentheses,     :when => [:implementing_a_dsl]
  validates_with_method :ensure_allows_manual_memory_management, :when => [:doing_system_programming]
end

ProgrammingLanguage instance now use #valid? method with one of two context symbols:

@ruby.valid?(:implementing_a_dsl)       # => true
@ruby.valid?(:doing_system_programming) # => false

@c.valid?(:implementing_a_dsl)       # => false
@c.valid?(:doing_system_programming) # => true

Each context causes different set of validations to be triggered. If you don't
specify a context using :when, :on or :group options (they are all aliases and do
the same thing), default context name is :default. When you do model.valid? (without
specifying context explicitly), again, :default context is used. One validation
can be used in two, three or five contexts if you like:

class Book

  #
  # Behaviors
  #

  # this time it is a DM model
  include ::DataMapper::Resource

  #
  # Accessors
  #

  property :id,           Serial
  property :name,         String

  property :agreed_title, String
  property :finished_toc, Boolean

  #
  # Validations
  #

  # used in all contexts, including default
  validates_present :name,         :when => [:default, :sending_to_print]
  validates_present :agreed_title, :when => [:sending_to_print]

  validates_with_block :toc, :when => [:sending_to_print] do
    if self.finished_toc
      [true]
    else
      [false, "TOC must be finalized before you send a book to print"]
    end
  end
end

In the example above, name is validated for presence in both :default context and
:sending_to_print context, while TOC related block validation and title presence validation
only take place in :sending_to_print context.
