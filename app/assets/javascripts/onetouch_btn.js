$(function() {
  var de;

  de = function() {
    var d;
    d = '#input_field';

    if ($.find(d).length !== 1) {
      return;
    }

    $("[id^=OBT]").click(function(e){
      e.preventDefault();
      flg = all_clear();
      if (flg === true) {
        switch ($(this).attr('id')) {
          case 'OBT1':
            set_slbox_val('kari_ka1', '食費')
            set_slbox_val('kasi_ka1', '現金')
            set_slbox_val('kasi_ka2', '当座預金');
            set_kogaki('飲食代・食料品購入');
            break;
          case 'OBT2':
            break;
        }
      }
      total_amt();
    });
  }
  $(document).on('turbolinks:load', de);
});

function set_slbox_val(selector, cat_name){
  document.getElementById(selector).selectedIndex = gon.category.indexOf(cat_name) + 1;
}

function set_kogaki(text){
  $('.form_kogaki').val(text);
}

function all_clear() {
  all_data = []
  $('.form_cat').each(function(){
    all_data.push($(this).val())
  });
  $('.form_amt').each(function(){
    all_data.push($(this).val())
  });
  all_data.push($('.form_kogaki').val());

  if (all_data.some(value => value != "")) {
    if ( window.confirm('既に科目や金額、小書きが設定されています。上書きしますか?') ){
      $('.form_cat').each(function(){
        $(this).selectedIndex = 0;
      });
      $('.form_amt').each(function(){
        $(this).val('');
      });
      $('.form_kogaki').val('');
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}
