module CacheHelper
  extend ActiveSupport::Concern

  included do
    # Ensure Rails cache is available even in development/test
    Rails.cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  # Read value directly from cache
  def read_cache(key)
    Rails.logger.info("Reading cache for key: #{key}")
    Rails.cache.read(key)
  end

  # Write value to cache with optional expiration
  def write_cache(key, value, expires_in: 1.hour)
    Rails.logger.info("Writing cache for key: #{key} (expires_in: #{expires_in.inspect})")
    Rails.cache.write(key, value, expires_in: expires_in)
  end

  # 🔹 Fetch with fallback — if cache miss, block result will be cached
  def fetch_cache(key, expires_in: 1.hour)
    Rails.logger.info("Fetching cache for key: #{key}")

    Rails.cache.fetch(key, expires_in: expires_in) do
      Rails.logger.info("Cache miss for key: #{key}, executing block...")
      result = yield
      if result.nil?
        Rails.logger.warn("Fetch block for #{key} returned nil — not caching.")
      end
      result
    end
  end

  # Delete cache manually if needed
  def delete_cache(key)
    Rails.logger.info("Deleting cache for key: #{key}")
    Rails.cache.delete(key)
  end

  # Check if key exists in cache
  def cache_exists?(key)
    Rails.cache.exist?(key)
  end
end
