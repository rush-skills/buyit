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
  rating = doc.css('.sd-product-main-rating')[0]["md-data-rating"]

  #Selenium
  # driver = Selenium::WebDriver.for :firefox
  # driver.navigate.to "http://topsy.com/s?q=moto%20g"
  # sentiment = driver.execute_script("return $('.sentiment-score').html()")
  # driver.quit
  #end selenium

  #hard code to skip selenium
  sentiment = "1"

  return {:sentiment => sentiment, :rating => rating}.to_json
end