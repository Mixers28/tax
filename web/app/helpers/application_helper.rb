module ApplicationHelper
  def confidence_class(confidence_score)
    case confidence_score
    when 0.9..1.0
      'high'
    when 0.7..0.9
      'medium'
    else
      'low'
    end
  end
end
