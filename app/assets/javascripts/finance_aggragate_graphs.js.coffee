window.draw_graph = ->
# 各月CFグラフ
  ctx = document.getElementById("CF_GRAPH").getContext('2d')
  CF_GRAPH = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: gon.graph_label,
      datasets: [{
        label: 'FCF',
        data: gon.cf_graph_free_cf,
        backgroundColor: 'green'
      }, {
        label: '累積FCF',
        data: gon.cf_graph_accum_cf,
        backgroundColor: 'blue'
      }, {
        label: '営業CF',
        data: gon.cf_graph_o_cf,
        borderColor: 'purple',
        fill: false,
        tension: 0,
        type: 'line'
      }, {
        label: '投資CF',
        data: gon.cf_graph_i_cf,
        borderColor: 'skyblue',
        fill: false,
        tension: 0,
        type: 'line'
      }, {
        label: '財務CF',
        data: gon.cf_graph_f_cf,
        borderColor: 'red',
        fill: false,
        tension: 0,
        type: 'line'
      }]
    },
    options: {
      title: {
        display: true,
        text: '各月CFグラフ',
        fontSize: 18
      },
      legend: {
        position: 'bottom'
      },
    }
  })

# 各月残高グラフ
  ctx = document.getElementById("BALANCE_GRAPH").getContext('2d')
  BALANCE_GRAPH = new Chart(ctx, {
    type: 'line',
    data: {
      labels: gon.graph_label,
      datasets: [{
        label: '現金月末残高(VISA)',
        data: gon.bl_graph_visa_m_balance,
        borderColor: 'blue',
        fill: false,
        tension: 0,
      }, {
        label: '入金前現金残高(VISA)',
        data: gon.bl_graph_bfp_visa_m_balance,
        borderColor: 'red',
        fill: false,
        tension: 0,
      }, {
        label: '現金月末残高',
        data: gon.bl_graph_m_balance,
        borderColor: 'green',
        fill: false,
        tension: 0,
      }]
    },
    options: {
      title: {
        display: true,
        text: '各月残高グラフ',
        fontSize: 18
      },
      legend: {
        position: 'bottom'
      },
      scales: {
        yAxes: [{
          ticks: {
            max: 600000,
            min: 180000,
          }
        }]
      }
    }
  })

# 総合計資金グラフ
  ctx = document.getElementById("SUPER_TOTAL_GRAPH").getContext('2d')
  SUPER_TOTAL_GRAPH = new Chart(ctx, {
    type: 'line',
    data: {
      labels: gon.graph_label,
      datasets: [{
        label: '総合計資金',
        data: gon.super_total_cash,
        borderColor: 'blue',
        fill: false,
        tension: 0,
      }, {
        label: '総合計資金(VISA)',
        data: gon.super_total_visa_cash,
        borderColor: 'red',
        fill: false,
        tension: 0,
      }]
    },
    options: {
      title: {
        display: true,
        text: '総合計資金',
        fontSize: 18
      },
      legend: {
        position: 'bottom'
      },
      scales: {
        yAxes: [{
          ticks: {
            max: 900000,
            min: 0,
          }
        }]
      }
    }
  })

# 増加達成率
  ctx = document.getElementById("ACHIEVEMENT_RATE").getContext('2d')
  ACHIEVEMENT_RATE = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: gon.graph_label,
      datasets: [{
        label: '増加達成率',
        data: gon.achievement_rate,
        backgroundColor: 'blue'
        borderColor: 'blue',
        fill: false,
        tension: 0,
      }, {
        label: '基準線',
        data: gon.standard_line,
        borderColor: 'orange',
        fill: false,
        tension: 0,
        type: 'line'
      }]
    },
    options: {
      title: {
        display: true,
        text: '増加達成率',
        fontSize: 18
      },
      legend: {
        position: 'bottom'
      },
      scales: {
        yAxes: [{
          ticks: {
            max: 150,
            min: 50,
          }
        }]
      }
    }
  })

# 単純利益/累積利益
  ctx = document.getElementById("PROFIT_GRAPH").getContext('2d')
  PROFIT_GRAPH = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: gon.graph_label,
      datasets: [{
        label: '累積利益',
        data: gon.accum_profit,
        backgroundColor: 'red',
        fill: false,
        tension: 0,
        type: 'bar'
      }, {
        label: '単純利益',
        data: gon.m_profit,
        borderColor: 'blue',
        fill: false,
        tension: 0,
        type: 'line'
      }]
    },
    options: {
      title: {
        display: true,
        text: '単純利益/累積利益',
        fontSize: 18
      },
      legend: {
        position: 'bottom'
      },
    }
  })