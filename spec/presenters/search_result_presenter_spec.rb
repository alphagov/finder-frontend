require 'spec_helper'

RSpec.describe SearchResultPresenter do

  subject(:presenter) { SearchResultPresenter.new(document)}

  let(:document) {
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
        { label: "Case state", value: "Open", is_text: true },
        { label: "Opened date", is_date: true, machine_date: "2006-07-14", human_date: "14 July 2006" },
        { label: "Case type", value: "CA98 and civil cartels", is_text: true },
      ]
    }

    it "should return a hash of the data we need to show the document" do
      hash = subject.to_hash
      hash[:title].should == title
      hash[:slug].should == slug
      hash[:metadata].should == formatted_metadata
    end
  end

  describe '#metadata' do
    it 'should return an array' do
      subject.metadata.is_a?(Array).should == true
    end

    it 'should format metadata' do
      allow(presenter).to receive(:build_text_metadata).and_call_original
      allow(presenter).to receive(:build_date_metadata).and_call_original

      subject.metadata
      subject.should have_received(:build_date_metadata).with({:name=>"Opened date", :value=>"2006-7-14", :type=>"date"})
      subject.should have_received(:build_text_metadata).with({:name=>"Case state", :value=>"Open", :type=>"text"})
      subject.should have_received(:build_text_metadata).with({:name=>"Case state", :value=>"Open", :type=>"text"})

    end
  end

  describe '#build_text_metadata' do
    let(:data) { {name: 'some name', value: 'some value'} }
    it 'should return a hash' do
      subject.build_text_metadata(data).is_a?(Hash).should == true
    end
    it 'should set the type to text' do
      subject.build_text_metadata(data).fetch(:is_text).should == true
    end
  end

  describe '#build_date_metadata' do
    let(:data) { {name: 'some name', value: raw_date} }
    let(:raw_date) { '2003-12-01' }
    let(:formatted_date) { '1 December 2003' }
    let(:iso_date) { '2003-12-01' }

    it 'should return a hash' do
      subject.build_date_metadata(data).is_a?(Hash).should == true
    end

    it 'should set the type to date' do
      subject.build_date_metadata(data).fetch(:is_date).should == true
    end

    it 'should format the date' do
      date_metadata = subject.build_date_metadata(data)
      date_metadata.fetch(:human_date).should == formatted_date
      date_metadata.fetch(:machine_date).should == iso_date
    end
  end
end
