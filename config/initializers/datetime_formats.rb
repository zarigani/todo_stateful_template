# 日時表示の書式を設定できる
# http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/DateTime/Calculations/ClassMethods.html
# >> user.created_at.to_s(:month_and_year)
# => August 2008
# >> user.updated_at.to_s(:short_ordinal)
# => August 7th
Time::DATE_FORMATS[:month_and_year] = "%B %Y"
Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }

Time::DATE_FORMATS[:time_only] = "%H:%M:%S"
Time::DATE_FORMATS[:simple] = "%Y-%m-%d<br />%H:%M:%S"
Time::DATE_FORMATS[:ja] = "%Y年%m月%d日 %H:%M:%S"
