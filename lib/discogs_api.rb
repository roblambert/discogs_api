require 'open-uri'

# Provides simple access to the Discogs 2.0 API (see http://www.discogs.com/help/api)
#
# This plugin simply retrieves JSON from the Discogs API and wraps the response in a Hashie::Mash
# to return pseudo-objects that have method-like accessors.
module DiscogsApi

  BASE_URL = 'http://api.discogs.com'

  def self.user_agent=(value)
    @@user_agent = value
  end

  def self.get_master(id)
    get_resource('master', id)
  end

  def self.get_release(id)
    get_resource('release', id)
  end

  def self.search_releases(criteria, page = 1)
    search(criteria, 'releases', page)
  end

  def self.get_artist(artist_name)
    get_resource('artist', artist_name, {'releases'=>'1'}) #include artist releases per http://www.discogs.com/help/forums/topic/234163
  end

  def self.search_artists(criteria, page = 1)
    search(criteria, 'artists')
  end

  def self.get_label(label_name)
    get_resource('label', label_name)
  end

  def self.search_labels(criteria, page = 1)
    search(criteria, 'labels')
  end
  
  def self.resource_url(resource, id, params = {})
    "#{BASE_URL}/#{resource}/#{CGI.escape(id.to_s)}?f=json#{params.keys.sort.inject(""){|string,key| "#{string}&#{key}=#{CGI.escape(params[key].to_s)}"}}"
  end
  
  private

  def self.get_resource(resource, id, params = {})
    retrieve_data(resource, resource_url(resource, id, params))
  end
  
  def self.retrieve_data(response_type, url)
    #TODO: deal w/ gzipped content
    JSON.parse(open(url, {'UserAgent'=> @@user_agent,'Accept-Encoding'=>'gzip'}).read)["resp"][response_type]     
  end
  
  def self.search(criteria, resource_type = 'all', page = 1)
    retrieve_data('search', search_url(criteria, resource_type))["searchresults"]
  end
  
  def self.search_url(criteria, resource_type, page = 1 )
    "#{BASE_URL}/search?type=#{resource_type}&f=json&page=#{page}&q=#{CGI.escape(criteria)}"
  end

end