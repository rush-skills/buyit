require 'rubygems'
require 'sinatra'
require 'spreadsheet'
require 'json'
require 'selenium-webdriver'
require 'nokogiri'
require 'open-uri'


get '/' do
  return "hello"
end

get '/*' do
  # Fetch and parse HTML document
  url = params["splat"][0].to_s
  doc = Nokogiri::HTML(open("http://" + url))

  rating = doc.css('.sd-product-main-rating')[0]["md-data-rating"] if doc.css('.sd-product-main-rating')[0]
  rating_count = doc.css('.showRatingTooltip')[0].content.to_s.split(" ")[0] if doc.css('.showRatingTooltip')[0]
  reviews_count = doc.css('.review_land')[0].content.to_s.split(" ")[0] if doc.css('.review_land')[0]
  seller_review = doc.css('.pdp-e-seller-info-score .roboto')[0].content.to_s.split(" ")[0] if doc.css('.pdp-e-seller-info-score .roboto')[0]
  other_sellers = doc.css('.pdp-other-sellers span')[0].content.to_s.split(" ")[0] if doc.css('.pdp-other-sellers span')[0]
  title = doc.css('.pdp-e-i-head')[0].content.to_s

  #Selenium
  driver = Selenium::WebDriver.for :firefox
  str = "http://topsy.com/s?q="+title
  final_url = URI::encode(str)
  driver.navigate.to final_url
  sentiment = driver.execute_script("return $('.sentiment-score').html()")
  driver.quit
  #end selenium

  #hard code to skip selenium
  # sentiment = "1"

  return {:sentiment => sentiment, :rating => rating,:rating_count => rating_count,:reviews_count => reviews_count, :seller_review => seller_review, :other_sellers => other_sellers, :title => title}.to_json
end