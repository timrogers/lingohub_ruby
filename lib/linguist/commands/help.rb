module Linguist::Command
  class Help < Base
    class HelpGroup < Array

      attr_reader :title

      def initialize(title)
        @title = title
      end

      def command(name, description)
        self << [name, description]
      end

      def space
        self << ['', '']
      end
    end

    def self.groups
      @groups ||= []
    end

    def self.group(title, &block)
      groups << begin
        group = HelpGroup.new(title)
        yield group
        group
      end
    end

    def self.create_default_groups!
      return if @defaults_created
      @defaults_created = true
      group 'General Commands' do |group|
        group.command 'help',                         'show this usage'
        group.command 'version',                      'show the gem version'
        group.space
      end

      group 'Project Commands' do |group|
        group.command 'project:list',                         'list your projects'
        group.command 'project:create <name>',                'create a new project'
        group.command 'project:info <name>',                  'show project info, like web url and number of translations'
        group.command 'project:open <name>',                  'open the project in a web browser'
        group.command 'project:rename <oldname> <newname>',   'rename the project'
        group.command 'project:destroy <name',                'destroy the project permanently'
        group.space
      end

      group 'Collaborator Commands' do |group|
        group.command 'collaborator:list',           'list project collaborators'
        group.command 'collaborator:invite <email>', 'invite the collaborator'
        group.command 'collaborator:remove <email>', 'remove the collaborator'
        group.space
      end
    end

    def index
      display usage
    end

    def version
      display Linguist::Client.version
    end

    def usage
      longest_command_length = self.class.groups.map do |group|
        group.map { |g| g.first.length }
      end.flatten.max

      self.class.groups.inject(StringIO.new) do |output, group|
        output.puts "=== %s" % group.title
        output.puts

        group.each do |command, description|
          if command.empty?
            output.puts
          else
            output.puts "%-*s # %s" % [longest_command_length, command, description]
          end
        end

        output.puts
        output
      end.string
    end
  end
end

Linguist::Command::Help.create_default_groups!
