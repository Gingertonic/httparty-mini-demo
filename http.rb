require "httparty"
require "pry"
require "launchy"

class API 
    def self.get_posts
        data = HTTParty.get('https://learn.co/magazine/blog-posts?page=1&page_size=200')

        blog_posts = data["blog_posts"]

        blog_posts.each do |post_data|
            BlogPost.new(post_data)
        end 
    end
end



class BlogPost 
    attr_accessor :title, :lesson_title, :author, :excerpt, :url
    @@all = []

    def initialize(data_hash)
        @title = data_hash["title"]
        @author = data_hash["author"]
        @excerpt = data_hash["excerpt"]
        @url = data_hash["url"] 
        @lesson_title = data_hash["lesson_title"]
        @@all << self
    end 

    def self.all 
        API.get_posts if @@all.empty?
        @@all
    end 

    def self.find_related_to(query)
        all.find_all{|bp| bp.title.downcase.include?(query)}
    end
end 


class CLI

    def list(query)
        matching = BlogPost.find_related_to(query)
        matching.each.with_index(1) do |bp, i|
            puts "#{i}. #{bp.title}"
        end 
        puts "\nChoose one!\n"
        show_one(matching)
    end

    def app_loop 
        puts "\nWhaddya wanna see?\n"
        user_input = gets.strip
        if user_input != 'exit'
            list(user_input)
            puts "\nHit enter to continue"
            gets 
            app_loop
        end 
        puts "Ciao"
    end 

    def show_one(matches)
        input = gets.strip.to_i - 1
        post = matches[input]
        puts "\n#{post.title}"
        puts post.author
        puts post.excerpt 
        puts "\nType 'open' to see full post in browser\n"
        input = gets.strip 
        Launchy.open(post.url) if input == "open"
    end 

    def run
        puts "Hello!"
        app_loop
    end 
end 

CLI.new.run
