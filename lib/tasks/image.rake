require 'net/http'

namespace :image do
  desc 'Reset image sources'
  task :reset => :environment do
    pixiv_regexp = /\A(?:http:\/\/www\.pixiv\.net\/member_illust\.php\?mode=medium&illust_id=([0-9]+))\z/
    Image.where(illustrator: '')
         .where('source LIKE ?', '%pixiv.net%')
         .find_each(batch_size: 10) do |image|
      puts image.source
      pixiv_match = pixiv_regexp.match(image.source)
      pixiv_illust_id = pixiv_match[1]
      pixiv_illust_info = get_pixiv_illust_info(pixiv_illust_id)
      if not pixiv_illust_info
        puts 'Error'
        next
    end
      image.update!(illustrator: pixiv_illust_info[:nickname])
    end
  end

  def http_request(uri, req)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 10
    http.use_ssl = true if uri.scheme == 'https'
    http.request(req)
  end

  def http_get_response_body(url, headers = {})
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    headers.each do |name, value|
      req[name] = value
    end
    res = http_request(uri, req)
    res.is_a?(Net::HTTPSuccess) ? res.body : nil
  end

  def get_pixiv_illust_info(illust_id)
    headers = {
      'Authorization' => 'Bearer 8mMXXWT9iuwdJvsVIvQsFYDwuZpRCMePeyagSh30ZdU'
    }
    res_body = http_get_response_body("https://public-api.secure.pixiv.net/v1/works/#{illust_id}.json?image_sizes=large", headers) rescue nil
    return nil if res_body.nil?
    illust_hash = JSON.parse(res_body)
    return false if illust_hash['status'] != 'success'
    illust_hash_response = illust_hash['response'].first
    {
      illust_id: illust_hash_response['id'],
      image_url: illust_hash_response['image_urls']['large'],
      nickname: illust_hash_response['user']['name'],
      tags: illust_hash_response['tags'],
      type: illust_hash_response['type']
    }
  end
end
