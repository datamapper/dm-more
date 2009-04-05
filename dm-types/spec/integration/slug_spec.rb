# encoding: utf-8

require 'pathname'
require 'iconv'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Fixtures::Article do
  describe "persisted with title and slug set to 'New DataMapper Type'" do
    before :all do
      @input = 'New DataMapper Type'
      @model = DataMapper::Types::Fixtures::Article.create(:title => @input, :slug => @input)

      @model.reload
    end

    it "has slug equal to 'new-datamapper-type'" do
      @model.slug.should == "new-datamapper-type"
    end

    it "can be found by slug" do
      DataMapper::Types::Fixtures::Article.first(:slug => "new-datamapper-type").should == @model
    end
  end

  [
   ["Iñtërnâtiônàlizætiøn",      "internationalizaetion" ],
   ["This is Dan's Blog",        "this-is-dans-blog"],
   ["This is My Site, and Blog", "this-is-my-site-and-blog"],
   ["Google searches for holy grail of Python performance", "google-searches-for-holy-grail-of-python-performance"],
   ["iPhone dev: Creating length-controlled data sources", "iphone-dev-creating-length-controlled-data-sources"],
   ["Review: Nintendo's New DSi -- A Quantum Leap Forward", "review-nintendos-new-dsi-a-quantum-leap-forward"],
   ["Arriva BraiVe, è l'auto-robot che si 'guida' da sola'", "arriva-braive-e-lauto-robot-che-si-guida-da-sola"],
   ["La ley antipiratería reduce un 33% el tráfico online en Suecia", "la-ley-antipirateria-reduce-un-33-el-trafico-online-en-suecia"],
   ["L'Etat américain du Texas s'apprête à interdire Windows Vista", "letat-americain-du-texas-sapprete-a-interdire-windows-vista"]
  ].each do |title, slug|

    describe "persisted with title '#{title}'" do
      before :all do
        @model = DataMapper::Types::Fixtures::Article.new(:title => title)
        @model.save.should be_true
        @model.reload
      end

      it "has slug equal to '#{slug}'" do
        @model.slug.should == slug
      end

      it "can be found by slug" do
        DataMapper::Types::Fixtures::Article.first(:slug => slug).should == @model
      end
    end
  end
end
