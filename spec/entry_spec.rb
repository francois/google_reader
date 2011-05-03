require "spec_helper"
require "set"

describe GoogleReader::Entry, "where the author is known, and the updated timestamp is different from the published timestamp, and with 3 liking users" do
  let :entry_xml do
    File.read(File.dirname(__FILE__) + "/fixtures/entry.xml")
  end

  let :entry do
    Nokogiri::XML(entry_xml).root.search("entry").first
  end

  let :liking_users do
    expected = Set.new
    expected << "06592066937024742113"
    expected << "07355112106994622540"
    expected << "09036194539349082984"
  end

  subject do
    GoogleReader::Entry.new(entry)
  end

  it "should HTML unescape the title" do
    subject.title.should == "Find cheapest combination of rooms in hotels & other entries"
  end

  it "should HTML unescape the source's title" do
    subject.source.title.should == "select * from depesz where 1 < 41 and 1 > 41 and \"public\".sometable = 'asdf';"
  end

  it { subject.published_at.should == Time.utc(2011, 4, 27, 13, 28, 53) }
  it { subject.updated_at.should   == Time.utc(2011, 4, 28, 14, 28, 53) }
  it { subject.href.should == "http://www.depesz.com/index.php/2011/04/27/find-cheapest-combination-of-rooms-in-hotels/" }
  it { subject.should have_known_author }
  it { subject.author.should == "depesz" }
  it { subject.source.should_not be_nil }
  it { subject.source.id.should == "tag:google.com,2005:reader/feed/http://www.depesz.com/index.php/feed/" }
  it { subject.source.href == "http://www.depesz.com" }
  it { subject.id.should == "tag:google.com,2005:reader/item/d5dee0c34e012ddb" }
  it { subject.original_id.should == "http://www.depesz.com/?p=2149" }

  it "should ignore Google categories" do
    subject.categories.should_not include("read")
    subject.categories.should_not include("fresh")
    subject.categories.should_not include("tracking-item-link-used")
  end

  it "should find the entry's categories" do
    subject.categories.should include("Uncategorized")
    subject.categories.should include("combinations")
    subject.categories.should include("cte")
    subject.categories.should include("postgresql")
    subject.categories.should include("recursive")
    subject.categories.should include("stackoverflow")
    subject.categories.should include("with recursive")
  end

  it "should find liking users" do
    subject.liking_users.to_set.should == liking_users
  end
end

describe GoogleReader::Entry, "where the author is unknown" do
  let :entry_xml do
    File.read(File.dirname(__FILE__) + "/fixtures/entry-with-unknown-author.xml")
  end

  let :entry do
    Nokogiri::XML(entry_xml).root.search("entry").first
  end

  subject do
    GoogleReader::Entry.new(entry)
  end

  it { subject.should_not have_known_author }
  it { subject.author.should == "(author unknown)" }
end

describe GoogleReader::Entry, "where no users have liked the entry" do
  let :entry_xml do
    File.read(File.dirname(__FILE__) + "/fixtures/entry-with-no-likes.xml")
  end

  let :entry do
    Nokogiri::XML(entry_xml).root.search("entry").first
  end

  subject do
    GoogleReader::Entry.new(entry)
  end

  it { subject.liking_users.should be_empty }
end

describe GoogleReader::Entry, "when no original ID is present" do
  let :entry_xml do
    File.read(File.dirname(__FILE__) + "/fixtures/entry-with-no-original-id.xml")
  end

  let :entry do
    Nokogiri::XML(entry_xml).root.search("entry").first
  end

  subject do
    GoogleReader::Entry.new(entry)
  end

  it { subject.original_id.should == subject.id }
end
