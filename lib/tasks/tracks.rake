namespace :tracks do
  DEFAULT_USER_AGENT = 'Mozilla/5.0 (compatible; Phate Radio/3.0; +https://phate.io/)'.freeze

  desc 'Create or update tracks by utaitedb.net'
  task create_or_update_by_utaitedb: :environment do
    max_results_count = 50

    query = {
      onlyWithPvs: true,
      pvServices: 'NicoNicoDouga',
      status: 'Finished',
      start: 0,
      maxResults: max_results_count,
      getTotalCount: true,
      sort: 'PublishDate',
      fields: 'Artists,PVs,Tags'
    }
    headers = {
      'User-Agent' => DEFAULT_USER_AGENT
    }
    response = HTTParty.get('http://utaitedb.net/api/songs', query: query, headers: headers)
    total_count = response['totalCount']
    puts "Total count: #{total_count}"

    pages_count = total_count ? (total_count / max_results_count.to_f).ceil : 1
    (0...pages_count).reverse_each do |page_index|
      query[:start] = page_index * max_results_count
      response = HTTParty.get('http://utaitedb.net/api/songs', query: query, headers: headers)
      items = response['items']

      items.reverse_each do |item|
        niconico = item['pvs'].find { |pv| pv['service'].eql?('NicoNicoDouga') }['pvId']
        next unless acceptable?(niconico)

        utaitedb_song_id = item['id']
        title = item['name']
        bands = item['artists'].select do |artist|
          artist['categories'].split(',').map(&:strip).include?('Band') && !artist['isSupport']
        end.map { |artist| artist['name'] }
        vocalists = item['artists'].select do |artist|
          artist['categories'].split(',').map(&:strip).include?('Vocalist') && !artist['isSupport']
        end.map { |artist| artist['name'] }
        support_vocalists = item['artists'].select do |artist|
          artist['categories'].split(',').map(&:strip).include?('Vocalist') && artist['isSupport']
        end.map { |artist| artist['name'] }
        producers = item['artists'].select do |artist|
          artist['categories'].split(',').map(&:strip).include?('Producer')
        end.map { |artist| artist['name'] }
        composers = item['artists'].select do |artist|
          artist['roles'].split(',').map(&:strip).include?('Composer')
        end.map { |artist| artist['name'] }
        instrumentalists = item['artists'].select do |artist|
          artist['roles'].split(',').map(&:strip).include?('Instrumentalist')
        end.map { |artist| artist['name'] }
        tags = item['tags'].map { |tag| tag['tag']['name'] }
        primary_tag = tags.include?('vocaloid original') ? 'VOCALOID' : '歌ってみた'

        artists = vocalists.presence || bands.presence || instrumentalists.presence || producers.presence
        tags = (['niconico'] + [primary_tag] + producers + composers + support_vocalists).uniq.join(',')

        raise "Irregular id: #{utaitedb_song_id}" if title.empty? || artists.empty? || niconico.empty?

        track = Track.find_or_initialize_by(niconico: niconico)
        track.update!(
          title: title,
          artist: artists.join('、'),
          tags: tags,
          uploader: 'utaitedb.net',
          status: track.new_record? ? 'QUEUED' : track.status
        )
      end
    end
  end
end

def acceptable?(video_id)
  niconico_video_info = get_niconico_thumb_info(video_id)
  niconico_video_info && niconico_video_info[:view_counter] > 10_000
end

def get_niconico_thumb_info(video_id)
  headers = {
    'User-Agent' => DEFAULT_USER_AGENT
  }
  response = HTTParty.get("http://ext.nicovideo.jp/api/getthumbinfo/#{video_id}", headers: headers)
  raise unless response.code.eql?(200)
  thumb_info_doc = Nokogiri::XML(response.body)
  thumb_element = thumb_info_doc.xpath('/nicovideo_thumb_response/thumb')
  document_hash = Hash.from_xml(thumb_element.to_s)
  return false if document_hash.nil?
  thumb_hash = document_hash['thumb']
  thumb_hash.slice!('video_id', 'title', 'length', 'movie_type', 'view_counter', 'tags')
  thumb_hash.symbolize_keys!
  thumb_hash[:tags] = Array(thumb_hash[:tags].to_h['tag'])
  thumb_hash[:view_counter] = thumb_hash[:view_counter].to_i
  thumb_hash
end
