require 'sinatra'
require 'pry'
require 'sinatra/reloader'
require 'pg'

def db_connection
	begin
		connection = PG.connect(dbname: "recipes_")

		yield(connection)

	ensure
		connection.close
	end
end

def get_recipes
	query = "SELECT * FROM recipes ORDER BY name"
	
	db_connection do |conn|
		actors = conn.exec(query)
	end
end

def get_recipe_info(recipe_id)
  query = %Q{
    SELECT recipes.name, recipes.instructions, recipes.description, ingredients.name AS ingredients FROM recipes
    JOIN ingredients ON ingredients.recipe_id = recipes.id
    WHERE recipes.id = $1;
  }

  results = db_connection do |conn|
    conn.exec_params(query, [recipe_id])
  end

  results.to_a
end

get '/recipes' do
	@recipes = get_recipes

	erb :index
end

get '/recipes/:id' do
	@recipe_info = get_recipe_info(params[:id])

	erb :show
end
