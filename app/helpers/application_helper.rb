module ApplicationHelper

  def digit_sep(num)
    num.is_a?(Integer) ? num.to_s(:delimited) : num
  end

  def delete_sep(num)
    num.is_a?(String) ? num.delete(',').to_i : num
  end

  def arr_delete_sep(arr)
    arr.map { |i| delete_sep(i) }
  end

  def negative_num?(num)
    num.is_a?(Integer) && num.negative?
  end
end
