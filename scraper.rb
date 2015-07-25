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

  photo_count = doc.css('#bx-pager-left-image-panel a').count
  content_length = doc.css('.comp-product-specs')[0].to_s.length
  more_styles = doc.css('.product-attribute-container ul li').count

  questions = doc.css('#qna-question-count-dialog-heading')[0].content.split(' ')[0].split('Q')[0] if doc.css('#qna-question-count-dialog-heading')[0]
  answers = doc.css('#qna-answer-count-dialog-heading')[0].content.split(' ')[0].split('A')[0] if doc.css('#qna-answer-count-dialog-heading')[0]
  discount = doc.css('.pdp-e-i-MRP-r-dis')[0].content.to_s if doc.css('.pdp-e-i-MRP-r-dis')[0]
  price = doc.css('.payBlkBig')[0].content.to_s if doc.css('.payBlkBig')[0]


  #Selenium
  # driver = Selenium::WebDriver.for :firefox
  # str = "http://topsy.com/s?q="+title
  # final_url = URI::encode(str)
  # driver.navigate.to final_url
  # sentiment = driver.execute_script("return $('.sentiment-score').html()")
  # driver.quit
  #end selenium

  #hard code to skip selenium
  sentiment = "1"

  #Send request to compare price
  # puts "Title = " + title.to_s
  price_content =JSON.parse open("http://api.dataweave.in/v1/price_intelligence/findProduct/?api_key=535a9366a1504e52e57fd2db33db31e50fe9658a&product="+title.downcase.tr(" ", "+").tr("&", "+")+"&page=1&per_page=10000").read
  high = -1
  low = 9999999999999999999999999999999999
  count = 0
  total = 0
  price_content["data"].each do |i|
    cp = i["available_price"].to_i
    unless cp == -1
      high =  cp if cp > high
      low = cp if cp < low
    end
    count +=1
    total += cp
  end

  average = total/count

  value = (price.gsub(',','').to_i - average)/average.to_f

  data_points =  {:sentiment => sentiment, :rating => rating,:rating_count => rating_count,:reviews_count => reviews_count,
    :seller_review => seller_review, :other_sellers => other_sellers, :title => title, :photo_count => photo_count,
    :content_length => content_length, :more_styles => more_styles, :questions => questions, :answers => answers,
    :discount => discount, :price => price, :high => high, :low => low, :average => average, value: value}

  result = algo(data_points)
  return result
  end

  def algo(data)

  end
end