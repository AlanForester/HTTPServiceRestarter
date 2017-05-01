require 'net/http'

loop do
  is_error = false

  file = "#{File.dirname(__FILE__)}/logs/#{Time.new.strftime("%Y-%m-%d")}.txt"
  f = File.open(file, "a")

  url = 'http://localhost:8888'
  url = URI.parse(url)
  req = Net::HTTP::Get.new(url.to_s)
  begin
    res = Net::HTTP.start(url.host, url.port, :read_timeout => 10) { |http|
      http.request(req)
    }
  rescue Net::ReadTimeout
    f.write "#{Time.now.to_s}: Timeout"
    is_error = true
  rescue Errno::ECONNREFUSED
    f.write "#{Time.now.to_s}: Failed to open TCP connection "
    is_error = true
  end

  unless is_error
    if res.code != '200'
      f.write "#{Time.now.to_s}: ERROR CODE #{res.code}"
      is_error = true
    else
      f.write "#{Time.now.to_s}: OKAY"
    end
  end

  if is_error
    system('service apache2 restart')
    sleep(5)
  end

  f.write "\n"
  f.close
  sleep(5)
end