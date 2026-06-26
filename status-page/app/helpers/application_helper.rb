module ApplicationHelper
  def status_bg(status)
    case status
    when "operational" then "#d4edda"
    when "degraded" then "#fff3cd"
    when "outage" then "#f8d7da"
    when "maintenance" then "#cce5ff"
    else "#e2e3e5"
    end
  end

  def status_fg(status)
    case status
    when "operational" then "#155724"
    when "degraded" then "#856404"
    when "outage" then "#721c24"
    when "maintenance" then "#004085"
    else "#383d41"
    end
  end
end
