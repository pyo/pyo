class RedirectionController < ActionController::Base
  def redirect
    options = params[:args].extract_options!
    status = options.delete(:permanent) ? :moved_permanently : :found
    url_options = params[:args].first || options
    redirect_to url_options, :status => status
  end
end