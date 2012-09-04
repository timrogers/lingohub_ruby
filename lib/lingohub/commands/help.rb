module Lingohub::Command
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
        group.command 'login',                        "let's you (re)login"
        group.command 'logout',                       'logs you out by clearing your current credentials'
      end

      group 'Project Commands' do |group|
        group.command 'project:list',                         'list your projects'
        group.command 'project:create <name>',                'create a new project'
        group.command 'project:info --project <name>',        'show project info, like web url and number of translations'
        group.command 'project:open --project <name>',        'open the project in a web browser'
        group.command 'project:rename <oldname> <newname>',   'rename the project'
        group.command 'project:deactivate --project <name>',   'deactivates the project'
        group.command 'project:activate --project <name>',   'activates a deactivated project again'
        group.space
      end

      group 'Collaborator Commands' do |group|
        group.command 'collaborator:list --project <name>',           'list project collaborators'
        group.command 'collaborator:invite <email> --project <name>', 'invite the collaborator'
        group.command 'collaborator:remove <email> --project <name>', 'remove the collaborator'
        group.space
      end

      group 'Translation Commands' do |group|
        group.command 'resource:down --all --directory <path> --project <name>',                                          'download all resource files'
        group.command 'resource:down --locale <iso2_code> --all --directory <path> --project <name>',                     'download all resource files, using the given locale as filter'
        group.command 'resource:down <file1> <file2> ... --directory <path> --project <name>',                            'download specific resource files'
        group.command 'resource:up <file1> <file2> ... --locale <iso2_code> --project <name>',                            'upload specific resource files, a locale may be specified to tell lingohub the locale of file content'
        group.space
      end
    end

    def index
      display usage
    end

    def version
      display Lingohub::Client.version
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

Lingohub::Command::Help.create_default_groups!
