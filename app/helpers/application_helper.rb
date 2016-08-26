module ApplicationHelper

  def chart_address(result, chart_type)
    base_url = Vaalit::Results::PUBLIC_RESULT_URL
    name = chart_type == :candidates ? "candidates" : "result"

    "#{base_url}/#{chart_type}.html?json=#{result.filename('.json', name)}"
  end

end
