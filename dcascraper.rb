#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'date'

# Scrapes and outputs all movies.
def scrape
	monday = getMonday

	# create url to retrieve all movies from current date onwards
	allMoviesURL = "http://www.dca.org.uk/whats-on/films?from=#{monday.strftime("%Y-%m-%d")}&to=future"
	
	# retrieve page
	page = Nokogiri::HTML(open(allMoviesURL))

	# select the movies
	movieListingNodes = page.css('.event')

	# parse the movies
	movieListings = []
	movieListingNodes.each { |movieListingNode| movieListings << parseMovie(movieListingNode) }
	
	# output the movies
	movieListings.each { |movieListing| puts movieListing }
end

def getMonday
	now = Date.today
	monday = now - (now.wday - 1) % 7

	return monday
end

# Converts a movie listing node to a MovieListing object
def parseMovie(movieListingNode)
	title = parseTitle(movieListingNode)
	director = parseDirector(movieListingNode)
	date = parseDate(movieListingNode)
	return MovieListing.new(title, director, date)
end

def parseTitle(movieListingNode)
	titleNode = movieListingNode.css('.info')
	title = titleNode[0].text
	title.strip!
	# strip out newline and age rating
	title = title.sub(/\n\(.*\)/, '')
	return title
end

def parseDirector(movieListingNode)
	directorNode = movieListingNode.css('.subheading')
	director = directorNode[0].text
	return director
end

def parseDate(movieListingNode)
	dateNode = movieListingNode.css('.date')
	date = dateNode[0].text
	return date
end

class MovieListing
	def initialize(title, director, date)
		@title = title
		@director = director
		@date = date
	end

	def to_s
		return "#{@title} - #{@director} (#{@date})"
	end
end

scrape
