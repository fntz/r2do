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

module R2do
 
  class Category
    include DataMapper::Resource

    property :id,         Serial
    property :name,       String,  :key => true
    property :current,    Boolean, :default => false
    validates_presence_of :name
    validates_uniqueness_of :name
    
    before :save do 
      Category.clear
      self.current = true
    end
    has n, :tasks

    def current?
      self.current
    end

    def find_by_description(description)
      self.tasks.first(:description => description)
    end
    
    # Returns a string representation of this Category
    #
    # @return [String] the representation of this Category
    def to_s
      count = 0
      result = StringIO.new
 
      result << "%s:\n\n" % [self.name]
      result << "    %-30s     %s\n" % ["Task", "Completed"]
      result << "    " << "-"*51
      result << "\n"

      self.tasks.each do | task |
        count += 1
        result << "    %s\n" % task.description
      end
      return result.string
    end

    class << self
      def clear  
        ccur = Category.current
        ccur.update!(:current => false) if ccur 
      end
      
      def current
        first(:current => true)
      end

      def current=(other)
        Category.clear
        other.update!(:current => true)
      end

      def contains?(name)
        !all(:name => name).first.nil?
      end
    end  
  end
end

