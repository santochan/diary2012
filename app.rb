# -*- encoding : utf-8 -*-
require "sinatra/base"
require "json"
module ShowNote
  class App < Sinatra::Base
    use Rack::Session::Cookie
    use Rack::Flash

    set :erubis, :escape_html => true


    get '/about' do
      erb :about
    end

    get '/' do
      erb :index
    end

    get '/rank' do
      rank = $redis.zrevrange("rank",0, 9, :with_scores => true)
      @top_ten = rank.map { |e| e[2] =e[0]; e[0] = $redis.get("user:#{e[0]}"); e[1] =e[1].to_i ; e }
      p @top_ten
      erb :rank

    end


    get '/user/:uid' do

      user_result = $redis.get("analyse:#{params[:uid]}")
      if user_result
        @result = JSON.parse(user_result)
        @uname = @result["uname"]
        @first_note = @result["first_notes"][1]
        @first_time = time_ch(@result["first_notes"][0])
        @top_word =@result["word_top"][0]
        @words =@result["word_top"].slice(1..9).map { |e| e[0]  }.join('、')
        $redis.zincrby("rank",1,params[:uid])
        erb :show
      else
        flash[:notice] = '这个人不存在哦'
        redirect '/'
      end
      
    end

    post '/query' do
      @user_name = params["user_name"]
      @uid= $redis.get("user_name:#{@user_name}")
      if @uid
        redirect "/user/#{@uid}"
      else
        flash[:notice] = '这个人不存在哦'
        redirect '/'
      end
    end

    not_found do
      erb :error
    end


    helpers do
      def my_words_like(char_count)
        case char_count
        when 1..140
          return "一篇微博"
        when 140..400
          return "一篇小学生作文"
        when 400..800
          return "一篇初中生读后感"
        when 800..1000
          return "一篇高考作文"
        when 1000..2000
          return "一篇简报"
        when 2000..4000
          return "一篇读书笔记"
        when 4000..6000
          return "一篇本科生论文"
        when 6000..10000
          return "一篇研究生论文"
        when 10000..18000
          return "一篇社会化报告"    
        end
      end

    def set_color(count,value)
      case count
      when 1
        return "<span class=\"badge badge-important\">#{value}</span>"
      when 2
        return "<span class=\"badge badge-warning\">#{value}</span>"
      when 3
        return "<span class=\"badge badge-success\">#{value}</span>"
      else
        return "<span class=\"badge badge-info\">#{value}</span>"
      end

    end



    end

  private

    def time_ch(time_string)
      date_array=time_string.split('-')
      "#{date_array[0]}年#{date_array[1]}月#{date_array[2]}日"
    end

    # start the server if ruby file executed directly
    run! if app_file == $0
  end
end
