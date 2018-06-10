$(function() {
  $("[id^=amt_form]").keyup(function(){
    var num = $(this).val();
    if (num === '') {
      total_amt();
      return;
    }
    num = add_comma(num);
    $(this).val(num);
    total_amt();
  });
});

function valuechk(f_val) {
  var permit_pattern = new RegExp(/^[0-9,]+$/, 'g');
  var zeroonly_pattern = new RegExp(/^[0,]/, 'g');

  if ( f_val === '0' || zeroonly_pattern.test(f_val)) {
    return '';
  }
  if ( !permit_pattern.test(f_val) ) {
    return f_val.replace(/[^0-9,]/g, '');
  }
  return f_val;
}


function add_comma(input_val) {
  num = valuechk(input_val);
  return num.replace(/,/g, '').replace(/(\d)(?=(\d\d\d)+$)/g, '$1,');
}


function total_amt() {
  var kari_t = 0;
  var kasi_t = 0;

  $("[id^=amt_form_kari]").each(function() {
    if ($(this).val() != '') {
      kari_t += parseInt($(this).val().replace(/,/g, ''));
    }
  });
  $("[id^=amt_form_kasi]").each(function() {
    if ($(this).val() != '') {
      kasi_t += parseInt($(this).val().replace(/,/g, ''));
    }
  });

  if (kari_t === 0) {
    document.getElementById('kari_amt_total').innerHTML = 0;
  } else {
    document.getElementById('kari_amt_total').innerHTML = add_comma(kari_t + '');
  }

  if (kasi_t === 0) {
    document.getElementById('kasi_amt_total').innerHTML = 0;
  } else  {
    document.getElementById('kasi_amt_total').innerHTML = add_comma(kasi_t + '');
  }
}
