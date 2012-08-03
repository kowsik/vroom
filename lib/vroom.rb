require 'sinatra'
require 'sinatra/async'
require 'pool'

class Vroom < Sinatra::Application
  register Sinatra::Async

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

  get '/sync' do
    delay = params[:delay].to_i rescue 0
    sleep(delay/1000.0) unless delay.zero?
    "#{delay} ms"
  end

  aget '/async' do
    delay = params[:delay].to_i rescue 0
    EM.add_timer(delay/1000.0) do 
      body "#{delay} ms"
    end
  end

  def self.pool
    @@pool ||= Pool.new(10)
  end

  def self.queue
    @@queue ||= Queue.new
  end

  aget '/pool' do
    delay = params[:delay].to_i rescue 0

    Vroom.pool.schedule do
      sleep(delay/1000.0) unless delay.zero?
      Vroom.queue << true
    end

    op = proc { Vroom.queue.pop }
    cb = proc { body "ok" }
    EM.defer op, cb
  end
end
