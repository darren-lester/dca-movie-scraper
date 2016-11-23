#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

# Scrapes and outputs all movies.
def scrape
	# create url to retrieve all movies from current date onwards
	allMoviesURL = "http://www.dca.org.uk/whats-on/films?from=#{Time.now.strftime("%Y-%m-%d")}&to=future"

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

# Converts a movie listing node to a MovieListing object
def parseMovie(movieListingNode)
	titleNode = movieListingNode.css('.info')
	directorNode = movieListingNode.css('.subheading')
	dateNode = movieListingNode.css('.date')

	title = titleNode[0].text
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
