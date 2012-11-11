# encoding: UTF-8

class YTAnalytics
  module Parser #:nodoc:
    class FeedParser #:nodoc:
      def initialize(content)
        @content = (content =~ URI::regexp(%w(http https)) ? open(content).read : content)

      rescue OpenURI::HTTPError => e
        raise OpenURI::HTTPError.new(e.io.status[0],e)
      rescue
        @content = content

      end

      def parse
        parse_content @content
      end

      def parse_single_entry
        doc = Nokogiri::XML(@content)
        parse_entry(doc.at("entry") || doc)
      end

      def parse_videos
        doc = Nokogiri::XML(@content)
        videos = []
        doc.css("entry").each do |video|
          videos << parse_entry(video)
        end
        videos
      end

      def remove_bom str
        str.gsub /\xEF\xBB\xBF|ï»¿/, ''
      end
    end


    class TemporalParser < FeedParser

    private
      def parse_content(content)
        temporal_metrics = []
        if content.is_a? Hash and content["rows"].is_a? Array and content["rows"].length > 0

          headers = content["columnHeaders"]

          content["rows"].each do |row|
            metrics = {}

            headers.each_with_index do |column,i|
              if column["columnType"] == "DIMENSION"
                metrics[:endDate] = Date.strptime row[i], "%Y-%m-%d"
              elsif column["columnType"] == "METRIC"
                metrics[eval(":" + column["name"])] = row[i]
              end
            end
            temporal_metrics.push(YTAnalytics::Model::TemporalMetrics.new(metrics))
          end

          temporal_metrics.sort { |a,b| a.end_date <=> b.end_date }
        end
        temporal_metrics
      end
    end

    class AnalyticsParser < FeedParser #:nodoc:

    private
      def parse_content(content)
        entry = JSON.parse(content)
      end
    end
  end
end

