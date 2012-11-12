class YTAnalytics
  module Model #:nodoc:
    class DemographicMetrics #:nodoc:

      include YouTubeIt::Logging

      attr_accessor :end_date, :age13_17female, :age55_64female, :age65_female, :age25_34male, :age25_34female, :age55_64male, 
        :age45_54female, :age35_44female, :age18_24female, :age65_male, :age35_44male, :age45_54male, :age18_24male, :age13_17male

      def initialize params
        @age13_17female = params[:age13_17female]
        @age55_64female = params[:age55_64female]
        @age65_female = params[:age65_female]
        @age25_34male = params[:age25_34male]
        @age25_34female = params[:age25_34female]
        @age55_64male = params[:age55_64male]
        @age45_54female = params[:age45_54female]
        @age35_44female = params[:age35_44female]
        @age18_24female = params[:age18_24female]
        @age65_male = params[:age65_male]
        @age35_44male = params[:age35_44male]
        @age45_54male = params[:age45_54male]
        @age18_24male = params[:age18_24male]
        @age13_17male = params[:age13_17male]
      end

      def self.female
        return age13_17female + age18_24female + age25_34female + age35_44female + age45_54female + age55_64female + age65_female
      end

      def self.male
        return age13_17male + age18_24male + age25_34male + age35_44male + age45_54male + age55_64male + age65_male
      end

      def self.age13_17
        age13_17male + age13_17female
      end

      def self.age18_24
        age18_24male + age18_24female
      end

      def self.age25_34
        age25_34male + age25_34female
      end

      def self.age35_44
        age35_44male + age35_44female
      end

      def self.age45_54
        age45_54male + age45_54female
      end

      def self.age55_64
        age55_64male + age55_64female
      end

      def self.age65
        age65_male + age65_female
      end
    end
  end
end