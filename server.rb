require "sinatra"
require "pg"
require 'pry'
configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/actors" do
  db_connection do |conn|
    sql_query = %(
      SELECT name, id FROM actors
      ORDER BY name;
    )
  # binding.pry
    @actors = conn.exec(sql_query)
  end
  erb :'actors/index'
end

  # redirect "/actors/:id"

def all_actors
  db_connection do |conn|
    sql_query = %(
    SELECT name FROM actors;
    )
    conn.exec(sql_query)
  end
end

def movies_actor_in(actor_id)
  db_connection do |conn|
    sql_query = %(
      SELECT movies.title FROM movies
      JOIN cast_members ON cast_members.movie_id = movies.id
      JOIN actors ON actors.id = cast_members.actor_id
      WHERE actors.id = ($1);
    )
    # binding.pry
    data = [actor_id]
    conn.exec_params(sql_query, data)
  end
end

def characters
  db_connection do |conn|
    sql_query = %(
      SELECT character FROM cast_members;
    )
    conn.exec(sql_query)
  end
end

get "/actors/:id" do
  @actor_appears = movies_actor_in(params[:id].to_i).to_a
  @actor_names = all_actors.to_a
  @character_names = characters.to_a
  # binding.pry
  @page_id = params[:id]
  erb :'actors/shows'
  # redirect "/actors"
end
#
def get_genre(genre_id)
  db_connection do |conn|
    sql_query = %(
      SELECT name FROM genres
      WHERE genres.id = ($1);
    )
    data = [genre_id]
    # binding.pry
    conn.exec_params(sql_query, data)
  end
end

      # LEFT JOIN movies ON movies.genre_id = genres.id
def get_studio(studio_name)
  db_connection do |conn|
    sql_query = %(
      SELECT movies.title FROM movies
      LEFT JOIN studios ON movies.studio_id = studios.id
      WHERE studios.id = ($1);
    )
    data = [studio_name]
    conn.exec_params(sql_query, data)
  end
end

def get_movie_titles
  db_connection do |conn|
    sql_query = %(
      SELECT title FROM movies;
    )
    conn.exec(sql_query)
  end
end

def get_year
  db_connection do |conn|
    sql_query = %(
      SELECT year FROM movies;
    )
    conn.exec(sql_query)
  end
end

get "/movies" do

  @genres_names = get_genre(params[:genre_id].to_i).to_a
  @studio_names = get_studio(params[:studio_name]).to_a
  @movie_titles = get_movie_titles.to_a
  @movie_years = get_year.to_a
  # binding.pry
  erb :'movies/index'

end

#   @actor_ids = db_connection do |conn|
#
#
#
#
#
#     conn.exec("SELECT id FROM actors") }
#   # @actor_ids.to_a.each do |hash|
#   #   hash.each do |id, num|
#   #     @id_num = num
#       # binding.pry
#     # end
#   # end
#
#
# end
