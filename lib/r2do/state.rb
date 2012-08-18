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

  class State
    # @return [Hash] the collection of categories created by the user.
    attr_reader :categories
    
    # Creates a new instance of the State
    #
    def initialize()
      init()
    end

    def init()
      @categories = Category.all
    end

    def reset()
      init()
    end

    def current_category
      Category.current || nil
    end
    
    # Sets a Category as the current one.
    #
    # @param [category_name] name the category to be set as current.
    # @raise [CategoryNotFoundError] if category not found 
    # @return [void]
    def set_current(category_name)
      category = Category.first(:name => category_name)
      raise CategoryNotFoundError.new if category.nil?
      Category.current = category
    end

    # Clears the current category
    #
    # return [void]
    def clear_current_category()
      Category.current.update!(:current => false)
    end

    # Checks if a category with a specific name already exists.
    #
    # @param [String] category_name the name of the category to check.
    # @return [bool] true if the category is already present.
    def contains?(category_name)
      return Category.contains?(category_name)
    end

    # Retrieves a specific Category.
    #
    # @param [String] category_name the name of the category to retrieve.
    # @return [Category] the category identified by category_name.
    def get(category_name)
      Category.first(:name => category_name)
    end

    # Adds a category.
    #
    # @param [Category] must be hash with attributes.
    # @return [void]
    # Example
    # @state.add({:name => 'foo'})
    def add(category)
      Category.create(category)
    end

    #Rename category
    # @param original_name - name for category
    # @param new_category  - new name for category
    # @raise [CategoryAlreadyExistsError] 
    # @raise [CategoryNotFoundError]
    def refresh(original_name, new_category)
      old = Category.first(:name => original_name)
      unless old.nil?
        raise CategoryAlreadyExistsError.new if Category.first(:name => new_category)
        old.update!(:name => new_category)
      else 
        raise CategoryNotFoundError.new   
      end
    end

    # Removes the category from the state and from table.
    #
    # @param [Category] category the category to remove.
    # @raise [Exceptions::CategoryNotFoundError] if category is not found.
    # @return [void]
    def remove(category)
      cat = Category.first(:name => category)
      @categories.delete(cat) { raise CategoryNotFoundError.new() }
      cat.destroy
    end
  end
end