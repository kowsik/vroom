require 'sinatra'

class Vroom < Sinatra::Application
  GC_INTERVAL = (ENV['GC_INTERVAL'] || 1000).to_f/1000.0

  puts "GC_INTERVAL = #{GC_INTERVAL}s"
  GC.disable

  def self.do_gc_thing
    @@interval ||= Time.now.to_f
    now = Time.now.to_f
    if now - @@interval >= 1.0
      @@interval = now
      GC.enable
      GC.start
      GC.disable
    end

    yield
  end

  get '/gc' do
    Vroom.do_gc_thing do
      'doing the GC thing'
    end
  end

  get '/gc_count' do
    haml :gc_count
  end
end
