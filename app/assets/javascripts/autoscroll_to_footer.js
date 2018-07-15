$(function() {
  var de;

  de = function() {
    var d;
    d = '#journal_book';

    if ($.find(d).length !== 1) {
      return;
    }
    document.getElementById('journal_total').scrollIntoView();
  }
  $(document).on('turbolinks:load', de);
});
