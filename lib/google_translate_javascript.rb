require 'jekyll_plugin_support'
require_relative 'jekyll_google_translate/version'

# This Jekyll tag plugin inserts JavaScript for Google Translate.
# The {% google_translate_html %} tag must also be called to insert HTML into the page.
#
# The Jekyll log level defaults to :info, which means all the Jekyll.logger statements below will not generate output.
# You can control the log level when you start Jekyll.
# To set the log level to :debug, write an entry into _config.yml, like this:
# plugin_loggers:
#   GoogleTranslateJavascript: debug
module JekyllGoogleTranslate
  class GoogleTranslateJavascript < JekyllSupport::JekyllTag
    PLUGIN_NAME = 'google_translate_javascript'.freeze
    VERSION = JekyllGoogleTranslate::VERSION

    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    #
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param argument_string [String] the arguments from the web page.
    # @param tokens [Liquid::ParseContext] tokenized command line
    # @return [void]
    def render_impl
      <<~END_OUTPUT
        <script type="text/javascript">
          function googleTranslateElementInit() {
            new google.translate.TranslateElement({pageLanguage: 'en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
          }
        </script>
        <script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, PLUGIN_NAME)
  end
end
