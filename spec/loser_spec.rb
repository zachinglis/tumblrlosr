require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Tumblr do
  before(:all) do
    @tumblr = Tumblr.new
    @tumblr.agent.
  end
  
  describe '.new' do
    it "should login automatically" do
      @tumblr.page.should   ==  'http://www.tumblr.com/login'
    end
  end
  
  describe '#login' do
    it "should succesfully log in" do
      @tumblr.title.should  =~  /Logging in/
    end
  end
  
  describe '#get_followers' do
    it 'should return an array of followers' do
      @tumblr.get_followers.should be_kind_of(Array)
    end
  end
  
  describe "#write_followers" do
    it "should create a file if it does not exist" do
      File.delete('followers.txt') if File.exist?('followers.txt') # preperation
      @tumblr.write_followers
      File.exist?('followers.txt').should be_true
    end
    
    it "should write followers list and seperate the names by new lines" do
      @tumblr.write_followers
      File.read('followers.txt').should_not be_nil
    end
  end
  
  describe "#check_follower_changes" do
    it "should read old followers" do
      @tumblr.should_receive(:read_followers).once.and_return   %w(joe fred hans mike)
      @tumblr.should_receive(:write_followers).and_return       []
      @tumblr.should_receive(:get_followers).and_return         []
      @tumblr.check_follower_changes.should be_true
    end
    
    it "should write new followers" do
      @tumblr.should_receive(:read_followers).and_return        []
      @tumblr.should_receive(:write_followers).once.and_return  []
      @tumblr.should_receive(:get_followers).and_return         []
      @tumblr.check_follower_changes
    end
    
    it "should compare new and old followers" do
      @tumblr.should_receive(:read_followers).and_return            %w(joe fred ghunter)
      @tumblr.should_receive(:write_followers)
      @tumblr.should_receive(:get_followers).and_return             %w(joe fred hans mike)
      @tumblr.check_follower_changes.should ==                      [['ghunter'], ['hans', 'mike']]
    end
  end
  
  describe "#document_follower_changes" do
    before(:each) do
      File.delete('events.txt') if File.exist?('events.txt')
    end
    
    it "should create an events text file if it does not exist"
    
    it "should check follower changes" do
      @tumblr.should_receive(:check_follower_changes).once.and_return [%w(fred), %(joe)]
      @tumblr.document_follower_changes
    end
    
    it "should document a new follower" do
      @tumblr.should_receive(:check_follower_changes).once.and_return [%w(joe), %()]
      @tumblr.document_follower_changes
      File.read('events.txt').should =~                   /joe started following you/
    end
    
    it "should document a lost follower" do
      @tumblr.should_receive(:check_follower_changes).once.and_return [%w(), %(joe)]
      @tumblr.document_follower_changes
      File.read('events.txt').should =~                   /joe stopped following you/
    end
  end
  
end
