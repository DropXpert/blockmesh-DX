require 'net/http'
require 'json'
require 'uri'
require 'colorize'
require 'securerandom'
require 'websocket-client-simple'

# Colors & UI
RED = "\e[31m"
BLUE = "\e[34m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
RESET = "\e[0m"
BOLD = "\e[1m"

PROXIES = []
CREDENTIALS = {}

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:115.0) Gecko/20100101 Firefox/115.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 14; SM-A528B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_2_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 13; SM-M127F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
    "Mozilla/5.0 (iPad; CPU OS 16_5 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/118.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; SM-A715F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; SM-J810Y) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/116.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; SM-J400F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 8.1.0; SM-J730G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 7.1.2; SM-J530G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 6.0.1; SM-J500G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Mobile Safari/537.36",
]

# Fetch fresh proxies
def fetch_proxies
  url = "https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=1000&country=all"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  PROXIES.replace(response.split("\n").map(&:strip).reject(&:empty?))
rescue
  puts "#{RED}?? Failed to fetch proxies! Using direct connection...#{RESET}"
end

def get_proxy
  return nil if PROXIES.empty?
  proxy = PROXIES.sample
  host, port = proxy.split(":")
  { host: host, port: port.to_i }
end

# Load accounts from file
def load_accounts
  unless File.exist?("data.txt")
    puts "#{RED}? data.txt file not found!#{RESET}"
    exit
  end

  File.readlines("data.txt").each do |line|
    email, password = line.chomp.split(":", 2)
    CREDENTIALS[email] = password
  end
end

# Secure API Request with User-Agent
def secure_request(uri, payload, proxy = nil)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 10
  http.read_timeout = 10

  if proxy
    http.proxy_address = proxy[:host]
    http.proxy_port = proxy[:port]
  end

  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request['User-Agent'] = USER_AGENTS.sample  # ? Random User-Agent

  request.body = payload

  response = http.request(request)
  JSON.parse(response.body) rescue nil
rescue
  nil
end

# WebSocket Connection
def connect_websocket(email, api_token, proxy)
  ws_url = "wss://ws.blockmesh.xyz/ws?email=#{email}&api_token=#{api_token}"
  begin
    ws = WebSocket::Client::Simple.connect(ws_url)
    puts "#{GREEN}??? WebSocket Connected: #{email} | Proxy: #{proxy ? "#{proxy[:host]}:#{proxy[:port]}" : "Direct"} ??#{RESET}"
    ws.close
  rescue
    puts "#{RED}?? WebSocket Failed: #{email} | Proxy: #{proxy ? "#{proxy[:host]}:#{proxy[:port]}" : "Direct"}#{RESET}"
  end
end

# Submit Bandwidth
def submit_bandwidth(email, api_token, proxy)
  puts "#{YELLOW}?? Uploading Bandwidth: #{email} | Proxy: #{proxy ? "#{proxy[:host]}:#{proxy[:port]}" : "Direct"}#{RESET}"
  payload = {
    email: email,
    api_token: api_token,
    download_speed: rand(0.0..10.0).round(16),
    upload_speed: rand(0.0..5.0).round(16),
    latency: rand(20.0..300.0).round(16),
    device_id: SecureRandom.hex(16)
  }.to_json
  secure_request(URI("https://app.blockmesh.xyz/api/submit_bandwidth"), payload, proxy)
end

# Fetch Tasks
def execute_task(email, api_token, proxy)
  puts "#{BLUE}?? Fetching Task Go & Sleep: #{email} | Proxy: #{proxy ? "#{proxy[:host]}:#{proxy[:port]}" : "Direct"}#{RESET}"
  sleep(rand(2..5))
  puts "#{GREEN}? Task Completed Happy? Now subscribe the DropXpert: #{email} | Proxy: #{proxy ? "#{proxy[:host]}:#{proxy[:port]}" : "Direct"}#{RESET}"
end

# Clean UI
def clear_terminal
  system("clear") || system("cls")
end

# Professional UI Header
def show_banner
  puts "#{BOLD} If Anyone sell this script╭∩╮( •̀_•́ )╭∩╮#{RESET}"
  puts "#{BOLD} 📡BLOCKMESH - Multi Account📡 #{RESET}"
  puts "#{BOLD}-`♡´- Created by DropXpert -`♡´-#{RESET}"
  puts "#{BOLD}????????????????????????????????????????????????????????#{RESET}"
end

# Process Each Account with Random Delays
def process_account(email)
  start_time = Time.now.to_i
  api_token = SecureRandom.hex(8)
  proxy = get_proxy  # ? Diffrent proxy for every account

  loop do
    clear_terminal
    show_banner
    puts "#{GREEN}?? Running on Proxy: #{proxy ? "#{proxy[:host]}:#{proxy[:port]}" : "Direct"}#{RESET}"

    connect_websocket(email, api_token, proxy)
    submit_bandwidth(email, api_token, proxy)
    execute_task(email, api_token, proxy)

    elapsed_time = Time.now.to_i - start_time

    if elapsed_time > rand(108000..126000)  # ? 2-3 hours delay
      puts "#{RED}? Auto Restarting to Avoid Detection...#{RESET}"
      break
    end

    sleep(rand(10..30))
  end
end

# Main Execution
def main
  fetch_proxies
  load_accounts

  if CREDENTIALS.empty?
    puts "#{RED}? No accounts found in data.txt are you dumb??#{RESET}"
    exit
  end

  clear_terminal
  show_banner
  puts "#{GREEN}? Great! Starting Bot...#{RESET}"

  threads = []
  CREDENTIALS.keys.each do |email|
    threads << Thread.new { process_account(email) }
  end
  threads.each(&:join)
end

main if __FILE__ == $0
