require 'sinatra'

class Vroom < Sinatra::Application
  GC_INTERVAL = (ENV['GC_INTERVAL'] || 1000).to_i

  def self.do_gc_thing
    @@counter ||= 0
    GC.disable if @@counter.zero?
    @@counter += 1
    if @@counter == GC_INTERVAL
      GC.enable
      GC.start
    end

    yield
  end

  get '/gc' do
    Vroom.do_gc_thing do
      'doing the GC thing'
    end
  end
end
