module Twibot
  @@prompt = false

  def self.prompt=(p)
    @@prompt = f
  end

  module Macros
    def self.included(mod)
      @@bot = nil
    end

    def configure(&blk)
      bot.configure(&blk)
    end

    def message(pattern = nil, options = {}, &blk)
      add_handler(:message, pattern, options, &blk)
    end

    def reply(pattern = nil, options = {}, &blk)
      add_handler(:reply, pattern, options, &blk)
    end

    def tweet(pattern = nil, options = {}, &blk)
      add_handler(:tweet, pattern, options, &blk)
    end

    def follower(&blk)
      add_handler(:follower, nil, {}, &blk)
    end
    
    def hashtag(tag_or_tags, pattern = nil, options = {}, &blk)
      query = [tag_or_tags].flatten.map {|ht| ht.to_s[0] == ?# ? ht.to_s : "##{ht}"}.join(" OR ")
      add_handler([:search, query], pattern, options, &blk)
    end
    alias_method :hashtags, :hashtag
    
    def search(query, pattern = nil, options = {}, &blk)
      add_handler([:search, query], pattern, options, &blk)
    end
    
    def after(event=:all, &blk)
      add_hook :"after_#{event}", &blk
    end
    
    def before(event=:all, &blk)
      add_hook :"before_#{event}", &blk
    end
    
    def twitter
      bot.twitter
    end

    alias_method :client, :twitter

    def post_tweet(msg)
      message = msg.respond_to?(:text) ? msg.text : msg
      puts message
      client.status(:post, message)
    end
    
    def post_reply(status, msg)
      text = msg.respond_to?(:text) ? msg.text : msg
      reply_to_screen_name = status.user.screen_name
      reply_to_status_id = status.id
      message = "@#{reply_to_screen_name} #{text}"
      puts message
      client.status(:reply, message, reply_to_status_id)
    end
    
    def run?
      !@@bot.nil?
    end

   private
    def add_handler(type, pattern, options, &blk)
      bot.add_handler(type, Twibot::Handler.new(pattern, options, &blk))
    end
    
    def add_hook(hook, &blk)
      bot.add_hook(hook, &blk)
    end
    
    def bot
      return @@bot unless @@bot.nil?

      begin
        @@bot = Twibot::Bot.new nil, true
      rescue Exception
        @@bot = Twibot::Bot.new(Twibot::Config.default << Twibot::CliConfig.new, true)
      end

      @@bot
    end

    def self.bot=(bot)
      @@bot = bot
    end
  end
end
