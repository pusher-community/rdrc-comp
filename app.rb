require 'dotenv'
require 'sinatra'
require "sinatra/json"
require 'pusher'

Dotenv.load

client = Pusher::Client.new(
  app_id: ENV["PUSHER_APP_ID"],
  key: ENV["PUSHER_APP_KEY"],
  secret: ENV["PUSHER_APP_SECRET"],
  cluster: ENV["PUSHER_CLUSTER"],
  encrypted: true
)

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/config' do
  json key: ENV["PUSHER_APP_KEY"],
       cluster: ENV["PUSHER_CLUSTER"]
end

post '/pusher/auth' do
  puts params.inspect
  json client.authenticate(params[:channel_name], params[:socket_id], {
    user_id: params[:socket_id]
  })
end

post '/' do
  if ENV["SECRET"] && ENV["SECRET"] != params["SECRET"]
    403
  else
    client.trigger('presence-competition', 'winner', {
      name: 'BEN'
    })
    200
  end
end
