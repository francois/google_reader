require "spec_helper"

describe GoogleReader::Feed do
  let :entry_xml do
    File.read(File.dirname(__FILE__) + "/fixtures/entry.xml")
  end

  let :doc do
    Nokogiri::XML(entry_xml)
  end

  subject do
    GoogleReader::Feed.new(doc)
  end

  it "should have a title" do
    subject.title.should == %("tracking-item-link-used" via francois.beausoleil in Google Reader)
  end

  it "should have an #udpated_at" do
    subject.updated_at.should == Time.utc(2011, 5, 2, 17, 53, 46)
  end
end
