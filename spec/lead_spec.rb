# frozen_string_literal: true

require "spec_helper"

describe Amorail::Lead do
  before { mock_api }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status_id) }
  end

  describe ".attributes" do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :name,
        :price,
        :status_id,
        :pipeline_id,
        :tags
      )
    end
  end

  describe "#params" do
    let(:lead) do
      described_class.new(
        name: 'Test',
        price: 100,
        status_id: 2,
        pipeline_id: 17,
        tags: 'test lead'
      )
    end

    subject { lead.params }

    specify { is_expected.to include(:last_modified) }
    specify { is_expected.to include(name: 'Test') }
    specify { is_expected.to include(price: 100) }
    specify { is_expected.to include(status_id: 2) }
    specify { is_expected.to include(pipeline_id: 17) }
    specify { is_expected.to include(tags: 'test lead') }
  end

  describe "#contacts" do
    let(:lead) { described_class.new(id: 2) }

    it "fails if not persisted" do
      expect { described_class.new.contacts }
        .to raise_error(Amorail::Entity::NotPersisted)
    end

    context "has contacts" do
      before { leads_links_stub(Amorail.config.api_endpoint, [2]) }
      before { contacts_find_all_stub(Amorail.config.api_endpoint, [101, 102]) }

      it "loads contacts for lead" do
        res = lead.contacts
        expect(res.size).to eq 2
        expect(res.first.id).to eq 101
        expect(res.last.id).to eq 102
      end
    end

    context "no contacts" do
      before { leads_links_stub(Amorail.config.api_endpoint, [2], false) }

      it "returns empty" do
        expect(lead.contacts).to be_empty
      end
    end
  end

  describe "#update" do
    subject { lead.update }

    let(:lead) { described_class.new(name: 'RSpec lead', status_id: 142) }

    before do
      lead_create_stub(Amorail.config.api_endpoint)
      lead.save!
    end

    context 'with errors in response' do
      before do
        lead_update_stub(Amorail.config.api_endpoint, false)
        lead.name = 'Updated name'
      end

      it { is_expected.to be_falsey }

      specify do
        subject
        expect(lead.errors[:base]).to include('Last modified date is older than in database')
      end
    end
  end
end
