namespace :tracks do
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
      fields: 'Artists,PVs'
    }
    response = HTTParty.get('http://utaitedb.net/api/songs', query: query)
    total_count = response['totalCount']
    puts "Total count: #{total_count}"

    pages_count = total_count ? (total_count / max_results_count.to_f).ceil : 1
    (0...pages_count).reverse_each do |page_index|
      query[:start] = page_index * max_results_count
      response = HTTParty.get('http://utaitedb.net/api/songs', query: query)
      items = response['items']

      items.each do |item|
        niconico = item['pVs'].find { |pv| pv['service'].eql?('NicoNicoDouga') }['pvId']
        next unless acceptable?(niconico)

        utaitedb_song_id = item['id']
        title = item['name']
        artists = item['artists'].select { |artist| artist['categories'].split(',').map(&:strip).include?('Vocalist') }.map { |artist| artist['name'] }
        producers = item['artists'].select { |artist| artist['categories'].split(',').map(&:strip).include?('Producer') }.map { |artist| artist['name'] }
        composers = item['artists'].select { |artist| artist['roles'].split(',').map(&:strip).include?('Composer') }.map { |artist| artist['name'] }
        instrumentalists = item['artists'].select { |artist| artist['roles'].split(',').map(&:strip).include?('Instrumentalist') }.map { |artist| artist['name'] }

        artists.concat(instrumentalists) if artists.empty? && instrumentalists.any?
        artists.concat(producers) if artists.empty? && producers.any?
        tags = 'niconico,歌ってみた'
        tags = "#{tags}," + (producers + composers).uniq.join(',') if producers.any? || composers.any?

        raise "Irregular id: #{utaitedb_song_id}" if title.empty? || artists.empty? || niconico.empty?

        track = Track.find_or_initialize_by(niconico: niconico)
        track.update!(
          title: title,
          artist: artists.join('、'),
          tags: tags,
          uploader: 'utaitedb.net',
          status: 'QUEUED'
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
  response = HTTParty.get("http://ext.nicovideo.jp/api/getthumbinfo/#{video_id}")
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
