# -*- encoding : utf-8 -*-
require "redis"
require 'rmmseg'
require "json"
require "rmmseg/Dictionary"

RMMSeg::Dictionary.load_dictionaries
@redis = Redis.new(:host => "127.0.0.1", :port => 6379)
@sym_str =/\p{P}|[0-9]/u

def count_word(note_array)
  word_count =Hash.new(0)
  note_array.each do |note|
    note.gsub!(@sym_str,' ')
    algor = RMMSeg::Algorithm.new(note)
    loop do
      tok = algor.next_token
      break if tok.nil?
      next if tok.text.size == 3
      word_count[tok.text.force_encoding('utf-8')] += 1
    end
  end
  word_count
end


#get top10 words
def sort_word(words_map)
  ten_array=words_map.sort {|a,b| b[1]<=>a[1]}.slice(0..9)
end

def get_first_note(note_keys)  

  first_key = note_keys.sort[0]
  rev =[]
  rev<<first_key.split(':').slice(2)
  rev<<@redis.get(first_key)
  rev
end


def user_analyse
  user_keys = @redis.keys "user:*"
  user_keys.each do |user_key|
    uid= user_key.split(':')[1]
    uname = @redis.get(user_key)
    post_keys = @redis.keys "post:#{uid}:*"
    if  post_keys.length ==0
       @redis.set "analyse:#{uid}",Hash["char_count",0].to_json
      next 
    end
    note_array = @redis.mget(post_keys)
    # puts "#{uname}--#{note_array.to_s.size}"
    analyse_map = Hash.new
    analyse_map["uname"] = uname
    analyse_map["notes_count"] = post_keys.size
    analyse_map["first_notes"] = get_first_note(post_keys)
    analyse_map["char_count"] = note_array.to_s.size
    analyse_map["word_top"] = sort_word count_word(note_array)
    @redis.set "analyse:#{uid}",analyse_map.to_json
    p analyse_map
    puts "*"*30
  end
end 

user_analyse



