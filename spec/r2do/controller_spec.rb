#
#  Copyright 2012 Christian Giacomi http://www.christiangiacomi.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

require 'spec_helper'

module R2do

  describe State do

    before :each do
      @state = State.new()    
    end

    describe "#new" do
      context "default constructor" do
        it "returns a State object" do
          @state.should be_an_instance_of State
        end

        it "contains no Categories" do
          @state.should have(0).categories
        end

        it "has no selected category" do
          @state.current_category.should eql nil
        end
      end
    end

    describe "#current category" do
      before(:each) {
        @foo = Category.create(:name => "foo")
        @bar = Category.create(:name => "bar")
        @state = State.new
      }

      it "should set current category by name" do
        @state.categories.size.should eq(2)
        @state.current_category.should eq(@bar)
        @state.set_current("foo")
        @state.current_category.should eq(@foo)
      end

      it "should raise error if category not found" do
        expect { @state.set_current("zed") }.to raise_error(CategoryNotFoundError)
      end

      it "should set to nil current category" do
        @state.clear_current_category()
        @state.current_category.should eq(nil)
      end
    end

    describe "#contains" do
      it "should return true if state contain category" do
        Category.create(:name => "foo")
        Category.create(:name => "bar")
        state = State.new
        state.contains?("foo").should eq(true)
        state.contains?("bar").should eq(true)
        state.contains?("baz").should eq(false)
      end
    end

    describe "#get" do
      before(:each) {
        @foo = Category.create(:name => "foo")
        @bar = Category.create(:name => "bar")
        @state = State.new
      }
      it "should return category" do
        @state.get("foo").should eq(@foo)
        @state.get("bar").should eq(@bar)
        @state.get("zed").should eq(nil)
      end
    end

    describe "#add" do
      context "adding one category" do
        it "contains one category" do
          @state.add(:name => "A sample category")
          @state.should have(1).categories
        end
      end
    end

    describe "#refresh" do
      before(:each) {
        Category.create(:name => "foo")
        Category.create(:name => "bar")
        @state = State.new
      }
      it "should rename category" do
        @state.refresh("foo", "baz")
        @state.categories.first.name.should eq("baz")
      end
      it "should raise error if new name exist" do
        expect { @state.refresh("foo", "bar") }.to raise_error(CategoryAlreadyExistsError)
      end
      it "should raise error if name not found" do
        expect { @state.refresh("baz", "bar") }.to raise_error(CategoryNotFoundError)
      end
    end

    describe "#remove" do
      it "should remove category" do
        Category.create(:name => "foo")
        state = State.new
        state.categories.size.should eq(1)
        state.remove("foo")
        state.categories.size.should eq(0)
        Category.all.size.should eq(0)
      end
      it "should raise error if category not found" do
        state = State.new
        expect { @state.remove("baz") }.to raise_error(CategoryNotFoundError)
      end
    end
  end
end