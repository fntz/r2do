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

require 'yaml'

require 'r2do/category'
require 'r2do/task'
require 'r2do/exceptions'
require 'r2do/command'
require 'r2do/state'
require 'r2do/version'


module R2do
  class App

    # Creates an instance of the application.
    #
    # @param [Array] args the command line args.
    def initialize(args)
      @args = args
      @commands = create_commands()
      @modified = false

      @file_name = 'r2do_data.yml'
      if File.exists?(@file_name)
        file = File.open(@file_name, "rb")
        @state = YAML::load(file.read)
      else
        @state = State.new
      end
    end

    # Creates the list of commands the application responds to.
    #
    # @return [Hash] the collection of commands.
    def create_commands()
      cmd_list = Array.new
      cmd_list << Command.new('cat', '--category', 'NAME', 'description', method(:handle_category))
      cmd_list << Command.new('show', '--categories', nil, 'description', method(:show_categories))
      cmd_list << Command.new('now', '--current', nil, 'description', method(:show_current))
      cmd_list << Command.new('task', '--task', 'NAME', 'Adds a new task to the current category.', method(:handle_task))

      cmd_list << Command.new('-v', '--version', nil, 'Prints the application version.', method(:show_version))
      cmd_list << Command.new('-h', '--help', nil, 'You are looking at it.', method(:show_help))



      commands = Hash.new
      cmd_list.each do |cmd|
        commands[cmd.switch] = cmd
      end

      commands
    end

    # Evaluates the command passed by the user and calls the corresponding application command.
    #
    # @return [void]
    def run()
      option = @args[0]


      if @args.length > 0 and @commands.has_key?(option)
        cmd = @commands[option]
        cmd.execute(@args)
      elsif @args.length > 0
        invalid_command(option)
      else
        show_help(@args)
      end
    end


    def save()
      if @modified
        file = File.new(@file_name, 'w')
        file.write(YAML.dump(@state))
        file.close()
      end
    end


    def handle_category(args)
      if args.length < 2
        raise ArgumentError, "The 'cat' command requires a name argument."
      end

      new = ''
      category_name = args[1]
      if @state.contains?(category_name)
        cat = @state.get(category_name)
      else
        extra = 'new '
        cat = Category.new(category_name)
        @state.add(cat)
      end

      @state.set_current(cat)
      @modified = true

      puts "Switched to #{extra}category '#{category_name}'"
    end


    def handle_task(args)
      if @state.current_category
        task = Task.new(args[1])

        @state.current_category.add(task)
        puts "Created new task"
      end
    end


    def show_categories(args)
      @state.categories.each do |key, value|
        current = (value == @state.current_category && "*") || ' '
        puts "#{current} #{value.name}"
      end
    end


    def show_current(args)
      if not @state.current_category
        puts "No category is currently selected."
      else
        puts @state.current_category.name
      end
    end


    def invalid_command(option)
      puts "r2do: '#{option}' is not an r2do command. See 'r2do -h'."
    end

    def show_help(args)
      puts "The most commonly used r2do commands are:\n"

      @commands.each do |key, value|
        puts "   %s" % value.to_s()
      end
    end


    def show_version(args)
      puts R2do::VERSION
    end

  end

end