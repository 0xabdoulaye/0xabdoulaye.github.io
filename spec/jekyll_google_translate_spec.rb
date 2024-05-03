require_relative '../lib/jekyll_google_translate'

RSpec.describe JekyllGoogleTranslate::JekyllGoogleTranslate do
  let(:logger) do
    PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
  end

  let(:parse_context) { TestParseContext.new }

  it 'has a test' do
    expect(true).to be_true
  end
end
