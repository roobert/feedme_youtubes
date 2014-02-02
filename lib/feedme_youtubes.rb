#!/usr/bin/env ruby

require "feedme_youtubes/version"
require 'nokogiri'
require 'open-uri'
require 'awesome_print'
require 'youtube_dl'
require 'active_support/hash_with_indifferent_access'

# TODO:
# ncurses that launches mplayer (cos nice interface..)
# web interface on sinatra app with link to web page...

class FeedmeYoutubes
  def initialize(hash)
    @config = ActiveSupport::HashWithIndifferentAccess.new(hash)
    @feeds  = Feeds.new(@config[:authors])
  end

  def update
    @feeds.update
  end

  ###
  # entry
  #

  class Entry
    def initialize(title: title, published: published, link: link)
      @title     = title
      @published = published
      @link      = link
    end
  end

  ###
  # feed
  #

  class Feed
    attr_reader   :author
    attr_reader   :url
    attr_accessor :entries

    def initialize(author)
      @author   = author
      @feed_url = "https://gdata.youtube.com/feeds/api/users/#{author}/uploads"
      @entries = []
    end

    def update
      update_feed
      update_info
      update_entries
    end

    def update_feed
      @feed = Nokogiri::HTML(open(@feed_url))
    end

    def update_info
      @url     = @feed.xpath('id').text
      @updated = @feed.xpath('updated')
    end

    def update_entries
      @feed.xpath("//entry").each do |entry|
        title     = entry.xpath("title").text
        published = Date.parse(entry.xpath("published").text)
        link      = entry.xpath("link[@rel='alternate']").text

        @entries << Entry.new(title: title, published: published, link: link) 
      end
    end
  end

  ###
  # get rid of this?
  #

  class Feeds
    attr_accessor :feeds

    def initialize(authors)
      raise ArgumentError, "authors is not an Array" unless authors.class == Array

      @authors = authors
      @feeds   = []
    end

    def update
      populate_feeds
      update_feeds
    end

    def populate_feeds
      @feed = []
      @authors.each { |author| @feeds << Feed.new(author) }
    end

    def update_feeds
      @feeds.each { |feed| feed.update }
    end
  end
end
