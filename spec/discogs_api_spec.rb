require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

module DiscogsApiSpecHelper
  def mock_resource(api, resource, id, params = {})
    content = File.open(RAILS_ROOT + "/vendor/plugins/discogs_api/spec/mock-data/discogs-#{resource}-#{id}.json")
    api.should_receive(:open).exactly(1).times.with(any_args()).and_return(content)
  end

  def mock_search(api, response_type, criteria, page = 1)
    content = File.open(RAILS_ROOT + "/vendor/plugins/discogs_api/spec/mock-data/discogs-search-#{response_type}-#{criteria}-#{page}.json")
    api.should_receive(:open).exactly(1).times.with(any_args()).and_return(content)
  end
end

describe DiscogsApi do
  include DiscogsApiSpecHelper

  before(:each) do
    @api = DiscogsApi.new 'TestRubyClient/0.1 +http://testwebsite'
  end
  
  it "should use the provided constructor arg as the user_agent" do
    @api.user_agent.should == 'TestRubyClient/0.1 +http://testwebsite'
  end

  it "should use properly encoded URLs" do
    @api.resource_url('release', '1234').should == 'http://api.discogs.com/release/1234?f=json'
    @api.resource_url('artist', 'Van Halen').should == 'http://api.discogs.com/artist/Van+Halen?f=json'
    @api.resource_url('artist', 'Van Halen', {'releases', '1'}).should == 'http://api.discogs.com/artist/Van+Halen?f=json&releases=1'
  end

  it "should retrieve a master release" do
    mock_resource(@api, 'master', '45526')

    master = @api.get_master('45526')
    master.id.should == 45526
    master.main_release.should == 375379
    master.artists.first.name.should == "Beatles, The"
  end

  it "should retrieve a release" do
    mock_resource(@api, 'release', '375379')

    release = @api.get_release('375379')
    release.id.should == 375379
    release.title.should == 'Rubber Soul'
    release.artists.first.name.should == "Beatles, The"
    release.master_id.should == 45526
  end

  it "should retrieve an Artist" do
    mock_resource(@api, 'artist', 'Van Halen')

    artist = @api.get_artist('Van Halen')
    artist.name.should == 'Van Halen'
    artist.urls.first.should == "http://www.van-halen.com"
  end

  it "should retrieve a label" do
    mock_resource(@api, 'label', 'Sire')

    label = @api.get_label('Sire')
    label.name.should == 'Sire'
    label.parentLabel.should == 'Warner Bros. Records'
    label.urls.first.should == 'http://www.sirerecords.com/'
    label.sublabels.first.should == 'Discovery Records'
  end

  it "should search for releases first page when not specified" do
    mock_search(@api, 'releases', 'van')

    releases = @api.search_releases('van')
    releases.numResults.should == '83377'
    releases.start.should == '1'
    releases.results.first.title.should == 'Van - Ludwig Van'
    releases.results.last.title.should == 'Van Halen - Poundcake'
  end

  it "should search for releases specified page" do
    mock_search(@api, 'releases', 'van', 2)

    releases = @api.search_releases('van', 2)
    releases.numResults.should == '83377'
    releases.start.should == '21'
    releases.results.first.title.should == 'Alias (6) - Can I / Van Cleef'
    releases.results.last.title.should == 'Lars van Dalen - Uno'
  end

  it "should search for artists first page" do
    mock_search(@api, 'artists', 'van')

    artists = @api.search_artists('van')
    artists.numResults.should == '5521'
    artists.start.should == '1'
    artists.results.first.title.should == 'Van Cephus'
    artists.results.last.title.should == 'Van Valen'
  end

  it "should search for artists specified page" do
    mock_search(@api, 'artists', 'van', 2)

    artists = @api.search_artists('van', 2)
    artists.numResults.should == '5521'
    artists.start.should == '21'
    artists.results.first.title.should == 'van Andel'
    artists.results.last.title.should == 'Wim van Limpt'
  end

  it "should search for labels first page" do
    mock_search(@api, 'labels', 'van')

    labels = @api.search_labels('van')
    labels.numResults.should == '205'
    labels.start.should == '1'
    labels.results.first.title.should == 'Van Record Company'
  end

  it "should search for labels specified page" do
    mock_search(@api, 'labels', 'van', 2)

    labels = @api.search_artists('van', 2)
    labels.numResults.should == '205'
    labels.start.should == '21'
    labels.results.first.title.should == 'Funny Vinyl'
  end

end