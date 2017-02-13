require 'rack/throttle'
require 'gdbm'
class CustomLimiter < Rack::Throttle::Interval


  def allowed?(request)
      gdbm = GDBM.new("tmp/limits.db")
      api_key = request.has_header?('HTTP_AUTHORIZATION') ?
            request.get_header('HTTP_AUTHORIZATION').split(' ').last : nil

    if !api_key.nil?
        #puts gdbm.to_a
        gdbm[api_key] = "0" if gdbm[api_key].nil?
        limits = gdbm[api_key].to_i
        gdbm.close
        if limits < 100
            return true
        else
            t1 = request_start_time(request)
            t0 = cache_get(key = cache_key(request)) rescue nil
            allowed = !t0 || (dt = t1 - t0.to_f) >= minimum_interval
            begin
              cache_set(key, t1)
              allowed
                rescue => e
                  # If an error occurred while trying to update the timestamp stored
                  # in the cache, we will fall back to allowing the request through.
                  # This prevents the Rack application blowing up merely due to a
                  # backend cache server (Memcached, Redis, etc.) being offline.
                  allowed = true
                end
            end
        return allowed
    else
            return true
    end


  end
end
