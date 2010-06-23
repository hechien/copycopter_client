require 'net/http'
require 'uri'
require 'active_support'

# Capistrano tasks for notifying Skywriter of deploys
module SkywriterTasks

  # Alerts Skywriter of a deploy.
  #
  # @param [Hash] opts Data about the deploy that is set to Skywriter
  #
  # @option opts [String] :to Environment of the deploy (production, staging)
  # @option opts [String] :from Environment you are deploying from (production, staging)
  def self.deploy(opts = {})
    if SkywriterClient.configuration.api_key.blank?
      puts "I don't seem to be configured with an API key.  Please check your configuration."
      return false
    end

    if opts[:to].blank? || opts[:from].blank?
      puts "I don't know to which Rails environment to which you are deploying (use the TO=production option)."
      return false
    end
    params = {}
    api_key = opts.delete(:api_key) || SkywriterClient.configuration.api_key
    opts.each {|k,v| params["deploy[#{k}]"] = v }

    http = Net::HTTP.new("#{SkywriterClient.configuration.host || 'skywriterapp.com'}")
    response, data = http.post('/api/v1/deploys', params.map{|k,v| "#{k}=#{v}"}.join("&"), {'X-API-KEY' => api_key})
    puts response.body
    return Net::HTTPSuccess === response
  end
end
