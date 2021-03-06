module Hyrax
  class Event
    ##
    # Creates an event in Redis
    #
    # @note it's advisable to use Hyrax::TimeService for timestamps, or use the
    #   `.create_now` method provided
    #
    # @example
    #
    # @param [String] action
    # @param [Integer] timestamp
    def self.create(action, timestamp)
      store.create(action, timestamp)
    end

    ##
    # @return [#create]
    def self.store
      Hyrax::RedisEventStore
    end

    ##
    # Creates an event in Redis with a timestamp generated now
    #
    # @param [String] action
    #
    # @return [Event]
    def self.create_now(action)
      create(action, Hyrax::TimeService.time_in_utc.to_i)
    end
  end
end
