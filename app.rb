require 'sinatra'

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

post '/' do
  if ENV["SECRET"] && ENV["SECRET"] != params["SECRET"]
    403
  else
    200
  end
end
