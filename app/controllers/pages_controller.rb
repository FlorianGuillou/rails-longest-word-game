require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def new
    @generate_grid = generate_grid(10)
    session[:letter] = @generate_grid
    session[:start_time] = Time.now.to_time.to_i
  end

  def score
    @generate_grid = session[:letter]
    @word = params[:word]
    @english_word = english_word(@word)
    @included = included?(@word.upcase, @generate_grid)
    @start_time = session[:start_time]
    @end_time = Time.now.to_time.to_i
    @time_taken = @end_time - @start_time
    @score = compute_score(@word, @time_taken)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    alphabet = [*("A".."Z")]
    n = 0
    generate_letter = []
    while n < grid_size
      generate_letter << alphabet.sample
      n += 1
    end
    generate_letter
  end

  def english_word(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    data_serialized = URI.parse(url).read
    data_attempt = JSON.parse(data_serialized)
    data_attempt['found']
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end
end
