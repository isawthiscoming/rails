require "rack/cache"
require "rack/cache/context"
require "active_support/cache"

module ActionDispatch
  class RailsMetaStore < Rack::Cache::MetaStore
    def self.resolve(uri)
      new
    end

    # TODO: Finally deal with the RAILS_CACHE global
    def initialize(store = RAILS_CACHE)
      @store = store
    end

    def read(key)
      @store.read(key) || []
    end

    def write(key, value)
      @store.write(key, value)
    end

    def purge(key)
      @store.delete(key)
      nil
    end

    ::Rack::Cache::MetaStore::RAILS = self
  end

  class RailsEntityStore < Rack::Cache::EntityStore
    def self.resolve(uri)
      new
    end

    def initialize(store = RAILS_CACHE)
      @store = store
    end

    def exist?(key)
      @store.exist?(key)
    end

    def open(key)
      @store.read(key)
    end

    def read(key)
      body = open(key)
      body.join if body
    end

    def write(body)
      buf = []
      key, size = slurp(body) { |part| buf << part }
      @store.write(key, buf)
      [key, size]
    end

    def purge(key)
      @store.delete(key)
    end

    ::Rack::Cache::EntityStore::RAILS = self
  end
end