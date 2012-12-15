class YTAnalytics
  module Model #:nodoc:
    class WatchTimeMetrics #:nodoc:

      include YTAnalytics::Logging
      attr_accessor :end_date, :estimatedMinutesWatched, :averageViewDuration, :averageViewPercentage

      def initialize params
        @end_date = params[:endDate] if params[:endDate]
        @estimatedMinutesWatched = params[:estimatedMinutesWatched] if params[:estimatedMinutesWatched]
        @averageViewDuration = params[:averageViewDuration] if params[:averageViewDuration]
        @averageViewPercentage = params[:averageViewPercentage] if params[:averageViewPercentage]
      end
      
    end
  end
end