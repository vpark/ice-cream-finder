require 'addressable/uri'
require 'nokogiri'
require 'rest-open-uri'
require 'JSON'

class IceCreamFinder
  
  def place(geocode)
  Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/place/nearbysearch/json",
  :query_values => {location: geocode,
  rankby: "distance",
  types: "food",
  keyword: "ice cream",
  sensor: "false",
  key: "PLEASE INPUT YOUR OWN GOOGLE API KEY HERE"}
  ).to_s

  end

  def geocoding(address)
  Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/geocode/json",
  :query_values => {address: address,
  sensor: "false"}
  ).to_s
  end

  def directions(origin, destination)
  Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/directions/json",
  :query_values => {origin: origin,
    destination: destination,
    sensor: "false",
    mode: "walking"}
    ).to_s
  end

  def address_to_geocode(origin)
    html_doc = Nokogiri::HTML(open(geocoding(origin))) do |config|
      config.strict
    end

    parsed = JSON.parse(html_doc)
    geocode = parsed["results"].first["geometry"]["location"].values.join(",").to_s
  end

  def get_stores(geocode)
    html_doc = Nokogiri::HTML(open(place(geocode))) do |config|
      config.strict
    end

    parsed = JSON.parse(html_doc)
    destinations = {}
    parsed["results"].each do |store|
      destinations[store["name"]] = store["vicinity"]
    end
    destinations
  end

  def get_direction(geocode, destination)
    html_doc = Nokogiri::HTML(open(directions(geocode, destination))) do |config|
      config.strict
    end

    parsed = JSON.parse(html_doc)
    walking_direction = []
    parsed["routes"].first["legs"].first["steps"].each do |step|
      walking_direction << step["html_instructions"]
    end
    walking_direction
  end

  def display_choice(store_choices)
    index = 0
    store_choices.each do |name, address|
      puts "Choice: #{index}"
      puts "Store: #{name} At: #{address}"
      puts ""
      index += 1
    end
  end

  def parsed_step(step)
    parsed_step = Nokogiri::HTML(step)
    parsed_step.text
  end

  def ice_cream_finder
    puts "enter address: "
    origin = gets.chomp

    geocode = address_to_geocode(origin)
    store_choices = get_stores(geocode)

    display_choice(store_choices)
    puts "choose a store"
    response = gets.chomp

    destination_address = store_choices.values[response.to_i]
    walking_direction = get_direction(geocode, destination_address)

    walking_direction.each do |step|
      puts parsed_step(step)
    end
  end
end
      
ice_cream = IceCreamFinder.new
ice_cream.ice_cream_finder