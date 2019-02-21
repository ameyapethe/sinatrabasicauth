# config.ru

require "./app/main.rb"

map "/api" do 
  run Api
end

map "/" do
  run Public
end