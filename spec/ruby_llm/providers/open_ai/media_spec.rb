# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Providers::OpenAI::Media do
  describe '.format_content' do
    it 'serializes raw hash payloads to JSON strings' do
      raw = RubyLLM::Content::Raw.new({ country: 'France' })

      formatted = described_class.format_content(raw)

      expect(formatted).to eq('{"country":"France"}')
    end

    it 'passes through raw array payloads without serialization' do
      payload = [{ type: 'text', text: 'Hello' }]
      raw = RubyLLM::Content::Raw.new(payload)

      formatted = described_class.format_content(raw)

      expect(formatted).to eq(payload)
    end

    it 'serializes document attachments into file blocks' do
      docx_path = File.join('spec', 'fixtures', 'sample.docx')
      content = RubyLLM::Content.new('Summarize this', docx_path)

      blocks = described_class.format_content(content)

      expect(blocks.first).to include(type: 'text', text: 'Summarize this')
      file_block = blocks.detect { |block| block[:type] == 'file' }
      expect(file_block).to be_present
      expect(file_block[:file][:filename]).to eq('sample.docx')
      docx_mime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      expect(file_block[:file][:file_data]).to start_with("data:#{docx_mime};base64,")
    end
  end
end
