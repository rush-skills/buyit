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
  price = price.gsub(',','').to_i
  value = (price - average)/average.to_f

  data_points =  {:sentiment => sentiment.to_i, :rating => rating.to_f,:rating_count => rating_count.to_i,:reviews_count => reviews_count.to_i,
    :seller_review => seller_review.to_f, :other_sellers => other_sellers.to_i, :title => title, :photo_count => photo_count,
    :content_length => content_length, :more_styles => more_styles, :questions => questions.to_i, :answers => answers.to_i,
    :discount => discount.to_i, :price => price, :high => high, :low => low, :average => average, value: value}

  result = algo(data_points)
  # puts result
  # return data_points.to_json
  return result.to_s
end

r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

def algo(data)
  r1 = compute_rating(data)
  r2 = compute_seller(data)
  r3 = compute_other_seller(data)
  r4 = compute_photo data
  r5 = compute_content data
  r6 = compute_more_styles data
  r7 = compute_qa data
  r8 = compute_discount data
  r9 = compute_price_diff data
  r10 = compute_sentiment data

  total = 35 * r1 + 10 * r2 + 5 * r3 + 5 * r4 + 10 * r5 + 5 * r6 + 10 * r7 + 5 * r8 + 10 * r9 + 5 * r10
  final_rating = total/100.0
  final_rating.round

end

def compute_rating(data)
  unless data[:rating]
    0
  end
  if data[:rating_count] > 50 and data[:reviews_count] > 10
    if data[:rating] < 2
      r1 = 0
    elsif data[:rating] < 3.5 and data[:rating] > 2
      r1 = 1
    else
      r1 = 2
    end
  elsif data[:rating_count] > 10 and data[:reviews_count] > 1
    if data[:rating] < 3
      r1 = 0
    elsif data[:rating] < 4 and data[:rating] > 3
      r1 = 1
    else
      r1 = 2
    end
  else
    r1 = 0
  end

  r1
end

def compute_seller(data)
  unless data[:seller_review]
    0
  end
  if data[:seller_review] < 3.5
    r2 = 0
  elsif data[:seller_review] > 3.5 and data[:seller_review] < 4.5
    r2 = 1
  else
    r2 = 2
  end
  r2
end

def compute_other_seller(data)
  if data[:other_sellers] == 0
    r3 = 0
  elsif data[:other_sellers] < 3
    r3 = 1
  else
    r3 = 2
  end
  r3
end

def compute_photo(data)
  if data[:photo_count] == 0
    r4 = 0
  elsif data[:photo_count] == 1
    r4 = 1
  else
    r4 = 2
  end
  r4
end

def compute_content(data)
  unless data[:content_length]
    0
  end
  if data[:content_length] < 1500
    r5 = 0
  elsif data[:content_length] > 1500 and data[:content_length] < 5000
    r5 = 1
  else
    r5 = 2
  end
  r5
end

def compute_more_styles(data)
  if data[:more_styles] == 0
    r6 = 0
  elsif data[:more_styles] == 1
    r6 = 1
  else
    r6 = 2
  end
  r6
end

def compute_qa(data)
  unless data[:questions] and data[:answers]
    0
  end
  ratio = data[:answers]/data[:questions].to_f
  puts "Ratio = " + ratio.to_s
  if ratio < 0.25 or ratio.nan?
    r7 = 0
  elsif ratio > 0.25 and ratio < 0.5
    r7 = 1
  else
    r7 = 2
  end
  r7
end

def compute_discount(data)
  unless data[:discount]
    2
  end
  if data[:discount] > 75
    r8 = 0
  elsif data[:discount] >= 35
    r8 = 1
  else
    r8 = 2
  end
  r8
end

def compute_price_diff(data)
  if data[:value].abs > 1
    r9 = 0
  elsif data[:value].abs > 0.25 and data[:value].abs < 1
    r9 = 1
  else
    r9 = 2
  end
  r9
end

def compute_sentiment(data)
  if data[:sentiment] < 40
    r10 = 0
  elsif data[:sentiment] < 60
    r10 = 1
  else
    r10 = 2
  end
  r10
end  
