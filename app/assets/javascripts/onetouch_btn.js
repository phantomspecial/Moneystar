$(function() {
  $("[id^=OBT]").click(function(e){
    e.preventDefault();
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
  });
});

function set_slbox_val(selector, cat_name){
  document.getElementById(selector).selectedIndex = gon.category.indexOf(cat_name) + 1;
}

function set_kogaki(text){
  $('.form_kogaki').val(text);
}
