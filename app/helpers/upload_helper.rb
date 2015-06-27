module UploadHelper
  def render_upload_statistic_list(statistics)
    render partial: 'upload_statistic_list', :locals => {statistics: statistics}
  end

  def render_upload_statistic_list_columns(statistic, index)
    number = "##{index + 1}"
    uploader, count = statistic
    render partial: 'upload_statistic_list_columns', :locals => {uploader: uploader, count: count, number: number}
  end

  def render_upload_statistic_list_columns_header
    render partial: 'upload_statistic_list_columns_header'
  end
end
