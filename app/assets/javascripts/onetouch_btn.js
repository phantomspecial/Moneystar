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
            set_obt1();
            break;
          case 'OBT2':
            set_obt2();
            break;
          case 'OBT3':
            set_obt3();
            break;
          case 'OBT4':
            set_obt4();
            break;
          case 'OBT5':
            set_obt5();
            break;
          case 'OBT6':
            set_obt6();
            break;
          case 'OBT7':
            set_obt7();
            break;
          case 'OBT8':
            set_obt8();
            break;
          case 'OBT9':
            set_obt9();
            break;
          case 'OBT10':
            set_obt10();
            break;
          case 'OBT11':
            set_obt11();
            break;
          case 'OBT12':
            set_obt12();
            break;
          case 'OBT13':
            set_obt13();
            break;
          case 'OBT14':
            set_obt14();
            break;
          case 'OBT15':
            set_obt15();
            break;
          case 'OBT16':
            set_obt16();
            break;
          case 'OBT17':
            set_obt17();
            break;
          case 'OBT18':
            set_obt18();
            break;
          case 'OBT19':
            set_obt19();
            break;
          case 'OBT20':
            set_obt20();
            break;
        }
      }
      total_amt();
    });
  };
  $(document).on('turbolinks:load', de);
});

function set_slbox_val(selector, cat_name){
  document.getElementById(selector).selectedIndex = gon.category.indexOf(cat_name) + 1;
}

function set_txbox_val(selector, text) {
  document.getElementById(selector).value = text;
}

function set_kogaki(text){
  $('.form_kogaki').val(text);
}

function all_clear() {
  all_data = [];
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
        $(this).val(0);
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

function set_obt1(){
  set_slbox_val('kari_ka1', '食費');
  set_slbox_val('kasi_ka1', '現金');
  set_slbox_val('kasi_ka2', 'UFJ預金');
  set_kogaki('飲食代・食料品購入');
}

function set_obt2() {
  set_slbox_val('kari_ka1', '食費');
  set_slbox_val('kasi_ka1', '現金');
  set_kogaki('飲食代・食料品購入');
}

function set_obt3() {
  set_slbox_val('kari_ka1', '食費');
  set_slbox_val('kasi_ka1', 'UFJ預金');
  set_kogaki('飲食代・食料品購入');
}

function set_obt4() {
  set_slbox_val('kari_ka1', '交通費');
  set_slbox_val('kasi_ka1', 'Suica');
  set_kogaki('電車利用代');
}

function set_obt5() {
  set_slbox_val('kari_ka1', '予算減価償却費');
  set_slbox_val('kasi_ka1', '予算減価償却累計額');
  set_kogaki(now.getMonth() + '月分予算減価償却費計上');
}

function set_obt6() {
  set_slbox_val('kari_ka1', '通信費');
  set_slbox_val('kasi_ka1', 'VISAカード');
  set_txbox_val('amt_form_kari1', '4949');
  set_txbox_val('amt_form_kasi1', '4949');
  set_kogaki('DMM Mobile月額使用料¥521, インターネット利用料¥4,428計上');
}

function set_obt7() {
  set_slbox_val('kari_ka1', '保険料');
  set_slbox_val('kasi_ka1', 'VISAカード');
  set_txbox_val('amt_form_kari1', '540');
  set_txbox_val('amt_form_kasi1', '540');
  set_kogaki('DMM Mobile月額使用料¥521, インターネット利用料¥4,428計上');
}

function set_obt8() {
  set_slbox_val('kari_ka1', '水道光熱費');
  set_slbox_val('kasi_ka1', '未払水道光熱費');
}

function set_obt9() {
  set_slbox_val('kari_ka1', '未払水道光熱費');
  set_slbox_val('kasi_ka1', '郵便普通預金');
  set_kogaki('光熱費引き落とし');
}

function set_obt10() {
  set_slbox_val('kari_ka1', 'VISAカード');
  set_slbox_val('kasi_ka1', 'UFJ預金');
  set_kogaki('クレジット代金精算');
}

function set_obt11() {
  set_slbox_val('kari_ka1', '医療美容費');
  set_slbox_val('kasi_ka1', '現金');
}

function set_obt12() {
  set_slbox_val('kari_ka1', 'みずほ預金（九段）');
  set_slbox_val('kasi_ka1', '給与収入');
  set_kogaki(now.getMonth() + '月分給与受取');
}

function set_obt13() {
  set_slbox_val('kari_ka1', '支払家賃');
  set_slbox_val('kasi_ka1', 'UFJ預金');
  set_txbox_val('amt_form_kari1', '70000');
  set_txbox_val('amt_form_kasi1', '70000');
  set_kogaki((now.getMonth() + 1) + '月分家賃支払い');
}

function set_obt14() {
  set_slbox_val('kari_ka1', '現金');
  set_slbox_val('kasi_ka1', '仕送金・役務収益');
}

function set_obt15() {
  set_slbox_val('kari_ka1', '仕入');
  set_slbox_val('kasi_ka1', '仕送金・役務収益');
  set_txbox_val('amt_form_kari1', '1');
  set_txbox_val('amt_form_kasi1', '1');
}

function set_obt16() {
  set_slbox_val('kari_ka1', '売掛金');
  set_slbox_val('kari_ka2', '支払手数料');
  set_slbox_val('kasi_ka1', '商品売上');
}

function set_obt17() {
  set_slbox_val('kari_ka1', '発送費');
  set_slbox_val('kasi_ka1', '現金');
}

function set_obt18() {
  set_slbox_val('kari_ka1', 'UFJ預金');
  set_slbox_val('kasi_ka1', '売掛金');
  set_kogaki('売掛金回収');
}

function set_obt19() {
  set_slbox_val('kari_ka1', '娯楽費');
  set_slbox_val('kasi_ka1', '現金');
}

function set_obt20() {
  set_slbox_val('kari_ka1', 'UFJ預金');
  set_slbox_val('kasi_ka1', '受取利息');
  set_kogaki('デビット現金還元分受取');
}