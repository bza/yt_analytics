class YTAnalytics
  module Model #:nodoc:
    class TemporalMetrics #:nodoc:

      include YTAnalytics::Logging
      attr_accessor :end_date, :views, :comments, :favorites_added, :favorites_removed, :likes, :dislikes, :shares, :subscribers_gained, :subscribers_lost, :uniques

      def initialize params
        @end_date = params[:endDate] if params[:endDate]
        @views = params[:views] if params[:views]
        @comments = params[:comments] if params[:comments]
        @favorites_added = params[:favoritesAdded] if params[:favoritesAdded]
        @favorites_removed = params[:favoritesRemoved] if params[:favoritesRemoved]
        @likes = params[:likes] if params[:likes]
        @dislikes = params[:dislikes] if params[:dislikes]
        @shares = params[:shares] if params[:shares]
        @subscribers_gained = params[:subscribersGained] if params[:subscribersGained]
        @subscribers_lost = params[:subscribersLost] if params[:subscribersLost]
        @uniques = params[:uniques] if params[:uniques]
      end
      
    end
  end
end