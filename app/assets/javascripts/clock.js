function set2fig(num) {
   // 桁数が1桁だったら先頭に0を加えて2桁に調整する
   var ret;
   if( num < 10 ) { ret = "0" + num; }
   else { ret = num; }
   return ret;
}
function showClock2() {
   var nowTime = new Date();
   var nowYear = set2fig( nowTime.getFullYear() );
   var nowMonth = set2fig( nowTime.getMonth() + 1 );
   var nowday = set2fig( nowTime.getDate() );
   var nowHour = set2fig( nowTime.getHours() );
   var nowMin  = set2fig( nowTime.getMinutes() );
   var msg = "現在日時：" + nowYear + "/" + nowMonth + "/" + nowday + " " + nowHour + ":" + nowMin;
   document.getElementById("clockarea").innerHTML = msg;
}
setInterval('showClock2()',1000);
