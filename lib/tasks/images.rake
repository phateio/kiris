namespace :images do
  desc 'Create or update images from pixiv.net'
  task create_or_update_from_pixiv: :environment do
    Track.utaitedb.find_each do |track|
      artists = track.artist.split('、')
      track_tags = artists + [track.title]

      keywords = format('%s %s %s', artists.join(' '), track.title, '000users入り')
      works_api_url = 'https://public-api.secure.pixiv.net/v1/search/works.json'
      works_api_response = HTTParty.get(works_api_url, headers: pixiv_headers, query: { q: keywords })

      works_api_response['response'].each do |illust|
        illust_id = illust['id']
        illust_url = "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{illust_id}"
        illust_api_url = "https://public-api.secure.pixiv.net/v1/works/#{illust_id}.json?image_sizes=px_128x128,large"

        next if Image.exists?(source: illust_url)

        illust_response = HTTParty.get(illust_api_url, headers: pixiv_headers)
        illust_image_url = illust_response["response"].first["image_urls"]["large"]
        illust_thumbnail_url = illust_response["response"].first["image_urls"]["px_128x128"]
        illust_tags = illust_response["response"].first["tags"]
        age_limit = illust_response["response"].first["age_limit"]
        illustrator = illust_response["response"].first["user"]["name"]

        track_tags.map!(&:downcase).map! { |el| el.gsub(/[^\p{Word}]+|_/, '') }
        illust_tags.map!(&:downcase).map! { |el| el.gsub(/[^\p{Word}]+|_/, '') }

        unless age_limit.eql?('all-age')
          STDERR.puts "Explicit image: `#{age_limit}'"
          next
        end
        unless (not_found_tags = track_tags.map { |el| el } - illust_tags).empty?
          STDERR.puts "Tag(s) #{not_found_tags.inspect} not found in #{illust_url}"
          next
        end

        image_filename = File.basename(illust_image_url)
        thumbnail_filename = File.basename(illust_thumbnail_url)
        unless upload_from_url(illust_image_url, directory: 'pixiv', filename: image_filename)
          raise "Upload Failed `#{filename}'"
        end
        unless upload_from_url(illust_thumbnail_url, directory: 'pixiv', filename: thumbnail_filename)
          raise "Upload Failed `#{filename}'"
        end

        image_url = "https://images.phate.io/pixiv/#{image_filename}"
        track.images.create!(
          url: image_url,
          source: illust_url,
          nickname: 'pixiv.net',
          illustrator: illustrator,
          status: 'RANK_5',
          verified: true
        )
        puts "Created #{image_url}"
      end
    end
  end

  private

  def pixiv_headers
    {
      'Authorization' => ENV['PIXIV_AUTHORIZATION']
    }
  end

  def initialize_storage_bucket
    fog_storage = Fog::Storage::Google.new(
      google_storage_access_key_id: ENV['GOOGLE_STORAGE_ACCESS_KEY_ID'],
      google_storage_secret_access_key: ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY'],
      path_style: true,
      host: 'storage.googleapis.com'
    )
    storage_bucket = fog_storage.directories.new key: 'images.phate.io'
    Object.const_set('StorageBucket', storage_bucket)
  end

  def upload_from_url(url, directory:, filename:)
    defined?(StorageBucket) || initialize_storage_bucket

    response = HTTParty.get(url, headers: { referer: url })
    raise HTTParty::ResponseError unless response.success?

    content_type = response.headers['content-type']
    destination_path = "#{directory}/#{filename}"

    object = StorageBucket.files.new(
      key: destination_path,
      body: response.body,
      public: true,
      'Content-Type' => content_type
    )
    object.save
  end
end
