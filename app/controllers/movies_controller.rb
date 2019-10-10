class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all

    @all_ratings = Movie.get_ratings

    if (params[:ratings])
      @ratings_filter = params[:ratings]
      session[:ratings_filter] = @ratings_filter
    end

    if (params[:sort_by])
      session[:sort_by] = params[:sort_by]
    end

    if (params[:ratings].nil? && params[:sort_by].nil? && session[:ratings_filter])
      @sort_by = session[:sort_by]
      @ratings_filter = session[:ratings_filter]
      flash.keep
      redirect_to movies_path({order_by: @sort_by, ratings: @ratings_filter})
    end

    #check for params passed by clicking title, in order to sort specified field
    if (session[:sort_by] == "title")
      @movies = Movie.order(:title)
      @movie_click = "hilite"
    elsif (session[:sort_by] == "release_date")
      @movies = Movie.order(:release_date)
      @date_click = "hilite"
    end

   if (session[:ratings_filter])
    @movies = @movies.select{|movie| session[:ratings_filter].include? movie.rating}
   end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
