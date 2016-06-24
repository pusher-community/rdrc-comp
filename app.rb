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
  json client.authenticate(params[:channel_name], params[:socket_id], {
    user_id: params[:socket_id]
  })
end

post '/' do
  if ENV["SECRET"] && ENV["SECRET"] != params["SECRET"]
    403
  else

    case params["submit"]
    when "reload"
      client.trigger('presence-competition', 'reload', {})
      return [200, 'reloaded']

    when "reset"
      client.trigger('presence-competition', 'reset', {})
      return [200, 'reset']

    when "win"
      winner = client.channel_users('presence-competition')[:users].sample

      if winner
        client.trigger('presence-competition', 'winner', {
          user: winner
        })

        [200, "winner #{winner["id"]}!"]
      else
        [500, "no players"]
      end

    when "quick-win"
      winner = client.channel_users('presence-competition')[:users].sample

      if winner
        client.trigger('presence-competition', 'quick-winner', {
          user: winner
        })

        [200, "(quick) winner #{winner["id"]}!"]
      else
        [500, "no players"]
      end

    end

  end
end
