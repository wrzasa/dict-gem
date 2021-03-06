# -*- coding: utf-8 -*-

require 'nokogiri'
require 'dict/dictionary'

module Dict
  # Class fetching translations of given word from wiktionary.org.
  class Wiktionary < Dictionary

    # Returns an Dict::Result object.
    def translate
      translations.each do |translation|
        @result.add_translation(@result.term, translation.gsub(/(\s[^|\s]+\|)/,' '))
        examples(translation).each { |example| @result.add_example(translation, example) }
      end

      @result
    end

    def get_html(url)
      begin
        Nokogiri::HTML(open(URI.encode(url)))
      rescue OpenURI::HTTPError
        raise Dictionary::ConnectError
      end
    end

    private
    def polish?(content)
      ! /==Polish==/i.match(content).nil?
    end

    # Returns an array containing translations.
    def translations
      url_pl = "http://en.wiktionary.org/w/index.php?title=#{@word}&action=edit"
      url_en = "http://pl.wiktionary.org/w/index.php?title=#{@word}&action=edit"

      content_pl = get_html(url_pl).css('textarea#wpTextbox1').first
      if polish?(content_pl)
        @is_polish = true
        extract_polish_translations(content_pl)
      else
        @is_polish = false
        extract_english_translations(get_html(url_en).css('textarea#wpTextbox1').first.content)
      end
    end

    # Returns an array containing polish translations.
    def extract_polish_translations(content)
      translations = /Noun[^\{]+\{\{(?:head\|pl|pl\-noun)[^#]+#\s*\[\[([^\n]+)/.match(content)
      translations = (translations && translations[1].gsub(/\[|\]/,'').split(', ')) || []
    end

    # Returns an array containing english translations.
    def extract_english_translations(content)
      translations_block = /język\s+angielski(?:.|\n)+\{\{znaczenia\}\}(.|\n)+(?:\{\{odmiana){1,}/.match(content)
      return [] unless translations_block.instance_of?(MatchData)
      translations_block = translations_block[0].gsub(/odmiana(.|\n)+$/,'')
      translations = translations_block.scan(/:\s*\(\d\.?\d?\)\s*([^\n]+)/)
      translations.map! do |translation|
        translation[0].gsub(/\[|\]|\{\{[^\}]+\}\}|'|<.*/,'').strip
      end
      translations.delete_if(&:empty?)
      translations ||= []
    end

    def examples(word)
      url_pl = "http://pl.wiktionary.org/w/index.php?title=#{word}&action=edit"

      if @is_polish
        extract_english_examples(word)
      else
        []
      end
    end

    # Returns an array containing usage examples of translated polish word to english.
    def extract_english_examples(word)
      word = word.gsub(/\s+\(.+$/,'') || ''
      url_en = "http://en.wiktionary.org/w/index.php?title=#{word}&action=edit"
      examples = /Noun[^\{]+\{\{en\-noun[^=]+/.match(get_html(url_en.gsub('{word}',word)).css('textarea#wpTextbox1').first)
      return [] unless examples.instance_of?(MatchData)
      examples = examples[0].scan(/#: ''([^\n]+)\n/)
      examples.map! do |translation|
        translation[0].gsub(/'{2,}/,'')
      end
      examples
    end
  end
end
