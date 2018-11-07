module ApplicationHelper
  def chart_address(result, chart_type)
    base_url = Vaalit::Results::PUBLIC_RESULT_URL
    name = chart_type == :candidates ? "candidates" : "result"

    "#{base_url}/#{chart_type}.html?json=#{result.filename('.json', name)}"
  end

  def friendly_datetime(date)
    return nil if date.nil?

    date.localtime.strftime('%d.%m.%Y %H:%M')
  end
end
