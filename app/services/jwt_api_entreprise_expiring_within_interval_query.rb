class JwtApiEntrepriseExpiringWithinIntervalQuery
  def initialize(interval_start:, interval_stop:)
    @interval_start = interval_start
    @interval_stop  = interval_stop
  end

  def perform
    JwtApiEntreprise.where(exp: interval_range)
  end

  def interval_range
    (@interval_start.beginning_of_day.to_i..@interval_stop.end_of_day.to_i)
  end
end
