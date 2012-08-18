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

 describe Task do
    describe "#validators" do
      it "should have description" do
        t = Task.create(:description => "")
        t.should_not be_valid
      end

      it "should have length of description lt 30 letters" do
        t = Task.create(:description => "1"*31)
        t.should_not be_valid
      end
    end

    describe "#current" do
      it "should set current" do
        c = Category.create(:name => "foo")
        c.tasks.create(:description => "foo")
        bar = c.tasks.create(:description => "bar")
        Task.current.should eq(bar)
      end
    end

    describe "#associations" do
      it { should belong_to(:category) }
    end
    
    describe "#completed" do
      it "should take all completed tasks" do
        c = Category.create(:name => "Foo")
        t1 = c.tasks.create(:description => "foo", :done => true)
        t2 = c.tasks.create(:description => "bar", :done => true)
        c.tasks.create(:description => "baz")
        Task.completed.should eq([t1, t2])
      end
    end
  end

end