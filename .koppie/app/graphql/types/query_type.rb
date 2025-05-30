module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end

    field :resource, Types::Resource, null: true do
      description "Find a resource by ID"
      argument :id, ID, required: true
    end

    field :file_set, Types::Hyrax::FileSetType, null: true do
      description "Find a FileSet by ID"
      argument :id, ID, required: true
    end

    def resource(id:)
      resource = ::Hyrax.query_service.find_by(id: id)
      #return unless ability.can? :discover, resource
      resource
    rescue Valkyrie::Persistence::ObjectNotFoundError
      Valkyrie.logger.error("Failed to retrieve the resource #{id} for a GraphQL query")
      nil
    end

    def file_set(id:)
      file_set = ::Hyrax.query_service.find_by(id: id)
      file_set
    rescue Valkyrie::Persistence::ObjectNotFoundError
      Valkyrie.logger.error("Failed to retrieve the resource #{id} for a GraphQL query")
      nil
    end

    def change_set_persister
      context[:change_set_persister]
    end

    delegate :metadata_adapter, to: :change_set_persister
    #delegate :query_service, to: :metadata_adapter
  end
end
