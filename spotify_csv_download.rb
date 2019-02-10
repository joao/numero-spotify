require 'uri'
require 'net/https'
require 'date'


# https://spotifycharts.com/viral/pt/daily/latest/download

# Options:
# - top 200 or viral
# - global or regional
# - daily, weekly

endpoint = "https://spotifycharts.com/regional"
region = "pt"
chart_type = "daily" # daily, viral

sleep_interval = 2.5
export_folder = 'data'
export_path = File.join(Dir.pwd, export_folder) 

# Dates
start_date = Date.parse('20170101')
end_date = Date.parse('20181231')
interval = 1

current_date = start_date
date_range = [] # Array with dates to download
while (current_date <= end_date)
  date_range << current_date
  current_date = current_date + interval
end



date_range.each_with_index do |date, index|
  
  url = URI("#{endpoint}/#{region}/#{chart_type}/#{date}/download")

  puts "Download: #{index + 1}"
  puts "Date: #{date}"
  puts "Downloading CSV file..."

  puts url

  http = Net::HTTP.new(url.host, url.port)
  # enable HTTPS
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  # make request
  request = Net::HTTP::Get.new(url)

   begin
      retries ||= 0
      response = http.request(request)
    rescue
      retry if (retries += 1 ) < 10
      puts "Waiting to retry... attempt ##{retries.to_s}"
      sleep 10
  end

  puts "Saving CSV file..."

  # write file to disk
  filename = "#{region}_#{chart_type}_#{date}.csv"
  open(File.join(export_path, filename), "wb") do |file|
    file.write(response.read_body)
  end

  puts "#{date } CSV file saved."
  puts
  puts "Waiting #{sleep_interval}s}..."
  sleep sleep_interval
  puts
end

