$(function(){

  var dispatchEvents;

  dispatchEvents = function () {
    var d;
    d = '#budget_new';

    if ($(d).length !== 1) {
      return;
    }

    $("#budget_typ").change(function(){
      var et = $(this).val();
      if (et === '') {
        return;
      }

      $('#daily_budget').prop('disabled', true);
      $('#monthly_budget').prop('disabled', true);
      $('#weekday_budget').prop('disabled', true);
      $('#holiday_budget').prop('disabled', true);
      $('#even_month_budget').prop('disabled', true);
      $('#odd_month_budget').prop('disabled', true);

      switch (et) {
        case '定額予算日額':
          $('#daily_budget').prop('disabled', false);
          break;
        case '定額予算月額':
          $('#monthly_budget').prop('disabled', false);
          break;
        case '曜日区分別日額':
          $('#weekday_budget').prop('disabled', false);
          $('#holiday_budget').prop('disabled', false);
          break;
        case '隔月予算月額':
          $('#even_month_budget').prop('disabled', false);
          $('#odd_month_budget').prop('disabled', false);
          break;
      }
    });
  };

  $(document).on('turbolinks:load', dispatchEvents);
});