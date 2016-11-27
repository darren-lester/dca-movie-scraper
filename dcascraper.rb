#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'date'

# Scrapes and outputs all movies.
def scrape
	monday = getMonday

	# create url to retrieve all movies from current date onwards
	allMoviesURL = "http://www.dca.org.uk/whats-on/films?from=#{monday.strftime("%Y-%m-%d")}&to=future"
	puts allMoviesURL
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
	titleNode = movieListingNode.css('.info')
	directorNode = movieListingNode.css('.subheading')
	dateNode = movieListingNode.css('.date')

	title = titleNode[0].text
	title.strip!
	# strip out newline and age rating
	title = title.sub(/\n\(.*\)/, '')

	director = directorNode[0].text

	date = dateNode[0].text

	return MovieListing.new(title, director, date)
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
