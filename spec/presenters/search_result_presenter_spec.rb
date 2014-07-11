require 'spec_helper'

RSpec.describe SearchResultPresenter do

  subject(:presenter) { SearchResultPresenter.new(document)}

  let(:document){
    OpenStruct.new({
      title: title,
      slug: slug,
      metadata: metadata,
    })
  }

  let(:title) { 'Investigation into the distribution of road fuels in parts of Scotland' }
  let(:slug) { 'slug-1' }

  let(:metadata) {
    [
      { name: 'Case state', value: 'Open', type: 'text' },
      { name: 'Opened date', value: '2006-7-14', type: 'date' },
      { name: 'Case type', value: 'CA98 and civil cartels', type: 'text' },
    ]
  }

  describe "#to_hash" do
    it "should return a hash" do
      subject.to_hash.is_a?(Hash).should == true
    end

    let(:formatted_metadata) {
      [
        { name: 'Case state', value: 'Open' },
        { name: 'Opened date', value: '14 July 2006' },
        { name: 'Case type', value: 'CA98 and civil cartels' },
      ]
    }

    it "should return a hash of the data we need to show the document" do
      hash = subject.to_hash
      hash[:title].should == title
      hash[:slug].should == slug
      hash[:metadata].should == formatted_metadata
    end
  end

  describe '#format_metadata' do
    it 'should return an array' do
      subject.format_metadata(metadata).is_a?(Array).should == true
    end

    it 'should call format date on any date values' do
      allow(presenter).to receive(:format_date_if_date).and_call_original
      subject.format_metadata(metadata)
      presenter.should have_received(:format_date_if_date).with 'Open', 'text'
      presenter.should have_received(:format_date_if_date).with '2006-7-14', 'date'
      presenter.should have_received(:format_date_if_date).with 'CA98 and civil cartels', 'text'

    end
  end

 describe '#format_date_if_date' do
   let(:raw_date) { '2003-12-30' }
   let(:formatted_date) { '30 December 2003' }
   let(:a_date_type) { 'date'}
   let(:not_a_date_type) { 'not a date' }

   it 'should return a formatted date if type = date' do
     subject.format_date_if_date(raw_date, a_date_type).should == formatted_date
   end

   it 'should return the unchanged value if type != date' do
     subject.format_date_if_date(raw_date, not_a_date_type).should == raw_date
   end

 end
end
