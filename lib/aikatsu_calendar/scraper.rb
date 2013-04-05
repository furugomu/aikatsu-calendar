#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require 'nokogiri'
require 'uri'
require 'json'
require 'open-uri'

module AikatsuCalendar
  class Scraper
    attr_accessor :year, :month, :day, :schedules

    def self.scrape(path=AikatsuCalendar::URL)
      scraper = new()
      doc = open(path) {|f| Nokogiri::HTML.parse(f) }
      scraper.feed(doc)
      scraper.schedules.uniq do |x|
        [x[:type], x[:content], x[:date_from], x[:date_until]]
      end
    end

    def initialize
      @schedules = []
    end

    def feed(doc)
      container = doc.at_css(".info-schedule")
      container.css('table').each do |table|
        feed_table(table)
      end
    end

    def feed_table(table)
      # 年と月
      text = table.at_css('th').text
      m = text.match(/(\d+)年(\d+)月/) or raise ValueError, text
      @year = m[1].to_i
      @month = m[2].to_i

      table.css('tr')[1..-1].each do |tr|
        feed_row(tr)
      end
    end

    def feed_row(tr)
      # 日付
      text = tr.at_css('td').text
      m = text.match(/(\d+)日/) or raise ValueError, text
      @day = m[1].to_i

      tr.css('p').each do |p|
        feed_item(p)
      end
    end

    def feed_item(p)
      @schedules << parse_item(p)
    end

    def parse_item(p)
      # 日付
      text = p.text
      re = /(?:　※)?(\d+)年(\d+)月(\d+)日～(?:(\d+)年)?(\d+)月(\d+)日/
      m = text.match(re)
      if m
        year_until = (m[4] || m[1]).to_i
        date_from = Time.local(m[1].to_i, m[2].to_i, m[3].to_i)
        date_until = Time.local(year_until, m[5].to_i, m[6].to_i)
      else
        date_from = date_until = Time.local(@year, @month, @day)
      end
      # 日付をとっぱらう
      text = text.sub(re, '')

      # URL
      url = nil
      if (a = p.at_css('a[href]'))
        base = 'http://www.aikatsu.com/calender/'
        url = URI.join(base, a.attr(:href)).to_s
      end

      # type
      type = class_to_type(p.attr(:class))

      {
        type: type,
        date_from: date_from,
        date_until: date_until,
        content: text.strip,
        link: url,
      }
    end

    def class_to_type(s)
      if s =~ /schedule-(\w+)/
        $1
      else
        nil
      end
    end

    def to_json(pretty=false)
      if pretty
        JSON.pretty_generate(@schedules)
      else
        JSON.dump(@schedules)
      end
    end
  end
end
