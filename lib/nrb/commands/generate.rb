require 'nrb/commands/inside_group'

module Nrb
  module Commands
    class Generate < InsideGroup
      desc_with_warning "Generate a resource (#{Nrb.config.resources.join(', ')})"

      argument :resource, type: :string, required: true,
        desc: 'resource to generate',
        banner: 'RESOURCE',
        enum: Nrb.config.resources.map(&:singularize)

      argument :name, type: :string, required: true,
        desc: 'name of the resource',
        banner: 'NAME'

      def valid_resource?
        valid_resources = Nrb.config.resources.map(&:singularize)
        return true if valid_resources.include? resource
        message = "RESOURCE must be one of: #{valid_resources.join(', ')}."
        fail Nrb::InvalidResourceError, message
      end

      def generate_resource
        binding.pry

        template "templates/#{resource}.rb.tt", target("#{name.underscore}.rb"), options.merge({
          name: name.camelize
        })
      end

      def generate_table
        return unless resource == 'model'

        migration_name = "create_#{name.underscore.pluralize}"
        rake_options = args.join(' ')

        inside Nrb.root, options do
          run "rake db:new_migration name=#{migration_name} options='#{rake_options}'"
        end
      end

      private

      def target(final = nil)
        File.join(File.expand_path(resource.pluralize), final.to_s)
      end
    end
  end
end
