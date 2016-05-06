class ErrorsController < ApplicationController
  def error404
    render nothing: true, status: :not_found
  end
end
