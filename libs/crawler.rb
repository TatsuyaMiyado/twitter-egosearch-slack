module EgoSearch
  class Crawler
    include EventEmitter

    def initialize(opts={})
      @nosave = opts[:nosave]
      @client = ::Tw::Client.new
      @client.auth Config.twitter.user
    end

    def start
      Config.words.each do |word|
        @client.search(word).each do |tweet|
          emit :crawl, word, tweet
          tweet = Tweet.parse tweet
          begin
            tweet.save! unless @nosave
          rescue Mongoid::Errors::Validations
            next
          rescue => e
            emit :error, e
          end
          emit :new, word, tweet
        end
      end
    end

  end
end
