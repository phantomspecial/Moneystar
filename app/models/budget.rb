class Budget < ApplicationRecord
  belongs_to :category, foreign_key: :uuid

  enum budget_typ: { 定額予算日額: 1, 定額予算月額: 2, 曜日区分別日額: 3, 隔月予算月額: 4 }
  enum budget_division: { 借方残高増加予算: 1, 貸方残高増加予算: 2 }

  BUDGET_TYP = %w(定額予算日額 定額予算月額 曜日区分別日額 隔月予算月額).freeze
  BUDGET_DIVISION = %w(借方残高増加予算 貸方残高増加予算).freeze

  # Validates
  validates :uuid, :budget_typ, :budget_division, presence: true
  validates :uuid, inclusion: { in: Category.all.pluck(:uuid) }
  validates :budget_typ, inclusion: { in: BUDGET_TYP }
  validates :budget_division, inclusion: { in: BUDGET_DIVISION }
  validates :monthly_budget, presence: true, if: Proc.new { |v| v.budget_typ == '定額予算月額' }
  validates :daily_budget, presence: true, if: Proc.new { |v| v.budget_typ == '定額予算日額' }
  validates :weekday_budget, :holiday_budget, presence: true, if: Proc.new { |v| v.budget_typ == '曜日区分別日額' }
  validates :even_month_budget, :odd_month_budget, presence: true, if: Proc.new { |v| v.budget_typ == '隔月予算月額' }

  def progress_estimate(uuid, flg)
    budget = Budget.find_by(uuid: uuid)

    # 今月の開始日/終了日
    start_date, end_date = flg == 'month' ? month_total_days : payday_total_days

    # to_cnt系：start_dateから今日まで
    # to_cnt_weekday: start_dateから今日までの平日日数
    # to_cnt_day_off: start_dateから今日までの休日日数
    # to_cnt_st_to_current_days: start_dateから今日までの経過日数
    to_cnt_weekday, to_cnt_day_off, to_cnt_st_to_current_days = day_category_counts(start_date, Time.current)

    # to_eor系：start_dateからend_dateまで
    # to_eor_week_day： start_dateからend_dateまでの平日日数
    # to_eor_day_off： start_dateからend_dateまでの休日日数
    # to_eor_st_to_end_days： start_dateからend_dateまでの日数
    to_eor_weekday, to_eor_day_off, to_eor_st_to_end_days = day_category_counts(start_date, end_date)

    current_value = current_value(uuid, start_date, end_date)

    return { monthly_estimate_amt: 0, progress_estimate_amt: 0, current_value: current_value, estimate_ratio: 0, devide: 0 } if budget.nil?

    case budget.budget_typ
    when '定額予算日額'
      daily_budget = budget.daily_budget
      monthly_estimate_amt = daily_budget * to_eor_st_to_end_days
      progress_estimate_amt = daily_budget * to_cnt_st_to_current_days
      estimate_ratio = percent(current_value, progress_estimate_amt)

      { monthly_estimate_amt: monthly_estimate_amt,
        progress_estimate_amt: progress_estimate_amt,
        current_value: current_value,
        estimate_ratio: estimate_ratio,
        devide: devide(uuid, progress_estimate_amt, current_value)
      }
    when '定額予算月額'
      monthly_budget = budget.monthly_budget
      estimate_ratio = percent(current_value, monthly_budget)

      { monthly_estimate_amt: monthly_budget,
        progress_estimate_amt: monthly_budget,
        current_value: current_value,
        estimate_ratio: estimate_ratio,
        devide: devide(uuid, monthly_budget, current_value)
      }
    when '曜日区分別日額'
      weekday_budget = budget.weekday_budget
      holiday_budget = budget.holiday_budget

      monthly_estimate_amt = to_eor_weekday * weekday_budget + to_eor_day_off * holiday_budget
      progress_estimate_amt = to_cnt_weekday * weekday_budget + to_cnt_day_off * holiday_budget

      estimate_ratio = percent(current_value, progress_estimate_amt)

      { monthly_estimate_amt: monthly_estimate_amt,
        progress_estimate_amt: progress_estimate_amt,
        current_value: current_value,
        estimate_ratio: estimate_ratio,
        devide: devide(uuid, progress_estimate_amt, current_value)
      }
    when '隔月予算月額'
      even_month_budget = budget.even_month_budget
      odd_month_budget = budget.odd_month_budget

      current_month_estimate = Time.current.month.odd? ? odd_month_budget : even_month_budget
      estimate_ratio = percent(current_value, current_month_estimate)

      { monthly_estimate_amt: current_month_estimate,
        progress_estimate_amt: current_month_estimate,
        current_value: current_value,
        estimate_ratio: estimate_ratio,
        devide: devide(uuid, current_month_estimate, current_value)
      }
    end
  end

  def month_total_days
    # 今月の開始日と終了日を求める
    today = Time.current
    [today.beginning_of_month, today.end_of_month]
  end

  def payday_total_days
    # 15日開始日〜14日終了日の日付を求める
    if Time.current.day < 15
      lm = Time.current.ago(1.month)
      st = Time.zone.local(lm.year, lm.month, 15)
      ed = Time.zone.local(Time.current.year, Time.current.month, 14)
    else
      fm = Time.current.since(1.month)
      st = Time.zone.local(Time.current.year, Time.current.month, 15)
      ed = Time.zone.local(fm.year, fm.month, 14)
    end
    [st, ed]
  end

  private

  def percent(ds, dd)
    ((ds / dd.to_f)*100).round(2).to_s + '%'
  end

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

  def current_value(uuid, start_date, end_date)
    if Category.find_by(uuid: uuid).top_category_id == 5
      side = Constants::DEBIT_SIDE
    else
      side = Constants::CREDIT_SIDE
    end
    Ledger.category_range_total(uuid, side, start_date, end_date)
  end

  def devide(uuid, progress_estimate, current_value)
    if Category.default_division(uuid) == 1
      progress_estimate - current_value
    else
      current_value - progress_estimate
    end
  end
end
