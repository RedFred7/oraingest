module DashboardHelper

  # uses the type of an item to generate a corresponding CSS tag to be used in
  # the dashboard view
  #
  # @note returned tag must match the one found in styles.scss:
  # @param review_item [Hash] the review item (dataset/thesis/etc) to be processed
  # @return  [ String ] the generated tag, or an empty string if the argument is nil
  def get_type_tag(item_type)
    item_type ? item_type.downcase.gsub(%r{\s}, '-').prepend('tag-')
    : ""
  end

  # uses the status of an item to generate a corresponding CSS tag to be used # in the dashboard view
  #
  # @note (see #get_type_tag)
  # @param (see #get_type_tag)
  # @return (see #get_type_tag)
  def get_status_tag(item_status)
    item_status ? item_status.downcase.gsub(%r{\s}, '-').prepend('tag-')
    : ""
  end

  def is_it_looking_for_claimed?
    usr = (Rails.env.production? ? current_user.full_name : current_user.email)
    if session[:review_dash_filters] && session[:review_dash_filters].size > 1
    (session[:review_dash_filters][0].facet == :STATUS) &&
      (session[:review_dash_filters][0].value == :Claimed) &&
      (session[:review_dash_filters][1].value == usr) &&
      (session[:review_dash_filters][1].facet == :CURRENT_REVIEWER)
    else
      false
    end
  end


end
