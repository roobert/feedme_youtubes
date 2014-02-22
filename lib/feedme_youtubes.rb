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
  attr_accessor :feeds

  def initialize(hash)
    @config = ActiveSupport::HashWithIndifferentAccess.new(hash)
    @feeds  = []

    raise ArgumentError, "authors is not an Array" unless @config[:authors].class == Array

    @authors = @config[:authors]
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

  def to_s
    @feeds.map { |feed| feed.to_s }.join("\n")
  end

  ###
  # entry
  #

  class Entry
    attr_reader :title, :published, :link

    def initialize(title: title, published: published, link: link)
      @title       = title
      @published   = published
      @link        = link
      @remote_file = YoutubeDl::YoutubeVideo.new(link, { :location => "downloads/" })
    end

    def download
      @remote_file.video_filename
      @remote_file.download
    end

    def downloaded_state
      if File.exist? @remote_file.video_filename
        "+"
      else
        "-"
      end
    end

    def to_s
      "#{@published} [#{downloaded_state}] #{@title}"
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

    def to_s
      "#{@author}\n" + entries.each { |entry| entry.to_s }.join("\n")
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

        links = entry.xpath("link[@rel='alternate']['href']").map { |anchor| anchor['href'] }

        raise StandardError, "wrong number of links found on page!" if links.length != 1

        link = links[0]

        @entries << Entry.new(title: title, published: published, link: link) 
      end
    end
  end
end
