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

  class Task
    include DataMapper::Resource
   

    property :id,           Serial
    property :description,  String,   :key => true
    property :done,         Boolean,  :default => false   
    property :current,      Boolean,  :default => false
    property :date_created, DateTime
    property :date_done,    DateTime, :required => false     
    
    belongs_to :category
    validates_presence_of :description
    validates_length_of :description, :max => 30
    before :save, :set_date_time
    before :save do 
      t = Task.current
      #dirty
      if t  
        t.update!(:current => false)
      end
      self.current = true
    end
    
    def set_date_time
      self.date_created = DateTime.now
    end

    def self.current
      first(:current => true)
    end

    def self.completed 
      all(:done => true)
    end
    
    # Flags the specific task as completed.
    #
    # @return [DateTime] the date and time of completion.
    def completed()
      self.update!(:date_done => DateTime.now, :done => true)
    end
    # Returns a string representation of this Task
    #
    # @return [String] the representation of this Task
    def to_s()
      completed = ' '
      date = ''

      if done?
        completed = 'x'
        date = format_date()
      end

      return "[%s] %-30s %s" % [completed, self.description, self.date_created]
    end

    
    # Returns information regarding the state of this task.
    #
    # @return [String] the metadata for this task.
    def display()
      date = format_date()
      
      result = StringIO.new

      result << "Selected task:\n"
      result << "   %s\n\n" % self.description
      result << "Created:\n"
      result << "   %s" % self.date_created

      if done?
        result << "\nCompleted:\n"
        result << "   %s" % format_date()
      end

      return result.string
    end

    # Formats the date
    #
    # @return [String] the formatted date
    def format_date()
      self.date_created.strftime('%a %b %e, %Y')
    end
  end

end

