#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'date'

# Scrapes and outputs all movies.
def scrape
	monday = getMonday

	# create url to retrieve all movies from current date onwards
	allMoviesURL = getMoviesURL(monday)
	
	# retrieve page
	page = Nokogiri::HTML(open(allMoviesURL))

	# select the movies
	movieListingNodes = getMovieListingNodes(page)

	# parse the movies
	movieListings = parseMovieListings(movieListingNodes)
	
	return movieListings
end

def getMonday
	now = Date.today
	monday = now - (now.wday - 1) % 7

	return monday
end

def getMoviesURL(monday)
	return "http://www.dca.org.uk/whats-on/films?from=#{monday.strftime("%Y-%m-%d")}&to=future"
end

def getMovieListingNodes(page)
	return page.css('.event')
end

def parseMovieListings(movieListingNodes)
	movieListings = []
	movieListingNodes.each { |movieListingNode| movieListings << parseMovie(movieListingNode) }
	return movieListings
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

movieListings = scrape

# output the movies
movieListings.each { |movieListing| puts movieListing }
