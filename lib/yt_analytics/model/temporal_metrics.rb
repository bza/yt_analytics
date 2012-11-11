class YTAnalytics
  module Model #:nodoc:
    class TemporalMetrics #:nodoc:

      include YTAnalytics::Logging
      attr_accessor :end_date, :views, :comments, :favorites_added, :favorites_removed, :likes, :dislikes, :shares, :subscribers_gained, :subscribers_lost, :uniques


      def initialize params
        @end_date = params[:endDate]
        @views = params[:views]
        @comments = params[:comments]
        @favorites_added = params[:favoritesAdded]
        @favorites_removed = params[:favoritesRemoved]
        @likes = params[:likes]
        @dislikes = params[:dislikes]
        @shares = params[:shares]
        @subscribers_gained = params[:subscribersGained]
        @subscribers_lost = params[:subscribersLost]
        @uniques = params[:uniques]
      end
      
    end
  end
end