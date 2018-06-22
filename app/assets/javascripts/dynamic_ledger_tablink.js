$(function() {
  var de;

  de = function() {
    var d;
    d = '#ledger_book';

    if ($.find(d).length !== 1) {
      return;
    }

    $(document).ready(function() {

      var hashTabName = document.location.href.slice(-4);
      if (hashTabName >= 1101 && hashTabName <= 9999) {
        $('#1101').removeClass('show active');
        $('.nav1101').removeClass('active');
        $('#' + hashTabName).addClass('show active');
        $('.nav' + hashTabName).addClass('active');
      }
    });
  }
  $(document).on('turbolinks:load', de);
});
