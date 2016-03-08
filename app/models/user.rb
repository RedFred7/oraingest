class User < ActiveRecord::Base

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Sufia behaviors.
  include Sufia::User
  # Need to lookup email id
  include Qa::Authorities
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  if Rails.env.production?
    devise :remote_user_authenticatable, :database_authenticatable, :registerable,
      :recoverable, :rememberable, :trackable, :validatable
  else
    devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :trackable, :validatable
  end

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def user_info
    if Rails.env.production? && !@info
      c = Qa::Authorities::Cud.new
      ans = c.search(user_key, 'sso_username_exact')
      if ans && ans[0] && (ans[0]['sso_username'] == user_key)
        @info = ans[0]
      end
    end
    @info
  end


  def username
    @info['sso_username'] if user_info
  end

  def ox_email
    @info['oxford_email'] if user_info
  end

  def full_name
    @info['fullname'] if user_info
  end

  def first_name
    @info['firstname'] if user_info
  end

  def last_name
    @info['lastname'] if user_info
  end


  def display_name(user_info=nil)
    # Passing in user_info as a parameter rather than calling self.user_info to minimie calls to CUD.
    # NOTE: consequence of this is that sufia user model will display user key as name
    return unless user_info
    user_info['fullname']
  end

  def oxford_email(user_info=nil)
    # Passing in user_info as a parameter rather than calling self.user_info to minimie calls to CUD.
    return unless user_info
    user_info['oxford_email']
  end

  # Returns true if user has permission to act as a reviewer
  def reviewer?
    # self.groups.include?("reviewer")
    self.groupsarray.include?("reviewer")
  end

  # Override this when integrating with Oxford AuthN
  def groups
    RoleMapper.roles(user_key)
  end

  # NOTE: This was a hack to deal with the fact the the .groups method (above) wasn't overriding the implementation from Sufia
  def groupsarray
    RoleMapper.roles(user_key)
  end
end
