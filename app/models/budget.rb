class Budget < ApplicationRecord
  belongs_to :category, foreign_key: :uuid

  enum budget_typ: { 定額予算日額: 1, 定額予算月額: 2, 曜日区分別日額: 3, 隔月予算月額: 4 }

  BUDGET_TYP = %w(定額予算日額 定額予算月額 曜日区分別日額 隔月予算月額).freeze

  # Validates
  validates :uuid, :budget_typ, presence: true
  validates :uuid, inclusion: { in: Category.all.pluck(:uuid) }
  validates :budget_typ, inclusion: { in: BUDGET_TYP }
  validates :monthly_budget, presence: true, if: Proc.new { |v| v.budget_typ == '定額予算月額' }
  validates :daily_budget, presence: true, if: Proc.new { |v| v.budget_typ == '定額予算日額' }
  validates :weekday_budget, :holiday_budget, presence: true, if: Proc.new { |v| v.budget_typ == '曜日区分別日額' }
  validates :even_month_budget, :odd_month_budget, presence: true, if: Proc.new { |v| v.budget_typ == '隔月予算月額' }

  def monthly_progress_estimate(id, act_val)
    budget = Budget.find(id)

    # 今月の開始日/終了日
    start_date, end_date = month_total_days

    # to_cnt系：start_dateから今日まで
    # to_cnt_weekday: start_dateから今日までの平日日数
    # to_cnt_day_off: start_dateから今日までの休日日数
    # to_cnt_st_to_current_days: start_dateから今日までの経過日数
    to_cnt_weekday, to_cnt_day_off, to_cnt_st_to_current_days = day_category_counts(start_date, Time.current)

    # to_eom系：start_dateからend_dateまで
    # to_eom_week_day： start_dateからend_dateまでの平日日数
    # to_eom_day_off： start_dateからend_dateまでの休日日数
    # to_eom_st_to_end_days： start_dateからend_dateまでの日数
    to_eom_weekday, to_eom_day_off, to_eom_st_to_end_days = day_category_counts(start_date, end_date)

    case budget.budget_typ
    when '定額予算日額'
      daily_budget = budget.daily_budget
      monthly_estimate_amt = daily_budget * to_eom_st_to_end_days
      progress_estimate_amt = daily_budget * to_cnt_st_to_current_days
      estimate_ratio = percent(act_val, progress_estimate_amt)
      devide = progress_estimate_amt - act_val

      { monthly_estimate_amt: monthly_estimate_amt,
        progress_estimate_amt: progress_estimate_amt,
        estimate_ratio: estimate_ratio,
        devide: devide
      }
    when '定額予算月額'
      monthly_budget = budget.monthly_budget
      estimate_ratio = percent(act_val, monthly_budget)
      devide = monthly_budget - act_val

      { monthly_estimate_amt: monthly_budget,
        progress_estimate_amt: monthly_budget,
        estimate_ratio: estimate_ratio,
        devide: devide
      }
    when '曜日区分別日額'
      weekday_budget = budget.weekday_budget
      holiday_budget = budget.holiday_budget

      monthly_estimate_amt = to_eom_weekday * weekday_budget + to_eom_day_off * holiday_budget
      progress_estimate_amt = to_cnt_weekday * weekday_budget + to_cnt_day_off * holiday_budget

      estimate_ratio = percent(act_val, progress_estimate_amt)
      devide = progress_estimate_amt - act_val

      { monthly_estimate_amt: monthly_estimate_amt,
        progress_estimate_amt: progress_estimate_amt,
        estimate_ratio: estimate_ratio,
        devide: devide
      }
    when '隔月予算月額'
      even_month_budget = budget.even_month_budget
      odd_month_budget = budget.odd_month_budget

      current_month_estimate = Time.current.month.odd? ? odd_month_budget : even_month_budget
      estimate_ratio = percent(act_val, current_month_estimate)
      devide = current_month_estimate - act_val

      { monthly_estimate_amt: current_month_estimate,
        progress_estimate_amt: current_month_estimate,
        estimate_ratio: estimate_ratio,
        devide: devide
      }
    end
  end

  private

  def percent(ds, dd)
    ((ds / dd.to_f)*100).round(2).to_s + '%'
  end

  def month_total_days
    # 今月の開始日と終了日を求める
    today = Time.current
    [today.beginning_of_month, today.end_of_month]
  end

  # def progress_remain_days
  #   # 経過日数、未経過日数を表示する。
  #   # 今日は未経過とする。
  #   start_date, end_date = month_total_days
  #
  #   progress_days = (Time.current.to_date - start_date.to_date).to_i
  #   remain_days = (end_date.to_date - Time.current.to_date).to_i + 1
  #
  #   "経過日数：#{progress_days}日　　/　　残り日数：#{remain_days}日"
  # end

  def day_category_counts(start_date, end_date)
    # start_dateからend_dateまでの平日(weekday)・休日(day_off)のカウント
    start_date = start_date.to_date
    end_date = end_date.to_date

    st_to_end_days = (end_date - start_date).to_i + 1
    day_off_count = 0
    day_off_array = [0, 6]

    start_date.upto(end_date) do |i|
      day_off_count += 1 if day_off_array.include?(i.wday) || HolidayJp.holiday?(i).present?
    end
    weekday = st_to_end_days - day_off_count

    [weekday, day_off_count, st_to_end_days]
  end
end
