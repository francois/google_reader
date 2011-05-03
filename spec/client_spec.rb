require "spec_helper"

describe GoogleReader::Client, "#authenticate" do
  it "should immediately authenticate using Google's client login" do
    RestClient.should_receive(:post).and_return("Auth=abc")
    GoogleReader::Client.authenticate("abc", "123")
  end

  it "should use the provided username and password during the authentication process" do
    RestClient.should_receive(:post).with("https://www.google.com/accounts/ClientLogin", :Email => "user", :Passwd => "pass", :service => "reader").and_return("Auth=abc")
    GoogleReader::Client.authenticate("user", "pass")
  end

  it "should instantiate a new GoogleReader::Client instance with the correct authentication header" do
    RestClient.stub(:post).and_return("Auth=my-fancy-token")
    GoogleReader::Client.should_receive(:new).with(hash_including("Authorization" => "GoogleLogin auth=my-fancy-token"))
    GoogleReader::Client.authenticate("a", "b")
  end
end

describe GoogleReader::Client do
  subject do
    GoogleReader::Client.new("Authorization" => "GoogleLogin auth=my-fancy-token")
  end

  let :xml_content do
    File.read(File.dirname(__FILE__) + "/fixtures/entry.xml")
  end

  it "should fetch the default 20 items from #read_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/read?n=20", anything).and_return(xml_content)
    subject.read_items
  end

  it "should fetch the requested number of items from #read_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/read?n=59", anything).and_return(xml_content)
    subject.read_items(59)
  end

  it "should fetch the default 20 items from #broadcast_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/broadcast?n=20", anything).and_return(xml_content)
    subject.broadcast_items
  end

  it "should fetch the requested number of items from #broadcast_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/broadcast?n=59", anything).and_return(xml_content)
    subject.broadcast_items(59)
  end

  it "should fetch the default 20 items from #starred_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/starred?n=20", anything).and_return(xml_content)
    subject.starred_items
  end

  it "should fetch the requested number of items from #starred_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/starred?n=31", anything).and_return(xml_content)
    subject.starred_items(31)
  end

  it "should fetch the default 20 items from #subscriptions_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/subscriptions?n=20", anything).and_return(xml_content)
    subject.subscriptions_items
  end

  it "should fetch the requested number of items from #subscriptions_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/subscriptions?n=19", anything).and_return(xml_content)
    subject.subscriptions_items(19)
  end

  it "should fetch the default 20 items from #tracking_emailed_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/tracking-emailed?n=20", anything).and_return(xml_content)
    subject.tracking_emailed_items
  end

  it "should fetch the requested number of items from #tracking_emailed_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/tracking-emailed?n=43", anything).and_return(xml_content)
    subject.tracking_emailed_items(43)
  end

  it "should fetch the default 20 items from #tracking_item_link_used_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/tracking-item-link-used?n=20", anything).and_return(xml_content)
    subject.tracking_item_link_used_items
  end

  it "should fetch the requested number of items from #tracking_item_link_used_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/tracking-item-link-used?n=43", anything).and_return(xml_content)
    subject.tracking_item_link_used_items(43)
  end

  it "should fetch the default 20 items from #tracking_body_link_used_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/tracking-body-link-used?n=20", anything).and_return(xml_content)
    subject.tracking_body_link_used_items
  end

  it "should fetch the requested number of items from #tracking_body_link_used_items" do
    RestClient.should_receive(:get).with("http://www.google.com/reader/atom/user/-/state/com.google/tracking-body-link-used?n=43", anything).and_return(xml_content)
    subject.tracking_body_link_used_items(43)
  end
end
