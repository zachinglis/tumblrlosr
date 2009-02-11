#################
# Tumblr Losr
#################
# version 0.5
#
##################################
#
# Gems required:
#
# Notes
#
#   open-uri was giving me issues with http authentication so am using authentication through tumblr.
#
# Todo:
#
#   * Mock succesfull and failed pages
#
# Bugs:
#
#   * Logs you out of Tumblr. May have to use a different scraping library.
#

# require gems
require 'rubygems'
require 'yaml'
require 'mechanize'

# settings
class Tumblr
  def initialize
    @login_details = YAML::load_file("login.yml")
    @agent = WWW::Mechanize.new
    login
    raise "Invalid login" unless logged_in?
  end
  
  def login
    @login_page = agent.get('http://www.tumblr.com/login')
    @login_form = @login_page.forms[1]
    @login_form.email, @login_form.password = @login_details['email'], @login_details['password']
    agent.submit @login_form
  # Todo: UGLY. Make this right.
  rescue
    raise("Error: Please check your internet connection.")
  end
  
  def get_followers
    @followers_page = agent.get('http://www.tumblr.com/followers')
    @followers = @followers_page.search('#following .username').collect(&:content)
  end
  
  def read_followers
    File.read('followers.txt').split("\n")
  end
  
  def write_followers
    File.open("followers.txt", "w+") do |file|
      file.write(get_followers.join("\n"))
    end
  end
  
  def check_follower_changes
    old_follower_list = read_followers
    write_followers
    new_follower_list = get_followers

    lost_followers = old_follower_list - new_follower_list
    new_followers  = new_follower_list - old_follower_list

    [new_followers, lost_followers]
  end
  
  def document_follower_changes
    new_followers, lost_followers = check_follower_changes

    if new_followers.empty? and lost_followers.empty?
      puts "No new followers."
      return
    end

    changes =  "-----------------------------\n"
    changes += "--- #{Time.now.strftime("%I:%M%p, %A %d %m %Y")}\n"
    changes += "-----------------------------\n\n"

    changes += "
    New followers: #{new_followers.length}
    Lost followers: #{lost_followers.length}
    \n"
    
    new_followers.each do |follower|
      changes +=  " * #{follower} started following you\n"
    end

    lost_followers.each do |follower|
      changes +=  " * #{follower} stopped following you\n"
    end
    changes += "\n"
    
    puts changes
    File.open("events.txt", "w+") do |file|
      file.write(changes)
      file.write(file.read)
    end
  end
  
  def logged_in?
    not agent.page.search('#nav').to_s =~ /register/
  end
  
  def page
    agent.page.uri.to_s
  end

  def title
    agent.page.title
  end
  
  def agent
    @agent
  end
end

Tumblr.new.document_follower_changes
