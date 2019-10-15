# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Hyrax
  module Transactions
    ##
    # Applies and saves a ChangeSet.
    #
    # @since 3.0.0
    #
    # @example Applying a ChangeSet to a Work
    #   work = Hyrax::Work.new
    #   change_set = Hyrax::ChangeSet.for(work)
    #   change_set.title = ['Comet in Moominland']
    #
    #   transaction = Hyrax::Transactions::ApplyChangeSet.new
    #   persisted   = transaction.call(change_set).value_or(:error)
    #
    #   persisted.persisted? # => true
    #   persisted.title      # => ['Comet in Moominland']
    #
    class ApplyChangeSet
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      DEFAULT_STEPS = ['change_set.set_modified_date',
                       'change_set.set_uploaded_date',
                       'change_set.validate',
                       'change_set.save'].freeze

      ##
      # @!attribute [rw] container
      #   @return [Container]
      # @!attribute [rw] steps
      #   @return [Array<String>]
      attr_accessor :container, :steps

      ##
      # @param [Container] container
      # @param [Array<String>] steps
      def initialize(container: Container, steps: DEFAULT_STEPS)
        self.container = container
        self.steps     = steps
      end

      ##
      # @param [Valkyrie::ChangeSet] change_set
      #
      # @return [Dry::Monads::Result]
      def call(change_set)
        Success(
          steps.inject(change_set) do |w, s|
            yield container[s].call(w)
          end
        )
      end
    end
  end
end
