# frozen_string_literal: true

require_relative './config'

module RemoteRecord
  # RemoteRecord uses the Active Record Types system to serialize to and from a
  # remote resource.
  class Type < ActiveRecord::Type::Value
    class_attribute :config, default: RemoteRecord::Config.defaults, instance_writer: false, instance_predicate: false
    class_attribute :parent, instance_writer: false, instance_predicate: false

    def type
      :string
    end

    def cast(_remote_resource_id)
      raise 'cast not defined'
    end

    def deserialize(value)
      cast(value)
    end

    def serialize(representation)
      return representation.remote_resource_id if representation.respond_to? :remote_resource_id

      representation.to_s
    end

    def self.for(remote_record_class)
      Class.new(self) do |type|
        type.parent = remote_record_class
        def self.[](config_override)
          Class.new(self).tap { |configured_type| configured_type.config = config_override }
        end

        def cast(remote_resource_id)
          return remote_resource_id if remote_resource_id.is_a?(parent)

          parent.new(remote_resource_id, config)
        end
      end
    end
  end
end
