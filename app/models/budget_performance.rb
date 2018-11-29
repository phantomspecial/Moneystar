class BudgetPerformance
  COMMON_HEADER = %w(区分 科目 月次予算 進捗予算 実行額 進捗率 差異).freeze
  PROFIT_AND_LOSS_HEADER = %w(収益/費用) + COMMON_HEADER
  INCOME_AND_EXPENDITURE_HEADER  =%w(収入/支出) + COMMON_HEADER

  SECTION_HASH = { 本業: 1, 本業外: 0 }.freeze
  DIVISION_HASH = { 収益: 4, 費用: 5 }.freeze

  class << self
    def profit_and_loss
      result = []
      %i(本業 本業外).each do |section|
        %i(収益 費用).each do |division|
          mb_total = pb_total = cv_total = 0
          uuids = Category.where(top_category_id: DIVISION_HASH[division]).where(core_business_flg: SECTION_HASH[section]).pluck(:uuid)
          uuids.each do |uuid|
            budget_data = Budget.new.progress_estimate(uuid, 'month')

            result << { division: division,
                        section: section,
                        category: Category.find_by(uuid: uuid).name,
                        m_budget: budget_data[:monthly_estimate_amt],
                        p_budget: budget_data[:progress_estimate_amt],
                        cv: budget_data[:current_value],
                        ratio: budget_data[:estimate_ratio],
                        devide: budget_data[:devide]
            }

            mb_total += budget_data[:monthly_estimate_amt]
            pb_total += budget_data[:progress_estimate_amt]
            cv_total += budget_data[:current_value]
          end

          if ratio_devide_maker(division) == Constants::DEBIT_SIDE
            ratio = percent(cv_total, pb_total) if pb_total.positive?
            devide = pb_total - cv_total
          else
            ratio = percent(pb_total, cv_total) if cv_total.positive?
            devide = cv_total - pb_total
          end

          result << { division: division,
                      section: section,
                      category: '小計',
                      m_budget: mb_total,
                      p_budget: pb_total,
                      cv: cv_total,
                      ratio: ratio,
                      devide: devide
          }
          result << partition
        end
      end

      total_hash = result.select { |r| r[:category] == '小計' }
      %i(本業 本業外).each do |section|
        profit = total_hash.select { |r| r[:section] == section && r[:division] == :収益 }.first
        loss = total_hash.select { |r| r[:section] == section && r[:division] == :費用 }.first

        p_budget_total = profit[:p_budget] - loss[:p_budget]
        cv_total = profit[:cv] - loss[:cv]

        result << { division: '損益',
                    section: section,
                    category: '損益合計',
                    m_budget: profit[:m_budget] - loss[:m_budget],
                    p_budget: p_budget_total,
                    cv: cv_total,
                    ratio: percent(cv_total, p_budget_total),
                    devide: cv_total - p_budget_total
        }
      end

      g_total_hash = result.select { |r| r[:division] == '損益' }
      g_p_b_total = g_total_hash.map { |i| i[:p_budget] }.inject(:+)
      g_cv_total = g_total_hash.map { |i| i[:cv] }.inject(:+)

      result << { division: '損益',
                  section: '合計',
                  category: '損益合計',
                  m_budget: g_total_hash.map { |i| i[:m_budget] }.inject(:+),
                  p_budget: g_p_b_total,
                  cv: g_cv_total,
                  ratio: percent(g_cv_total, g_p_b_total),
                  devide: g_cv_total - g_p_b_total
      }

      result
    end

    def income_and_expenditure
      result = []
      # %i(本業 本業外).each do |section|
      #   non_cash_credit_uuids = Category.non_cash.where(top_category_id: [2, 3, 4]).where(core_business_flg: SECTION_HASH[section]).order(:uuid).pluck(:uuid)
      #   non_cash_debit_uuids = Category.non_cash.where(top_category_id: [1, 5]).where(core_business_flg: SECTION_HASH[section]).order(:uuid).pluck(:uuid)
      #
      #   mb_total = pb_total = cv_total = 0
      #   non_cash_credit_uuids.each do |uuid|
      #     budget_data = Budget.new.progress_estimate(uuid, 'month')
      #
      #     result << { division: :収入,
      #                 section: section,
      #                 category: Category.find_by(uuid: uuid).name,
      #                 m_budget: budget_data[:monthly_estimate_amt],
      #                 p_budget: budget_data[:progress_estimate_amt],
      #                 cv: budget_data[:current_value],
      #                 ratio: budget_data[:estimate_ratio],
      #                 devide: budget_data[:devide]
      #     }
      #
      #     mb_total += budget_data[:monthly_estimate_amt]
      #     pb_total += budget_data[:progress_estimate_amt]
      #     cv_total += budget_data[:current_value]
      #   end
      #
      #     if ratio_devide_maker(:収入) == Constants::DEBIT_SIDE
      #       ratio = percent(cv_total, pb_total) if pb_total.positive?
      #       devide = pb_total - cv_total
      #     else
      #       ratio = percent(pb_total, cv_total) if cv_total.positive?
      #       devide = cv_total - pb_total
      #     end
      #
      #     result << { division: :収入,
      #                 section: section,
      #                 category: '小計',
      #                 m_budget: mb_total,
      #                 p_budget: pb_total,
      #                 cv: cv_total,
      #                 ratio: ratio,
      #                 devide: devide
      #     }
      #     result << partition
      #
      #
      #   mb_total = pb_total = cv_total = 0
      #   non_cash_debit_uuids.each do |uuid|
      #     budget_data = Budget.new.progress_estimate(uuid, 'month')
      #
      #     result << { division: :支出,
      #                 section: section,
      #                 category: Category.find_by(uuid: uuid).name,
      #                 m_budget: budget_data[:monthly_estimate_amt],
      #                 p_budget: budget_data[:progress_estimate_amt],
      #                 cv: budget_data[:current_value],
      #                 ratio: budget_data[:estimate_ratio],
      #                 devide: budget_data[:devide]
      #     }
      #
      #     mb_total += budget_data[:monthly_estimate_amt]
      #     pb_total += budget_data[:progress_estimate_amt]
      #     cv_total += budget_data[:current_value]
      #   end
      #
      #   ratio = percent(cv_total, pb_total) if pb_total.present?
      #   devide =  pb_total - cv_total
      #
      #   result << { division: :支出,
      #               section: section,
      #               category: '小計',
      #               m_budget: mb_total,
      #               p_budget: pb_total,
      #               cv: cv_total,
      #               ratio: ratio,
      #               devide: devide
      #   }
      #   result << partition
      # end
      # result
    end

    private

    def partition
      { division: 'ーーー', section: 'ーーー', category: 'ーーー',
        m_budget: 'ーーー', p_budget: 'ーーー', cv: 'ーーー', ratio: 'ーーー', devide: 'ーーー' }
    end

    def ratio_devide_maker(division)
      (division == :費用 || division == :支出) ? Constants::DEBIT_SIDE : Constants::CREDIT_SIDE
    end

    def percent(ds, dd)
      ((ds / dd.to_f)*100).round(2).to_s + '%'
    end
  end
end